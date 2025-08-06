.SLIENT: 
.ONESHELL:
VENV := venv

include .env

API_IMAGE_NAME := restapi
API_IMAGE_VERSION := v1.0.0	
API_CONTAINER_NAME := restapi_container
MIGRATION_IMAGE_NAME := migration
MIGRATION_IMAGE_VERSION := v1.0.0
MIGRATION_CONTAINER_NAME := migration_container
DOCKER_NETWORK := dem



all: Start_DB install docker-migration-build  docker-migration-run docker-build docker-run


Start_DB:
ifeq ($(OS),Windows_NT)
	cd DB
	docker-compose up -d
else
	cd DB
	docker-compose up -d
endif

docker-migration-build:
ifeq ($(OS),Windows_NT)
	docker build -t ${MIGRATION_IMAGE_NAME}:${MIGRATION_IMAGE_VERSION} -f DB/Schemas/Dockerfile  .
else
	docker build -t ${MIGRATION_IMAGE_NAME}:${MIGRATION_IMAGE_VERSION} -f DB/Schemas/Dockerfile .
endif

docker-migration-run:
ifeq ($(OS),Windows_NT)
	docker  run --rm --name ${MIGRATION_CONTAINER_NAME} --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=${POSTGRES_DB} \
	-e POSTGRES_USER=${POSTGRES_USER} \
	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
	-e POSTGRES_PORT=${POSTGRES_PORT} \
	-e POSTGRES_HOST=${POSTGRES_HOST} \
	${MIGRATION_IMAGE_NAME}:${MIGRATION_IMAGE_VERSION}

else
	@docker run --rm --name ${MIGRATION_CONTAINER_NAME} --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=$(POSTGRES_DB) \
	-e POSTGRES_USER=$(POSTGRES_USER) \
	-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	-e POSTGRES_PORT=$(POSTGRES_PORT) \
	-e POSTGRES_HOST=$(POSTGRES_HOST) \
	$(MIGRATION_IMAGE_NAME):$(MIGRATION_IMAGE_VERSION)
endif

docker-build:
ifeq ($(OS),Windows_NT)
	docker build -t ${API_IMAGE_NAME}:${API_IMAGE_VERSION} .
else
	docker build -t ${API_IMAGE_NAME}:${API_IMAGE_VERSION} .
endif

docker-run:
ifeq ($(OS),Windows_NT)
	docker run --name ${API_CONTAINER_NAME} -d -p ${APP_PORT}:8000 --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=${POSTGRES_DB} \
	-e POSTGRES_USER=${POSTGRES_USER} \
	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
	-e POSTGRES_PORT=${POSTGRES_PORT} \
	-e POSTGRES_HOST=${POSTGRES_HOST} \
	${API_IMAGE_NAME}:${API_IMAGE_VERSION}
else
	@docker run --rm --name ${API_CONTAINER_NAME} -d -p $(APP_PORT):8000 --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=$(POSTGRES_DB) \
	-e POSTGRES_USER=$(POSTGRES_USER) \
	-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	-e POSTGRES_PORT=$(POSTGRES_PORT) \
	-e POSTGRES_HOST=$(POSTGRES_HOST) \
	$(API_IMAGE_NAME):$(API_IMAGE_VERSION)
endif



# Define a clean step
clean:
ifeq ($(OS),Windows_NT)
	@powershell -Command "Get-ChildItem -Recurse -Directory -Filter '__pycache__' | Remove-Item -Recurse -Force"
	@powershell -Command "Get-ChildItem -Recurse -Directory -Filter 'data' | Remove-Item -Recurse -Force"
else
	find . -type d -name "__pycache__" -exec rm -rf {} +
	find . -type d -name "data" -exec rm -rf {} +
endif

.PHONY: all Start_DB install docker-migration-build clean 
