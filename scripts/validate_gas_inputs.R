if (!file.exists(file.path("modules", "gas", "tests", "validate_gas_legacy_inputs.R"))) {
  stop("Ejecutar desde la raíz del repositorio SeasonalAdj")
}
local({
  original_wd <- getwd()
  on.exit(setwd(original_wd), add = TRUE)
  setwd(file.path("modules", "gas"))
  source(file.path("tests", "validate_gas_legacy_inputs.R"), local = TRUE)
})
