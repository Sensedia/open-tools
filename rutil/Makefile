SENSEDIA_APP_NAME = rutil

build:
	go mod download
	CGO_ENABLED=0 GOOS=linux go build -o bin/rutil

image:
	docker build -t ${SENSEDIA_APP_NAME}:latest .
