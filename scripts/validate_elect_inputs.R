if (!file.exists("modules/elect/tests/validate_elect_legacy_inputs.R")) stop("Ejecutar desde la raíz")
local({
  wd <- getwd(); on.exit(setwd(wd), add = TRUE)
  setwd("modules/elect")
  source("tests/validate_elect_legacy_inputs.R", local = TRUE)
})
