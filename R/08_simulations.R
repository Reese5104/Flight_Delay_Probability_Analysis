script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data(); flights <- read_clean_data(); simulations <- analysis_config$simulation_repetitions
lambda <- mean(daily$delayed_flights); p_day <- mean(daily$high_delay_day)
p_major <- mean(daily$major_delay_day); p_flight <- sum(flights$delay_flight_count) / sum(flights$total_flights); r <- analysis_config$negative_binomial_successes
if (is.na(p_day)) stop("The aggregate pathway does not support the daily-rate models. Use flight-level data.")
if (p_flight == 0) stop("No delayed flights were found; inspect the data and definitions.")
simulated <- tibble(
  poisson = rpois(simulations, lambda), binomial = rbinom(simulations, analysis_config$binomial_trials, p_day),
  negative_binomial_trials = rnbinom(simulations, r, p_flight) + r,
  hypergeometric = rhyper(simulations, sum(flights$delay_flight_count), sum(flights$total_flights - flights$delay_flight_count), min(analysis_config$hypergeometric_sample_size, sum(flights$total_flights)))
)
if (!is.na(p_major) && p_major > 0) simulated$geometric_days <- rgeom(simulations, p_major) + 1L
theoretical <- tibble(
  distribution = c("poisson", "binomial", "negative_binomial", "hypergeometric", "geometric"),
  theoretical_mean = c(lambda, analysis_config$binomial_trials * p_day, r / p_flight,
                       min(analysis_config$hypergeometric_sample_size, sum(flights$total_flights)) * p_flight, ifelse(is.na(p_major), NA, 1 / p_major)),
  theoretical_variance = c(lambda, analysis_config$binomial_trials * p_day * (1 - p_day), r * (1 - p_flight) / p_flight^2,
    min(analysis_config$hypergeometric_sample_size, sum(flights$total_flights)) * p_flight * (1 - p_flight) *
      ((sum(flights$total_flights) - min(analysis_config$hypergeometric_sample_size, sum(flights$total_flights))) / (sum(flights$total_flights) - 1)),
    ifelse(is.na(p_major), NA, (1 - p_major) / p_major^2)),
  simulation_status = c("simulated", "simulated", "simulated", "simulated", ifelse(is.na(p_major), "unsupported by aggregate data", "simulated"))
)
simulation_summary <- simulated |> pivot_longer(everything(), names_to = "distribution", values_to = "value") |>
  mutate(distribution = recode(distribution, negative_binomial_trials = "negative_binomial", geometric_days = "geometric")) |>
  group_by(distribution) |> summarise(simulated_mean = mean(value), simulated_variance = var(value), .groups = "drop") |>
  right_join(theoretical, by = "distribution")
write_csv(simulation_summary, "output/results/simulation_summary.csv")
saveRDS(simulated, "output/results/simulations.rds")
