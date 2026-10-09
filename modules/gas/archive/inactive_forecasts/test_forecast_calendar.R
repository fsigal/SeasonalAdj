# Independent synthetic tests: do not need the real Excel nor model fitting.
source("R/forecast_gas.R")
stopifnot(identical(next_target(c(2026L, 7L)), c(year=2026L, month=9L)))
stopifnot(months_between(c(2026L, 7L), c(2026L, 9L)) == 2L)
stopifnot(months_between(c(2026L, 12L), c(2027L, 3L)) == 3L)
x <- stats::ts(seq_len(43), start = c(2023, 1), frequency = 12) # ends 2026-07
series <- list(gas12=x, gas13=x)
p <- plan_gas_forecasts(series, target="2026-09")
stopifnot(nrow(p)==2L, all(p$horizon == 2L), all(p$action == "forecast"))
p0 <- plan_gas_forecasts(series, target="2026-07")
stopifnot(all(p0$action == "skipped"), all(p0$horizon == 0L))
p3 <- plan_gas_forecasts(series, mode="legacy_h3")
stopifnot(all(p3$horizon == 3L))
err <- try(plan_gas_forecasts(series, target="2026-05"), silent=TRUE)
stopifnot(inherits(err,"try-error"))
err <- try(plan_gas_forecasts(series, target="2026-08"), silent=TRUE)
stopifnot(inherits(err,"try-error"))
# Mock estimators: verify requested horizons and no execution when not required.
calls <- integer()
mock_fit <- function(z) {calls <<- c(calls, 1L); list(dummy=TRUE)}
mock_forecast <- function(fit, h) {calls <<- c(calls, as.integer(h)); list(mean=seq_len(h))}
r <- run_conditional_forecasts(series, target="2026-09", fit_fun=mock_fit,
                                forecast_fun=mock_forecast)
stopifnot(all(vapply(r$results,function(z) z$horizon, integer(1))==2L),
          identical(calls,rep(c(1L,2L),2L)))
calls <- integer()
r0 <- run_conditional_forecasts(series, target="2026-07", fit_fun=mock_fit,
                                 forecast_fun=mock_forecast)
stopifnot(!length(calls), all(vapply(r0$results,function(z) z$status,character(1))=="skipped"))
message("Forecast calendar / isolation / horizon tests: PASSED")
