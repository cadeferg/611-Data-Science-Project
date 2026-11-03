FROM rocker/rstudio:latest
RUN apt-get update && apt-get install -y git
