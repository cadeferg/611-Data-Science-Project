library(readr)
library(dplyr)
library(tidyverse)
library(gridExtra)

dir.create("figures", showWarnings = FALSE)

clean_data <- read_csv("data/derived/clean_data.csv")

clean_data %>% group_by(age) %>% tally()

p_age_gender <- ggplot(clean_data, aes(age)) + geom_histogram(stat="count", position="dodge",aes(fill=gender))
ggsave("figures/age_plot.png", p_age_gender)

races_ordered = clean_data %>% 
  group_by(race) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  pull(race)

p_race_gender <- ggplot(clean_data, aes(factor(race, races_ordered))) +
  geom_histogram(aes(fill=gender), position="dodge", stat="count")
ggsave("figures/race_plot.png", p_race_gender)

p_age_density <- ggplot(clean_data, aes(age)) + geom_density(position="dodge",aes(fill=race),bw = 7) + facet_wrap(~race)
ggsave("figures/anotherplot.png", p_age_density)

p_age_race <- ggplot(clean_data, aes(race,age)) + geom_violin(bw=7) + stat_summary(geom="crossbar")
ggsave("figures/age_plot_by_race.png", p_age_race)

age_rates <- clean_data %>% 
  group_by(age) %>% 
  summarize(readmit_rate = mean(readmitted30), n = n())

age_rates

p_age <- ggplot(age_rates, aes(age, readmit_rate)) + 
  geom_line() + 
  geom_point() + 
  scale_y_continuous(labels = scales::percent) + 
  labs(x = "Age", y = "30-day readmission rate")
ggsave("figures/readmit_by_age.png", p_age, width = 6, height = 4)

inpatient_rates <- clean_data %>% 
  mutate(prior_inpatient = if_else(number_inpatient >= 5, "5+", as.character(number_inpatient))) %>% 
  group_by(prior_inpatient) %>% 
  summarize(readmit_rate = mean(readmitted30), n = n())

inpatient_rates

p_inpatient <- ggplot(inpatient_rates, aes(prior_inpatient, readmit_rate,fill=readmit_rate)) + 
  geom_col() + 
  geom_text(aes(label = paste0("n=", n)), vjust = -0.5, size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  scale_fill_viridis_b(guide="none") +
  labs(x = "Inpatient visits in prior year", y = "30-day readmission rate")
ggsave("figures/readmit_by_inpatient.png", p_inpatient, width = 6, height = 4)

#readmission rate by discharge destination
discharge_rates <- clean_data %>% 
  group_by(discharge_to) %>% 
  summarize(readmit_rate = mean(readmitted30), n = n()) %>% 
  arrange(readmit_rate) %>% 
  mutate(discharge_to = factor(discharge_to, levels = discharge_to))

p_discharge <- ggplot(discharge_rates, aes(readmit_rate, discharge_to, fill = discharge_to)) + 
  geom_col() + 
  scale_x_continuous(labels = scales::percent) + 
  scale_fill_viridis_d(guide="none") + 
  labs(x = "30-day readmission rate", y = NULL, fill = "Discharged to")
ggsave("figures/readmit_by_discharge.png", p_discharge, width = 7, height = 4)

#all plots on one grid
grid_plot <- arrangeGrob(p_inpatient, p_discharge, p_age,
                         p_age_gender, p_race_gender, p_age_density, p_age_race,
                         ncol = 2)
ggsave("figures/eda_grid.png", grid_plot, width = 12, height = 16)