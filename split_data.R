library(tidyverse)

set.seed(123)

clean_data <- read_csv("data/derived/clean_data.csv")

train <- clean_data %>%
  group_by(readmitted30) %>%
  slice_sample(prop=0.8) %>%
  ungroup()
  
test <- clean_data %>%
  filter(!encounter_id %in% train$encounter_id)