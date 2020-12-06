#!/bin/bash

docker build -f Dockerfile-foreman-proxy.c7 -t smart-proxy-c7:stable .

docker container rm -f smart-proxy

docker run --name=smart-proxy -d -p 3000:3000 smart-proxy-c7:stable

docker logs -f smart-proxy
