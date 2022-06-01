# Trust custom certificate test

## Instructions

### Run the web server

```sh
make gencerts
make run-server
```

### Run Dapr

```sh
pip3 install -r app/requirements.txt
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

Create dapr images from the branch: shubham1172:shubham1172/add-volume-mount-support
```sh
export DAPR_REGISTRY=docker.io/shubham1172
export DAPR_TAG=certtests
make build-linux
make docker-build
make docker-push
```

K8s cluster created with AKS.
```sh
az aks get-credentials -n mydapr -g dapr-cert-test
make create-test-namespace
make docker-deploy-k8s
```

Install app on the k8s cluster.
```sh
make push-app-image
kubectl apply -f components/k8s/bindings.http.yaml
kubectl apply -f deploy/python.yaml
```

#### Without the fix
```python
Traceback (most recent call last):
  File "main.py", line 12, in <module>
    resp = client.invoke_binding(BINDING_NAME, BINDING_OPERATION, '')
  File "/usr/local/lib/python3.7/site-packages/dapr/clients/grpc/client.py", line 308, in invoke_binding
    response, call = self._stub.InvokeBinding.with_call(req, metadata=metadata)
  File "/usr/local/lib/python3.7/site-packages/grpc/_channel.py", line 957, in with_call
    return _end_unary_response_blocking(state, call, True, None)
  File "/usr/local/lib/python3.7/site-packages/grpc/_channel.py", line 849, in _end_unary_response_blocking
    raise _InactiveRpcError(state)
grpc._channel._InactiveRpcError: <_InactiveRpcError of RPC that terminated with:
        status = StatusCode.INTERNAL
        details = "error when invoke output binding helloworld: Get "https://20.219.10.119/": x509: certificate signed by unknown authority"
        debug_error_string = "{"created":"@1653888967.843891957","description":"Error received from peer ipv4:127.0.0.1:50001","file":"src/core/lib/surface/call.cc","file_line":952,"grpc_message":"error when invoke output binding helloworld: Get "https://20.219.10.119/": x509: certificate signed by unknown authority","grpc_status":13}"
```

```sh
kubectl delete -f deploy/python.yaml
```

#### With the fix
```sh
kubectl create secret generic https-cert --from-file ./cert.pem
kubectl apply -f deploy/python-withfix.yaml # contains volume mount and environment variable
```

```log
kubectl logs pythonapp-fc87667dd-hg2v4 -c python
INFO:root:Response: b'Hello, World!'
INFO:root:Response: b'Hello, World!'
INFO:root:Response: b'Hello, World!'
INFO:root:Response: b'Hello, World!'
INFO:root:Response: b'Hello, World!'
```

### Testing on Kubernetes (Windows)

#### Preparation
Golang server hosted on an Azure VM with a public IP.
Create a AKS cluster with Windows containers: https://docs.microsoft.com/en-us/azure/aks/learn/quick-windows-container-deploy-cli

```ps1
az aks create `
--resource-group dapr-cert-test `
--name mydaprwin `
--node-count 2 `
--enable-addons monitoring `
--generate-ssh-keys `
--windows-admin-username shubhash `
--vm-set-type VirtualMachineScaleSets `
--kubernetes-version 1.23.5 `
--network-plugin azure

# Add a Windows nodepool
az aks nodepool add `
--resource-group dapr-cert-test `
--cluster-name mydaprwin `
--os-type Windows `
--name npwin `
--node-count 1
```

Note, System NodePool can only be Linux, so the original Linux nodepool can't be deleted.

Create dapr images from the branch: shubham1172/configure-custom-certs-support-windows
```ps1
$ENV:DAPR_REGISTRY="docker.io/shubham1172"
$ENV:DAPR_TAG="certtestswin"
$ENV:TARGET_OS="windows"
make build
make docker-build
make docker-push
```

K8s cluster created with AKS.
```sh
az aks get-credentials -n mydaprwin -g dapr-cert-test
make create-test-namespace

# Before deploying, edit the Dapr Makefile temporarily 
# and add `--set global.nodeSelector."kubernetes\\.io/os"=windows`
# as a parameter in docker-deploy-k8s step.
# This will install Dapr on the Windows nodepool.
make docker-deploy-k8s
```

Install app on the k8s cluster.
```sh
make push-app-image
kubectl apply -f components/k8s/bindings.http.yaml
kubectl apply -f deploy/python-win.yaml
```

#### Without the fix
```python
Traceback (most recent call last):
  File "main.py", line 12, in <module>
    resp = client.invoke_binding(BINDING_NAME, BINDING_OPERATION, '')
  File "C:\Python\Lib\site-packages\dapr\clients\grpc\client.py", line 308, in invoke_binding
    response, call = self._stub.InvokeBinding.with_call(req, metadata=metadata)
  File "C:\Python\Lib\site-packages\grpc\_channel.py", line 957, in with_call
    return _end_unary_response_blocking(state, call, True, None)
  File "C:\Python\Lib\site-packages\grpc\_channel.py", line 849, in _end_unary_response_blocking
    raise _InactiveRpcError(state)
grpc._channel._InactiveRpcError: <_InactiveRpcError of RPC that terminated with:
        status = StatusCode.INTERNAL
        details = "error when invoke output binding helloworld: Get "https://20.219.143.173/": x509: certificate signed by unknown authority"
        debug_error_string = "{"created":"@1654013428.615000000","description":"Error received from peer ipv4:127.0.0.1:50001","file":"src/core/lib/surface/call.cc","file_line":953,"grpc_message":"error when invoke output binding helloworld: Get "https://20.219.143.173/": x509: certificate signed by unknown authority","grpc_status":13}"
```

#### With the fix

```ps1
kubectl create secret generic https-cert --from-file ./cert.pem
kubectl apply -f deploy/python-win-withfix.yaml # contains volume mount and environment variable
```