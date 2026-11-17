# Analysis of 30-Day Readmission for Patients with Diabetes
Author: Cade Ferguson
BIOS 611
12/02/2026

## Overview
This project explores the "Diabetes 130-US Hospitals for Years 1999-2008" dataset from UC Irvine’s Machine Learning Repository, which includes clinical data collected from inpatient diabetic encounters with a length of stay between one and fourteen days.

## Using this repository

Everything in this project runs inside a Docker container, a self-contained Linux environment with R, RStudio, Python, and every package the analysis needs already installed.

Note that this guide is designed for Mac users and has only been tested on a Macbook Pro M5. Steps for starting the container may require slight modification on Windows devices.

### What you need

- Docker
  - Install Docker Desktop and make sure it's running before you start.
- Git, to download the repository.
- A few GB of free disk space and memory.

### Steps

**1. Download the repository**

```bash
git clone https://github.com/cadeferg/611-Data-Science-Project.git
cd 611-Data-Science-Project
```

The dataset is included in the repository under data/raw/.

**2. Start the container using the provided start script**
```bash
sh start.sh
```

This script builds the Docker image from the Dockerfile. It may take several minutes to download all necessary packages to run the code. Then, the script starts a container running RStudio and shares the project folder with it. All project files and code are located in the **~/work** folder.

**3. Navigate to RStudio**

Go to http://localhost:8787 in your web browser and log in with:

- Username: rstudio
- Password: changeme

To use your own password, start the container instead with:

```bash
RSTUDIO_PASSWORD=yourpassword sh start.sh
```

