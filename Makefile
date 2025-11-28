.PHONY: help build build-all run test fmt vet tidy clean install \
	docker-build docker-up docker-down docker-logs docker-ps docker-restart docker-clean \
	run-account run-customer run-transaction run-transaction-credit run-transaction-debit \
	kafka-topics kafka-logs kafka-consume \
	dev all lint test-cover test-short

# =============================================================================
# Variáveis
# =============================================================================
BINARY_DIR := bin
CMD_DIR := cmd
MODULE := github.com/mrl00/stream-processing-with-apache-flink
DOCKER_DIR := docker
DOCKER_COMPOSE := $(DOCKER_DIR)/docker-compose.yaml
KAFKA_CONTAINER := kafka1
KAFKA_BOOTSTRAP := kafka1:19092,kafka2:19092,kafka3:19092

# Cores para output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RED := \033[0;31m
BLUE := \033[0;34m
RESET := \033[0m

# =============================================================================
# Help
# =============================================================================
help: ## Mostra esta mensagem de ajuda
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║  Stream Processing with Apache Flink - Comandos Make         ║$(RESET)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BLUE)Comandos disponíveis:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-30s$(RESET) %s\n", $$1, $$2}'
	@echo ""

.DEFAULT_GOAL := help

# =============================================================================
# Comandos Go - Build
# =============================================================================
build: tidy ## Compila todos os executáveis em cmd/
	@echo "$(CYAN)🔨 Building executables...$(RESET)"
	@mkdir -p $(BINARY_DIR)
	@for dir in $(CMD_DIR)/*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/main.go" ]; then \
			name=$$(basename $$dir); \
			echo "$(YELLOW)  → Building $$name...$(RESET)"; \
			go build -o $(BINARY_DIR)/$$name $$dir || exit 1; \
		fi; \
	done
	@echo "$(GREEN)✅ Build concluído!$(RESET)"

build-all: clean build ## Limpa e compila todos os executáveis

build-%: tidy ## Compila um executável específico (ex: build-account_producer)
	@echo "$(CYAN)🔨 Building $*...$(RESET)"
	@mkdir -p $(BINARY_DIR)
	@if [ -f "$(CMD_DIR)/$*/main.go" ]; then \
		go build -o $(BINARY_DIR)/$* $(CMD_DIR)/$*; \
		echo "$(GREEN)✅ $* compilado com sucesso!$(RESET)"; \
	else \
		echo "$(RED)❌ Erro: $(CMD_DIR)/$*/main.go não encontrado$(RESET)"; \
		exit 1; \
	fi

# =============================================================================
# Comandos Go - Run
# =============================================================================
run-account: build-account_producer ## Executa o account_producer
	@echo "$(CYAN)🚀 Executando account_producer...$(RESET)"
	@ENVRUN=local ./$(BINARY_DIR)/account_producer

run-customer: build-customer_producer ## Executa o customer_producer
	@echo "$(CYAN)🚀 Executando customer_producer...$(RESET)"
	@ENVRUN=local ./$(BINARY_DIR)/customer_producer

run-transaction: build-transaction_producer ## Executa o transaction_producer
	@echo "$(CYAN)🚀 Executando transaction_producer...$(RESET)"
	@ENVRUN=local ./$(BINARY_DIR)/transaction_producer

run-transaction-credit: build-transaction_credit_producer ## Executa o transaction_credit_producer
	@echo "$(CYAN)🚀 Executando transaction_credit_producer...$(RESET)"
	@ENVRUN=local ./$(BINARY_DIR)/transaction_credit_producer

run-transaction-debit: build-transaction_debit_producer ## Executa o transaction_debit_producer
	@echo "$(CYAN)🚀 Executando transaction_debit_producer...$(RESET)"
	@ENVRUN=local ./$(BINARY_DIR)/transaction_debit_producer

# =============================================================================
# Comandos Go - Test
# =============================================================================
test: ## Executa todos os testes
	@echo "$(CYAN)🧪 Executando testes...$(RESET)"
	@go test -v -race -coverprofile=coverage.out ./... || exit 1
	@echo "$(GREEN)✅ Testes concluídos!$(RESET)"

test-cover: test ## Executa testes e gera relatório de cobertura HTML
	@echo "$(CYAN)📊 Gerando relatório de cobertura...$(RESET)"
	@go tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)✅ Cobertura salva em coverage.html$(RESET)"
	@echo "$(YELLOW)  Abra coverage.html no navegador para visualizar$(RESET)"

test-short: ## Executa testes em modo rápido (sem race detector)
	@echo "$(CYAN)⚡ Executando testes (modo rápido)...$(RESET)"
	@go test -short ./...

test-verbose: ## Executa testes com output detalhado
	@echo "$(CYAN)🔍 Executando testes (modo verbose)...$(RESET)"
	@go test -v ./...

# =============================================================================
# Comandos Go - Code Quality
# =============================================================================
fmt: ## Formata o código Go
	@echo "$(CYAN)✨ Formatando código...$(RESET)"
	@go fmt ./...
	@echo "$(GREEN)✅ Formatação concluída!$(RESET)"

vet: ## Executa go vet para verificação estática
	@echo "$(CYAN)🔍 Executando go vet...$(RESET)"
	@go vet ./...
	@echo "$(GREEN)✅ go vet concluído!$(RESET)"

lint: fmt vet ## Executa formatação e verificação estática

tidy: ## Organiza e atualiza dependências do Go
	@echo "$(CYAN)📦 Organizando dependências...$(RESET)"
	@go mod tidy
	@go mod verify
	@echo "$(GREEN)✅ Dependências organizadas!$(RESET)"

# =============================================================================
# Comandos Go - Install & Clean
# =============================================================================
install: tidy ## Instala os executáveis no GOPATH/bin
	@echo "$(CYAN)📥 Instalando executáveis...$(RESET)"
	@for dir in $(CMD_DIR)/*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/main.go" ]; then \
			name=$$(basename $$dir); \
			echo "$(YELLOW)  → Instalando $$name...$(RESET)"; \
			go install $$dir; \
		fi; \
	done
	@echo "$(GREEN)✅ Instalação concluída!$(RESET)"

clean: ## Remove binários e arquivos gerados
	@echo "$(CYAN)🧹 Limpando arquivos gerados...$(RESET)"
	@rm -rf $(BINARY_DIR)
	@rm -f coverage.out coverage.html
	@go clean -cache -testcache
	@echo "$(GREEN)✅ Limpeza concluída!$(RESET)"

# =============================================================================
# Comandos Docker - Build
# =============================================================================
docker-build: ## Constrói as imagens Docker
	@echo "$(CYAN)🐳 Construindo imagens Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose build
	@echo "$(GREEN)✅ Build Docker concluído!$(RESET)"

docker-build-no-cache: ## Constrói as imagens Docker sem cache
	@echo "$(CYAN)🐳 Construindo imagens Docker (sem cache)...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose build --no-cache
	@echo "$(GREEN)✅ Build Docker concluído!$(RESET)"

# =============================================================================
# Comandos Docker - Lifecycle
# =============================================================================
docker-up: ## Inicia os serviços Docker
	@echo "$(CYAN)🚀 Iniciando serviços Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose up -d
	@echo "$(GREEN)✅ Serviços iniciados!$(RESET)"
	@echo "$(YELLOW)  Aguarde alguns segundos para os serviços ficarem prontos$(RESET)"
	@echo "$(BLUE)  Flink UI: http://localhost:8081$(RESET)"

docker-down: ## Para os serviços Docker
	@echo "$(CYAN)🛑 Parando serviços Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose down
	@echo "$(GREEN)✅ Serviços parados!$(RESET)"

docker-restart: docker-down docker-up ## Reinicia os serviços Docker

docker-stop: ## Para os serviços sem remover containers
	@echo "$(CYAN)⏸️  Parando serviços Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose stop
	@echo "$(GREEN)✅ Serviços parados!$(RESET)"

docker-start: ## Inicia serviços Docker já criados
	@echo "$(CYAN)▶️  Iniciando serviços Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose start
	@echo "$(GREEN)✅ Serviços iniciados!$(RESET)"

# =============================================================================
# Comandos Docker - Monitoring
# =============================================================================
docker-ps: ## Lista containers em execução
	@echo "$(CYAN)📋 Containers em execução:$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose ps

docker-logs: ## Mostra os logs de todos os serviços (seguindo)
	@cd $(DOCKER_DIR) && docker-compose logs -f

docker-logs-%: ## Mostra logs de um serviço específico (ex: docker-logs-kafka1)
	@cd $(DOCKER_DIR) && docker-compose logs -f $*

docker-stats: ## Mostra estatísticas de uso de recursos dos containers
	@docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"

# =============================================================================
# Comandos Docker - Cleanup
# =============================================================================
docker-clean: docker-down ## Remove containers, volumes e dados temporários
	@echo "$(CYAN)🧹 Limpando dados Docker...$(RESET)"
	@cd $(DOCKER_DIR) && docker-compose down -v
	@rm -rf $(DOCKER_DIR)/kafka*_data $(DOCKER_DIR)/logs
	@echo "$(GREEN)✅ Limpeza Docker concluída!$(RESET)"

docker-prune: docker-clean ## Limpeza completa (containers, volumes, imagens não utilizadas)
	@echo "$(CYAN)🗑️  Removendo imagens não utilizadas...$(RESET)"
	@docker system prune -f
	@echo "$(GREEN)✅ Prune concluído!$(RESET)"

# =============================================================================
# Comandos Kafka
# =============================================================================
kafka-topics: ## Lista todos os tópicos Kafka
	@echo "$(CYAN)📋 Listando tópicos Kafka...$(RESET)"
	@docker exec -it $(KAFKA_CONTAINER) kafka-topics \
		--bootstrap-server $(KAFKA_BOOTSTRAP) \
		--list

kafka-topics-create: ## Cria todos os tópicos Kafka necessários
	@echo "$(CYAN)📝 Criando tópicos Kafka...$(RESET)"
	@./create_topics.sh || echo "$(YELLOW)⚠️  Certifique-se de que o script create_topics.sh existe e está executável$(RESET)"

kafka-topics-delete: ## Deleta todos os tópicos (CUIDADO!)
	@echo "$(RED)⚠️  ATENÇÃO: Isso irá deletar todos os tópicos!$(RESET)"
	@read -p "Tem certeza? [y/N] " -n 1 -r; \
	echo; \
	if [[ $$REPLY =~ ^[Yy]$$ ]]; then \
		docker exec -it $(KAFKA_CONTAINER) kafka-topics \
			--bootstrap-server $(KAFKA_BOOTSTRAP) \
			--delete --topic accounts; \
		docker exec -it $(KAFKA_CONTAINER) kafka-topics \
			--bootstrap-server $(KAFKA_BOOTSTRAP) \
			--delete --topic customers; \
		docker exec -it $(KAFKA_CONTAINER) kafka-topics \
			--bootstrap-server $(KAFKA_BOOTSTRAP) \
			--delete --topic transactions; \
		docker exec -it $(KAFKA_CONTAINER) kafka-topics \
			--bootstrap-server $(KAFKA_BOOTSTRAP) \
			--delete --topic transactions.credits; \
		docker exec -it $(KAFKA_CONTAINER) kafka-topics \
			--bootstrap-server $(KAFKA_BOOTSTRAP) \
			--delete --topic transactions.debits; \
		echo "$(GREEN)✅ Tópicos deletados!$(RESET)"; \
	else \
		echo "$(YELLOW)Operação cancelada$(RESET)"; \
	fi

kafka-consume: ## Consome mensagens do tópico accounts (exemplo)
	@echo "$(CYAN)📥 Consumindo mensagens do tópico accounts...$(RESET)"
	@echo "$(YELLOW)  Pressione Ctrl+C para parar$(RESET)"
	@docker exec -it $(KAFKA_CONTAINER) kafka-console-consumer \
		--bootstrap-server $(KAFKA_BOOTSTRAP) \
		--topic accounts \
		--from-beginning

kafka-consume-%: ## Consome mensagens de um tópico específico (ex: kafka-consume-transactions)
	@echo "$(CYAN)📥 Consumindo mensagens do tópico $*...$(RESET)"
	@echo "$(YELLOW)  Pressione Ctrl+C para parar$(RESET)"
	@docker exec -it $(KAFKA_CONTAINER) kafka-console-consumer \
		--bootstrap-server $(KAFKA_BOOTSTRAP) \
		--topic $* \
		--from-beginning

kafka-describe-%: ## Descreve um tópico específico (ex: kafka-describe-accounts)
	@echo "$(CYAN)📊 Informações do tópico $*:$(RESET)"
	@docker exec -it $(KAFKA_CONTAINER) kafka-topics \
		--bootstrap-server $(KAFKA_BOOTSTRAP) \
		--describe --topic $*

# =============================================================================
# Comandos Combinados
# =============================================================================
dev: docker-up ## Inicia ambiente de desenvolvimento completo
	@echo "$(CYAN)🔧 Ambiente de desenvolvimento iniciado!$(RESET)"
	@echo "$(YELLOW)  Aguardando serviços iniciarem...$(RESET)"
	@sleep 10
	@echo "$(CYAN)  Criando tópicos Kafka...$(RESET)"
	@$(MAKE) kafka-topics-create || true
	@echo "$(CYAN)  Compilando executáveis...$(RESET)"
	@$(MAKE) build
	@echo "$(GREEN)✅ Ambiente pronto!$(RESET)"
	@echo "$(BLUE)  Flink UI: http://localhost:8081$(RESET)"
	@echo "$(BLUE)  Account Producer: http://localhost:14000$(RESET)"

all: clean lint test build ## Executa limpeza, lint, testes e build completo

setup: tidy docker-build docker-up kafka-topics-create ## Setup inicial completo do projeto
	@echo "$(GREEN)✅ Setup completo!$(RESET)"

check: fmt vet test ## Verifica código, formata e executa testes

# =============================================================================
# Comandos de Informação
# =============================================================================
info: ## Mostra informações sobre o projeto
	@echo "$(CYAN)╔════════════════════════════════════════════════════════════════╗$(RESET)"
	@echo "$(CYAN)║  Informações do Projeto                                       ║$(RESET)"
	@echo "$(CYAN)╚════════════════════════════════════════════════════════════════╝$(RESET)"
	@echo ""
	@echo "$(BLUE)Módulo:$(RESET) $(MODULE)"
	@echo "$(BLUE)Go Version:$(RESET) $$(go version)"
	@echo "$(BLUE)Diretório de Binários:$(RESET) $(BINARY_DIR)"
	@echo "$(BLUE)Docker Compose:$(RESET) $(DOCKER_COMPOSE)"
	@echo ""
	@echo "$(BLUE)Producers disponíveis:$(RESET)"
	@for dir in $(CMD_DIR)/*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/main.go" ]; then \
			echo "  • $$(basename $$dir)"; \
		fi; \
	done
	@echo ""

version: ## Mostra versão do Go e módulo
	@go version
	@echo "Module: $(MODULE)"
