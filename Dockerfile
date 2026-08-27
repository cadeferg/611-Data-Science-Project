FROM rocker/rstudio:latest
RUN apt update && apt install -y man-db manpages && yes | unminimize && rm -rf /var/lib/apt/lists/*
