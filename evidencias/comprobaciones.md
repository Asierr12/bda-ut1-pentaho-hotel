# Tabla de comprobaciones — paquete A011 (`cierre_aula_01`)

Columna **Esperado**: resultados de referencia de la práctica.
Columna **Obtenido**: métricas de pasos (W = filas escritas) y salidas de la ejecución con Kitchen del 25/11/2026 (`logs/prueba1_primera_ejecucion.log` y `salida/`).

| # | Comprobación | Dónde se mira | Esperado | Obtenido | ¿OK? |
|---|---|---|---|---|---|
| 1 | Filas leídas de `reservas_pdi.csv` | *Step metrics* de "Leer reservas" | 20, sin errores de conversión | 20 (W=20), E=0 | ✅ |
| 2 | Filas leídas de `cobros_pdi.csv` | "Leer cobros" | 15, sin errores | 15 (W=15), E=0 | ✅ |
| 3 | Filas leídas de `hoteles_pdi.csv` | "Leer hoteles" | 5, sin errores | 5 (W=5), E=0 | ✅ |
| 4 | Filas tras unir reservas y cobros (INNER) | "Unir reservas y cobros (INNER)" | 15 | 15 | ✅ |
| 5 | Filas tras añadir hoteles | "Añadir hotel (INNER)" | 15 | 15 | ✅ |
| 6 | Filas del informe (sin cabecera) | `salida/informe_hotel_canal.csv` | 13 | 13 | ✅ |
| 7 | Suma de `n_reservas` | log de `validar_informe` | 15 | 15 | ✅ |
| 8 | Suma de `cobrado_total` | log de `validar_informe` | 3965.50 | 3965.5 | ✅ |
| 9 | Laredo, web | fila del informe | 2 reservas, 496.50 | 2 reservas, 496.50 | ✅ |
| 10 | Filas tras LEFT OUTER reservas-cobros | "Unir reservas con cobros (LEFT OUTER)" | 20 | 20 | ✅ |
| 11 | Reservas sin cobro | `salida/reservas_sin_cobro.csv` | 5: ids 4, 9, 11, 15, 18 | 5: ids 4, 9, 11, 15, 18 | ✅ |
| 12 | Reconciliación | 11 + 6 | 15 + 5 = 20 | 15 + 5 = 20 | ✅ |
| 13 | Contraste por grupo con la tabla del taller 2 | tabla de abajo | coinciden los 13 grupos | coinciden los 13 grupos | ✅ |

## Informe por grupo (esperado con los datos de A011)

Se ha calculado independientemente de Pentaho, sumando a mano los cobros del paquete A011 (también en `evidencias/referencia/`). La última columna se ha contrastado con la tabla «Resultado de referencia del taller 2» de la web de la asignatura (https://iesataulfoargentasor.github.io/bda_2026_2027/ut1/pentaho/#resultado-de-referencia-del-taller-2): coinciden los 13 grupos, las 15 reservas y los 3965.50 €.

| hotel | canal | n_reservas | cobrado_total | Obtenido | ¿Coincide con el taller 2? |
|---|---|---|---|---|---|
| Comillas | ota | 1 | 132.00 | igual | ✅ sí |
| Comillas | recepcion | 1 | 525.00 | igual | ✅ sí |
| Comillas | web | 2 | 642.00 | igual | ✅ sí |
| Laredo | ota | 1 | 124.00 | igual | ✅ sí |
| Laredo | web | 2 | 496.50 | igual | ✅ sí |
| Noja | ota | 1 | 195.00 | igual | ✅ sí |
| Noja | web | 1 | 280.00 | igual | ✅ sí |
| Potes | ota | 1 | 260.00 | igual | ✅ sí |
| Potes | recepcion | 1 | 201.00 | igual | ✅ sí |
| Potes | web | 1 | 150.00 | igual | ✅ sí |
| Santander | ota | 1 | 390.00 | igual | ✅ sí |
| Santander | recepcion | 1 | 410.00 | igual | ✅ sí |
| Santander | web | 1 | 160.00 | igual | ✅ sí |
| **Total** | | **15** | **3965.50** | 15 / 3965.50 | ✅ sí |

## Reservas sin cobro (esperado)

| id_reserva | hotel | canal | importe (precio de la reserva) |
|---|---|---|---|
| 4 | Santander | web | 89.90 |
| 9 | Noja | ota | 140.00 |
| 11 | Laredo | recepcion | 72.00 |
| 15 | Noja | recepcion | 268.00 |
| 18 | Potes | ota | 70.00 |
