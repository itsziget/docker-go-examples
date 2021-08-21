#!/bin/bash

set -eu

dir="$(cd "$(dirname "$0")" && pwd)"

source $dir/args-source.sh

show_command "${go_build_command_full[@]}"

if [[ "$dry_run" == "0" ]]; then
  "${go_build_command[@]}"
fi