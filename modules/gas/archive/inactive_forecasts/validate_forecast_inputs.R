# Validate actual workbook sheets before attempting optional forecasts.
# Total Servicios / gas11 is intentionally excluded.
library(readxl)
source("R/import_gas.R")
source("R/forecast_gas.R")
input_file <- "data/raw/10- Consumo de gas.xlsx"
catalog <- read.csv("config/gas_forecast_series.csv", stringsAsFactors = FALSE)
stopifnot(!"gas11" %in% catalog$series_id,
          !"Total Servicios" %in% catalog$sheet)
available <- readxl::excel_sheets(input_file)
status <- data.frame(series_id = catalog$series_id,
                     requested_sheet = catalog$sheet,
                     exists = catalog$sheet %in% available)
print(status, row.names = FALSE)
if (!all(status$exists)) {
  cat("Available workbook sheets:\n")
  print(available)
  stop("Auxiliary sources not yet mapped. Confirm exact sheets/data sources; no forecast was fitted.")
}
aux <- read_gas_forecast_series(input_file, catalog)
print(data.frame(series_id = names(aux),
                 first = vapply(aux, function(x) paste(start(x), collapse = "-"), character(1)),
                 last = vapply(aux, function(x) paste(end(x), collapse = "-"), character(1)),
                 n = vapply(aux, length, integer(1))), row.names = FALSE)
cat("Sources loaded. Numerical comparison with historic inputs still pending.\n")
