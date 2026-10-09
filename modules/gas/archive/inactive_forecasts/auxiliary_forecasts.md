# Auxiliary gas forecasts: scope and validation

The legacy `gas.R` (GitHub main, 2026-10-09) comments out imports of `gas11`, `gas12`, `gas13` but invokes `auto.arima()` and `forecast(h=3)` on them. Its forecast output is not fed to X-11. This module is therefore **separate** and does not alter the validated gas01–gas10 outputs.

## Rules

- The user must specify a publication cutoff (`YYYY-MM`) among March/May/July/September/December. Example `2026-09`.
- If a series ends before that cutoff: fit `forecast::auto.arima()` to the observed series and generate only the missing months.
- If it ends on the cutoff: skip estimation; the observed data already cover the cutoff.
- If it ends after the cutoff: **error**, rather than retrospectively fitting to information unavailable at that date.
- `legacy_h3` always fits `auto.arima()` and forecasts 3 months (historic procedure), even if the last month is a publication cutoff. This is intentionally different from the target mode.
- A selected cutoff is the **target observation month**, not necessarily the month when reports are delivered. Consult the stakeholders to confirm this meaning.
- Auxiliary forecasts are NOT inserted into gas01–gas10 or X-11, and must never be described as observed data.

## Run

1. Put the workbook in `data/raw/10- Consumo de gas.xlsx`.
2. Run `source("tests/test_forecast_calendar.R")`.
3. Run `source("tests/validate_forecast_inputs.R")` and check the three dates/ranges before approving their use.
4. Edit `publication_target` in `scripts/run_gas_forecasts.R` to the desired cutoff; then run `source("scripts/run_gas_forecasts.R")`.
5. Review `outputs/forecasts/gas_aux_plan.csv`, `gas_aux_predictions.csv`, `gas_aux_forecasts.rds`.

## Historic equivalence: open work

For each gas11–gas13, compare original range values to imported data **by month**; inspect any differences. Under a frozen `forecast`/R version, compare `auto.arima()` orders, coefficients and `forecast(h=3)` paths against the legacy procedure. A different target horizon is a methodological extension, not equivalence.

## Excel layout assumption to verify

The catalog currently assumes date column A and value column B in auxiliary sheets, as supplied for the main sheets. The source script provides fixed ranges B6:B390 and B5:B385 but no date-column configuration. The user must check the actual period and time coverage of these auxiliary sheets before production use.

## v0.7 correction
`Total Servicios` (`gas11`) is outside the current workflow: no import, forecast, X-11, or export. The entries for `gas12`/`gas13` are provisional until their Excel source sheets and historical correspondence are confirmed. The forecast runner fails safely if sheets are missing.
