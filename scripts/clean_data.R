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
            (num >= 390 & num <= 459) | floor(num) == 785 ~ "Circulatory",
            (num >= 460 & num <= 519) | floor(num) == 786 ~ "Respiratory",
            (num >= 520 & num <= 579) | floor(num) == 787 ~ "Digestive",
            (num >= 580 & num <= 629) | floor(num) == 788 ~ "Genitourinary",
            num >= 800 & num <= 999 ~ "Injury",
            num >= 710 & num <= 739 ~ "Musculoskeletal",
            num >= 140 & num <= 239 ~ "Neoplasms",
            TRUE ~ "Other")
}

raw_data = read_csv("data/raw/diabetic_data.csv") 
raw_data[raw_data == "?"] <- NA

raw_data = raw_data %>% 
  mutate(age=parse_age(age)) %>%
  mutate(weight=parse_weight(weight))%>% 
  mutate(diag_1 = group_diagnoses(diag_1),
         diag_2 = group_diagnoses(diag_2),
         diag_3 = group_diagnoses(diag_3))

raw_data$readmitted30 = as.integer(raw_data$readmitted=="<30")

raw_data$race[is.na(raw_data$race)] = "Unknown"

raw_data$gender[raw_data$gender=="Unknown/Invalid"] = "Unknown"

#expired/hospice discharge codes from IDS_mapping.csv
expired_hospice = c(11, 13, 14, 19, 20, 21)

raw_data = raw_data %>% 
  filter(!discharge_disposition_id %in% expired_hospice)

raw_data = raw_data %>%
  group_by(patient_nbr) %>%
  slice_min(encounter_id, n = 1) %>%
  ungroup()

raw_data = raw_data %>% 
  mutate(admission_type_id = as.factor(admission_type_id),
         discharge_disposition_id = as.factor(discharge_disposition_id),
         admission_source_id = as.factor(admission_source_id))