FROM rocker/rstudio:latest
RUN apt-get update && apt-get install -y git
RUN R -e "install.packages(c('tidyverse','readr','dplyr))"