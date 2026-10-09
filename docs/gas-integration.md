# Gas migration: integration & regression contract

## Scope

`gas.R` in the repository root remains untouched as a historical reference. The active, refactored workflow is `scripts/run_gas.R`, which invokes the namespaced module at `modules/gas/`.

### Data contract

| Series | Sheet | Date column | Value column | First month |
|---|---|---|---|---|
| gas01 | Res_C | A | B | 1993-01 |
| gas02 | Res_SF | A | B | 1993-01 |
| gas03 | Res_ER | A | B | 2000-01 |
| gas04 | Ind_C | A | B | 1993-01 |
| gas05 | Ind_SF | A | B | 1993-01 |
| gas06 | Ind_ER | A | B | 2000-01 |
| gas07 | Total_C | A | B | 1993-01 |
| gas08 | Total_ER | A | B | 2000-01 |
| gas09 | Total_SF | A | B | 1993-01 |
| gas10 | TOTAL_ER_2 | A | D | 2000-01 |

Dates are taken from Excel, not hard-coded terminal row offsets. Missing months, duplicates, non-finite values and out-of-order dates are rejected.

### Regression evidence, original environment (2026-10-09)

- 10 series: 403 observations (1993-01 through 2026-07) or 319 (2000-01 through 2026-07).
- 10 X-11 model runs and 20 D11/D12 components with correct dimensions.
- 40 Excel files passed checks for component values, layout and date alignment.
- Comparison with old fixed-cell Excel inputs: six exact, four within relative tolerance 1e-12. Largest observed relative difference `2.281378e-15` (gas09).
- Calls to `seas(x, x11="")` matched refactored X-11 components exactly in the same environment.

These results were reported from RStudio by the project maintainer. They do **not** constitute an independent original-script run, and the integration overlay itself still needs to be run after applying to the main repository.

### How to run

From the main repository root:

```r
source("scripts/run_gas.R")
source("scripts/validate_gas.R")
source("scripts/validate_gas_inputs.R")
```

Outputs: `modules/gas/outputs/{legacy,dated}/` and `modules/gas/outputs/gas_run.rds`; validation CSVs in `modules/gas/outputs/validation/`.

### Scope exclusions

Historical `model11`, `model12`, `model13` (Total Servicios, Residencial, Industria) are inactive. Their code is preserved under `modules/gas/archive/inactive_forecasts/` only. `gas.R` remains unchanged during the migration. `ILCE.R` and other sector scripts remain unchanged until their dependencies on gas exports are mapped.

### CI / reproducibility

Do not automatically run models in CI until X-13 version, dependencies and a redistributable reference fixture have been pinned. Capture `sessionInfo()` in saved RDS; introduce `renv.lock` separately after validation in maintainer's environment.
