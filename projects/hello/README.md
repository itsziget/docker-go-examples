# Docker Go Examples: hello

## The simplest build without dependencies

* Run

  ```bash
  ../../bin/build.sh main
  ```
  
  to generate and execute the following command:

  ```bash
  go build -o build/main src/main.go
  ```

* Now run the generated binary

  ```
  ./build/main
  ```

  Output:
  ```
  Hello Go!
  ```

* Run the following command to build a Docker image

  ```bash
  ../../bin/build-image.sh main
  ```

  It will generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello:main -f build/Dockerfile.main .
  ```

* Run the container version of the previous program

  ```bash
  docker run --rm -it localhost/go-examples/hello:main
  ```

  Output:
  ```
  Hello Go!
  ```

## Use embedded C source code

* Run

  ```bash
  ../../bin/build.sh mainc
  ```
  
  to generate and execute the following command:

  ```bash
  go build -o build/mainc src/mainc.go
  ```

* Now run the generated binary

  ```
  ./build/mainc
  ```

  Output:
  ```
  Hello Go! 2
  ```

  The number 2 came from the C function "number".

* Run the following command to build a Docker image

  ```bash
  ../../bin/build-image.sh mainc
  ```

  It will generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello:mainc -f build/Dockerfile.mainc .
  ```

* Run the container version of the previous program

  ```bash
  docker run --rm -it localhost/go-examples/hello:mainc
  ```

  Output:
  ```
  standard_init_linux.go:228: exec user process caused: no such file or directory
  ```

  The problem is we don't have the required libraries inside the container
  to execute the built binary with embedded C source code.

* Let's build the libraries into the built binary

  ```bash
  ../../bin/build-image.sh mainc --static
  ```

  IT will use the following Go command to build the binary

  ```bash
  go build -o build/mainc -ldflags '-extldflags "-static" ' src/mainc.go
  ```

  and generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello:mainc-static -f build/Dockerfile.mainc-static .
  ```

  **Note:** "LD" in "ldflags" means "Linker Directive". It will pass those flags to the external linker like "gcc".

* Run the new container which has the required libraries inside.

  ```bash
  docker run --rm -it localhost/go-examples/hello:mainc-static 
  ```

  Output:
  ```
  Hello Go! 2
  ```

* See the sizes of the docker images

  ```bash
  docker image ls localhost/go-examples/hello:* --format '{{ .Tag }} {{ .Size }}' | column -t | sort
  ```

  **Note:** ```{{ .Tag }} {{ .Size }}``` is a [Go template](https://pkg.go.dev/text/template)

  Output

  ```
  main              1.22MB
  mainc             1.3MB
  mainc-static      2.36MB
  ```

## Decrease the size of the image

* Build the docker image without generating the
  [Symbol table](https://en.wikipedia.org/wiki/Symbol_table) into the binary.

  ```bash
  ../../bin/build-image.sh mainc --static --no-symbol-table
  ```

  It will use the following command to build the binary

  ```bash
  go build -o build/mainc -ldflags '-extldflags "-static" -s ' src/mainc.go
  ```

  and generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello:mainc-static-st0 -f build/Dockerfile.mainc-static-st0 .
  ```

* Run the container

  ```bash
  docker run --rm -it localhost/go-examples/hello:mainc-static-st0
  ```

  Output:
  ```
  Hello Go! 2
  ```

* See the sizes of the images

  ```bash
  docker image ls localhost/go-examples/hello:* --format '{{ .Tag }} {{ .Size }}' | column -t | sort
  ```

  Output

  ```
  main              1.22MB
  mainc             1.3MB
  mainc-static      2.36MB
  mainc-static-st0  1.67MB
  ```

  ```-w``` in the Go command would disable only the [DWARF symbol table](https://en.wikipedia.org/wiki/DWARF) which is for debug purposes.

  ```-s``` disables the symbol table completely. When ```-s``` is used ```-w``` is not necessary.

  **Note:** You can ommit these options in case you want to use a debugger tool like gdb.


* The smallest image can be achieved with the previous options when you don't need any static library

  ```bash
  ../../bin/build-image.sh main --no-symbol-table
  ```

  It will use the following Go command to build the binary

  ```bash
  go build -o build/main -ldflags '-s ' src/main.go 
  ```

  and generate the Dockerfile and execute the Docker build command

  ```bash
  docker build -t localhost/go-examples/hello:main-st0 -f build/Dockerfile.main-st0 .
  ```

  It wouldn't work with "mainc" however.

* Run the container

  ```bash
  docker run --rm -it localhost/go-examples/hello:main-st0
  ```
  
  Output

  ```
  Hello Go!
  ```

* See the sizes of the Docker images

  ```bash
  docker image ls localhost/go-examples/hello:* --format '{{ .Tag }} {{ .Size }}' | column -t | sort
  ```

  Output

  ```
  main              1.22MB
  main-st0          836kB
  mainc             1.3MB
  mainc-static      2.36MB
  mainc-static-st0  1.67MB
  ```

  "main-st0" is the smallest but it cannot use embedded C sourcecode.

## The embedded C source code requires CGO

* Run 

  ```bash
  .../../bin/build.sh mainc --no-cgo
  ```

  It will generate and execute the following command:

  ```bash
  CGO_ENABLED=0 go build -o build/mainc ' src/mainc.go
  ```

  Output

  ```
  go: no Go source files
  ```

  The problem is disabling CGO also means: Do not build files with embedded C code.
  Itt will not fail to build those files since it will not even try to build them.
  In this case we need CGO enabled, but sometimes disabling it can result even
  smaller builds and Docker images
