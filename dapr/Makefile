build-app-image:
	docker build -t shubham1172/dapr-python-app:latest -f app/Dockerfile app/
	docker build -t shubham1172/dapr-python-app:windows -f app/Dockerfile-windows app/

push-app-image: build-app-image
	docker push shubham1172/dapr-python-app:latest
	docker push shubham1172/dapr-python-app:windows

run-app-local:
	dapr run --app-id myapp --components-path ./components/local python3 app/main.py