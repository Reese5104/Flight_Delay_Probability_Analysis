# Redo reproducibility addendum

## Exact data and code path

The reported outputs were produced from `data/raw/flight_delays.csv` by running `Rscript R/run_all.R` from this project root. The cleaning script detected the flight-level path: `FL_DATE` was normalized to `fl_date` and `DEP_DELAY` to `dep_delay`. Rows with missing departure delay or date were excluded because an observed departure-delay event cannot be defined for them.

The input contains 3e+06 rows; 2922356 flight-level records remained after this documented exclusion. The observation calendar runs from 2019-01-01 through 2023-08-31, with 1704 observed daily intervals and 1704 calendar days. The complete-calendar check is `TRUE`.

The archive's monthly arrival-delay aggregate schema is not used to produce these results. That schema cannot establish daily departure-delay events or identify individual flights delayed over 30 minutes.

## Operational definitions

- Delayed flight: `DEP_DELAY > 0 minutes`.
- Binomial success: daily delayed-flight rate > 0.4.
- Geometric success: daily proportion of flights with DEP_DELAY > 30 minutes >= 0.1. This is a high-severity day, not merely a day containing one delayed flight; the latter was degenerate in this large flight-level sample.

## Reproducible checks

- Poisson daily-count rate: lambda = 582.654343. The empirical variance is 73845.029599, versus Poisson variance 582.654343 (variance-to-mean ratio 126.739), documenting overdispersion rather than claiming a good Poisson fit.
- Binomial p = 0.275235; Geometric p = 0.487676.
- `output/results/simulation_summary.csv` compares theoretical and 10,000-replicate simulation means and variances for all five distributions. The seed is 562.

## Files to review

- `output/tables/preprocessing_summary.csv`: source schema, dates, interval count, and definitions.
- `data/cleaned/daily_delays.csv`: the 1,704 daily intervals used by the daily models.
- `output/results/*.csv`: model calculations and simulation comparison.
- `R/config.R`: every modeling threshold and simulation setting.
