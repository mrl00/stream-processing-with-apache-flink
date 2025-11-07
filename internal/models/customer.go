package models

import (
	"time"
)

type Customer struct {
	CustomerID string    `json:"customerId"`
	Sex        string    `json:"sex"`
	Social     string    `json:"social"`
	FullName   string    `json:"fullName"`
	Phone      string    `json:"phone"`
	Email      string    `json:"email"`
	Address1   string    `json:"address1"`
	Address2   string    `json:"address2,omitempty"`
	City       string    `json:"city"`
	State      string    `json:"state"`
	Zipcode    string    `json:"zipcode"`
	DistrictID string    `json:"districtId"`
	BirthDate  string    `json:"birthDate"` // ou time.Time + tag `json:"birthDate,omitempty" layout:"2006-01-02"`
	UpdateTime time.Time `json:"updateTime,omitempty"`
}
