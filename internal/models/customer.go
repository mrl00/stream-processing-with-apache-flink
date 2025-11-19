package models

import (
	"fmt"
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
	BirthDate  time.Time `json:"birthDate" layout:"YYYY-MM-dd"`
	UpdateTime time.Time `json:"updateTime" layout:"YYYY-MM-dd"`
}

func CustomerMapper(line []string) (*Customer, error) {
	dateLayout := "2006-01-02"
	birthDate, err := time.Parse(dateLayout, line[19])
	if err != nil {
		return nil, fmt.Errorf("[CustomerMapper] :: cannot parse birth date: %v", err)
	}

	fullName := line[8] + line[9] + line[10]
	return &Customer{
		CustomerID: line[0],
		Sex:        line[1],
		Social:     line[7],
		FullName:   fullName,
		Phone:      line[11],
		Email:      line[12],
		Address1:   line[13],
		Address2:   line[14],
		City:       line[15],
		State:      line[16],
		Zipcode:    line[17],
		DistrictID: line[18],
		BirthDate:  birthDate,
		UpdateTime: time.Now(),
	}, nil
}
