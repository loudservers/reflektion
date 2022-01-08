APP_NAME := reflektion
LOCAL_PORT := 9000

help:
	@cat $(MAKEFILE_LIST) | grep -E '^[a-zA-Z_-]+:.*?## .*$$' | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

build: ## Build the container 
	docker build -t ${APP_NAME} .

run: ## Run the container
	docker run --name ${APP_NAME} --env-file ./env.list -p ${LOCAL_PORT}:8080 -v ~/.aws:/root/.aws:ro ${APP_NAME}:latest

start: stop build run

stop: ## Stop a container
	@docker stop ${APP_NAME}
	@docker rm ${APP_NAME} 
	@echo "stopped"

tail: ## Tail logs
	docker logs ${APP_NAME} -f

invoke: ## Invoke a command
	curl -X POST "http://localhost:${LOCAL_PORT}/2015-03-31/functions/function/invocations" --data @payload.json


.PHONY: run
.DEFAULT_GOAL := help
