package models_test

import (
	"testing"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/models"
)

func TestAccountMapper(t *testing.T) {
	t.Run("testing account mapper", func(t *testing.T) {
		line := []string{"A00000576", "55", "Monthly Issuance", "2013-01-01", "2013", "1", "1", "2013-01-01"}
		acc, _ := models.AccountMapper(line)
		if acc.AccountID != "A00000576" {
			t.Errorf("Error")
		}
		t.Log(acc)
	})
}

func TestTransactionMapper(t *testing.T) {
	t.Run("testing transaction mapper", func(t *testing.T) {
		line := []string{"T00695247", "A00002378", "Credit", "Credit in Cash", "700", "700", "", "2013-01-01T11:02:40", "C00002873"}
		acc, _ := models.TransactionMapper(line)
		if acc.TransactionID != "T00695247" {
			t.Errorf("Error")
		}
		t.Log(acc)
	})
}

func TestCustomerMapper(t *testing.T) {}
