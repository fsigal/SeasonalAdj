# Ejecutar desde modules/elect, después de validar inputs y run_elect.
library(seasonal)
catalog <- read.csv("config/elect_series.csv", stringsAsFactors = FALSE, check.names = FALSE, fileEncoding = "UTF-8")
new <- readRDS("outputs/elect_run.rds")
file <- file.path("..", "..", "09- Electricidad.xlsx")
if (!file.exists(file)) file <- "data/raw/09- Electricidad.xlsx"
stopifnot(file.exists(file))
rows <- lapply(seq_len(nrow(catalog)), function(i) {
  r <- catalog[i, ]; id <- r$series_id
  old_data <- as.numeric(readxl::read_excel(file, sheet = r$sheet, range = r$legacy_range,
                        col_names = FALSE, .name_repair = "minimal")[[1]])
  old_ts <- ts(old_data, start = c(r$legacy_start_year, r$legacy_start_month), frequency = 12)
  old_model <- seasonal::seas(old_ts, x11 = "")
  do.call(rbind, lapply(c("d11", "d12"), function(component) {
    a <- seasonal::series(old_model, component)
    b <- seasonal::series(new$models[[id]], component)
    same_dates <- length(a) == length(b) && identical(as.numeric(time(a)), as.numeric(time(b)))
    max_abs <- if (length(a) == length(b)) max(abs(as.numeric(a) - as.numeric(b))) else NA_real_
    data.frame(series = id, component = component, same_dates = same_dates,
               max_absolute_difference = max_abs,
               passed = same_dates && is.finite(max_abs) && max_abs <= 1e-8)
  }))
})
report <- do.call(rbind, rows)
print(report, row.names = FALSE)
dir.create("outputs/validation", recursive = TRUE, showWarnings = FALSE)
write.csv(report, "outputs/validation/elect_x11_comparison.csv", row.names = FALSE)
cat("Componentes X-11 equivalentes:", sum(report$passed), "de", nrow(report), "\n")
if (!all(report$passed)) stop("Diferencias en X-11: revisar modelos y versiones")
