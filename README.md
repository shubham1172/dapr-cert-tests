# Trust custom certificate test

## Instructions

### Run the web server

```sh
make gencerts
make run-server
```

### Run Dapr

```sh
pip3 install -r requirements.txt
make run-app
```

### Cleanup

```sh
make clean
```

## Test Results

### Local testing

Before installing the certificate locally, this is the error:
```log
== APP ==     raise _InactiveRpcError(state)
== APP == grpc._channel._InactiveRpcError: <_InactiveRpcError of RPC that terminated with:
== APP ==       status = StatusCode.INTERNAL
== APP ==       details = "error when invoke output binding helloworld: Get "https://localhost:8080": x509: certificate signed by unknown authority"
== APP ==       debug_error_string = "{"created":"@1653652000.406596000","description":"Error received from peer ipv4:127.0.0.1:38675","file":"src/core/lib/surface/call.cc","file_line":952,"grpc_message":"error when invoke output binding helloworld: Get "https://localhost:8080": x509: certificate signed by unknown authority","grpc_status":13}"
```

Install the certificate on local computer. For Windows,
```ps1
certutil.exe -f -addstore root .\cert.pem # From elevated powershell
```

Run Dapr
```ps1
dapr run --app-id myapp --components-path ./components cmd /c "python3 app/main.py" 
```

This time it works!!

### Testing on Kubernetes

#### Preparation
Golang server hosted on an Azure VM with a public IP.

Create dapr images from my branch: shubham1172:shubham1172/add-volume-mount-support
```sh
export DAPR_REGISTRY=docker.io/shubham1172
export DAPR_TAG=certtests
make build-linux
make docker-build
make docker-push
```
