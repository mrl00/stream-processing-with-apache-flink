package kafka

import (
	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
)

type StateConsumer *kafka.Consumer
type StateProducer *kafka.Producer

func NewStateProducer(cfg *config.AppConfig) (StateProducer, error) {
	return NewProducer(cfg)
}

func NewAccountsConsumer(cfg *config.AppConfig) (StateConsumer, error) {
	return NewConsumer(cfg, "accounts", "accounts")
}

func NewCustomersConsumer(cfg *config.AppConfig) (StateConsumer, error) {
	return NewConsumer(cfg, "customers", "customers")
}
