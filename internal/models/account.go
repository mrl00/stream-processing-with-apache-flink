package models

import (
	"fmt"
	"strconv"
	"time"
)

type Account struct {
	AccountID    string    `json:"accountId" validate:"required,alphanum" db:"account_id"`
	DistrictID   int       `json:"districtId" validate:"required,min=1" db:"district_id"`
	Frequency    string    `json:"frequency" validate:"required" db:"frequency"`
	CreationDate time.Time `json:"creationDate" validate:"required,date" db:"parseddate"`
	UpdateTime   time.Time `json:"updateTime" validate:"required" db:"date"`
}

func AccountMapper(line []string) (*Account, error) {
	distId, err := strconv.Atoi(line[1])
	if err != nil {
		return nil, fmt.Errorf("[AccountMapper] :: cannot convert district_id value %s: %v", line[1], err)
	}

	creationDate, err := time.Parse("2006-01-02", line[3])
	if err != nil {
		return nil, fmt.Errorf("[AccountMapper] :: cannot parse creation data: %v", err)
	}

	return &Account{
		AccountID:    line[0],
		DistrictID:   distId,
		Frequency:    line[2],
		CreationDate: creationDate,
		UpdateTime:   time.Now(),
	}, nil
}
