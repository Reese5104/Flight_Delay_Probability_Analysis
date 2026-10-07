script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data()
lambda_estimate <- mean(daily$delayed_flights)
poisson_results <- tibble(lambda = lambda_estimate, theoretical_mean = lambda_estimate,
  theoretical_variance = lambda_estimate, empirical_mean = mean(daily$delayed_flights),
  empirical_variance = var(daily$delayed_flights), probability_zero = dpois(0, lambda_estimate),
  probability_at_least_one = ppois(0, lambda_estimate, lower.tail = FALSE),
  variance_to_mean_ratio = var(daily$delayed_flights) / mean(daily$delayed_flights))
write_csv(poisson_results, "output/results/poisson_results.csv")
# M_X(t) = exp(lambda * (exp(t) - 1)); compare mean and variance before claiming fit.
