package models

import (
	"fmt"
	"strconv"
	"time"
)

type Transaction struct {
	TransactionID string    `json:"transaction_id"`
	AccountID     string    `json:"account_id"`
	Type          string    `json:"type"`
	Operation     string    `json:"operation"`
	Amount        float64   `json:"amount"`
	Balance       float64   `json:"balance"`
	EventTime     time.Time `json:"event_time"`
	CustomerID    string    `json:"customer_id"`
}

func TransactionMapper(line []string) (*Transaction, error) {
	amount, err := strconv.ParseFloat(line[4], 64)
	if err != nil {
		return nil, fmt.Errorf("[TransactionMapper] :: cannot convert amount value: %v", err)
	}

	balance, err := strconv.ParseFloat(line[5], 64)
	if err != nil {
		return nil, fmt.Errorf("[TransactionMapper] :: cannot convert amount value: %v", err)
	}

	eventTime, err := time.Parse("2006-01-02T15:04:05", line[7])
	if err != nil {
		return nil, fmt.Errorf("[TransactionMapper] :: cannot parse event time: %v", err)
	}

	return &Transaction{
		TransactionID: line[0],
		AccountID:     line[1],
		Type:          line[2],
		Operation:     line[3],
		Amount:        amount,
		Balance:       balance,
		EventTime:     eventTime,
		CustomerID:    line[8],
	}, nil
}
