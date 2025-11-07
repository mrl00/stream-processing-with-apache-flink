package models

type Transaction struct {
	TransactionID      string  `json:"transactionId"`
	AccountID          string  `json:"accountId"`
	CustomerID         string  `json:"customerId"`
	EventTime          int64   `json:"eventTime"`
	EventTimeFormatted string  `json:"eventTimeFormatted"`
	Type               string  `json:"type"`
	Operation          string  `json:"operation"`
	Amount             float64 `json:"amount"`
	Balance            float64 `json:"balance"`
}
