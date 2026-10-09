# Cargar el núcleo compartido desde la raíz de SeasonalAdj.
sa_load_core <- function(repo_root = ".", envir = parent.frame()) {
  repo_root <- normalizePath(repo_root, mustWork = TRUE)
  files <- file.path(repo_root, "R", c("import_monthly_excel.R", "x11.R", "export_x11.R"))
  if (!all(file.exists(files))) stop("Faltan funciones del núcleo compartido en: ", repo_root)
  for (f in files) sys.source(f, envir = envir)
  invisible(files)
}
