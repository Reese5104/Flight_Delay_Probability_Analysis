script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
flights <- read_clean_data()
N <- sum(flights$total_flights); K <- sum(flights$delay_flight_count); n_sample <- min(analysis_config$hypergeometric_sample_size, N)
if (N < 2 || n_sample < 1) stop("Need at least two flights for the finite-population calculation.")
hypergeometric_results <- tibble(N = N, K = K, n = n_sample, expected_value = n_sample * K / N,
  variance = n_sample * (K / N) * (1 - K / N) * ((N - n_sample) / (N - 1)),
  probability_zero_delays = dhyper(0, K, N - K, n_sample))
write_csv(hypergeometric_results, "output/results/hypergeometric_results.csv")
# M_X(t) is the finite sum of exp(t*x) * P(X=x) over the valid support.
