SERVER_BINARY_NAME=server
BINARY_DIR=bin

gencerts:
	openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem -config openssl.conf

build:
	mkdir -p ${BINARY_DIR}
	go build -o ${BINARY_DIR}/${SERVER_BINARY_NAME} server/main.go

run-server: build
	./${BINARY_DIR}/${SERVER_BINARY_NAME}

clean:
	rm key.pem cert.pem
	rm -rf ${BINARY_DIR}

run-app:
	dapr run --app-id myapp --components-path ./components/local python3 app/main.py