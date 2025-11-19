.PHONY: help build up down logs clean test

help: ## Mostra esta mensagem de ajuda
	@echo "Comandos disponíveis:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

build: ## Constrói as imagens Docker
	docker-compose -f deployments/docker-compose.yaml build

up: ## Inicia os serviços
	docker-compose -f deployments/docker-compose.yaml up -d

down: ## Para os serviços
	docker-compose -f deployments/docker-compose.yaml down

logs: ## Mostra os logs dos serviços
	docker-compose -f deployments/docker-compose.yaml logs -f

clean: ## Remove containers, volumes e dados temporários
	docker-compose -f deployments/docker-compose.yaml down -v
	rm -rf kafka*_data logs

test: ## Executa testes Go
	go test ./...

fmt: ## Formata o código Go
	go fmt ./...

tidy: ## Organiza dependências do Go
	go mod tidy

