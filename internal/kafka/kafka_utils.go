package kafka

type Cleanup int

const (
	Delete Cleanup = iota
	Compact
)

func (c Cleanup) String() string {
	switch c {
	case Delete:
		return "delete"
	case Compact:
		return "compact"
	default:
		return "unknown"
	}
}
