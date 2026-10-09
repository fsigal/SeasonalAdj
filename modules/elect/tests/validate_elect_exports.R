library(readxl)
library(seasonal)
x <- readRDS("outputs/elect_run.rds")
checks <- list()
for (id in names(x$models)) {
  cmp <- list(d11 = seasonal::series(x$models[[id]], "d11"),
              d12 = seasonal::series(x$models[[id]], "d12"))
  ref11 <- as.numeric(cmp$d11); ref12 <- as.numeric(cmp$d12)
  for (type in c("d11", "d12", "d11_d12", "dated")) {
    path <- file.path("outputs", if (type == "dated") "dated" else "legacy",
                      paste0(id, "_", type, ".xlsx"))
    if (!file.exists(path)) stop("Archivo ausente: ", path)
    tab <- readxl::read_excel(path)
    if (type %in% c("d11", "d12")) {
      expected <- if (type == "d11") ref11 else ref12
      ok <- ncol(tab) == 1L && length(tab[[1]]) == length(expected) &&
        isTRUE(all.equal(as.numeric(tab[[1]]), expected, tolerance = 1e-10))
    } else if (type == "d11_d12") {
      ok <- ncol(tab) == 4L && nrow(tab) == length(ref11) &&
        all(is.na(tab[[2]])) && all(is.na(tab[[3]])) &&
        isTRUE(all.equal(as.numeric(tab[[1]]), ref11, tolerance = 1e-10)) &&
        isTRUE(all.equal(as.numeric(tab[[4]]), ref12, tolerance = 1e-10))
    } else {
      tt <- time(cmp$d11); years <- floor(as.numeric(tt) + 1e-7)
      months <- round((as.numeric(tt) - years) * 12) + 1L
      dates <- as.Date(sprintf("%04d-%02d-01", years, months))
      ok <- identical(names(tab), c("date", "d11", "d12")) && nrow(tab) == length(ref11) &&
        identical(as.Date(tab$date), dates) &&
        isTRUE(all.equal(as.numeric(tab$d11), ref11, tolerance = 1e-10)) &&
        isTRUE(all.equal(as.numeric(tab$d12), ref12, tolerance = 1e-10))
    }
    checks[[length(checks) + 1L]] <- data.frame(series = id, file = type, passed = ok)
  }
}
report <- do.call(rbind, checks)
print(report, row.names = FALSE)
dir.create("outputs/validation", recursive = TRUE, showWarnings = FALSE)
write.csv(report, "outputs/validation/elect_exports.csv", row.names = FALSE)
cat("Exportaciones válidas:", sum(report$passed), "de", nrow(report), "\n")
if (!all(report$passed)) stop("Fallaron verificaciones de exportaciones")
