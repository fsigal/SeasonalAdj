# Execute from project root. This does not call or overwrite X-11 outputs.
# REQUIRED: set publication_target below to the period stakeholders need.
publication_target <- "2026-09"  # Example only: change explicitly for each publication.
forecast_mode <- "target"        # Alternative "legacy_h3" for historical h=3.

needed <- c("readxl", "forecast")
missing <- needed[!vapply(needed, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Install packages: ", paste(missing, collapse = ", "))
source("R/import_gas.R")
source("R/forecast_gas.R")
input_file <- "data/raw/10- Consumo de gas.xlsx"
catalog <- utils::read.csv("config/gas_forecast_series.csv", stringsAsFactors = FALSE)
stopifnot(!"gas11" %in% catalog$series_id,
          !"Total Servicios" %in% catalog$sheet)
available <- readxl::excel_sheets(input_file)
missing_sheets <- setdiff(catalog$sheet, available)
if (length(missing_sheets)) stop("Auxiliary sheet(s) not found: ",
  paste(missing_sheets, collapse=", "),
  ". Validate sources before forecasting; X-11 remains unchanged.")
aux <- read_gas_forecast_series(input_file, catalog)
plan <- plan_gas_forecasts(aux,
                           target = if (forecast_mode == "target") publication_target else NULL,
                           mode = forecast_mode)
print(plan, row.names = FALSE)
# Only execute the model fitting if the plan is acceptable.
run <- run_conditional_forecasts(aux,
                                 target = if (forecast_mode == "target") publication_target else NULL,
                                 mode = forecast_mode)
dir.create("outputs/forecasts", recursive = TRUE, showWarnings = FALSE)
utils::write.csv(run$plan, "outputs/forecasts/gas_aux_plan.csv", row.names = FALSE)
saveRDS(list(run = run, catalog = catalog, session = utils::sessionInfo()),
        "outputs/forecasts/gas_aux_forecasts.rds")
# Export all forecast horizons as dated rows in a single CSV, including intervals.
rows <- lapply(names(run$results), function(id) {
  item <- run$results[[id]]
  if (item$status != "forecasted") return(NULL)
  p <- run$plan[run$plan$series_id == id, ]
  idx <- (p$last_year * 12 + p$last_month - 1L) + seq_len(item$horizon)
  d <- as.Date(sprintf("%04d-%02d-01", idx %/% 12, idx %% 12 + 1L))
  fc <- item$forecast
  out <- data.frame(series_id = id, date = d, mean = as.numeric(fc$mean))
  if (!is.null(fc$lower)) for (j in seq_len(ncol(fc$lower))) {
    pct <- colnames(fc$lower)[j]
    out[[paste0("lower_", pct)]] <- as.numeric(fc$lower[, j])
    out[[paste0("upper_", pct)]] <- as.numeric(fc$upper[, j])
  }
  out
})
rows <- Filter(Negate(is.null), rows)
if (length(rows)) utils::write.csv(do.call(rbind, rows),
    "outputs/forecasts/gas_aux_predictions.csv", row.names = FALSE)
cat("Auxiliary forecasts completed. X-11 models were not modified.\n")
