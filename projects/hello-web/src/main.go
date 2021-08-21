package main

import (
	"fmt"
	"log"
	"net/http"
)

func HelloServer(response http.ResponseWriter, request *http.Request) {
	fmt.Fprintf(response, "Hello, you requested: %s\n", request.URL.Path)
	log.Printf("Received request for path: %s", request.URL.Path)
}

func main() {
	var addr string = ":8180"
	handler := http.HandlerFunc(HelloServer)
	err := http.ListenAndServe(addr, handler)
	if err != nil {
		log.Fatalf("Could not listen on port %s %v", addr, err)
	}
}
