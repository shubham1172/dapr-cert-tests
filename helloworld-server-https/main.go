package main

import (
	"crypto/tls"
	"log"
	"net/http"
	"os"
)

func main() {
	handler := http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello, World! (Using HTTPS)"))
	})

	var certPath string

	if v, ok := os.LookupEnv("CERT_PATH"); !ok {
		certPath = "/tmp/certs"
	} else {
		certPath = v
	}

	server := &http.Server{
		Addr:    ":443",
		Handler: handler,
		TLSConfig: &tls.Config{
			ClientAuth: tls.RequestClientCert,
		},
	}
	log.Fatal(server.ListenAndServeTLS(certPath+"/cert.pem", certPath+"/key.pem"))
}
