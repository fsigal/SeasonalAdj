# Prueba automatizada de exportaciones y alineación temporal; no reestima modelos.
# Ejecutar desde la raíz del proyecto: source("tests/validate_gas_exports.R")
required <- c("readxl", "seasonal")
missing <- required[!vapply(required, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing)) stop("Faltan paquetes: ", paste(missing, collapse = ", "))
path <- "outputs/gas_run.rds"
if (!file.exists(path)) stop("No existe ", path, ". Ejecutar scripts/run_gas.R")
run <- readRDS(path)
ids <- sprintf("gas%02d", 1:10)
if (!setequal(names(run$models), ids) || !setequal(names(run$series), ids))
  stop("Deben existir exactamente gas01...gas10 en series y models")

near <- function(actual, expected, tolerance = 1e-10) {
  is.numeric(actual) && length(actual) == length(expected) &&
    !anyNA(actual) && all(is.finite(actual)) &&
    isTRUE(all.equal(unname(as.numeric(actual)), unname(as.numeric(expected)),
                     tolerance = tolerance, check.attributes = FALSE))
}

monthly_dates <- function(x) {
  tt <- as.numeric(stats::time(x))
  y <- floor(tt + 1e-7)
  m <- round((tt - y) * 12) + 1L
  as.Date(sprintf("%04d-%02d-01", y, m))
}

read_date_column <- function(x) {
  if (inherits(x, "Date")) return(x)
  if (inherits(x, "POSIXt")) return(as.Date(x))
  if (is.numeric(x)) return(as.Date(x, origin = "1899-12-30"))
  as.Date(as.character(x))
}

results <- list()
add_check <- function(id, type, values_ok, dates_ok = NA, structure_ok = TRUE,
                      detail = "") {
  passed <- isTRUE(values_ok) && isTRUE(structure_ok) &&
    (is.na(dates_ok) || isTRUE(dates_ok))
  results[[length(results) + 1L]] <<- data.frame(
    series = id, file = type, values_ok = isTRUE(values_ok),
    dates_ok = if (is.na(dates_ok)) NA else isTRUE(dates_ok),
    structure_ok = isTRUE(structure_ok), passed = passed,
    detail = detail, stringsAsFactors = FALSE)
}

for (id in ids) {
  model <- run$models[[id]]
  d11 <- seasonal::series(model, "d11")
  d12 <- seasonal::series(model, "d12")
  v11 <- as.numeric(d11); v12 <- as.numeric(d12)
  expected_dates <- monthly_dates(d11)
  series_dates <- monthly_dates(run$series[[id]])
  if (!identical(expected_dates, series_dates) ||
      !identical(monthly_dates(d12), series_dates))
    stop(id, ": fechas de componentes y serie original no coinciden")

  for (comp in c("d11", "d12")) {
    fn <- file.path("outputs", "legacy", paste0(id, "_", comp, ".xlsx"))
    if (!file.exists(fn)) stop("Archivo inexistente: ", fn)
    tab <- readxl::read_excel(fn)
    expected <- if (comp == "d11") v11 else v12
    add_check(id, comp, ncol(tab) == 1L && near(tab[[1]], expected),
              structure_ok = ncol(tab) == 1L &&
                tolower(names(tab)[1]) == comp,
              detail = basename(fn))
  }

  fn_comb <- file.path("outputs", "legacy", paste0(id, "_d11_d12.xlsx"))
  if (!file.exists(fn_comb)) stop("Archivo inexistente: ", fn_comb)
  combined <- readxl::read_excel(fn_comb)
  structure_comb <- ncol(combined) == 4L &&
    identical(tolower(names(combined)), c("d11", "blank_1", "blank_2", "d12"))
  val_comb <- structure_comb && near(combined[[1]], v11) &&
    near(combined[[4]], v12) && all(is.na(combined[[2]])) &&
    all(is.na(combined[[3]]))
  add_check(id, "d11_d12", val_comb, structure_ok = structure_comb,
            detail = basename(fn_comb))

  fn_dated <- file.path("outputs", "dated", paste0(id, "_dated.xlsx"))
  if (!file.exists(fn_dated)) stop("Archivo inexistente: ", fn_dated)
  dated <- readxl::read_excel(fn_dated)
  structure_dated <- ncol(dated) == 3L &&
    identical(tolower(names(dated)), c("date", "d11", "d12"))
  date_ok <- FALSE
  val_dated <- FALSE
  if (structure_dated) {
    actual_dates <- tryCatch(read_date_column(dated[[1]]), error = function(e) as.Date(NA))
    date_ok <- length(actual_dates) == length(expected_dates) &&
      !anyNA(actual_dates) && identical(as.Date(actual_dates), expected_dates)
    val_dated <- near(dated[[2]], v11) && near(dated[[3]], v12)
  }
  add_check(id, "dated", val_dated, dates_ok = date_ok,
            structure_ok = structure_dated, detail = basename(fn_dated))
}

report <- do.call(rbind, results)
print(report[, c("series", "file", "values_ok", "dates_ok", "structure_ok", "passed")],
      row.names = FALSE)
cat("\nArchivos validados:", sum(report$passed), "de", nrow(report), "\n")
dir.create("outputs/validation", recursive = TRUE, showWarnings = FALSE)
utils::write.csv(report, "outputs/validation/gas_export_validation.csv", row.names = FALSE)
if (!all(report$passed)) stop("Fallaron ", sum(!report$passed), " verificaciones. Ver informe CSV")
message("Exportaciones y fechas comprobadas; pendiente comparación histórica independiente")
