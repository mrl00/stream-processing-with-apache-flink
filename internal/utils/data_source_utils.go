package utils

import (
	"encoding/csv"
	"fmt"
	"log/slog"
	"os"

	"github.com/mariomac/gostream/stream"
)

func LoadDataFile[T any](fpath string, mapper func([]string) (*T, error)) (stream.Stream[*T], error) {
	slog.Debug("file path", "fpath", fpath)
	file, err := os.Open(fpath)
	if err != nil {
		return nil, fmt.Errorf("cannot open file: %v", err)
	}
	defer file.Close()

	records, err := csv.NewReader(file).ReadAll()
	if err != nil {
		return nil, fmt.Errorf("failed to read all data from %s file: %v", fpath, err)
	}

	data := make([]*T, len(records))
	for i, record := range records {
		if i > 0 {
			data[i], err = mapper(record)
			if err != nil {
				return nil, fmt.Errorf("cannot map data: %v", err)
			}
		}
	}

	return stream.Of(data...), nil
}
