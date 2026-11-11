.PHONY: all clean

all: data/derived/clean_data.csv

data/derived/clean_data.csv: scripts/clean_data.R data/raw/diabetic_data.csv
	Rscript scripts/clean_data.R
	
data/derived/train.csv data/derived/test.csv: scripts/split_data.R data/derived/clean_data.csv
	Rscript scripts/split_data.R
	
figures/age_plot.png figures/race_plot.png figures/anotherplot.png figures/age_plot_by_race.png \
  figures/readmit_by_age.png figures/readmit_by_inpatient.png figures/readmit_by_discharge.png \
  figures/eda_grid.png: scripts/exploratory_data_analysis.R data/derived/clean_data.csv
	Rscript scripts/exploratory_data_analysis.R
	
models/rf.joblib: scripts/train_rf.py data/derived/train.csv
	python3 scripts/train_rf.py

data/derived/rf_predictions.csv: scripts/predict_rf.py models/rf.joblib data/derived/test.csv
	python3 scripts/predict_rf.py
	
models/logistic.rds: scripts/train_logistic.R data/derived/train.csv
	Rscript scripts/train_logistic.R

figures/odds_ratios.png data/derived/odds_ratios.csv: scripts/odds_ratio.R models/logistic.rds
	Rscript scripts/odds_ratio.R

clean:
	rm -rf data/derived/* models/* figures/*