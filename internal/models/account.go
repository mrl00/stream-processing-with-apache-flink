package models

import (
	"fmt"
	"time"
)

type Account struct {
	AccountID    string    `json:"account_id"`
	DistrictID   string    `json:"district_id"`
	Frequency    string    `json:"frequency"`
	CreationDate time.Time `json:"creation_data"`
	UpdateTime   time.Time `json:"update_time"`
}

func AccountMapper(line []string) (*Account, error) {
	creationDate, err := time.Parse("2006-01-02", line[3])
	if err != nil {
		return nil, fmt.Errorf("[AccountMapper] :: cannot parse creation data: %v", err)
	}

	return &Account{
		AccountID:    line[0],
		DistrictID:   line[1],
		Frequency:    line[2],
		CreationDate: creationDate,
		UpdateTime:   time.Now(),
	}, nil
}
