#!/bin/bash

set -eu -o pipefail

set -- "$@" "--no-tagged-filename"

dir="$(cd "$(dirname "$0")" && pwd)"

source $dir/args-source.sh

dockerfile=build/Dockerfile
version=$(basename $outname)
if [[ -n "$outname_suffix" ]]; then
  version+="$outname_suffix"
fi
dockerfile+=".$version"

export DOCKER_GO_BUILD_COMMAND="$(no_color=1 show_command "${go_build_command_full[@]}")"
export DOCKER_GO_OUTNAME=$outname
envsubst < ../../Dockerfile > $dockerfile

export DOCKER_BUILDKIT=1
project_name="$(basename "$(pwd)")"
image_tag="localhost/go-examples/$project_name:$version"
docker_build_command=(
  docker build -t $image_tag -f $dockerfile .
)
docker_run_command=(
  docker run --rm -it $image_tag
)

if [[ "$dry_run" == "0" ]]; then
  "${docker_build_command[@]}"
fi

echo
echo "Go build command:"
show_command "${go_build_command_full[@]}"
echo

echo "Docker build command:"
show_command "${docker_build_command[@]}"
echo

echo "Run the container:"
show_command "${docker_run_command[@]}"
echo
echo "Tips:"
echo " - Press CTRL+C to terminate the container if it does not happen automatically."
echo " - Add '-p hostport:containerport' to 'docker run' to forward a host port to the containers IP address" 


