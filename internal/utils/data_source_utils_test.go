package utils_test

import (
	"testing"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/models"
	"github.com/mrl00/stream-processing-with-apache-flink/internal/utils"
)

func TestCustomerLoadDataFile(t *testing.T) {
	t.Run("testing load data file", func(t *testing.T) {
		filename := "customers_test.csv"
		stream, err := utils.LoadDataFile(filename, models.CustomerMapper)
		if err != nil {
			t.Errorf("cannot load file %v", err)
		}

		t.Logf("stream size: %d", stream.Count())
		if stream.Count() < 9 && stream.ToSlice()[8].Email != "william.marek.gonzalez@gmail.com" {
			t.Error("customer load data failed")
		}
	})
}

func TestTransactionsLoadDataFile(t *testing.T) {
	t.Run("testing load data file", func(t *testing.T) {
		filename := "transactions_test.csv"
		stream, err := utils.LoadDataFile(filename, models.TransactionMapper)
		if err != nil {
			t.Errorf("cannot load file %v", err)
		}

		t.Logf("stream size: %d", stream.Count())
		if stream.Count() < 9 && stream.ToSlice()[8].CustomerID != "C00002058" {
			t.Error("customer load data failed")
		}
	})
}
