# Docker Go Examples: hello-web

## Build the binary without parameters

* Run

  ```bash
  ../../bin/build.sh main
  ```

  It generates and executes the following Go build command command

  ```bash
  go build -o build/main src/main.go
  ```

* Run the generated binary to start the webserver which will listen on port 8180

  ```bash
  ./build/main
  ```

* In an other terminal use curl to test the server

  ```bash
  curl localhost:8180
  ```

  The output on server side

  ```
  2021/08/21 18:02:18 Received request for path: /
  ```

  The output on client side

  ```
  Hello, you requested: /
  ```

* Build a Docker image

  ```bash
  ../../bin/build-image.sh main
  ```

  It will use the following Go build command

  ```bash
  go build -o build/main src/main.go
  ```

  and generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello-web:main -f build/Dockerfile.main .
  ```

* Run the container

  ```bash
  docker run --rm -it -p 8180:8180 localhost/go-examples/hello-web:main
  ```

  Output

  ```
  standard_init_linux.go:228: exec user process caused: no such file or directory
  ```

  Last time we used the "--static" option to solve this.
  It woud not help this time, since the problem is a missing library
  but a reference to a library which we do not actually need.

* Run

  ```bash
  strings ./build/main | grep '\.so\.'
  ```

  Output

  ```
  /lib64/ld-linux-x86-64.so.2
  libpthread.so.0
  libc.so.6
  libc.so.6
  libpthread.so.0
  ```

  You can check in the 'hello' and 'hello-time' examples that their main binaries
  did not include these references.

* Disable CGO to remove the references

  ```bash
  ../../bin/build.sh main --no-cgo
  ```

  It generates and executes the following Go build command

  ```bash
  CGO_ENABLED=0 go build -o build/main-cgo0 src/main.go
  ```  

* Look for so file references in the new build

  ```bash
  strings ./build/main-cgo0 | grep '\.so\.'
  ```

  The will be none.

* Build the container version of the fixed binary

  ```bash
  ../../bin/build-image.sh main --no-cgo
  ```

  It will use the following Go build command

  ```bash
  CGO_ENABLED=0 go build -o build/main src/main.go
  ```

  and generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello-web:main-cgo0 -f build/Dockerfile.main-cgo0 .
  ```

* Run the container

  ```bash
  docker run --rm -it -p 8180:8180 localhost/go-examples/hello-web:main-cgo0
  ```

* Then use curl in an other terminal

  ```bash
  curl localhost:8180
  ```

  The server side output

  ```
  2021/08/21 18:17:56 Received request for path: /
  ```

  The client side output

  ```
  Hello, you requested: /
  ```

* See the sizes of the Docker images

  ```bash
  docker image ls localhost/go-examples/hello-web:* --format '{{ .Tag }} {{ .Size }}' | column -t | sort
  ```

  Output

  ```
  main       6.18MB
  main-cgo0  6.13MB
  ```

  "main-cgo0" is not just smaller but the only working container version.
  This is one of the cases when disabling CGO helps even if we don't have
  embedded C source code or anything which requires CGO enabled, since
  the dependencies could require it.
  If we don't need those parts of the dependencies, then we can get rid of them.

