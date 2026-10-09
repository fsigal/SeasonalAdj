# Ajuste X-11 de las diez series operativas. No utiliza pronósticos externos.
run_gas_adjustment <- function(series_list) {
  lapply(series_list, function(x) seasonal::seas(x, x11 = ""))
}

extract_gas_components <- function(model) {
  list(d11 = seasonal::series(model, "d11"),
       d12 = seasonal::series(model, "d12"))
}
