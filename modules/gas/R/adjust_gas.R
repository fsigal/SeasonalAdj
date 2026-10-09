# Compatibilidad con la API histórica de Gas: delegación al núcleo común.
run_gas_adjustment <- function(series_list) sa_adjust_x11(series_list)
extract_gas_components <- function(model) sa_extract_x11(model)
# Ajuste X-11 de las diez series operativas. No utiliza pronósticos externos.
run_gas_adjustment <- function(series_list) {
  lapply(series_list, function(x) seasonal::seas(x, x11 = ""))
}

extract_gas_components <- function(model) {
  list(d11 = seasonal::series(model, "d11"),
       d12 = seasonal::series(model, "d12"))
}
