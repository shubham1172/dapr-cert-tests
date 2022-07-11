FROM golang:1.18 AS builder
WORKDIR /go/src/github.com/shubham172/dapr-cert-tests/
COPY main.go    ./
COPY go.mod     ./
RUN CGO_ENABLED=0 GOOS=linux go build -o app .

FROM alpine:latest  
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /go/src/github.com/shubham172/dapr-cert-tests/app ./
CMD ["./app"]  

EXPOSE 80