# Adaptadores para compatibilidad con Gas Core v1.0.
# Cargar primero R/load_core.R mediante el ejecutor sectorial.
parse_gas_month <- function(x) parse_sa_month(x)
read_gas_sheet <- function(file, sheet, date_col = 1L, value_col = 2L) {
  read_sa_sheet(file, sheet, date_col, value_col)
}
read_gas_series <- function(file, catalog) read_sa_series(file, catalog)
