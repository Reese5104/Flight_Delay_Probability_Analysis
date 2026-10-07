# Analysis decisions recorded once and used by every script.
analysis_config <- list(
  delayed_flight_threshold_minutes = 0,
  major_delay_threshold_minutes = 30,
  # A high-delay day means >40% of observed flights have DEP_DELAY > 0.
  binomial_daily_delay_rate_threshold = 0.40,
  # A high-severity day means >=10% of observed flights have DEP_DELAY > 30.
  geometric_daily_major_delay_rate_threshold = 0.10,
  binomial_trials = 10L,
  negative_binomial_successes = 5L,
  hypergeometric_sample_size = 100L,
  simulation_repetitions = 10000L,
  random_seed = 562L
)
