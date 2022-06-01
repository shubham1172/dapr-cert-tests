SERVER_BINARY_NAME=server
BINARY_DIR=bin

gencerts:
	openssl req -newkey rsa:2048 -nodes -keyout key.pem -x509 -days 365 -out cert.pem -config openssl.conf

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
	docker build -t shubham1172/dapr-python-app:windows -f app/Dockerfile-windows app/

push-app-image: build-app-image
	docker push shubham1172/dapr-python-app:latest
	docker push shubham1172/dapr-python-app:windows

run-app:
	dapr run --app-id myapp --components-path ./components/local python3 app/main.py