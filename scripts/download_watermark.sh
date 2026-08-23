#!/usr/bin/env sh

set -eu

# Export the TU Darmstadt watermark without storing the copyrighted asset in Git.
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
project_dir=$(dirname "$script_dir")

docker buildx build --output "$project_dir/img" -f "$project_dir/.github/Dockerfile.logo" "$project_dir/.github"
touch "$project_dir/img/tuda_logo.svg"
