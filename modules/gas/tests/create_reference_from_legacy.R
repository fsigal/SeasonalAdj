# USAR EN UNA SESIÓN R DONDE YA ESTÉN DEFINIDOS gas01d ... gas10d
# por ejecución del código original. No recalcula los modelos.
# Importante: el gas.R público falla con gas11-13 sin definir, por lo que
# se debe ejecutar hasta antes del bloque ARIMA no definido, o ejecutar
# expresamente sus líneas de ajuste X-11 sobre los objetos gas01 ... gas10.
ids <- sprintf("gas%02d", 1:10)
legacy <- setNames(lapply(ids, function(id) {
  name <- paste0(id, "d")
  if (!exists(name, inherits = TRUE)) stop("No existe ", name)
  m <- get(name, inherits = TRUE)
  list(d11 = seasonal::series(m, "d11"), d12 = seasonal::series(m, "d12"))
}), ids)
saveRDS(legacy, "tests/reference_gas.rds")
message("Baseline original guardado en tests/reference_gas.rds")
