.PHONY: help up down restart logs status clean update build shell

help: ## Show this help message
	@echo "Available commands:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

up: ## Start all services in detached mode
	docker-compose up -d

down: ## Stop and remove all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## View logs from all services (follow mode)
	docker-compose logs -f

logs-obsidian: ## View logs from obsidian service only
	docker-compose logs -f obsidian-web

logs-couchdb: ## View logs from couchdb service only
	docker-compose logs -f couchdb

status: ## Show status of all services
	docker-compose ps

clean: ## Stop services and remove all containers, networks, and volumes
	docker-compose down -v --remove-orphans

update: ## Pull latest images and restart services
	docker-compose pull && docker-compose up -d

build: ## Build services (if using custom Dockerfile)
	docker-compose build

shell-obsidian: ## Open shell in obsidian container
	docker-compose exec obsidian-web /bin/bash

shell-couchdb: ## Open shell in couchdb container
	docker-compose exec couchdb /bin/bash

backup: ## Create backup of volumes
	@echo "Creating backup directory..."
	@mkdir -p backups
	@echo "Backing up CouchDB data..."
	@docker run --rm -v obsidian-self-hosted_couchdb_data:/data -v $(PWD)/backups:/backup alpine tar czf /backup/couchdb_data_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "Backing up Obsidian vaults..."
	@docker run --rm -v obsidian-self-hosted_obsidian_vaults:/data -v $(PWD)/backups:/backup alpine tar czf /backup/obsidian_vaults_$(shell date +%Y%m%d_%H%M%S).tar.gz -C /data .
	@echo "Backup completed in backups/ directory"

setup: ## Initial setup - copy example env and start services
	@if [ ! -f .env ]; then \
		echo "Copying .env.example to .env..."; \
		cp .env.example .env; \
		echo "Please edit .env file with your settings"; \
	else \
		echo ".env file already exists"; \
	fi
	@echo "Starting services..."
	@make up

dev: ## Development mode - start with logs following
	docker-compose up

reset: ## Reset everything - stop, clean, and start fresh
	@echo "Warning: This will remove all data!"
	@read -p "Are you sure? (y/N): " confirm && [ "$$confirm" = "y" ]
	@make clean
	@make up