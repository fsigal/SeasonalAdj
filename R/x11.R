# Núcleo reutilizable de X-11. La opción x11 = "" preserva Gas Core v1.0.
sa_adjust_x11 <- function(series_list) {
  if (!is.list(series_list) || !length(series_list) ||
      is.null(names(series_list)) || any(!nzchar(names(series_list))) ||
      anyDuplicated(names(series_list))) {
    stop("series_list debe ser una lista nombrada, no vacía y sin IDs duplicados")
  }
  if (!all(vapply(series_list, function(x) inherits(x, "ts"), logical(1))))
    stop("Todas las series deben ser objetos ts")
  lapply(series_list, function(x) seasonal::seas(x, x11 = ""))
}

sa_extract_x11 <- function(model) {
  list(d11 = seasonal::series(model, "d11"),
       d12 = seasonal::series(model, "d12"))
}
