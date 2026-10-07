# Data provenance and schema

## Dataset used for the redo

- Local input filename: `flight_delays.csv`
- User-provided source file: `flights_sample_3m.csv`
- Source file path at project setup: `/Users/reesefarquharson/Downloads/archive/flights_sample_3m.csv`
- Input rows: 3,000,000
- Unit of observation: one scheduled flight record
- Flight date field: `FL_DATE`
- Departure-delay field: `DEP_DELAY` (minutes)
- Additional retained identifiers: airline, origin, destination, flight number,
  cancellation status, and diversion status

The original download URL and publisher should be added here before submission;
this project does not infer or invent one.

## Analysis path

`R/01_data_cleaning.R` detects this file as **flight-level** data, normalizes
`FL_DATE` to `fl_date` and `DEP_DELAY` to `dep_delay`, and excludes records with
missing dates or departure delays. It then constructs genuine daily intervals.
The exact post-cleaning row count, date range, and calendar check are written to
`output/tables/preprocessing_summary.csv` each time the project runs.

## Aggregate-input limitation

The cleaner can recognize an airport/carrier/month aggregate input with
`year`, `month`, `arr_flights`, `arr_del15`, and `arr_delay`. That is a distinct
schema: `arr_del15` counts arrival delays of at least 15 minutes, and `arr_delay`
is total arrival-delay minutes. It must not be described as daily departure data
or used to establish individual delays over 30 minutes. The redo outputs are not
produced from that aggregate pathway.
