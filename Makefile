.PHONY: help build run test fmt vet tidy clean install docker-up docker-down docker-logs docker-clean docker-build

# Variáveis
BINARY_DIR := bin
CMD_DIR := cmd
MODULE := github.com/mrl00/stream-processing-with-apache-flink
DOCKER_COMPOSE := docker-compose.yaml

# Cores para output
CYAN := \033[0;36m
GREEN := \033[0;32m
YELLOW := \033[0;33m
RESET := \033[0m

help: ## Mostra esta mensagem de ajuda
	@echo "$(CYAN)Comandos disponíveis:$(RESET)"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}'
	@echo ""

# Comandos Go
build: tidy ## Compila todos os executáveis em cmd/
	@echo "$(CYAN)Building executables...$(RESET)"
	@mkdir -p $(BINARY_DIR)
	@for dir in $(CMD_DIR)/*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/main.go" ]; then \
			name=$$(basename $$dir); \
			echo "$(YELLOW)Building $$name...$(RESET)"; \
			go build -o $(BINARY_DIR)/$$name $$dir; \
		fi; \
	done
	@echo "$(GREEN)Build concluído!$(RESET)"

run-account-producer: build ## Executa o account_producer
	@echo "$(CYAN)Executando account_producer...$(RESET)"
	@./$(BINARY_DIR)/account_producer

install: tidy ## Instala os executáveis no GOPATH/bin
	@echo "$(CYAN)Instalando executáveis...$(RESET)"
	@for dir in $(CMD_DIR)/*; do \
		if [ -d "$$dir" ] && [ -f "$$dir/main.go" ]; then \
			name=$$(basename $$dir); \
			echo "$(YELLOW)Instalando $$name...$(RESET)"; \
			go install $$dir; \
		fi; \
	done
	@echo "$(GREEN)Instalação concluída!$(RESET)"

test: ## Executa todos os testes
	@echo "$(CYAN)Executando testes...$(RESET)"
	go test -v -race -coverprofile=coverage.out ./...
	@echo "$(GREEN)Testes concluídos!$(RESET)"

test-cover: test ## Executa testes e mostra cobertura
	@echo "$(CYAN)Gerando relatório de cobertura...$(RESET)"
	go tool cover -html=coverage.out -o coverage.html
	@echo "$(GREEN)Cobertura salva em coverage.html$(RESET)"

test-short: ## Executa testes em modo rápido
	@echo "$(CYAN)Executando testes (modo rápido)...$(RESET)"
	go test -short ./...

fmt: ## Formata o código Go
	@echo "$(CYAN)Formatando código...$(RESET)"
	go fmt ./...
	@echo "$(GREEN)Formatação concluída!$(RESET)"

vet: ## Executa go vet
	@echo "$(CYAN)Executando go vet...$(RESET)"
	go vet ./...
	@echo "$(GREEN)go vet concluído!$(RESET)"

lint: fmt vet ## Executa formatação e verificação estática

tidy: ## Organiza dependências do Go
	@echo "$(CYAN)Organizando dependências...$(RESET)"
	go mod tidy
	@echo "$(GREEN)Dependências organizadas!$(RESET)"

clean: ## Remove binários e arquivos gerados
	@echo "$(CYAN)Limpando arquivos gerados...$(RESET)"
	rm -rf $(BINARY_DIR)
	rm -f coverage.out coverage.html
	go clean -cache
	@echo "$(GREEN)Limpeza concluída!$(RESET)"

# Comandos Docker
docker-build: ## Constrói as imagens Docker
	@echo "$(CYAN)Construindo imagens Docker...$(RESET)"
	docker-compose -f $(DOCKER_COMPOSE) build
	@echo "$(GREEN)Build Docker concluído!$(RESET)"

docker-up: ## Inicia os serviços Docker
	@echo "$(CYAN)Iniciando serviços Docker...$(RESET)"
	docker-compose -f $(DOCKER_COMPOSE) up -d
	@echo "$(GREEN)Serviços iniciados!$(RESET)"

docker-down: ## Para os serviços Docker
	@echo "$(CYAN)Parando serviços Docker...$(RESET)"
	docker-compose -f $(DOCKER_COMPOSE) down
	@echo "$(GREEN)Serviços parados!$(RESET)"

docker-logs: ## Mostra os logs dos serviços Docker
	docker-compose -f $(DOCKER_COMPOSE) logs -f

docker-ps: ## Lista containers em execução
	docker-compose -f $(DOCKER_COMPOSE) ps

docker-restart: docker-down docker-up ## Reinicia os serviços Docker

docker-clean: docker-down ## Remove containers, volumes e dados temporários
	@echo "$(CYAN)Limpando dados Docker...$(RESET)"
	docker-compose -f $(DOCKER_COMPOSE) down -v
	rm -rf kafka*_data logs
	@echo "$(GREEN)Limpeza Docker concluída!$(RESET)"

# Comandos combinados
dev: docker-up ## Inicia ambiente de desenvolvimento (Docker + build)
	@echo "$(CYAN)Ambiente de desenvolvimento iniciado!$(RESET)"
	@echo "$(YELLOW)Aguardando serviços iniciarem...$(RESET)"
	@sleep 5
	@$(MAKE) build

all: clean lint test build ## Executa limpeza, lint, testes e build completo

.DEFAULT_GOAL := help
