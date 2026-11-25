# Pruebas obligatorias

**Entorno de ejecución:** PDI 9.4.0.0-343 (instalación `pdi-ce-9.4.0.0-343` del equipo) con `pan.sh` y `kitchen.sh` sobre OpenJDK 11.0.33, en el entorno Linux del equipo `pcasier`. Fecha: 25/11/2026.
Por eso las rutas de los logs empiezan por `/sessions/.../repo/`, que es la copia de trabajo del repositorio; todas las rutas de los procesos son relativas.
Las ejecuciones las lanzó el asistente de IA (ver "Fuentes y ayudas" en el README) con el script de pruebas descrito en cada apartado. Los CSV originales de `entrada/` no se modificaron en ningún momento.

Códigos de salida: 0 = éxito, 1 = terminado con errores.

| # | Prueba | Esperado | Obtenido | Conclusión | Log |
|---|---|---|---|---|---|
| 1 | Primera ejecución sin informes previos | Dos salidas correctas y éxito final | Kitchen rc=0; `CIERRE OK`; informe con 13 filas y listado con 5 filas | ✅ Correcta | `logs/prueba1_primera_ejecucion.log` |
| 2 | Repetición con las mismas entradas | Mismos grupos, filas y totales, sin duplicados | rc=0; 13 y 5 filas; archivos idénticos byte a byte a los de la prueba 1 (md5 47422c06 y a0ca3980) | ✅ No acumula filas | `logs/prueba2_repeticion.log` |
| 3 | Falta una entrada | Job con error y sin publicar | rc=1; se para en *Abort: falta cobros_pdi.csv*; no se ejecuta ninguna transformación; `salida/` sin cambios | ✅ No publica | `logs/prueba3_falta_entrada.log` |
| 4a | Informe provisional solo con cabecera (solo `validar_informe`) | Error | rc=1; fila de resumen `[0], [null], [null]` enviada a *Informe no válido* → `VALIDACION FALLIDA` | ✅ Detecta salida vacía | `logs/prueba4a_informe_solo_cabecera.log` |
| 4b | Listado provisional solo con cabecera (solo `validar_sin_cobro`) | Error | rc=1; resumen `[0], [null]` → *Número de filas incorrecto* | ✅ Detecta salida vacía | `logs/prueba4b_sin_cobro_solo_cabecera.log` |
| 5 | Total incorrecto (Laredo web 496.50 → 496.00, solo `validar_informe`) | Error | rc=1; resumen `[13], [15], [3965.0]` frente a 3965.5 → `VALIDACION FALLIDA` | ✅ Detecta el total erróneo | `logs/prueba5_total_incorrecto.log` |
| 6 | Recuperación: restaurar y ejecutar el job completo | Salidas regeneradas, publicadas y correctas | rc=0; `CIERRE OK`; salidas idénticas a las de la prueba 1 | ✅ Se recupera | `logs/prueba6_recuperacion.log` |

---

## Detalle

### Prueba 1: primera ejecución
- **Pasos:** vaciar `salida/` y `temporal/` y ejecutar `kitchen.sh -file=procesos/cierre_hotel.kjb -level=Basic`.
- **Obtenido:** se ejecutan todas las entradas del job en orden. El log muestra `VALIDACION OK ... 13 grupos, 15 reservas y 3965.50 EUR` (n_grupos = 13, suma_n_reservas = 15, suma_cobrado = 3965.5) y `VALIDACION OK ... 5 reservas (4, 9, 11, 15, 18) sin duplicados`, se hacen las dos copias y aparece `CIERRE OK`.
- **Métricas de pasos:** Leer reservas W=20, Leer cobros W=15, Leer hoteles W=5, Unir reservas y cobros (INNER) W=15, Añadir hotel (INNER) W=15, Agrupar W=13. En `reservas_sin_cobro`, Unir reservas con cobros (LEFT OUTER) W=20 y el filtro deja 5.

### Prueba 2: repetición
- **Pasos:** sin borrar nada, ejecutar otra vez el job.
- **Obtenido:** rc=0. Las dos salidas tienen las mismas filas y los mismos totales, y la comparación byte a byte (`cmp`) con las de la prueba 1 no muestra diferencias. Solo cambia la hora de modificación, porque se sobrescriben y no se añaden filas.

### Prueba 3: falta una entrada
- **Pasos:** se copió el proyecto entero a otra carpeta (`prueba3/`) y en **la copia** se borró `entrada/cobros_pdi.csv`. Después se ejecutó el job de la copia.
- **Obtenido:** `¿Existe reservas_pdi.csv?` da OK, `¿Existe cobros_pdi.csv?` da falso y salta *Abort: falta cobros_pdi.csv* con el mensaje "ERROR: falta la entrada entrada/cobros_pdi.csv. No se genera ni se publica el informe." Kitchen termina con "Finished with errors". No se llega a ejecutar ninguna transformación ni ninguna copia: la `salida/` de la copia conserva los archivos anteriores, iguales a los de la prueba 2.

### Prueba 4: salida incompleta
- **Pasos:** se guardó una copia de seguridad de los provisionales, se dejó solo la cabecera y se ejecutó **solo** la validación con Pan (el job completo regeneraría el archivo). Después se restauró el provisional.
- **Obtenido:** gracias a "Always give back a result row", el resumen devuelve una fila aunque no haya datos: en el informe 0 grupos con sumas nulas y en el listado 0 identificadores. Esa fila va al *Abort* y Pan termina con errores. `salida/` no cambia.

### Prueba 5: total incorrecto
- **Pasos:** en `temporal/informe_hotel_canal.csv` se cambió `Laredo;web;2;496.50` por `Laredo;web;2;496.00` y se ejecutó solo `validar_informe.ktr`.
- **Obtenido:** suma_cobrado = 3965.0, distinta de 3965.5, así que el filtro da falso, se lanza *Abort* y Pan termina con errores. `salida/` no cambia: las fechas de modificación son las de la prueba 2.

### Prueba 6: recuperación
- **Pasos:** se borraron los provisionales manipulados y se ejecutó el job completo.
- **Obtenido:** rc=0. Se regeneran `temporal/`, se valida, se publica y aparece `CIERRE OK`. Las salidas son idénticas a las de la prueba 1.

## Ejecución en Windows con `ejecutar_cierre.bat`

Además de las seis pruebas, el 25/11/2026 se lanzó el job en Windows con doble clic sobre `ejecutar_cierre.bat`, que llama a `Kitchen.bat` de la instalación de PDI 9.4 del equipo.

- **Resultado:** `RESULTADO: CIERRE OK - informes publicados en salida\`. Todas las entradas del job terminan con `result=[true]`.
- **Comprobación:** los CSV publicados son idénticos byte a byte a los de la prueba 1 (mismo md5).
- **Log:** `logs/ejecucion_windows.log`, convertido a UTF-8. El log original de Kitchen se escribe en la codificación de Windows.

## Conclusión general

Los errores de entrada (prueba 3) y de validación (pruebas 4 y 5) impiden publicar. En todos esos casos `salida/` conservó el último informe válido sin cambios. Repetir la ejecución no acumula filas (prueba 2) y, al restaurar los datos, el job vuelve a publicar exactamente el mismo resultado (prueba 6).

La rama de fallo durante la copia (aviso de posible estado parcial) no se ha provocado, porque el enunciado no lo pide entre las seis pruebas.
