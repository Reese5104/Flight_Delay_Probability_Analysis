# Run from the project root: Rscript R/run_all.R
source("R/bootstrap.R")
for (script in sprintf("R/%02d_%s.R", 1:9, c("data_cleaning", "descriptive_statistics", "poisson", "binomial", "geometric", "negative_binomial", "hypergeometric", "simulations", "visualizations"))) {
  message("Running ", script)
  source(script)
}
source("R/10_reproducibility_summary.R")
message("Complete. Review output/tables/preprocessing_summary.csv, output/results/simulation_summary.csv, and report/REDO_reproducibility_addendum.md.")
