package config_test

import (
	"testing"

	"github.com/mrl00/stream-processing-with-apache-flink/internal/config"
)

func Test_AppConfig(t *testing.T) {
	t.Run("testing app config", func(t *testing.T) {
		app, _ := config.NewAppConfig(t.Context(), config.Docker)
		if app.Brokers[0] != "kafka1:19093" {
			t.Error("wrong!")
		}
	})
}
