# Auxiliary forecasts: intentionally independent from the validated X-11 core.
publication_months <- c(3L, 5L, 7L, 9L, 12L)

month_index <- function(year_month) {
  if (length(year_month) != 2L || anyNA(year_month) ||
      year_month[1L] < 1900 || year_month[2L] < 1 || year_month[2L] > 12 ||
      any(year_month != as.integer(year_month))) stop("Invalid year/month")
  as.integer(year_month[1L] * 12L + year_month[2L] - 1L)
}

last_observation <- function(x) {
  if (!stats::is.ts(x) || stats::frequency(x) != 12L || !length(x) ||
      anyNA(x) || any(!is.finite(x))) stop("Expected a complete, finite monthly ts")
  e <- stats::end(x)
  c(year = as.integer(e[1L]), month = as.integer(e[2L]))
}

next_target <- function(last, months = publication_months) {
  month_index(last)
  months <- sort(unique(as.integer(months)))
  if (!length(months) || anyNA(months) || any(months < 1L | months > 12L))
    stop("Invalid publication months")
  remaining <- months[months > last[2L]]
  if (length(remaining)) return(c(year = as.integer(last[1L]), month = remaining[1L]))
  c(year = as.integer(last[1L] + 1L), month = months[1L])
}

months_between <- function(last, target) month_index(target) - month_index(last)

parse_target_month <- function(target, months = publication_months) {
  if (is.character(target) && length(target) == 1L &&
      grepl("^[0-9]{4}-(0[1-9]|1[0-2])$", target)) {
    target <- c(as.integer(substr(target, 1, 4)), as.integer(substr(target, 6, 7)))
  }
  month_index(target)
  if (!as.integer(target[2L]) %in% months) stop("Target is not a publication month")
  setNames(as.integer(target), c("year", "month"))
}

# Build a plan without estimating models; explicit target applies to all series.
plan_gas_forecasts <- function(series_list, target = NULL,
                               mode = c("target", "legacy_h3"),
                               months = publication_months) {
  mode <- match.arg(mode)
  if (!length(series_list) || is.null(names(series_list)) ||
      anyNA(names(series_list)) || any(!nzchar(names(series_list))) ||
      anyDuplicated(names(series_list))) stop("Named series_list required")
  if (mode == "target" && is.null(target))
    stop("Specify target='YYYY-MM' for the publication; no implicit publication date")
  if (!is.null(target)) target <- parse_target_month(target, months)
  out <- lapply(names(series_list), function(id) {
    last <- last_observation(series_list[[id]])
    h <- if (mode == "legacy_h3") 3L else months_between(last, target)
    if (mode == "target" && h < 0L)
      stop(id, ": last observation is later than publication target")
    data.frame(series_id = id, last_year = unname(last[1L]),
               last_month = unname(last[2L]),
               target_year = if (is.null(target)) NA_integer_ else unname(target[1L]),
               target_month = if (is.null(target)) NA_integer_ else unname(target[2L]),
               horizon = as.integer(h),
               action = if (h == 0L) "skipped" else "forecast", stringsAsFactors = FALSE)
  })
  do.call(rbind, out)
}

# Injectable fit/forecast functions allow isolated unit tests without fitting ARIMA.
run_conditional_forecasts <- function(series_list, target = NULL,
                                      mode = c("target", "legacy_h3"),
                                      fit_fun = forecast::auto.arima,
                                      forecast_fun = forecast::forecast) {
  mode <- match.arg(mode)
  plan <- plan_gas_forecasts(series_list, target = target, mode = mode)
  out <- setNames(vector("list", nrow(plan)), plan$series_id)
  for (i in seq_len(nrow(plan))) {
    p <- plan[i, ]
    if (p$action == "skipped") {
      out[[p$series_id]] <- list(status = "skipped", horizon = 0L,
                                  reason = "Last observation reaches requested cutoff")
    } else {
      fit <- fit_fun(series_list[[p$series_id]])
      fc <- forecast_fun(fit, h = p$horizon)
      out[[p$series_id]] <- list(status = "forecasted", horizon = p$horizon,
                                  model = fit, forecast = fc)
    }
  }
  list(plan = plan, results = out, mode = mode, target = target)
}

# Uses same sheet-aware date parser as standard gas data; no fixed Excel ranges.
read_gas_forecast_series <- function(file, catalog) {
  read_gas_series(file, catalog)
}
