script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))
flights <- read_clean_data(); daily <- read_daily_data()

# In aggregate data, rows with zero delayed flights have no average delay value.
# Keep them in flight totals, but exclude their undefined average from delay-time summaries.
delay_values <- flights |> filter(!is.na(dep_delay_minutes))
if (nrow(delay_values) == 0) stop("No non-missing delay-duration values are available for descriptive statistics.")

summary_table <- tibble(
  flight_records = nrow(flights), total_flights = sum(flights$total_flights),
  delayed_flights = sum(flights$delay_flight_count),
  delayed_proportion = sum(flights$delay_flight_count) / sum(flights$total_flights),
  mean_delay = mean(delay_values$dep_delay_minutes), variance_delay = var(delay_values$dep_delay_minutes),
  sd_delay = sd(delay_values$dep_delay_minutes), min_delay = min(delay_values$dep_delay_minutes),
  q1_delay = quantile(delay_values$dep_delay_minutes, .25), median_delay = median(delay_values$dep_delay_minutes),
  q3_delay = quantile(delay_values$dep_delay_minutes, .75), max_delay = max(delay_values$dep_delay_minutes)
)
write_csv(summary_table, "output/tables/descriptive_statistics.csv")
write_csv(daily, "output/tables/daily_delay_counts.csv")

plot_title <- if (first(flights$data_granularity) == "flight-level record") "Distribution of flight-level departure delays" else "Average delay per delayed flight by reported record"
plot_x <- if (first(flights$data_granularity) == "flight-level record") "Departure delay (minutes)" else "Average arrival-delay minutes"
plot_y <- if (first(flights$data_granularity) == "flight-level record") "Flights" else "Airport/carrier/month records"
ggplot(delay_values, aes(dep_delay_minutes)) + geom_histogram(bins = 40, fill = "steelblue") +
  labs(title = plot_title, x = plot_x, y = plot_y)
ggsave("output/figures/departure_delay_histogram.png", width = 8, height = 5, dpi = 300)
