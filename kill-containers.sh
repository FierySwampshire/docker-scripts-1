#!/bin/bash
docker container rm -f `docker container ls | grep "$1" | tail -n 1 | awk  '{print $1}'`
