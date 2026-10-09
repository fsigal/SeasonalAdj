# Importación por fecha usando Shared Core. Sin cambios en R/.
read_elect_series <- function(file, catalog) {
  stopifnot(exists("read_sa_series", mode = "function"))
  read_sa_series(file, catalog)
}
