.SLIENT: 
.ONESHELL:
VENV := venv

include .env

all: Start_DB docker-build docker-run

Start_DB:
ifeq ($(OS),Windows_NT)
	cd DB\Schemas
	docker-compose up -d
else
	cd DB\Schemas
	docker-compose up -d
endif

docker-build:
ifeq ($(OS),Windows_NT)
	docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .
else
	docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .
endif

docker-run:
ifeq ($(OS),Windows_NT)
	docker run --rm --name ${CONTAINER_NAME} -d -p ${APP_PORT}:8000 --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=${POSTGRES_DB} \
	-e POSTGRES_USER=${POSTGRES_USER} \
	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
	-e POSTGRES_PORT=${POSTGRES_PORT} \
	-e POSTGRES_HOST=${POSTGRES_HOST} \
	${IMAGE_NAME}:${IMAGE_VERSION}
else
	docker run --rm --name ${CONTAINER_NAME} -d -p $(APP_PORT):8000 --network ${DOCKER_NETWORK} \
	-e POSTGRES_DB=$(POSTGRES_DB) \
	-e POSTGRES_USER=$(POSTGRES_USER) \
	-e POSTGRES_PASSWORD=$(POSTGRES_PASSWORD) \
	-e POSTGRES_PORT=$(POSTGRES_PORT) \
	-e POSTGRES_HOST=$(POSTGRES_HOST) \
	$(IMAGE_NAME):$(IMAGE_VERSION)
endif

install: $(VENV)/Scripts/activate

$(VENV)/Scripts/activate: requirements.txt
	python -m venv $(VENV)

ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\activate.ps1
	$(VENV)\Scripts\python -m pip install --upgrade pip
	$(VENV)\Scripts\pip install -r requirements.txt
else
	chmod +x $(VENV)/bin/activate
	$(VENV)/bin/activate
	$(VENV)/bin/python -m pip install --upgrade pip
	$(VENV)/bin/pip install -r requirements.txt
endif



#Creating Schema from outside of docker container
Schema-creation:
ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\python DB\Schemas\Create_Student.py
else
	$(VENV)/bin/python DB/Schemas/Create_Student.py
endif

# Define the run step
run:
ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\uvicorn Main:app --reload --host 0.0.0.0 --port 8000
else
	$(VENV)/bin/uvicorn Main:app --reload --host 0.0.0.0 --port 8000
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

test:
ifeq ($(OS),Windows_NT)
	$(VENV)\Scripts\python test/test.py
else
	$(VENV)/bin/python test/test.py
endif

.PHONY: all install run clean
