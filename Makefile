.PHONY: all clean

all: data/derived/clean_data.csv

data/derived/clean_data.csv: scripts/clean_data.R data/raw/diabetic_data.csv
	Rscript scripts/clean_data.R
	
data/derived/train.csv data/derived/test.csv: scripts/split_data.R data/derived/clean_data.csv
	Rscript scripts/split_data.R
	
models/rf.joblib: scripts/train_rf.py data/derived/train.csv
	python3 scripts/train_rf.py

data/derived/rf_predictions.csv: scripts/predict_rf.py models/rf.joblib data/derived/test.csv
	python3 scripts/predict_rf.py
	
models/logistic.rds: scripts/train_logistic.R data/derived/train.csv
	Rscript scripts/train_logistic.R

figures/odds_ratios.png data/derived/odds_ratios.csv: scripts/odds_ratio.R models/logistic.rds
	Rscript scripts/odds_ratio.R

clean:
	rm data/derived/clean_data.csv data/derived/train.csv data/derived/test.csv models/rf.joblib data/derived/rf_importance.csv data/derived/rf_predictions.csv