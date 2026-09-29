# STAT 562 Project 1 — Flight Delay Probability Analysis

## Overview

This project applies statistical probability models to real-world **flight delay data** using R. The goal is to investigate flight-delay patterns and demonstrate how discrete probability distributions can be used to model real-world events.

The analysis focuses on five discrete probability distributions:

* **Poisson**
* **Binomial**
* **Geometric**
* **Negative Binomial**
* **Hypergeometric**

The project follows a reproducible data-analysis workflow from **data cleaning → exploratory analysis → probability modeling → simulation → visualization → interpretation**.

> **Project Status:** The analysis framework and R workflow are complete. Dataset-specific findings and statistical results are populated after the final flight-delay dataset is processed.

---

## Key Findings

The final analysis is designed to answer practical questions about flight delays, including:

* How frequently do flight delays occur?
* How well can the number of delays be modeled using a Poisson distribution?
* What is the probability of observing a specific number of delayed flights?
* How many flights might be expected before observing a delay?
* How does the Negative Binomial distribution describe repeated delay events?
* How does sampling without replacement affect delay probabilities?

### Key Takeaways

The completed analysis will summarize:

**Flight Delay Frequency**

* Overall number and percentage of delayed flights.
* Distribution of delays across the available observation period.

**Probability Modeling**

* Estimated parameters for each applicable probability distribution.
* Comparison between theoretical and observed probabilities.

**Model Behavior**

* Evaluation of how well each distribution represents the underlying flight-delay process.
* Identification of situations where distribution assumptions may or may not be appropriate.

**Practical Interpretation**

* Translation of statistical results into understandable conclusions about flight-delay behavior.

> Dataset-specific numerical findings will be added here after the final dataset is analyzed so that all reported values are reproducible.

---

## Statistical Results

The project evaluates several discrete probability models.

| Distribution          | Statistical Question                                          | Application                                     |
| --------------------- | ------------------------------------------------------------- | ----------------------------------------------- |
| **Poisson**           | How many events occur within a fixed interval?                | Number of flight delays                         |
| **Binomial**          | How many successes occur in a fixed number of trials?         | Number of delayed flights in a group of flights |
| **Geometric**         | How many trials occur before the first success?               | Flights observed before a delay                 |
| **Negative Binomial** | How many trials occur before a specified number of successes? | Flights observed before multiple delays         |
| **Hypergeometric**    | How many successes occur when sampling without replacement?   | Delayed flights within a finite sample          |

### Statistical Evaluation

The analysis separates:

* **Empirical results** — probabilities calculated from the observed flight data.
* **Theoretical results** — probabilities calculated from the specified probability distributions.
* **Simulation results** — repeated random experiments used to demonstrate distribution behavior.

The project also considers the assumptions behind each distribution rather than treating every model as automatically appropriate.

---

## Visualizations

The project generates visualizations to make the statistical results easier to interpret.

Visual outputs are saved in:

```text
output/figures/
```

Planned visualizations include:

* Flight-delay distributions
* Empirical vs. theoretical probability comparisons
* Probability distribution plots
* Simulation results
* Distribution-specific diagnostic visualizations

### Example Analysis Workflow

```text
Raw Flight Data
       ↓
Data Cleaning
       ↓
Descriptive Statistics
       ↓
Probability Modeling
       ↓
Simulation
       ↓
Statistical Comparison
       ↓
Visualization
       ↓
Interpretation
```

This structure demonstrates the ability to move from **raw data to statistical insight**, rather than only producing individual charts or calculations.

---

## Skills Demonstrated

### Statistical Analysis

* Probability distributions
* Discrete random variables
* Parameter estimation
* Descriptive statistics
* Empirical probability
* Theoretical probability
* Simulation
* Statistical model assumptions
* Distribution comparison

### Data Analysis

* Data cleaning
* Data transformation
* Exploratory data analysis
* Feature preparation
* Reproducible analysis workflows
* Statistical interpretation
* Data visualization

### Programming

**R**

Libraries used:

* `tidyverse`
* `lubridate`
* `broom`

The repository separates each stage of the analysis into individual R scripts, making the workflow easier to reproduce and maintain.

### Tools

* R / RStudio
* Git
* GitHub
* Markdown
* Data visualization
* Statistical reporting

---

## Technical Workflow

The analysis is organized into nine stages:

```text
01  Data Cleaning
 ↓
02  Descriptive Statistics
 ↓
03  Poisson Distribution
 ↓
04  Binomial Distribution
 ↓
05  Geometric Distribution
 ↓
06  Negative Binomial Distribution
 ↓
07  Hypergeometric Distribution
 ↓
08  Simulations
 ↓
09  Visualizations
```

The scripts are designed to be executed in numerical order so that cleaned data and intermediate outputs are available to subsequent analyses.

---

## Project Structure

```text
STAT562_Project1/
│
├── R/
│   ├── 01_data_cleaning.R
│   ├── 02_descriptive_statistics.R
│   ├── 03_poisson.R
│   ├── 04_binomial.R
│   ├── 05_geometric.R
│   ├── 06_negative_binomial.R
│   ├── 07_hypergeometric.R
│   ├── 08_simulations.R
│   └── 09_visualizations.R
│
├── data/
│   └── raw/
│
├── literature/
│
├── output/
│   ├── figures/
│   ├── results/
│   └── tables/
│
├── presentation/
│
├── report/
│
├── .gitignore
└── README.md
```

The repository currently contains dedicated directories for the R analysis, data, literature, outputs, presentation, and written report.

---

## Dataset

The project uses a flight-delay dataset containing information needed to analyze flight delays.

Before running the analysis, the dataset is placed at:

```text
data/raw/flight_delays.csv
```

The project documents the dataset source, coverage period, variables, and definition of a delayed flight in:

```text
data/raw/DATA_SOURCE.md
```

The default definition used by the analysis is:

```text
Departure delay > 0 minutes
```

This definition can be reviewed or modified in:

```text
R/01_data_cleaning.R
```

---

## How to Run

### 1. Install Required Packages

```r
install.packages(c(
  "tidyverse",
  "lubridate",
  "broom"
))
```

### 2. Add the Dataset

Place the flight-delay dataset in:

```text
data/raw/flight_delays.csv
```

### 3. Run the Analysis

From the project root:

```r
source("R/01_data_cleaning.R")
source("R/02_descriptive_statistics.R")
source("R/03_poisson.R")
source("R/04_binomial.R")
source("R/05_geometric.R")
source("R/06_negative_binomial.R")
source("R/07_hypergeometric.R")
source("R/08_simulations.R")
source("R/09_visualizations.R")
```

### 4. Review Outputs

Generated results are organized into:

```text
output/figures/
output/results/
output/tables/
```

---

## Why This Project Matters

Flight delays are a practical example of how probability and statistics can be applied to operational data.

This project demonstrates the ability to:

1. Work with real-world data.
2. Clean and prepare data for analysis.
3. Select appropriate statistical models.
4. Calculate and interpret probabilities.
5. Validate theoretical results using simulation.
6. Communicate statistical findings through visualization.
7. Organize an analysis into a reproducible workflow.

These skills translate directly to **Data Analyst, Data Scientist, Business Intelligence, and quantitative analytics** roles.

---

## Deliverables

The repository is structured to support multiple forms of communication:

* **R scripts** — statistical analysis and reproducible workflow
* **Figures** — visual representation of findings
* **Tables** — statistical results
* **Presentation** — concise communication of project findings
* **Report** — detailed statistical analysis and interpretation

---

## Author

**Reese Farquharson**

M.S. Data Analytics — Virginia State University
B.S. Computer Science — West Virginia Wesleyan College

### Technical Focus

`R` • `Python` • `SQL` • `Data Analytics` • `Statistics` • `Data Visualization` • `Machine Learning`

---
