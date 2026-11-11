library(tidyverse)
library(broom)

m <- readRDS("models/logistic.rds")

odds_ratios <- tidy(m) %>% 
  filter(term != "(Intercept)") %>% 
  mutate(odds_ratio = exp(estimate),
         lower = exp(estimate-1.96*std.error),
         upper = exp(estimate+1.96*std.error))

odds_ratios %>% select(term, odds_ratio, lower, upper, p.value) %>% print(n = Inf)

ggplot(odds_ratios, aes(odds_ratio, term)) + 
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") + 
  geom_linerange(aes(xmin = lower, xmax = upper)) + 
  geom_point() + 
  scale_x_log10() + 
  labs(x = "Odds ratio for 30-day readmission", y = NULL)
ggsave("figures/odds_ratios.png", width = 7, height = 8)

write_csv(odds_ratios, "data/derived/odds_ratios.csv")