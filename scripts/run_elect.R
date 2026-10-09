# Ejecutar desde la raíz de SeasonalAdj.
if (!file.exists(file.path("modules", "elect", "scripts", "run_elect.R")))
  stop("Ejecutar desde la raíz de SeasonalAdj")
local({
  original_wd <- getwd()
  on.exit(setwd(original_wd), add = TRUE)
  setwd(file.path("modules", "elect"))
  source(file.path("scripts", "run_elect.R"), local = TRUE)
})
