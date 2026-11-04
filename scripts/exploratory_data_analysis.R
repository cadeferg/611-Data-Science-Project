library(readr)
library(dplyr)
library(tidyverse)

dir.create("figures")

clean_data <- read_csv("data/derived/clean_data.csv")

clean_data %>% group_by(age) %>% tally()

ggplot(clean_data, aes(age)) + geom_histogram(stat="count", position="dodge",aes(fill=gender))
ggsave("figures/age_plot.png")

races_ordered = clean_data %>% 
  group_by(race) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  pull(race)

ggplot(clean_data, aes(factor(race, races_ordered))) +
  geom_histogram(aes(fill=gender), position="dodge", stat="count")
ggsave("figures/race_plot.png")

head(clean_data %>% pull(age))

clean_data %>% group_by(age) %>% tally()

ggplot(clean_data, aes(age)) + geom_histogram(stat="count", position="dodge",aes(fill=gender))
ggsave("figures/age_plot.png")

ggplot(clean_data, aes(age)) + geom_density(position="dodge",aes(fill=race),bw = 7) + facet_wrap(~race)
ggsave("figures/anotherplot.png")

ggplot(clean_data, aes(race,age)) + geom_violin(bw=7) + stat_summary(geom="crossbar")
ggsave("figures/age_plot_by_race.png")

inpatient_rates <- clean_data %>% 
  mutate(prior_inpatient = if_else(number_inpatient >= 5, "5+", as.character(number_inpatient))) %>% 
  group_by(prior_inpatient) %>% 
  summarize(readmit_rate = mean(readmitted30), n = n())

ggplot(inpatient_rates, aes(prior_inpatient, readmit_rate,fill=readmit_rate)) + 
  geom_col() + 
  geom_text(aes(label = paste0("n=", n)), vjust = -0.5, size = 3) + 
  scale_y_continuous(labels = scales::percent) + 
  scale_fill_gradient(low="green", high="red", guide="none")
  labs(x = "Inpatient visits in prior year", y = "30-day readmission rate")
ggsave("figures/readmit_by_inpatient.png", width = 6, height = 4)
