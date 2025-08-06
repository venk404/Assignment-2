
# Student Management API(SRE/Assignment 2)

This project is a simple Student Management API built using FastAPI. It allows for basic CRUD operations on student data. The API supports creating, reading, updating, and deleting student information.



## Features

- Create Student: Add a new student.
- Get All Students: Retrieve a list of all students.
- Get Student by ID: Retrieve a specific student by their ID.
- Update Student: Update a student's information.
- Delete Student: Delete a student by their ID.


## Requirments
- Python 3.13
- PIP
- Docker & Docker Compose(For database)
- Make (Optional)


## Installation
1) Clone the repository:

```bash
  git clone https://github.com/venk404/SRE_Projects.git
  cd Assignments 2
```
2) There are two .env example files that need to be renamed and updated:

- The first file is located in the current directory.
- The second file is located in the DB directory.

3) Update the env files and run the command to set up the DB, schema, build the REST API image, and start it.
 ```bash
  make all
```
## If you dont have make installed then you can manually run it.

3) Navigate to the DB folder and run docker-compose to start the database.
 ```bash
  cd DB
  docker-compose up -d
```
4) After running the DB, return to the project directory and build the Docker image for the REST API.
 ```bash
  cd..
  docker build -t ${IMAGE_NAME}:${IMAGE_VERSION} .
```

5) Let’s run the container now. This will connect to the database, create the schema, and start the Restapi in container on the given port.
 ```bash
  cd..
  docker run --rm --name ${CONTAINER_NAME} -d -p ${APP_PORT}:8000 --network ${DOCKER_NETWORK} \
  -e POSTGRES_DB=${} \
  -e POSTGRES_USER=${} \
  -e POSTGRES_PASSWORD=${} \
  -e POSTGRES_PORT=${} \
  -e POSTGRES_HOST=${} \
  ${IMAGE_NAME}:${IMAGE_VERSION}
```


## Documentation(API Documentation)

- Refer to the API documentation for the endpoints listed below
```bash
  http://127.0.0.1:8000/docs
```