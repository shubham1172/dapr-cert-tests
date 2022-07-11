CERT_DIR=/tmp/certs

gen-certs:
	mkdir -p ${CERT_DIR}
	openssl req -newkey rsa:2048 -nodes -keyout ${CERT_DIR}/key.pem -x509 -days 365 -out ${CERT_DIR}/cert.pem -config openssl.conf

docker-build:
	docker build -t ghcr.io/shubham1172/helloworld-server-https:latest -f Dockerfile .

docker-push: docker-build
	docker push ghcr.io/shubham1172/helloworld-server-https:latest

run-app:
	docker run -p 443:443 --rm --name helloworld-server-https --volume "$(CERT_DIR)":/tmp/certs ghcr.io/shubham1172/helloworld-server-https:latest