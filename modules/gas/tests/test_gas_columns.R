# Test unitario sin archivo Excel: verifica el contrato de columnas del catálogo.
catalog <- utils::read.csv("config/gas_series.csv", stringsAsFactors = FALSE)
stopifnot(nrow(catalog) == 10L)
stopifnot(all(catalog$date_col == 1L))
stopifnot(identical(catalog$value_col[catalog$series_id == "gas10"], 4L))
stopifnot(all(catalog$value_col[catalog$series_id != "gas10"] == 2L))
message("Catálogo: gas10 A/D; demás series A/B: OK")
