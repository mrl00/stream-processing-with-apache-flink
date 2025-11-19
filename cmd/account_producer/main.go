package main

import (
	"context"
	"log"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/kafka"
)

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	cfg, err := config.NewAppConfig(config.Docker)
	if err != nil {
		log.Fatalf("config error: %v", err)
	}

	producer, err := kafka.NewProducer(cfg)
	if err != nil {
		log.Fatalf("main :: produce create :: %v", err)
	}
	defer producer.Close()

	if err = kafka.EnsureTopic(ctx, "accounts", cfg); err != nil {
		panic(err)
	}

}
