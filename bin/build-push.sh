#!/bin/bash
set -e
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  --target final \
  -t nimasystems/wordpress-bitnami:latest . \
  --push
