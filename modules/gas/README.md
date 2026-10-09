# Gas — seasonal adjustment (X-11)

Production module for 10 monthly natural-gas consumption series from Argentina's Región Centro.

- Data: one Excel sheet per series; dates in A; values in B except `gas10`, whose values are in D.
- Models: `seasonal::seas(x, x11 = "")` (unchanged from the historical `gas.R`).
- Outputs: D11 (seasonally adjusted) and D12 (trend-cycle); 40 Excel files plus RDS.
- Excluded from current processing: Total Servicios, Residencial and Industria (`model11`–`model13`); historical code archived, **not executed**.

From the **repository root**:

```r
install.packages(c("readxl", "writexl", "seasonal", "x13binary"))
seasonal::checkX13()
source("scripts/run_gas.R")
source("scripts/validate_gas.R")
source("scripts/validate_gas_inputs.R")
```

If the original workbook is not at the repository root, place it at `modules/gas/data/raw/10- Consumo de gas.xlsx`.

Generated outputs live in `modules/gas/outputs/` and are not committed. See `docs/gas-integration.md`.
