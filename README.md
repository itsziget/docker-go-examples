# Go Examples

## Description

This repository contains Go example projects to help you learn to build
some very basic Go programs which could work even inside a Docker container
based on "scratch" image.

The examples were tested with Go 1.6.5. The Dockerfile files will contain
the proper version using the ```golang:1.16.5-buster``` as a builder base image.

We will use multi-stage Docker build for the container versions of the Go examples.

## Project hierarchy

* "projects" folder contains the example projects
* "bin" contains helper scripts to generate "go build" and "docker build" and "docker run" commands
* Dockerfile in the root folder is a template to generate Dockerfile for use case in each example project.
* .dockerignore is to avoid copying built binaries into docker images
* Each example contains a README.md which describes the relevant use cases, problems and solutions.
* There are "build" and "src" folders in each example project to store the Go source codes and
  the built binaries which are to run on the host not inside Docker containers.

## How to use helper scripts

* You need to cd into an example project before using any script
* Run ```../../build.sh``` without parameters to show the help.
* Run ```../../build-image.sh``` without parameters to show the help.
  It uses ```build.sh``` and adds Docker build commands.
* Run ```../../clear.sh``` to delete the generated files
* To use the proper parameters follow the instructions in each project's ```README.md```.

The recommended order to try the examples

* [hello](projects/hello/README.md)
* [hello-time](projects/hello-time/README.md)
* [hello-web](projects/hello-web/README.md)

## Conclusion

If you just want to know which command would usually work with or without containers,
check the following commands. If you want to know the details, check the referred
examples above.

### Without containers on your host machine

Usually the following command is enough for one Go source code.

```bash
go build -o path/to/output-file path/to/source-code.go
```

The generated binary can use pre-built libraries from the host operating system.

### Build Docker image based on scratch embedded C source code

The following command can be used in a Dockerfile

```bash
CGO_ENABLED=0 go build -o path/to/output -ldflags '-extldflags "-static" -s' -tags timetzdata path/to/source-code.go
```

Of course different projects could require different tags. "timetzdata" is useful only if you need to work with timezones.

```-s``` just makes your image smaller if you don't want to use debuggger tools on the generated binary.

### Build Docker image based on scratch with embedded C source code

```bash
go build -o path/to/output -ldflags '-extldflags "-static" -s' -tags timetzdata path/to/source-code.go
```

You cannot disable CGO, but you definitely need ```ldflags``` with the ```static``` option.

## Articles which inspired me to create this project

* https://chemidy.medium.com/create-the-smallest-and-secured-golang-docker-image-based-on-scratch-4752223b7324
* https://medium.com/@diogok/on-golang-static-binaries-cross-compiling-and-plugins-1aed33499671
* https://developers.redhat.com/articles/go-container#let_s_get_some_code
* https://medium.com/a-journey-with-go/go-how-to-take-advantage-of-the-symbols-table-360dd52269e5
