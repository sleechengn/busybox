#!/usr/bin/env sh
docker build . -t sleechengn/busybox:latest
docker run -it --rm sleechengn/busybox:latest
