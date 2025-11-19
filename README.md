# Stream Processing with Apache Flink

Projeto de processamento de streams utilizando Apache Flink e Kafka.

## Estrutura do Projeto

```
.
├── cmd/                    # Aplicações executáveis principais
├── internal/               # Código privado da aplicação
│   ├── pkg/               # Pacotes internos reutilizáveis
│   └── config/            # Configurações internas
├── configs/               # Arquivos de configuração (SQL, YAML, etc)
├── deployments/           # Arquivos de deployment (Docker, Kubernetes)
│   ├── docker-compose.yaml
│   └── Dockerfile
├── assets/                # Recursos estáticos
│   ├── jars/             # JARs do Flink
│   └── datasets/         # Datasets CSV
├── go.mod                 # Módulo Go
└── README.md             # Este arquivo
```

## Requisitos

- Docker e Docker Compose
- Go 1.21+
- Apache Flink 1.20

## Como Executar

1. Inicie os serviços com Docker Compose:
```bash
make up
# ou
docker-compose -f deployments/docker-compose.yaml up -d
```

Para ver todos os comandos disponíveis:
```bash
make help
```

2. Acesse o Flink Web UI:
- http://localhost:8081

3. Acesse o AKHQ (Gerenciador Kafka):
- http://localhost:9090

## Configuração

Os arquivos de configuração do Flink SQL estão em `configs/`.

Os JARs necessários estão em `assets/jars/`.

## Desenvolvimento

Para adicionar código Go:

- Aplicações principais: `cmd/`
- Código reutilizável: `internal/pkg/`
- Configurações: `internal/config/`

## Licença

MIT

