package kafka

import (
	"context"
	"encoding/json"
	"fmt"
	"log/slog"
	"strconv"
	"time"

	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
)

func NewProducer(cfg *config.AppConfig) (*kafka.Producer, error) {
	p, err := kafka.NewProducer(&kafka.ConfigMap{
		"bootstrap.servers": cfg.GetBrokers(),
		"acks":              "all",
		"retries":           5,
	})
	if err != nil {
		return nil, fmt.Errorf("Failed to create producer: %v", err)
	}
	return p, nil
}

func NewConsumer(cfg *config.AppConfig, groupID string, topic string) (*kafka.Consumer, error) {
	consumer, err := kafka.NewConsumer(&kafka.ConfigMap{
		"bootstrap.servers":  cfg.GetBrokers(),
		"group.id":           groupID,
		"auto.offset.reset":  "earliest",
		"enable.auto.commit": true,
	})
	if err != nil {
		return nil, fmt.Errorf("cannot create consumer: %v", err)
	}
	err = consumer.SubscribeTopics([]string{topic}, nil)
	if err != nil {
		consumer.Close()
		return nil, fmt.Errorf("failed to subscribe topic %s: %v", topic, err)
	}

	return consumer, nil
}

func Produce[E any](ctx context.Context, producer *kafka.Producer, e E) error {
	message, err := json.Marshal(e)
	if err != nil {
		return fmt.Errorf("failed to marshal: %v", err)
	}

	topic := ctx.Value("topic").(string)
	err = producer.Produce(&kafka.Message{
		TopicPartition: kafka.TopicPartition{Topic: &topic, Partition: kafka.PartitionAny},
		Value:          message,
	}, nil)
	if err != nil {
		return fmt.Errorf("failed to produce message: %v", err)
	}

	select {
	case ev := <-producer.Events():
		switch e := ev.(type) {
		case *kafka.Message:
			if e.TopicPartition.Error != nil {
				return fmt.Errorf("delivery failed: %v", e.TopicPartition.Error)
			}
			fmt.Printf("Produce order: %s\n", string(message))

		case kafka.Error:
			return fmt.Errorf("producer error: %v", e)
		}
	case <-ctx.Done():
		return ctx.Err()
	}

	return nil
}

func Consume[M any](ctx context.Context, consumer *kafka.Consumer) error {
	slog.InfoContext(ctx, "Consuming from "+consumer.String())

	for {
		select {
		case <-ctx.Done():
			return ctx.Err()
		default:
			msg, err := consumer.ReadMessage(2 * time.Second)
			if err != nil {
				if err.(kafka.Error).Code() == kafka.ErrTimedOut {
					continue
				}
				return fmt.Errorf("error reading message: %v", err)
			}

			var m M
			if err := json.Unmarshal(msg.Value, &m); err != nil {
				return fmt.Errorf("error unmarshaling message: %v", err)
			}

			slog.InfoContext(ctx, "Consumed", "object", m)
		}
	}
}

func CheckTopic(ctx context.Context, admin *kafka.AdminClient, topic string) (bool, error) {
	metadata, err := admin.GetMetadata(&topic, false, 5000)
	if err == nil && len(metadata.Topics) > 0 && len(metadata.Topics[topic].Partitions) > 0 {
		slog.Log(ctx, slog.LevelDebug, "topic %s already exists", topic, nil)
		return true, nil
	}
	return false, fmt.Errorf("check topic :: %v", err)
}

func CreateTopic(ctx context.Context, admin *kafka.AdminClient, topic kafka.TopicSpecification) error {
	exists, err := CheckTopic(ctx, admin, topic.Topic)
	if err != nil && exists == false {
		slog.ErrorContext(ctx, "create topic error", slog.String("err1", err.Error()))
		return err
	}

	maxDur, err := time.ParseDuration("60s")
	if err != nil {
		panic("ParseDuration(60s)")
	}

	results, err := admin.CreateTopics(ctx, []kafka.TopicSpecification{topic}, kafka.SetAdminOperationTimeout(maxDur))
	if err != nil {
		slog.Log(ctx, slog.LevelError, "failed to create topic %s: %v", topic.Topic, err)
		return err
	}

	for i, result := range results {
		if result.Error.Code() != kafka.ErrNoError && result.Error.Code() != kafka.ErrTopicAlreadyExists {
			slog.WarnContext(ctx, "%s: %s ", strconv.Itoa(i), result.Topic, result.Error.String(), nil)
		}
	}

	slog.Debug("")
	return nil
}

func EnsureTopic(ctx context.Context, topicName string, cfg *config.AppConfig) error {
	admin, err := kafka.NewAdminClient(&kafka.ConfigMap{
		"bootstrap.servers": cfg.GetBrokers(),
	})
	if err != nil {
		return fmt.Errorf("ensure topic :: failed to create kafka admin client: %v", err)
	}

	topicExists, err := CheckTopic(ctx, admin, topicName)
	if err != nil {
		return err
	}

	if !topicExists {
		if err = CreateTopic(ctx, admin, kafka.TopicSpecification{
			Topic:             topicName,
			NumPartitions:     3,
			ReplicationFactor: 3,
		}); err != nil {
			return err
		}
	}

	return nil
}
