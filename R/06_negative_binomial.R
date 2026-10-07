script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
flights <- read_clean_data(); r_successes <- analysis_config$negative_binomial_successes
p_estimate <- sum(flights$delay_flight_count) / sum(flights$total_flights)
if (p_estimate == 0) stop("No delayed flights; negative-binomial model cannot be estimated.")
negative_binomial_results <- tibble(r = r_successes, p = p_estimate,
  expected_trials = r_successes / p_estimate, variance = r_successes * (1 - p_estimate) / p_estimate^2,
  probability_finish_on_trial_5 = if_else(r_successes == 5, p_estimate^5, NA_real_))
write_csv(negative_binomial_results, "output/results/negative_binomial_results.csv")
# R's rnbinom returns failures before r successes; trials required = failures + r.
