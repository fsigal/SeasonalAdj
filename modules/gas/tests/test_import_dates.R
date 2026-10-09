# Test de fechas preservado después de mover el importador al núcleo compartido.
# Ejecutar desde modules/gas (igual que la prueba original).
source(file.path("..", "..", "R", "load_core.R"))
sa_load_core(file.path("..", ".."), envir = environment())
# Test de calendario puro (no necesita Excel).
source("R/import_gas.R")
stopifnot(identical(parse_gas_month(c("2024-01", "2024-02")),
                    as.Date(c("2024-01-01", "2024-02-01"))))
stopifnot(identical(parse_gas_month(as.Date("2024-05-31")),
                    as.Date("2024-05-01")))
message("Parsing dates: PASSED")
