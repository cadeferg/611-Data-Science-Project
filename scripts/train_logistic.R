library(tidyverse)

train <- read_csv("data/derived/train.csv")

train <- train %>% 
  mutate(race = relevel(factor(race), ref = "Caucasian"),
         gender = relevel(factor(gender), ref = "Female"),
         discharge_to = relevel(factor(discharge_to), ref = "Home"),
         admission_type = relevel(factor(admission_type), ref = "Emergency"),
         admission_source = relevel(factor(admission_source), ref = "Emergency room"),
         diag_1 = relevel(factor(diag_1), ref = "Circulatory"),
         A1Cresult = relevel(factor(A1Cresult), ref = "None"),
         insulin = relevel(factor(insulin), ref = "No"),
         change = relevel(factor(change), ref = "No"))

f <- readmitted30 ~ age + gender + race + 
  number_inpatient + number_emergency + number_outpatient + 
  time_in_hospital + num_medications + number_diagnoses + 
  admission_type + admission_source + discharge_to + diag_1 + 
  A1Cresult + n_diabetes_meds + insulin + change

m <- glm(f, data = train, family = binomial())

print(summary(m))

dir.create("models", showWarnings = FALSE)
saveRDS(m, "models/logistic.rds")