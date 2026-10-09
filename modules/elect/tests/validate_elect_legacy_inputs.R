# Ejecutar desde modules/elect mediante scripts/validate_elect_inputs.R
source(file.path("..", "..", "R", "load_core.R"))
sa_load_core(repo_root = file.path("..", ".."), envir = environment())
catalog <- read.csv("config/elect_series.csv", stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8")
file <- file.path("..", "..", "09- Electricidad.xlsx")
if (!file.exists(file)) file <- file.path("data", "raw", "09- Electricidad.xlsx")
if (!file.exists(file)) stop("Excel faltante: 09- Electricidad.xlsx")
results <- lapply(seq_len(nrow(catalog)), function(i) {
  item <- catalog[i, ]
  old <- as.numeric(readxl::read_excel(file, sheet = item$sheet, range = item$legacy_range,
                                      col_names = FALSE, .name_repair = "minimal")[[1]])
  now <- read_sa_sheet(file, item$sheet, item$date_col, item$value_col)$series
  expected <- ts(old, start = c(item$legacy_start_year, item$legacy_start_month), frequency = 12)
  len_ok <- length(old) == length(now)
  dates_ok <- len_ok && identical(as.numeric(time(expected)), as.numeric(time(now)))
  max_rel <- if (len_ok && !anyNA(old) && !anyNA(now))
    max(abs(old - as.numeric(now)) / pmax(abs(old), 1)) else NA_real_
  data.frame(series = item$series_id, sheet = item$sheet,
             n_legacy = length(old), n_new = length(now),
             dates_ok = dates_ok, max_relative_difference = max_rel,
             passed = len_ok && dates_ok && is.finite(max_rel) && max_rel <= 1e-12)
})
report <- do.call(rbind, results)
print(report, row.names = FALSE)
dir.create("outputs/validation", recursive = TRUE, showWarnings = FALSE)
write.csv(report, "outputs/validation/elect_legacy_inputs.csv", row.names = FALSE)
cat("Entradas históricas equivalentes:", sum(report$passed), "de", nrow(report), "\n")
if (!all(report$passed)) stop("No ejecutar X-11 hasta corregir diferencias en fechas/datos")
