library(tidyverse)
library(readr)
library(dplyr)

dir.create("data/derived", showWarnings = FALSE, recursive = TRUE)

parse_age <- function(age) {
  age %>% str_replace("\\[","") %>% 
    str_replace("\\)","") %>% 
    str_replace("-.*","") %>% 
    as.numeric() %>% 
    `+`(5)
}

parse_weight <- function(weight) {
  weight %>% str_replace("\\[","") %>% 
    str_replace("\\)","") %>% 
    str_replace(">","") %>%
    str_replace("-.*","") %>% 
    as.numeric() %>% 
    `+`(12.5)
}

#from the ICD-9 codebook
group_diagnoses <- function(code) {
  num <- as.numeric(code)
  case_when(is.na(code) ~ "Unknown",
            str_starts(code, "250") ~ "Diabetes",
            (num >= 390 & num < 460) | floor(num) == 785 ~ "Circulatory",
            (num >= 460 & num < 520) | floor(num) == 786 ~ "Respiratory",
            (num >= 520 & num < 580) | floor(num) == 787 ~ "Digestive",
            (num >= 580 & num < 630) | floor(num) == 788 ~ "Genitourinary",
            num >= 800 & num < 1000 ~ "Injury",
            num >= 710 & num < 740 ~ "Musculoskeletal",
            num >= 140 & num < 240 ~ "Neoplasms",
            TRUE ~ "Other")
}

raw_data <- read_csv("data/raw/diabetic_data.csv") 
raw_data[raw_data == "?"] <- NA

raw_data <- raw_data %>% 
  mutate(age=parse_age(age)) %>%
  mutate(weight=parse_weight(weight))%>% 
  mutate(diag_1 = group_diagnoses(diag_1),
         diag_2 = group_diagnoses(diag_2),
         diag_3 = group_diagnoses(diag_3))

raw_data$readmitted30 <- as.integer(raw_data$readmitted=="<30")

raw_data$race[is.na(raw_data$race)] <- "Unknown"

raw_data$gender[raw_data$gender=="Unknown/Invalid"] <- "Unknown"
raw_data <- raw_data %>% filter(gender != "Unknown")

raw_data <- raw_data %>% 
  select(-payer_code, -weight)

#expired/hospice discharge codes from IDS_mapping.csv
expired_hospice <- c(11, 13, 14, 19, 20, 21)

raw_data <- raw_data %>% 
  filter(!discharge_disposition_id %in% expired_hospice)

raw_data <- raw_data %>%
  group_by(patient_nbr) %>%
  slice_min(encounter_id, n = 1) %>%
  ungroup()

#groups from IDS_mapping.csv
raw_data <- raw_data %>% 
  mutate(admission_type = case_when(admission_type_id %in% c(1, 7) ~ "Emergency",
                                    admission_type_id == 2 ~ "Urgent",
                                    admission_type_id == 3 ~ "Elective",
                                    TRUE ~ "Other/Unknown"),
         discharge_to = case_when(discharge_disposition_id == 1 ~ "Home",
                                  discharge_disposition_id %in% c(6, 8) ~ "Home with health service",
                                  discharge_disposition_id %in% c(3, 4, 5, 15, 22, 23, 24, 27, 28, 30) ~ "Care facility",
                                  discharge_disposition_id %in% c(2, 10, 29) ~ "Another hospital",
                                  discharge_disposition_id == 7 ~ "Left against medical advice",
                                  TRUE ~ "Other/Unknown"),
         admission_source = case_when(admission_source_id %in% c(1, 2, 3) ~ "Referral",
                                      admission_source_id == 7 ~ "Emergency room",
                                      admission_source_id %in% c(4, 5, 6, 10, 18, 22, 25, 26) ~ "Transfer",
                                      TRUE ~ "Other/Unknown")) %>% 
  select(-admission_type_id, -discharge_disposition_id, -admission_source_id)

raw_data <- raw_data %>% 
  mutate(medical_specialty = replace_na(medical_specialty, "Unknown"),
         A1Cresult = replace_na(A1Cresult, "None"),
         max_glu_serum = replace_na(max_glu_serum, "None"))

raw_data <- raw_data %>% 
  mutate(diag_1 = if_else(diag_1 == "Unknown", "Other", diag_1))

meds <- raw_data %>% select(metformin:`metformin-pioglitazone`)

raw_data$n_diabetes_meds <- rowSums(meds != "No")
raw_data$n_dose_changes <- rowSums(meds == "Up" | meds == "Down")

all_meds <- raw_data %>% select(metformin:`metformin-pioglitazone`) %>% names()

for (med in all_meds) {
  n_taking <- sum(raw_data[[med]] != "No")
  if (n_taking < 700) {
    raw_data[[med]] <- NULL
  }
}

clean_data <- raw_data
write_csv(clean_data, "data/derived/clean_data.csv")