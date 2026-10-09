# Ejecución regular: importación -> X-11 -> exportación. Sin pronósticos ARIMA.
required <- c("readxl", "writexl", "seasonal")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Instalar paquetes: ", paste(missing, collapse = ", "))
# Este script se ejecuta desde modules/gas, según scripts/run_gas.R.
source(file.path("..", "..", "R", "load_core.R"))
sa_load_core(repo_root = file.path("..", ".."), envir = environment())
source("R/import_gas.R")
source("R/adjust_gas.R")
source("R/export_gas.R")
# Prefer the original workbook already tracked at the repository root.
input_file <- file.path("..", "..", "10- Consumo de gas.xlsx")
if (!file.exists(input_file)) {
  input_file <- file.path("data", "raw", "10- Consumo de gas.xlsx")
}
if (!file.exists(input_file)) {
  stop("Excel no encontrado: coloque 10- Consumo de gas.xlsx en la raíz del repositorio o modules/gas/data/raw/")
}
catalog <- utils::read.csv("config/gas_series.csv", stringsAsFactors = FALSE,
                           check.names = FALSE, fileEncoding = "UTF-8")
series_list <- read_gas_series(input_file, catalog)
message("Importadas ", length(series_list), " series de gas")
models <- run_gas_adjustment(series_list)
dir.create("outputs", showWarnings = FALSE)
saveRDS(list(series = series_list, models = models, catalog = catalog,
             session = utils::sessionInfo()), "outputs/gas_run.rds")
export_gas_legacy(models, "outputs/legacy")
export_gas_dated(models, "outputs/dated")
message("Ajuste X-11 generado en outputs/ (sin pronósticos)")
