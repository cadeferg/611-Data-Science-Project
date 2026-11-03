.PHONY: all clean

all: data/derived/clean_data.csv

data/derived/clean_data.csv: scripts/clean_data.R data/raw/diabetic_data.csv
	Rscript scripts/clean_data.R

clean:
	rm -f data/derived/clean_data.csv
	