.PHONY: all clean

all: data/derived/clean_data.csv

data/derived/clean_data.csv: scripts/clean_data.R data/raw/diabetic_data.csv
	Rscript scripts/clean_data.R
	
data/derived/train.csv data/derived/test.csv: scripts/split_data.R data/derived/clean_data.csv
	Rscript scripts/split_data.R
	
models/rf.joblib: scripts/train_rf.py data/derived/train.csv
	python3 scripts/train_rf.py

clean:
	rm -f data/derived/clean_data.csv
	