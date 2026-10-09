# Test de calendario puro (no necesita Excel).
source("R/import_gas.R")
stopifnot(identical(parse_gas_month(c("2024-01", "2024-02")),
                    as.Date(c("2024-01-01", "2024-02-01"))))
stopifnot(identical(parse_gas_month(as.Date("2024-05-31")),
                    as.Date("2024-05-01")))
message("Parsing dates: PASSED")
