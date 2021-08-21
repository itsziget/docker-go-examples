FROM golang:1.16.5-buster as build
COPY src /src
WORKDIR /
RUN $DOCKER_GO_BUILD_COMMAND

FROM scratch
WORKDIR /
COPY --from=build /$DOCKER_GO_OUTNAME /run
STOPSIGNAL SIGINT
CMD ["/run"]