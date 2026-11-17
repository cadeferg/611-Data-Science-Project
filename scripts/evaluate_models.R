library(tidyverse)

test <- read_csv("data/derived/test.csv")
logistic <- readRDS("models/logistic.rds")
rf_predictions <- read_csv("data/derived/rf_predictions.csv")

scores <- test %>% 
  select(encounter_id, y = readmitted30) %>% 
  mutate(logistic = predict(logistic, newdata = test, type = "response")) %>% 
  left_join(rf_predictions, by = "encounter_id")

#area under the roc curve
auc <- function(roc){
  roc <- roc %>% arrange(`False Positive Rate`, `True Positive Rate`)
  x <- roc$`False Positive Rate`
  y <- roc$`True Positive Rate`
  sum(diff(x) * (head(y, -1) + tail(y, -1)) / 2)
}

make_roc <- function(score, y, model_name){
  ths <- score %>% unique() %>% sort(decreasing = TRUE)
  ths <- c(Inf, ths, -Inf)
  
  map_dfr(ths, function(t){
    pred <- as.integer(score >= t)
    tp <- sum(pred == 1 & y == 1)
    fp <- sum(pred == 1 & y == 0)
    tn <- sum(pred == 0 & y == 0)
    fn <- sum(pred == 0 & y == 1)
    tibble(model = model_name,
           `False Positive Rate` = fp/(fp + tn),
           `True Positive Rate` = tp/(tp + fn),
           threshold = t)
  })
}

#confusion counts at a threshold
evaluate_model <- function(score, y, model_name, threshold){
  pred <- as.integer(score >= threshold)
  tp <- sum(pred == 1 & y == 1)
  fp <- sum(pred == 1 & y == 0)
  tn <- sum(pred == 0 & y == 0)
  fn <- sum(pred == 0 & y == 1)
  tibble(model = model_name,
         threshold = threshold,
         tp = tp, fp = fp, tn = tn, fn = fn,
         accuracy = (tp + tn)/(tp + fp + tn + fn),
         sensitivity = tp/(tp + fn),
         specificity = tn/(tn + fp))
}

#threshold that maximizes TPR - FPR
best_threshold <- function(roc){
  roc %>% 
    filter(is.finite(threshold)) %>% 
    slice_max(`True Positive Rate` - `False Positive Rate`, n = 1, with_ties = FALSE) %>% 
    pull(threshold)
}

#logistic regression
logistic_roc <- make_roc(scores$logistic, scores$y, "Logistic regression")
logistic_metrics <- evaluate_model(scores$logistic, scores$y, "Logistic regression", best_threshold(logistic_roc)) %>% 
  mutate(auc = auc(logistic_roc))

#random forest
rf_roc <- make_roc(scores$rf, scores$y, "Random forest")
rf_metrics <- evaluate_model(scores$rf, scores$y, "Random forest", best_threshold(rf_roc)) %>% 
  mutate(auc = auc(rf_roc))

roc <- rbind(logistic_roc, rf_roc)
metrics <- rbind(logistic_metrics, rf_metrics)
print(metrics)

dir.create("figures", showWarnings = FALSE)

ggplot(roc, aes(`False Positive Rate`, `True Positive Rate`)) + 
  geom_line(aes(color = model)) + 
  geom_abline(slope = 1, intercept = 0, color = "red", linetype = "dashed") + 
  scale_color_viridis_d(end = 0.8) + 
  labs(color = NULL)
ggsave("figures/roc_curves.png", width = 6, height = 4)

write_csv(metrics, "data/derived/model_metrics.csv")