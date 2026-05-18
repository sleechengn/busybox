#!/usr/bin/env sh
set -e
docker build --target dev . -t sleechengn/busybox:latest
docker run -it -p 8081:8081 --name busybox -p 8082:8082 --rm sleechengn/busybox:latest
