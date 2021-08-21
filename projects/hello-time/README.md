# Go Examples: hello-time

## Build main.go without parameters

* Run

  ```bash
  ../../bin/build.sh main
  ```

  It generates and executes the following Go build command:

  ```bash
  go build -o build/main src/main.go
  ```

* Run the generated binary

  ```bash
  ./build/main
  ```

  Output

  ```
  Hello Go! 2021-08-20T12:00:00+02:00
  ```

* Build a Docker container

  ```bash
  ../../bin/build-image.sh main
  ```

  It will use the following Go command to build the binary

  ```bash
  go build -o build/main src/main.go
  ```

* Run the container

  ```bash
  docker run --rm -it localhost/go-examples/hello-time:main
  ```

  Output

  ```
  panic: time: missing Location in call to Date

  goroutine 1 [running]:
  time.Date(0x7e5, 0x8, 0x14, 0xc, 0x0, 0x0, 0x0, 0x0, 0x414801, 0x0, ...)
          /usr/local/go/src/time/time.go:1344 +0x5f1
  main.main()
          /src/main.go:7 +0x7d
  ```

  It is actually looking for the timezone "Europe/Budapest" which is not inside the container.

## Generate timezone database into the binary

* Run

  ```bash
  ./../bin/build-image.sh main --timetzdata
  ```

  It will use the following Go build command

  ```bash
  go build -o build/main -tags timetzdata src/main.go
  ```

  Go source codes can define tags which must be used in the build command
  in order to build those files. "timetzdata" tag means build the timezone information
  into the binary. On the host operating system, you could find the information in
  ```/usr/share/zoneinfo/```.

* Run the container

  ```bash
  docker run --rm -it localhost/go-examples/hello-time:main-tz
  ```
  
  Output

  ```
  Hello Go! 2021-08-20T12:00:00+02:00
  ```

* See the sizes of the built docker images

  ```bash
  docker image ls localhost/go-examples/hello-time:* --format '{{ .Tag }} {{ .Size }}' | column -t | sort
  ```

  ```
  main     1.42MB
  main-tz  1.85MB
  ```
