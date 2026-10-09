# SeasonalAdj Shared Core v1.0 - prueba de regresion contra Gas Core v1.0.
# Ejecutar desde la raiz del repositorio DESPUES de haber guardado el RDS
# anterior en modules/gas/tests/reference/gas_core_v1.rds.
# No estima ni sobrescribe resultados.
ref_path <- "modules/gas/tests/reference/gas_core_v1.rds"
new_path <- "modules/gas/outputs/gas_run.rds"
if (!file.exists(ref_path)) stop("Falta referencia previa: ", ref_path,
  "\nRecuperar el gas_run.rds producido por Gas Core v1.0 ANTES de ejecutar Shared Core.")
if (!file.exists(new_path)) stop("Falta resultado Shared Core: ", new_path)
if (!requireNamespace("seasonal", quietly = TRUE)) stop("Falta seasonal")
old <- readRDS(ref_path); new <- readRDS(new_path)
ids <- sprintf("gas%02d", 1:10)
stopifnot(identical(names(old$series), ids), identical(names(new$series), ids),
          identical(names(old$models), ids), identical(names(new$models), ids))
check <- list(); i <- 0L
for (id in ids) {
  for (component in c("original", "d11", "d12")) {
    i <- i + 1L
    a <- if (component == "original") old$series[[id]] else seasonal::series(old$models[[id]], component)
    b <- if (component == "original") new$series[[id]] else seasonal::series(new$models[[id]], component)
    same_window <- identical(as.numeric(stats::time(a)), as.numeric(stats::time(b)))
    same_n <- length(a) == length(b)
    finite <- !anyNA(a) && !anyNA(b) && all(is.finite(a)) && all(is.finite(b))
    max_abs <- if (same_n && finite) max(abs(as.numeric(a) - as.numeric(b))) else NA_real_
    # Objetivo: igualdad exacta dentro de la misma instalacion R/X-13.
    exact <- same_n && same_window && finite && identical(as.numeric(a), as.numeric(b))
    check[[i]] <- data.frame(series = id, component = component,
                             same_length = same_n, same_dates = same_window,
                             max_absolute_difference = max_abs, exact = exact)
  }
}
report <- do.call(rbind, check)
print(report, row.names = FALSE)
cat("\nComparaciones identicas:", sum(report$exact), "de", nrow(report), "\n")
if (!all(report$exact)) stop("REGRESSION FAILED: revisar diferencias antes de fusionar")
message("Shared Core vs Gas Core v1.0: PASSED (30/30 exact comparisons)")
