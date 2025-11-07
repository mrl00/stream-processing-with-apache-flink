package config

import (
	"os"

	"gopkg.in/yaml.v3"
)

type Env int

const (
	Local Env = iota
	Docker
)

type rawConfig struct {
	Local  AppConfig `yaml:"local,omitempty"`
	Docker AppConfig `yaml:"docker,omitempty"`
}

type AppConfig struct {
	Brokers []string `yaml:"brokers,omitempty"`
	Topics  []string `yaml:"topics,omitempty"`
}

func NewAppConfig(e Env) (*AppConfig, error) {
	var filePath string
	switch e {
	case Local:
		filePath = "../../configs/config-local.yaml"
	case Docker:
		filePath = "../../configs/config-docker.yaml"
	}

	yamlFile, err := os.ReadFile(filePath)
	if err != nil {
		return nil, err
	}

	c := &rawConfig{}

	err = yaml.Unmarshal(yamlFile, c)
	if err != nil {
		return nil, err
	}

	switch e {
	case Local:
		return &c.Local, nil
	case Docker:
		return &c.Docker, nil
	default:
		return nil, nil
	}
}

func (c AppConfig) GetBrokers() string {
	var brokers = c.Brokers[0]
	if len(c.Brokers) > 1 {
		for _, broker := range c.Brokers[1:] {
			brokers = brokers + "," + broker
		}
	}
	return brokers
}
