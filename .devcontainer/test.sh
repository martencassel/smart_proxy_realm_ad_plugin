#!/bin/bash

curl -H "Accept: application/json" http://localhost:3000/features

curl -d 'hostname=server1.example.com' http://localhost:3000/realm/example.com

curl -d 'hostname=server1.example.com&rebuild=true' http://localhost:3000/realm/example.com

curl -XDELETE http://localhost:3000/realm/example.com/server1.example.com

