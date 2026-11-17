library(tidyverse)

m <- readRDS("models/logistic.rds")

odds_ratios <- coef(summary(m)) %>% 
  as_tibble(rownames = "term") %>% 
  filter(term != "(Intercept)") %>% 
  mutate(odds_ratio = exp(Estimate),
         lower = exp(Estimate-1.96*`Std. Error`),
         upper = exp(Estimate+1.96*`Std. Error`)) %>% 
  arrange(odds_ratio) %>% 
  mutate(term = factor(term, levels = term)) %>%
  mutate(effect = case_when(lower > 1 ~ "Higher readmission odds",
                            upper < 1 ~ "Lower readmission odds",
                            TRUE ~ "No clear effect"))

odds_ratios %>% select(term, odds_ratio, lower, upper, `Pr(>|z|)`) %>% print(n = Inf)

ggplot(odds_ratios, aes(odds_ratio, term, color = effect)) + 
  geom_vline(xintercept = 1, linetype = "dashed", color = "grey50") + 
  geom_linerange(aes(xmin = lower, xmax = upper)) + 
  geom_point() + 
  scale_x_log10() + 
  scale_color_manual(values = c("Higher readmission odds" = "red",
                                "Lower readmission odds" = "blue",
                                "No clear effect" = "grey60")) + 
  labs(x = "Odds ratio for 30-day readmission", y = NULL, color = NULL)

dir.create("figures", showWarnings = FALSE)
ggsave("figures/odds_ratios.png", width = 7, height = 8)

write_csv(odds_ratios, "data/derived/odds_ratios.csv")