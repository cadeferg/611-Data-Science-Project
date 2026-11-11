library(tidyverse)

train <- read_csv("data/derived/train.csv")

f <- readmitted30 ~ age + gender + race + 
  number_inpatient + number_emergency + number_outpatient + 
  time_in_hospital + num_medications + number_diagnoses + 
  admission_type + admission_source + discharge_to + diag_1 + 
  A1Cresult + n_diabetes_meds + insulin + change

m <- glm(f, data = train, family = binomial())

print(summary(m))

dir.create("models", showWarnings = FALSE)
saveRDS(m, "models/logistic.rds")