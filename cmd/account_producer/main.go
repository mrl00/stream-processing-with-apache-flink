package main

import (
	"context"
	"log"
	"time"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/kafka"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/models"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/utils"
)

const (
	accountTopic    = "accounts"
	accountDataFile = "accounts.csv"
)

func main() {
	ctx := context.Background()
	ctx, cancel := context.WithCancel(ctx)
	defer cancel()

	cfg, err := config.NewAppConfig(config.Docker)
	if err != nil {
		log.Fatalf("config error: %v", err)
	}

	if err = kafka.EnsureTopic(ctx, accountTopic, cfg); err != nil {
		log.Fatalf("main :: ensure topic err :: %v", err)
	}

	producer, err := kafka.NewProducer(cfg)
	if err != nil {
		log.Fatalf("main :: produce create :: %v", err)
	}
	defer producer.Close()

	accounts, err := utils.LoadDataFile(accountDataFile, models.AccountMapper)
	if err != nil {
		log.Fatalf("main :: load file :: %v", err)
	}

	accountCtx := context.WithValue(ctx, "topic", accountTopic)
	accounts.ForEach(func(a *models.Account) {
		if err := kafka.Produce(accountCtx, producer, a); err != nil {
			log.Fatalf("main :: produce accounts :: %v", err)
		}
		time.Sleep(1 * time.Second)
	})

	select {}
}
