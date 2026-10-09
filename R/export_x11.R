# Exportación compartida; preserva diseño y nombres de Gas Core v1.0.
# Preserva nombres y orden: gas01_d11_d12.xlsx, gas01_d11.xlsx, etc.
# Las dos columnas centrales son vacías (NA) en lugar de un objeto global 'blanco'.
sa_export_x11_legacy <- function(models, output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  for (id in names(models)) {
    cmp <- sa_extract_x11(models[[id]])
    d11 <- as.numeric(cmp$d11)
    d12 <- as.numeric(cmp$d12)
    if (length(d11) != length(d12)) stop(id, ": longitudes D11/D12 distintas")
    combined <- data.frame(d11 = d11, blank_1 = rep(NA_real_, length(d11)),
                           blank_2 = rep(NA_real_, length(d11)), d12 = d12)
    writexl::write_xlsx(combined, file.path(output_dir, paste0(id, "_d11_d12.xlsx")))
    writexl::write_xlsx(data.frame(d11 = d11),
                        file.path(output_dir, paste0(id, "_d11.xlsx")))
    writexl::write_xlsx(data.frame(d12 = d12),
                        file.path(output_dir, paste0(id, "_d12.xlsx")))
  }
  invisible(output_dir)
}

sa_export_x11_dated <- function(models, output_dir) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  for (id in names(models)) {
    cmp <- sa_extract_x11(models[[id]])
    tt <- stats::time(cmp$d11)
    years <- floor(as.numeric(tt) + 1e-7)
    months <- round((as.numeric(tt) - years) * 12) + 1L
    dat <- data.frame(date = as.Date(sprintf("%04d-%02d-01", years, months)),
                      d11 = as.numeric(cmp$d11), d12 = as.numeric(cmp$d12))
    writexl::write_xlsx(dat, file.path(output_dir, paste0(id, "_dated.xlsx")))
  }
  invisible(output_dir)
}
