# SeasonalAdj — núcleo compartido v1

La implementación compartida reside en `R/` del repositorio. `modules/gas/R/` mantiene adaptadores de compatibilidad, no duplicaciones de algoritmos.

## Interfaz

```r
source("R/load_core.R")
sa_load_core()
catalog <- read.csv("modules/gas/config/gas_series.csv")
series <- read_sa_series("10- Consumo de gas.xlsx", catalog)
models <- sa_adjust_x11(series)
sa_export_x11_legacy(models, "modules/gas/outputs/legacy")
sa_export_x11_dated(models, "modules/gas/outputs/dated")
```

`read_sa_sheet(file, sheet, date_col, value_col)` devuelve `list(series, data)`; `read_sa_series(file, catalog)` devuelve una lista nombrada de `ts` mensuales. Cada fila del catálogo define `series_id`, `sheet`, `date_col`, `value_col`; la fecha está en una columna configurable y los valores en otra. El módulo de Gas mantiene su columna D excepcional en `gas10`.

`sa_adjust_x11()` realiza exclusivamente `seasonal::seas(x, x11 = "")`; no incluye pronósticos auxiliares. `sa_extract_x11()` extrae D11/D12. Los exportadores conservan el formato Gas validado: columnas `d11, blank_1, blank_2, d12` y archivos individuales con encabezados, o `date,d11,d12` en los fechados.

## Compatibilidad y límites

El soporte compartido actual es **mensual**. Los sectores trimestrales, como `finan.R`, requerirán una extensión explícita y pruebas adicionales. No se modifica la configuración X-13, ni se generaliza en esta etapa la selección RegARIMA, calendarios, regresores o tratamientos excepcionales.

Este paquete es un overlay incremental: no contiene ni debe sobrescribir el `gas.R` histórico, el Excel original ni `ILCE.R`. Requiere `readxl`, `seasonal`, `writexl` y X-13 disponible. La comparación numérica histórica ya se había realizado sobre Gas Core v1; debe repetirse después de cambiar el código por estos adaptadores.

## Regresión

Desde la raíz del repositorio:

```r
source("modules/gas/tests/test_shared_contract.R")
source("scripts/run_gas.R")
source("scripts/validate_gas.R")
source("scripts/validate_gas_inputs.R")
```

**Criterio de aceptación:** 10/10 entradas y 40/40 exportaciones validadas; asimismo, comparar los componentes nuevos frente al `gas_run.rds` previo si se conservó un snapshot, antes de sobrescribir el resultado anterior. En la secuencia anterior, `run_gas.R` sobreescribe el RDS; guardá una copia primero si querés comparar con el snapshot. No se ejecutaron tests R en el entorno donde se generó este overlay.
