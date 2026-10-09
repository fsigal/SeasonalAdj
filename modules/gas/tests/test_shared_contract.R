# Ejecutar desde raíz del repositorio: source("modules/gas/tests/test_shared_contract.R")
source("R/load_core.R")
sa_load_core(envir = environment())
source("modules/gas/R/import_gas.R")
source("modules/gas/R/adjust_gas.R")
source("modules/gas/R/export_gas.R")
catalog <- utils::read.csv("modules/gas/config/gas_series.csv", stringsAsFactors = FALSE)
stopifnot(nrow(catalog) == 10L,
          identical(catalog$series_id, sprintf("gas%02d", 1:10)),
          identical(as.integer(catalog$value_col), c(rep(2L, 9L), 4L)),
          identical(parse_gas_month(c("2024-01", "2024-02")),
                    parse_sa_month(c("2024-01", "2024-02"))))
# Las llamadas de compatibilidad apuntan al núcleo común.
stopifnot(identical(body(run_gas_adjustment),
                    body(function(series_list) sa_adjust_x11(series_list))))
message("Shared core / Gas compatibility: PASSED")
