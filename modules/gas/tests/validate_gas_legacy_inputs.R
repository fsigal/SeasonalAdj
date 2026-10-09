# Historical input comparison against exact fixed Excel ranges in original gas.R.
# Run from modules/gas working directory after run_gas.R.
if (!requireNamespace("readxl", quietly = TRUE)) stop("Instalar readxl")
run_path <- file.path("outputs", "gas_run.rds")
if (!file.exists(run_path)) stop("Falta outputs/gas_run.rds")
run <- readRDS(run_path)
file <- file.path("..", "..", "10- Consumo de gas.xlsx")
if (!file.exists(file)) file <- file.path("data", "raw", "10- Consumo de gas.xlsx")
if (!file.exists(file)) stop("Falta el libro Excel")
sheets <- c("Res_C", "Res_SF", "Res_ER", "Ind_C", "Ind_SF", "Ind_ER",
            "Total_C", "Total_ER", "Total_SF", "TOTAL_ER_2")
ranges <- c("B5:B407", "B5:B407", "B5:B323", "B5:B407", "B5:B407",
            "B5:B323", "B3:B405", "B3:B321", "B3:B405", "D2:D320")
report <- do.call(rbind, lapply(seq_along(sheets), function(i) {
  id <- sprintf("gas%02d", i)
  old <- as.numeric(readxl::read_excel(file, sheet=sheets[i], range=ranges[i],
               col_names=FALSE, .name_repair="minimal")[[1]])
  new <- as.numeric(run$series[[id]])
  same_n <- length(old) == length(new)
  max_rel <- if (same_n && !anyNA(old) && !anyNA(new))
    max(abs(old - new) / pmax(abs(old), 1)) else Inf
  data.frame(series=id, same_length=same_n, max_relative_difference=max_rel,
             passed=is.finite(max_rel) && max_rel < 1e-12)
}))
print(report, row.names=FALSE)
dir.create(file.path("outputs","validation"), recursive=TRUE, showWarnings=FALSE)
write.csv(report, file.path("outputs","validation","gas_legacy_inputs.csv"), row.names=FALSE)
if (!all(report$passed)) stop("Diferencias con los rangos históricos; investigar")
cat("Entradas históricas validadas: ",sum(report$passed)," de ",nrow(report),"\n",sep="")
