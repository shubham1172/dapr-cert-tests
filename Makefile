SERVER_BINARY_NAME=server
BINARY_DIR=bin

gencerts:
	openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem -config openssl.conf -extfile extfile.cnf

build-server:
	mkdir -p ${BINARY_DIR}
	go build -o ${BINARY_DIR}/${SERVER_BINARY_NAME} server/main.go

run-server: build-server
	./${BINARY_DIR}/${SERVER_BINARY_NAME}

clean:
	rm key.pem cert.pem
	rm -rf ${BINARY_DIR}

build-app-image:
	docker build -t shubham1172/dapr-python-app:latest -f app/Dockerfile app/

push-app-image: build-app-image
	docker push shubham1172/dapr-python-app:latest

run-app:
	dapr run --app-id myapp --components-path ./components/local python3 app/main.py