library(readr)
library(dplyr)
library(tidyverse)

parse_age <- function(age) {
  age %>% str_replace("\\[","") %>% 
    str_replace("\\)","") %>% 
    str_replace("-.*","") %>% 
    as.numeric() %>% 
    `+`(5)
}

#check ethnicity distribution in US
d = read_csv("data/raw/diabetic_data.csv") %>% 
  mutate(age=parse_age(age))
head(d)

races_ordered = d %>% 
  group_by(race) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  pull(race)

ggplot(d, aes(factor(race, races_ordered))) +
  geom_histogram(aes(fill=gender), position="dodge", stat="count")
ggsave("figures/race_plot.png")

head(d %>% pull(age))

d %>% group_by(age) %>% tally()

ggplot(d, aes(age)) + geom_histogram(stat="count", position="dodge",aes(fill=gender))
ggsave("figures/age_plot.png")

ggplot(d, aes(age)) + geom_density(position="dodge",aes(fill=race),bw = 7) + facet_wrap(~race)
ggsave("figures/anotherplot.png")

ggplot(d, aes(race,age)) + geom_violin(bw=7) + stat_summary(geom="crossbar")
ggsave("figures/age_plot_by_race.png")

d %>% group_by(race) %>% summarize(average_age=mean(age))

encounter_count <- d %>% 
  group_by(patient_nbr) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  group_by(n) %>% 
  tally()

encounter_count

ggplot(encounter_count, aes(n, nn)) + geom_col()
ggsave("figures/encounters.png")
