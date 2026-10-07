script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))

provenance <- read_csv("output/tables/preprocessing_summary.csv", show_col_types = FALSE)
poisson <- read_csv("output/results/poisson_results.csv", show_col_types = FALSE)
binomial <- read_csv("output/results/binomial_results.csv", show_col_types = FALSE)
geometric <- read_csv("output/results/geometric_results.csv", show_col_types = FALSE)
simulation <- read_csv("output/results/simulation_summary.csv", show_col_types = FALSE)

lines <- c(
  "# Redo reproducibility addendum",
  "",
  "## Exact data and code path",
  "",
  "The reported outputs were produced from `data/raw/flight_delays.csv` by running `Rscript R/run_all.R` from this project root. The cleaning script detected the flight-level path: `FL_DATE` was normalized to `fl_date` and `DEP_DELAY` to `dep_delay`. Rows with missing departure delay or date were excluded because an observed departure-delay event cannot be defined for them.",
  "",
  sprintf("The input contains %s rows; %s flight-level records remained after this documented exclusion. The observation calendar runs from %s through %s, with %s observed daily intervals and %s calendar days. The complete-calendar check is `%s`.", provenance$rows_raw, provenance$rows_cleaned, provenance$first_observation, provenance$last_observation, provenance$observed_intervals, provenance$calendar_intervals, provenance$complete_daily_calendar),
  "",
  "The archive's monthly arrival-delay aggregate schema is not used to produce these results. That schema cannot establish daily departure-delay events or identify individual flights delayed over 30 minutes.",
  "",
  "## Operational definitions",
  "",
  sprintf("- Delayed flight: `%s`.", provenance$delayed_definition),
  sprintf("- Binomial success: %s.", binomial$event_definition),
  sprintf("- Geometric success: %s. This is a high-severity day, not merely a day containing one delayed flight; the latter was degenerate in this large flight-level sample.", geometric$event_definition),
  "",
  "## Reproducible checks",
  "",
  sprintf("- Poisson daily-count rate: lambda = %.6f. The empirical variance is %.6f, versus Poisson variance %.6f (variance-to-mean ratio %.3f), documenting overdispersion rather than claiming a good Poisson fit.", poisson$lambda, poisson$empirical_variance, poisson$theoretical_variance, poisson$variance_to_mean_ratio),
  sprintf("- Binomial p = %.6f; Geometric p = %.6f.", binomial$p, geometric$p),
  "- `output/results/simulation_summary.csv` compares theoretical and 10,000-replicate simulation means and variances for all five distributions. The seed is 562.",
  "",
  "## Files to review",
  "",
  "- `output/tables/preprocessing_summary.csv`: source schema, dates, interval count, and definitions.",
  "- `data/cleaned/daily_delays.csv`: the 1,704 daily intervals used by the daily models.",
  "- `output/results/*.csv`: model calculations and simulation comparison.",
  "- `R/config.R`: every modeling threshold and simulation setting."
)
writeLines(lines, "report/REDO_reproducibility_addendum.md")
