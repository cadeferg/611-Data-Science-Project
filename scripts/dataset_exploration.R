library(readr)
library(dplyr)
library(tidyverse)
d = read_csv("diabetes+130-us+hospitals+for+years+1999-2008/diabetic_data.csv")
head(d, n=100)

d %>% group_by(weight) %>% tally()



#want to cluster on all the dimensions (full dataset)
# visualize in lower dimensional space

