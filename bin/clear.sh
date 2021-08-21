#!/bin/bash

set -eu

dir=$PWD/build/

echo "Are you sure you want to delete everything in $dir except .gitignore?"
echo -n "[y/N]: "
read answer

if [[ "$answer" != "y" ]]; then
  echo "Cleaning was cancalled"
  exit 0
fi

rm -rf "$dir/"*
