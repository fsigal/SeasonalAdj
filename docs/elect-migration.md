# Migración elect.R — auditoría v0.1

Fuente: `elect.R` de la rama principal de SeasonalAdj, consultado el 9 de octubre de 2026.

- 12 entradas Excel, 12 llamadas idénticas `seas(x, x11 = "")`.
- 36 exportaciones históricas (12 archivos con D11/D12 y 24 individuales).
- El script depende de `blanco` (objeto no definido localmente) para dos columnas vacías. Shared Core no requiere esa variable global.
- No hay ARIMA auxiliares explícitos ni pronósticos independientes en este script.
- A/B (fecha/valor) es configuración provisional, **no está verificada con el Excel**.
- El enlace público al libro `09- Electricidad.xlsx` no resultó accesible al preparar esta versión. Se requiere libro local para completar tests.
- El período final no se presupone: el comentario de importación dice julio de 2026, pero los rangos fijos de elect04/elect05/elect07/elect08/elect10/elect11 tienen 175 observaciones, equivalentes a 2012-01 a 2026-07.
- En Gas se usaron pruebas de consistencia y de equivalencia. Aquí se aplican separadamente a importación y X-11.
