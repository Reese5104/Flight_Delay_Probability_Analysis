script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
daily <- read_daily_data()
daily_plot <- ggplot(daily, aes(flight_date, delayed_flights)) + geom_line(color = "firebrick") +
  labs(title = "Daily flights with departure delay > 0 minutes", x = "Flight date", y = "Delayed flights")
ggsave("output/figures/daily_delayed_flights.png", plot = daily_plot, width = 9, height = 5, dpi = 300)

lambda <- mean(daily$delayed_flights)
observed <- daily |> count(delayed_flights, name = "observed") |> mutate(observed_probability = observed / sum(observed))
comparison <- observed |> mutate(poisson_probability = dpois(delayed_flights, lambda))
write_csv(comparison, "output/tables/poisson_observed_vs_theoretical.csv")
poisson_plot <- ggplot(comparison, aes(delayed_flights)) +
  geom_col(aes(y = observed_probability, fill = "Observed"), alpha = .7) +
  geom_point(aes(y = poisson_probability, color = "Poisson"), size = 2) +
  labs(title = "Observed daily delays versus Poisson probabilities", x = "Delayed flights per day", y = "Probability", fill = NULL, color = NULL)
ggsave("output/figures/poisson_observed_vs_theoretical.png", plot = poisson_plot, width = 8, height = 5, dpi = 300)
