# Electricidad — módulo candidato v0.1

Migración controlada de `elect.R` al Shared Core. No reemplaza el script original.

## Inventario
- 12 series (`elect01`–`elect12`), importadas desde `09- Electricidad.xlsx`.
- Ajustes: exclusivamente `seasonal::seas(x, x11 = "")`.
- Salidas: 36 archivos heredados (12 combinados + 24 individuales) y 12 fechados.
- Rango original y fecha inicial de cada serie en `config/elect_series.csv`.
- Las columnas de fecha A y valor B son **hipótesis pendientes de validar con Excel**. Si el libro tiene otra disposición, cambiar únicamente el catálogo tras inspeccionarlo.

## Uso desde la raíz del repositorio

```r
source("scripts/validate_elect_inputs.R")  # REQUERIDO primero
source("scripts/run_elect.R")
source("scripts/validate_elect_x11.R")
```

`validate_elect_inputs.R` compara el nuevo importador con los rangos originales y sus fechas. Se detiene si hay diferencias. `validate_elect_x11.R` reestima los 12 modelos a partir de rangos históricos independientes y compara D11/D12; es una comprobación adicional y no sustituye conservar resultados de una ejecución histórica antigua.

**No ejecutar `elect.R` original completo:** utiliza el objeto externo `blanco`. La comparación se hace mediante sus rangos y especificaciones, sin tocar el script original.

Los resultados se guardan en `modules/elect/outputs/`. No versionar salidas ni datos internos sin revisar permisos de distribución.
