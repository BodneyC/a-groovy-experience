#!/usr/bin/env bash

set -e

case "$1" in
  "")
    echo "Not building this time"
    ;;
  build)
    docker buildx build -t jenkins-local .
    ;;
  *)
    echo "Unknown option: $1"
    exit 1
    ;;
esac

docker run --rm \
  -m 1g \
  -p 8080:8080 -p 50000:50000 \
  jenkins-local:latest
