FROM rocker/rstudio:latest
RUN apt-get update && apt-get install -y git python3-pip
RUN pip3 install --break-system-packages scikit-learn pandas
RUN R -e "install.packages(c('tidyverse','readr','dplyr','pROC','gridExtra')"