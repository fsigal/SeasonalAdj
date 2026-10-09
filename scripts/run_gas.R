# Execute from SeasonalAdj repository root. Keep legacy gas.R unchanged.
if (!file.exists(file.path("modules", "gas", "scripts", "run_gas.R"))) {
  stop("Ejecutar desde la raíz del repositorio SeasonalAdj")
}
local({
  original_wd <- getwd()
  on.exit(setwd(original_wd), add = TRUE)
  setwd(file.path("modules", "gas"))
  source(file.path("scripts", "run_gas.R"), local = TRUE)
})
