#!/bin/bash

docker build -f Dockerfile-foreman-proxy.c7 -t smart-proxy-c7:stable .
docker container rm -f smart-proxy
docker run -it --net=host --name=smart-proxy -p 3000:3000 smart-proxy-c7:stable 
docker exec -it smart-proxy tail -f /var/log/foreman-proxy/proxy.log
docker exec -it smart-proxy /bin/bash
   