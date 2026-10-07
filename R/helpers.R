# Shared helpers for STAT 562 Project 1

required_packages <- c("tidyverse", "lubridate", "broom", "data.table")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace,
                                                logical(1), quietly = TRUE)]
if (length(missing_packages) > 0) {
  stop("Install required packages: ", paste(missing_packages, collapse = ", "))
}

library(tidyverse)
library(lubridate)
library(broom)

dir.create("output/figures", recursive = TRUE, showWarnings = FALSE)
dir.create("output/tables", recursive = TRUE, showWarnings = FALSE)
dir.create("output/results", recursive = TRUE, showWarnings = FALSE)
dir.create("data/cleaned", recursive = TRUE, showWarnings = FALSE)

read_clean_data <- function() {
  path <- "data/cleaned/flights_cleaned.rds"
  if (!file.exists(path)) stop("Run R/01_data_cleaning.R first.")
  readRDS(path)
}

read_daily_data <- function() {
  path <- "data/cleaned/daily_delays.rds"
  if (!file.exists(path)) stop("Run R/01_data_cleaning.R first.")
  readRDS(path)
}

write_result <- function(object, name) {
  write_csv(as_tibble(object), file.path("output/results", name))
}

set.seed(analysis_config$random_seed)
