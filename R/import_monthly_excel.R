# Funciones reutilizables: importación de series mensuales desde Excel.
# Extraído de Gas Core v1.0; no modifica el algoritmo de lectura validado.
# Importación basada en fechas: una hoja por serie, columna 1 = mes,
# columna de valor configurable por catálogo (gas10 = D).
parse_sa_month <- function(x) {
  if (inherits(x, "POSIXt") || inherits(x, "Date")) {
    d <- as.Date(x)
    return(as.Date(format(d, "%Y-%m-01")))
  }
  x <- trimws(as.character(x))
  out <- as.Date(rep(NA_character_, length(x)))
  blank <- is.na(x) | !nzchar(x)
  # YYYY-MM, YYYY/MM, YYYY-MM-DD (interpretamos siempre el mes)
  iso <- !blank & grepl("^[0-9]{4}[-/][0-9]{1,2}([-/][0-9]{1,2})?$", x)
  if (any(iso)) {
    parts <- strsplit(gsub("/", "-", x[iso]), "-", fixed = TRUE)
    out[iso] <- as.Date(vapply(parts, function(p) sprintf("%04d-%02d-01", as.integer(p[1]), as.integer(p[2])), character(1)))
  }
  # Fechas serializadas de Excel; readxl suele devolverlas como datetime.
  serial <- !blank & !iso & grepl("^[0-9]{4,5}(\\.[0-9]+)?$", x)
  if (any(serial)) out[serial] <- as.Date(as.numeric(x[serial]), origin = "1899-12-30")
  # Formato DD/MM/YYYY o DD-MM-YYYY (primero día, luego mes).
  dmy <- !blank & !iso & !serial & grepl("^[0-9]{1,2}[-/][0-9]{1,2}[-/][0-9]{4}$", x)
  if (any(dmy)) {
    tmp <- as.Date(gsub("-", "/", x[dmy]), format = "%d/%m/%Y")
    out[dmy] <- tmp
  }
  out[!is.na(out)] <- as.Date(format(out[!is.na(out)], "%Y-%m-01"))
  out
}

read_sa_sheet <- function(file, sheet, date_col = 1L, value_col = 2L) {
  date_col <- as.integer(date_col); value_col <- as.integer(value_col)
  if (anyNA(c(date_col, value_col)) || any(c(date_col, value_col) < 1L) || date_col == value_col)
    stop(sheet, ": columnas de fecha/valor inválidas")
  if (!sheet %in% readxl::excel_sheets(file)) stop("Hoja inexistente: ", sheet)
  raw <- readxl::read_excel(file, sheet = sheet, col_names = FALSE,
                             col_types = "list", .name_repair = "minimal")
  if (ncol(raw) < max(date_col, value_col)) stop(sheet, ": no existen las columnas solicitadas")
  # Los encabezados quedan excluidos porque la primera celda no es una fecha.
  date_cells <- raw[[date_col]]
  value_cells <- raw[[value_col]]
  # Para preservar las fechas Excel, convertir Date/POSIX antes de serializar.
  dates <- as.Date(rep(NA_character_, length(date_cells)))
  for (j in seq_along(date_cells)) dates[j] <- parse_sa_month(date_cells[[j]])[1]
  # Evitar interpretar códigos de otras filas como fechas válidas sin valores.
  values <- suppressWarnings(as.numeric(vapply(value_cells, function(z)
    if (length(z)==0 || is.na(z[1])) NA_character_ else as.character(z[1]), character(1))))
  present <- !is.na(dates)
  if (!any(present)) stop(sheet, ": no se encontraron meses válidos en la primera columna")
  if (anyNA(values[present]) || any(!is.finite(values[present])))
    stop(sheet, ": valores faltantes o no numéricos en meses identificados")
  # Las filas con valores, pero sin fecha, fuera del encabezado son sospechosas.
  first <- which(present)[1L]; last <- tail(which(present), 1L)
  if (any(!present[first:last])) stop(sheet, ": fecha no reconocida entre observaciones")
  dates <- dates[present]; values <- values[present]
  if (anyDuplicated(dates)) stop(sheet, ": meses duplicados")
  order_idx <- order(dates)
  if (!identical(order_idx, seq_along(dates))) stop(sheet, ": fechas desordenadas")
  if (length(dates) > 1L) {
    expected <- seq(dates[1L], by = "month", length.out = length(dates))
    if (!identical(dates, expected)) stop(sheet, ": faltan meses intermedios")
  }
  sy <- as.integer(format(dates[1L], "%Y")); sm <- as.integer(format(dates[1L], "%m"))
  list(series = stats::ts(values, start = c(sy, sm), frequency = 12),
       data = data.frame(date = dates, value = values))
}

read_sa_series <- function(file, catalog) {
  if (!file.exists(file)) stop("No se encontró el Excel: ", file)
  stopifnot(all(c("series_id", "sheet") %in% names(catalog)))
  if (anyDuplicated(catalog$series_id)) stop("series_id duplicados")
  if (!"date_col" %in% names(catalog)) catalog$date_col <- 1L
  if (!"value_col" %in% names(catalog)) catalog$value_col <- 2L
  result <- setNames(vector("list", nrow(catalog)), catalog$series_id)
  for (i in seq_len(nrow(catalog))) {
    result[[i]] <- read_sa_sheet(file, catalog$sheet[i], catalog$date_col[i], catalog$value_col[i])$series
  }
  result
}
