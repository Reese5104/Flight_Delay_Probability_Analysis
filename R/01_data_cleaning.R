script_file <- tryCatch(sys.frame(1)$ofile, error = function(e) NULL)
if (is.null(script_file) || !nzchar(script_file)) script_file <- sub("^--file=", "", commandArgs(FALSE)[grepl("^--file=", commandArgs(FALSE))][1])
source(file.path(dirname(normalizePath(script_file)), "bootstrap.R"))

raw_path <- "data/raw/flight_delays.csv"
if (!file.exists(raw_path)) {
  stop("Place a real CSV dataset at data/raw/flight_delays.csv before running.")
}

# Read only analysis fields. This keeps the 3-million-row input runnable on a
# typical student laptop while preserving the exact source file and schema.
raw_header <- data.table::fread(raw_path, nrows = 0, showProgress = FALSE)
original_names <- names(raw_header)
raw_names <- names(raw_header) |> str_to_lower() |> str_replace_all("[^a-z0-9]+", "_") |> str_remove("_$")
names(raw_header) <- raw_names

# Recognize either flight-level records or BTS-style airport/carrier/month aggregates.
date_candidates <- c("flight_date", "fl_date", "date", "departure_date")
delay_candidates <- c("dep_delay", "departure_delay", "departure_delay_minutes")
date_col <- intersect(date_candidates, raw_names)[1]
delay_col <- intersect(delay_candidates, raw_names)[1]
is_aggregate <- all(c("year", "month", "arr_flights", "arr_del15", "arr_delay") %in% raw_names)
selected_columns <- if (is_aggregate) {
  c("year", "month", "arr_flights", "arr_del15", "arr_delay", "carrier", "airport")
} else {
  unique(c(date_col, delay_col, "airline", "origin", "dest", "fl_number", "cancelled", "diverted"))
}
selected_columns <- selected_columns[selected_columns %in% raw_names]
selected_source_columns <- original_names[match(selected_columns, raw_names)]
flights_raw <- as_tibble(data.table::fread(raw_path, select = selected_source_columns, showProgress = FALSE))
names(flights_raw) <- names(flights_raw) |> str_to_lower() |> str_replace_all("[^a-z0-9]+", "_") |> str_remove("_$")
rows_raw <- nrow(flights_raw)

# Inspect the exact fields used by the analysis before exclusions.
print(dim(flights_raw)); print(head(flights_raw)); glimpse(flights_raw)
write_csv(enframe(colSums(is.na(flights_raw)), name = "variable", value = "missing_count"),
          "output/tables/missing_values_raw.csv")
duplicate_key <- c(date_col, "airline", "origin", "dest", "fl_number")
duplicate_key <- duplicate_key[!is.na(duplicate_key) & duplicate_key %in% names(flights_raw)]
duplicate_key_text <- paste(duplicate_key, collapse = ", ")
duplicate_key_rows <- if (length(duplicate_key) > 0) sum(duplicated(select(flights_raw, all_of(duplicate_key)))) else NA_integer_
write_csv(tibble(duplicate_key = duplicate_key_text, duplicate_key_rows = duplicate_key_rows),
          "output/tables/duplicate_rows_raw.csv")

if (is_aggregate) {
  # This file is aggregated by airport, carrier, and month. `arr_del15` counts
  # arrival delays of 15+ minutes; `arr_delay` is total delay minutes.
  flights_cleaned <- flights_raw |>
    mutate(
      flight_date = make_date(as.integer(year), as.integer(month), 1L),
      total_flights = as.numeric(arr_flights),
      delay_flight_count = as.numeric(arr_del15),
      dep_delay_minutes = if_else(delay_flight_count > 0, as.numeric(arr_delay) / delay_flight_count, NA_real_),
      delayed = NA, delay_over_30 = NA, data_granularity = "airport-carrier-month aggregate",
      observation_unit = "month"
    ) |>
    filter(!is.na(flight_date), !is.na(total_flights), !is.na(delay_flight_count),
           total_flights >= 0, delay_flight_count >= 0, delay_flight_count <= total_flights) |>
    distinct()
  date_col <- "year + month"; delay_col <- "arr_del15 (arrival delays of 15+ minutes)"
} else {
  if (is.na(date_col) || is.na(delay_col)) {
    stop("This file lacks both flight-level date/delay columns and the recognized BTS aggregate schema. See data/raw/DATA_SOURCE.md and update the candidate names if needed.")
  }
  flights_cleaned <- flights_raw |>
    transmute(
      flight_date = suppressWarnings(ymd(.data[[date_col]])),
      dep_delay_minutes = as.numeric(.data[[delay_col]]),
      airline = if ("airline" %in% names(flights_raw)) .data[["airline"]] else NA_character_,
      origin = if ("origin" %in% names(flights_raw)) .data[["origin"]] else NA_character_,
      destination = if ("dest" %in% names(flights_raw)) .data[["dest"]] else NA_character_,
      flight_number = if ("fl_number" %in% names(flights_raw)) .data[["fl_number"]] else NA_real_,
      delayed = !is.na(dep_delay_minutes) & dep_delay_minutes > analysis_config$delayed_flight_threshold_minutes,
      delay_over_30 = !is.na(dep_delay_minutes) & dep_delay_minutes > analysis_config$major_delay_threshold_minutes,
      total_flights = 1, delay_flight_count = as.numeric(delayed), data_granularity = "flight-level record",
      observation_unit = "day"
    ) |>
    filter(!is.na(flight_date), !is.na(dep_delay_minutes))
}

# The raw file can be large. All later work uses only the compact cleaned schema.
rm(flights_raw)
invisible(gc())

daily_delays <- flights_cleaned |>
  group_by(flight_date) |>
  summarise(
    flights = sum(total_flights), delayed_flights = sum(delay_flight_count),
    daily_delay_rate = delayed_flights / flights,
    daily_major_delay_rate = if (is_aggregate) NA_real_ else mean(delay_over_30),
    .groups = "drop"
  ) |>
  mutate(
    over_three_delays = delayed_flights > 3,
    high_delay_day = daily_delay_rate > analysis_config$binomial_daily_delay_rate_threshold,
    major_delay_day = daily_major_delay_rate >= analysis_config$geometric_daily_major_delay_rate_threshold
  )

saveRDS(flights_cleaned, "data/cleaned/flights_cleaned.rds")
saveRDS(daily_delays, "data/cleaned/daily_delays.rds")
write_csv(daily_delays, "data/cleaned/daily_delays.csv")
calendar <- tibble(flight_date = seq(min(daily_delays$flight_date), max(daily_delays$flight_date), by = "day"))
write_csv(tibble(rows_raw = rows_raw, rows_cleaned = nrow(flights_cleaned),
                 date_column = date_col, delay_column = delay_col,
                 granularity = first(flights_cleaned$data_granularity),
                 observation_unit = first(flights_cleaned$observation_unit),
                 first_observation = as.character(min(daily_delays$flight_date)),
                 last_observation = as.character(max(daily_delays$flight_date)),
                 observed_intervals = nrow(daily_delays), calendar_intervals = nrow(calendar),
                 complete_daily_calendar = nrow(daily_delays) == nrow(calendar),
                 delayed_definition = paste0("DEP_DELAY > ", analysis_config$delayed_flight_threshold_minutes, " minutes"),
                 geometric_definition = paste0("daily proportion of flights with DEP_DELAY > ", analysis_config$major_delay_threshold_minutes,
                                                " minutes is at least ", analysis_config$geometric_daily_major_delay_rate_threshold)),
          "output/tables/preprocessing_summary.csv")
