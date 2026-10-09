# Ejecutar SOLO después de guardar resultados originales en tests/reference_gas.rds.
# Debe contener lista nombrada gas01..gas10 con d11 y d12 por serie.
source("scripts/run_gas.R")
ref_path <- "tests/reference_gas.rds"
if (!file.exists(ref_path)) stop("Falta baseline del script original: ", ref_path)
ref <- readRDS(ref_path)
for (id in names(models)) {
  stopifnot(id %in% names(ref))
  cmp <- extract_gas_components(models[[id]])
  for (component in c("d11", "d12")) {
    old <- ref[[id]][[component]]
    now <- cmp[[component]]
    if (!identical(stats::tsp(old), stats::tsp(now)))
      stop(id, " ", component, ": fechas/frecuencia distintas")
    if (!isTRUE(all.equal(as.numeric(old), as.numeric(now), tolerance = 1e-8)))
      stop(id, " ", component, ": diferencia estadística detectada")
  }
}
message("D11/D12 coinciden con baseline dentro de tolerancia 1e-8")
