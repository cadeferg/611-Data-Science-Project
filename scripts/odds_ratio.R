library(tidyverse)

m <- readRDS("models/logistic.rds")

odds_ratios <- coef(summary(m)) %>% 
  as_tibble(rownames = "term") %>% 
  filter(term != "(Intercept)") %>% 
  mutate(odds_ratio = exp(Estimate),
         lower = exp(Estimate-1.96*`Std. Error`),
         upper = exp(Estimate+1.96*`Std. Error`)) %>% 
  arrange(odds_ratio) %>% 
  mutate(term = factor(term, levels = term))

odds_ratios %>% select(term, odds_ratio, lower, upper, `Pr(>|z|)`) %>% print(n = Inf)

ggplot(odds_ratios, aes(odds_ratio, term)) + 
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") + 
  geom_linerange(aes(xmin = lower, xmax = upper)) + 
  geom_point() + 
  scale_x_log10() + 
  labs(x = "Odds ratio for 30-day readmission", y = NULL)
ggsave("figures/odds_ratios.png", width = 7, height = 8)

write_csv(odds_ratios, "data/derived/odds_ratios.csv")