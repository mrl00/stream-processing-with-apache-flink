# Stream Processing with Apache Flink

Projeto de processamento de streams em tempo real utilizando Apache Flink e Apache Kafka, desenvolvido em Go. O sistema simula um ambiente bancário processando transações financeiras, contas e clientes.

## 📋 Visão Geral

Este projeto implementa uma arquitetura de processamento de streams que:

- **Produz dados** de contas, clientes e transações para tópicos Kafka usando produtores Go
- **Processa streams** em tempo real com Apache Flink
- **Gerencia dados** através de um cluster Kafka distribuído (3 brokers)
- **Suporta ambientes** local e Docker

## 🏗️ Arquitetura

```
┌─────────────────┐     ┌──────────────┐     ┌─────────────┐
│   Producers     │────▶│    Kafka     │────▶│    Flink    │
│   (Go Apps)     │     │   Cluster    │     │  (SQL Jobs) │
└─────────────────┘     └──────────────┘     └─────────────┘
     │                         │
     │                         │
     ▼                         ▼
┌─────────────┐         ┌──────────────┐
│   Datasets  │         │   Topics     │
│    (CSV)    │         │  (Streams)   │
└─────────────┘         └──────────────┘
```

### Componentes Principais

1. **Producers (Go)**: Aplicações que leem dados CSV e publicam em tópicos Kafka
   - `account_producer`: Produz dados de contas
   - `customer_producer`: Produz dados de clientes
   - `transaction_producer`: Produz todas as transações
   - `transaction_credit_producer`: Produz apenas transações de crédito
   - `transaction_debit_producer`: Produz apenas transações de débito

2. **Apache Kafka**: Cluster com 3 brokers para alta disponibilidade
   - Tópicos: `accounts`, `customers`, `transactions`, `transactions.credits`, `transactions.debits`
   - Replicação: 3x
   - Partições: 3

3. **Apache Flink**: Processamento de streams
   - JobManager: Gerencia jobs
   - TaskManagers: 2 instâncias com 2 slots cada

## 📁 Estrutura do Projeto

```
.
├── cmd/                          # Aplicações executáveis
│   ├── account_producer/         # Producer de contas
│   ├── customer_producer/        # Producer de clientes
│   ├── transaction_producer/    # Producer de transações
│   ├── transaction_credit_producer/  # Producer de créditos
│   └── transaction_debit_producer/   # Producer de débitos
│
├── internal/                     # Código interno do projeto
│   ├── config/                   # Configurações (local/docker)
│   ├── handler/                  # Handlers HTTP
│   ├── kafka/                    # Utilitários Kafka
│   ├── models/                   # Modelos de dados
│   ├── router/                   # Roteador HTTP
│   └── utils/                    # Utilitários gerais
│
├── configs/                      # Arquivos de configuração
│   ├── config-local.yaml         # Config para ambiente local
│   ├── config-docker.yaml        # Config para ambiente Docker
│   └── create_transaction_table.flinksql  # SQL do Flink
│
├── docker/                       # Configurações Docker
│   ├── docker-compose.yaml       # Orquestração de serviços
│   ├── Dockerfile                # Imagem base Flink
│   ├── Dockerfile.account        # Imagem do account_producer
│   └── jars/                     # JARs do Flink
│
├── assets/                       # Recursos estáticos
│   ├── datasets/                 # Datasets CSV
│   │   ├── accounts.csv
│   │   ├── customers.csv
│   │   └── transactions.csv
│   └── jars/                     # JARs necessários
│       ├── flink-connector-kafka-4.0.1-2.0.jar
│       ├── flink-connector-jdbc-3.3.0-1.20.jar
│       ├── flink-sql-connector-postgres-cdc-3.5.0.jar
│       └── postgresql-42.7.8.jar
│
├── go.mod                        # Módulo Go
├── Makefile                      # Comandos automatizados
├── create_topics.sh              # Script para criar tópicos Kafka
└── README.md                     # Este arquivo
```

## 🔧 Requisitos

- **Go**: 1.24+
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **Make**: (opcional, mas recomendado)

## 🚀 Instalação e Configuração

### 1. Clone o repositório

```bash
git clone <repository-url>
cd stream-processing-with-apache-flink
```

### 2. Instale as dependências Go

```bash
go mod download
```

### 3. Configure o ambiente

O projeto suporta dois ambientes:

- **Local**: Para desenvolvimento local
- **Docker**: Para execução em containers

As configurações estão em `configs/config-local.yaml` e `configs/config-docker.yaml`.

## 🏃 Como Executar

### Opção 1: Usando Docker Compose (Recomendado)

Inicia todos os serviços (Kafka, Flink, Producers):

```bash
cd docker
docker-compose up -d
```

Ou usando Make:

```bash
make docker-up
```

**Serviços disponíveis:**
- Kafka Brokers: `localhost:29092`, `localhost:39092`, `localhost:49092`
- Flink Web UI: http://localhost:8081
- Account Producer: http://localhost:14000

### Opção 2: Ambiente Local

#### 1. Inicie o cluster Kafka e Flink

```bash
cd docker
docker-compose up -d kafka1 kafka2 kafka3 jobmanager taskmanager1 taskmanager2
```

#### 2. Crie os tópicos Kafka

```bash
./create_topics.sh
```

Ou manualmente:

```bash
docker exec -it kafka1 kafka-topics --create \
  --bootstrap-server "kafka1:19092,kafka2:19092,kafka3:19092" \
  --replication-factor 3 --partitions 1 \
  --config cleanup.policy=compact --topic accounts
```

#### 3. Execute os producers

```bash
# Compilar todos os executáveis
make build

# Executar producers individualmente
./bin/account_producer
./bin/customer_producer
./bin/transaction_producer
```

Ou usando Make:

```bash
make run-account-producer
```

## 📊 Tópicos Kafka

| Tópico | Cleanup Policy | Descrição |
|--------|---------------|-----------|
| `accounts` | `compact` | Dados de contas bancárias |
| `customers` | `compact` | Dados de clientes |
| `transactions` | `delete` | Todas as transações |
| `transactions.credits` | `delete` | Transações de crédito |
| `transactions.debits` | `delete` | Transações de débito |

## 🔌 Configuração

### Variáveis de Ambiente

- `ENVRUN`: Define o ambiente (`local` ou `docker`)

### Arquivos de Configuração

- **config-local.yaml**: Configuração para ambiente local
  - Brokers: `localhost:29092`, `localhost:39092`, `localhost:49092`

- **config-docker.yaml**: Configuração para ambiente Docker
  - Brokers: `kafka1:19092`, `kafka2:19092`, `kafka3:19092`

## 🛠️ Comandos Make

O projeto inclui um Makefile com comandos úteis:

```bash
make help              # Mostra todos os comandos disponíveis
make build             # Compila todos os executáveis
make test              # Executa testes
make test-cover        # Executa testes com cobertura
make fmt               # Formata o código
make vet               # Executa go vet
make lint              # Formata e verifica o código
make tidy              # Organiza dependências
make clean             # Remove arquivos gerados

# Docker
make docker-up         # Inicia serviços Docker
make docker-down       # Para serviços Docker
make docker-logs       # Mostra logs dos serviços
make docker-ps          # Lista containers em execução
make docker-restart    # Reinicia os serviços
make docker-clean      # Remove containers e volumes
```

## 🧪 Desenvolvimento

### Estrutura de Código

- **cmd/**: Aplicações executáveis principais
- **internal/**: Código privado da aplicação
  - `config/`: Gerenciamento de configurações
  - `kafka/`: Cliente e utilitários Kafka
  - `models/`: Modelos de dados e mappers
  - `router/`: Roteamento HTTP
  - `utils/`: Utilitários gerais

### Adicionar um Novo Producer

1. Crie um novo diretório em `cmd/`:
```bash
mkdir -p cmd/my_producer
```

2. Crie `main.go` seguindo o padrão dos outros producers

3. Adicione ao Makefile se necessário

4. Compile: `make build`

### Executar Testes

```bash
# Todos os testes
make test

# Testes com cobertura
make test-cover

# Testes rápidos
make test-short
```

## 🐳 Docker

### Estrutura Docker

- **Dockerfile**: Imagem base do Flink com conectores
- **Dockerfile.account**: Imagem do account_producer
- **docker-compose.yaml**: Orquestração completa

### Build de Imagens

```bash
# Build da imagem Flink
docker build -f docker/Dockerfile -t flink-custom .

# Build do account_producer
docker build -f docker/Dockerfile.account -t account-producer .
```

### Logs

```bash
# Todos os logs
make docker-logs

# Logs de um serviço específico
docker-compose -f docker/docker-compose.yaml logs -f account-producer
```

## 📈 Monitoramento

### Flink Web UI

Acesse http://localhost:8081 para:
- Visualizar jobs em execução
- Monitorar performance
- Verificar logs
- Submeter novos jobs SQL

### Kafka

Use ferramentas como:
- **kafka-console-consumer**: Para consumir mensagens
- **kafka-topics**: Para gerenciar tópicos
- **AKHQ** (opcional): Interface web para Kafka

Exemplo de consumo:

```bash
docker exec -it kafka1 kafka-console-consumer \
  --bootstrap-server kafka1:19092 \
  --topic accounts \
  --from-beginning
```

## 🔍 Modelos de Dados

### Account
```go
type Account struct {
    AccountID    string
    DistrictID   string
    Frequency    string
    CreationDate time.Time
    UpdateTime   time.Time
}
```

### Customer
```go
type Customer struct {
    CustomerID string
    Sex        string
    Social     string
    FullName   string
    Phone      string
    Email      string
    Address1   string
    Address2   string
    City       string
    State      string
    Zipcode    string
    DistrictID string
    BirthDate  time.Time
    UpdateTime time.Time
}
```

### Transaction
```go
type Transaction struct {
    TransactionID string
    AccountID     string
    Type          string
    Operation     string
    Amount        float64
    Balance       float64
    KSymbol       string
    EventTime     time.Time
    CustomerID    string
}
```

## 🚨 Troubleshooting

### Kafka não está acessível

Verifique se os containers estão rodando:
```bash
docker-compose -f docker/docker-compose.yaml ps
```

### Tópicos não existem

Crie os tópicos manualmente:
```bash
./create_topics.sh
```

### Producer não consegue conectar

Verifique:
1. Variável `ENVRUN` está configurada corretamente
2. Arquivo de configuração existe em `configs/`
3. Brokers estão acessíveis

### Flink não processa dados

1. Verifique se os JARs estão em `docker/jars/`
2. Confirme que os tópicos existem
3. Verifique os logs do Flink: `docker-compose logs jobmanager`

## 📝 Licença

MIT

## 🤝 Contribuindo

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📚 Recursos Adicionais

- [Apache Flink Documentation](https://flink.apache.org/docs/)
- [Apache Kafka Documentation](https://kafka.apache.org/documentation/)
- [Go Kafka Client](https://github.com/confluentinc/confluent-kafka-go)

---

**Desenvolvido com ❤️ usando Go, Apache Flink e Apache Kafka**
