BINARY_NAME=server
BINARY_DIR=bin

gencerts:
	openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem

build:
	mkdir -p ${BINARY_DIR}
	go build -o ${BINARY_DIR}/${BINARY_NAME} server/main.go

run: build
	./${BINARY_DIR}/${BINARY_NAME}

clean:
	rm key.pem cert.pem
	rm -rf ${BINARY_DIR}