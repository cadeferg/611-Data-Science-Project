#!/bin/bash

docker build . -t bios611

docker run --rm -p 8787:8787 \
  -v "$(pwd)":/home/rstudio/work \
  -e PASSWORD="${RSTUDIO_PASSWORD:-changeme}" \
  -it bios611