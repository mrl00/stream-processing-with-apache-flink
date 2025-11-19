package kafka

import (
	"github.com/confluentinc/confluent-kafka-go/v2/kafka"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
)

type TransactionConsumer *kafka.Consumer
type TransactionProducer *kafka.Producer

func NewTransactionsConsumer(cfg *config.AppConfig) (TransactionConsumer, error) {
	return NewConsumer(cfg, "transactions", "transactions")
}

func NewTransactionProducer(cfg *config.AppConfig) (TransactionProducer, error) {
	return NewProducer(cfg)
}
