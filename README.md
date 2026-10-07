# STAT 562 Project 1: reproducible redo

This runnable project analyzes the supplied **flight-level** sample in
`data/raw/flight_delays.csv`. It does not use monthly arrival-delay aggregates
to make daily or individual-flight claims.

## Run the analysis

From the project root:

```sh
Rscript R/run_all.R
```

Required R packages: `tidyverse`, `lubridate`, `broom`, and `data.table`.
The cleaner reads only the fields required for analysis, so the 3-million-row
source can run on typical hardware. It creates needed output directories
automatically.

## Reproducible data-to-result path

1. `R/01_data_cleaning.R` identifies the flight-level `FL_DATE` and
   `DEP_DELAY` fields, records missingness and duplicate-key diagnostics, and
   writes compact cleaned flight and daily files.
2. `R/02` through `R/07` produce the descriptive and five distribution-model
   result tables.
3. `R/08_simulations.R` uses seed 562 and 10,000 simulations for every model,
   with theoretical and simulated means/variances in one table.
4. `R/09_visualizations.R` writes figures.
5. `R/10_reproducibility_summary.R` writes the provenance addendum used to
   reconcile the report with the actual input and outputs.

Key verification files:

- `output/tables/preprocessing_summary.csv` - exact schema, cleaned rows,
  dates, interval count, calendar check, and event definitions.
- `data/cleaned/daily_delays.csv` - the daily intervals used by the daily models.
- `output/results/simulation_summary.csv` - theoretical versus simulated
  evidence for all five distributions.
- `report/REDO_reproducibility_addendum.md` - concise data-to-result audit.

## Model definitions

All modeling settings live in `R/config.R`.

- A delayed flight has `DEP_DELAY > 0` minutes.
- The Poisson outcome is the number of delayed flights per observed day.
- Binomial success is a day whose delayed-flight rate exceeds 40%.
- Geometric success is a high-severity day: at least 10% of observed flights
  have `DEP_DELAY > 30` minutes. This prevents the degenerate result created by
  defining success as merely one major delay in a large daily sample.
- Negative Binomial success is a delayed flight; the model counts flights until
  five successes.
- Hypergeometric sampling selects 100 flights without replacement from the
  cleaned finite population.

The Poisson variance-to-mean ratio is reported rather than ignored; substantial
overdispersion is evidence that the simple Poisson assumption is limited.

## Important limitation

The source is a sample of flight records. A complete sequence of represented
calendar dates does not mean the data contain every flight scheduled on each
date. Interpret estimates as describing this sample, and add the verified
publisher/download citation to `data/raw/DATA_SOURCE.md` before submission.
