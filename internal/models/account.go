package models

import (
	"time"
)

type Account struct {
	AccountID    string    `json:"accountId" validate:"required,alphanum" db:"account_id"`
	DistrictID   int       `json:"districtId" validate:"required,min=1" db:"district_id"`
	Frequency    string    `json:"frequency" validate:"required,oneof=monthly weekly fortnightly yearly" db:"frequency"`
	CreationDate string    `json:"creationDate" validate:"required,date" db:"creation_date"`
	UpdateTime   time.Time `json:"updateTime" validate:"required" db:"update_time"`
}
