COMPOSE := docker compose -f compose.dev.yml --env-file .env

.DEFAULT_GOAL := help
.PHONY: help env up up-apps down logs ps reset config

help: ## List available targets
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-8s %s\n", $$1, $$2}'

env: ## Create .env from .env.example if it does not exist
	@test -f .env || (cp .env.example .env && echo "created .env from .env.example")

up: env ## Start the infrastructure, wait until it is healthy and create the bucket
	$(COMPOSE) up -d --wait
	$(COMPOSE) run --rm minio-init

up-apps: env ## Build and start the infrastructure plus api, ai-api, ai-worker and web
	$(COMPOSE) --profile apps up -d --build --wait
	$(COMPOSE) run --rm minio-init

down: ## Stop every service, keeping the volumes
	$(COMPOSE) --profile '*' down --remove-orphans

logs: ## Follow the logs of every service
	$(COMPOSE) --profile '*' logs -f --tail=100

ps: ## Show service status and health
	$(COMPOSE) --profile '*' ps

reset: ## Stop every service and delete all volumes (data loss)
	$(COMPOSE) --profile '*' down -v --remove-orphans

config: env ## Validate the compose file
	$(COMPOSE) --profile '*' config --quiet && echo "compose.dev.yml is valid"
