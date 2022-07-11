docker-build:
	docker build -t ghcr.io/shubham1172/helloworld-server:latest -f Dockerfile .

docker-push: docker-build
	docker push ghcr.io/shubham1172/helloworld-server:latest

run-app:
	docker run -p 80:80 --rm --name helloworld-server ghcr.io/shubham1172/helloworld-server:latest