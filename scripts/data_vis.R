library(readr)
library(dplyr)
library(tidyverse)

setwd("~/work")

parse_age <- function(age) {
  age %>% str_replace("\\[","") %>% 
    str_replace("\\)","") %>% 
    str_replace("-.*","") %>% 
    as.numeric() %>% 
    `+`(5)
}

#check ethnicity distribution in US
d = read_csv("diabetes+130-us+hospitals+for+years+1999-2008/diabetic_data.csv") %>% 
  mutate(age=parse_age(age))
head(d)

races_ordered = d %>% 
  group_by(race) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  pull(race)

ggplot(d, aes(factor(race, races_ordered))) +
  geom_histogram(aes(fill=gender), position="dodge", stat="count")
ggsave("race_plot.png")

head(d %>% pull(age))

d %>% group_by(age) %>% tally()

ggplot(d, aes(age)) + geom_histogram(stat="count", position="dodge",aes(fill=gender))
ggsave("age_plot.png")

ggplot(d, aes(age)) + geom_density(position="dodge",aes(fill=race),bw = 7) + facet_wrap(~race)
ggsave("anotherplot.png")

ggplot(d, aes(race,age)) + geom_violin(bw=7) + stat_summary(geom="crossbar")
ggsave("age_plot_by_race.png")

d %>% group_by(race) %>% summarize(average_age=mean(age))

encounter_count <- d %>% 
  group_by(patient_nbr) %>% 
  tally() %>% 
  arrange(desc(n)) %>% 
  group_by(n) %>% 
  tally()

encounter_count

patient_nbr_order <- encounter_count %>% pull(patient_nbr)

ggplot(d, aes(factor(patient_nbr,patient_nbr_order))) + geom_histogram(stat="count")
ggsave("encounters.png")
