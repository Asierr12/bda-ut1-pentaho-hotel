# bda-ut1-pentaho-hotel — Informe del hotel con Pentaho

**Autor:** Asier Núñez Correa · Big Data Aplicado · UT1 (práctica integradora)
**Código asignado:** **A011**, conjunto `cierre_aula_01` (ver `asignacion.json`)

## Objetivo

Procesar los datos del cierre `cierre_aula_01` del grupo hotelero de Cantabria con Pentaho Data Integration para obtener:

1. **`salida/informe_hotel_canal.csv`**: importe cobrado y número de reservas cobradas por hotel y canal.
2. **`salida/reservas_sin_cobro.csv`**: listado de control de las reservas sin cobro asociado.

El procedimiento puede repetirse y **no publica nada** si falta una entrada o si falla la preparación o la validación.

## Versiones

| Herramienta | Versión |
|---|---|
| Pentaho Data Integration | 9.4.0.0-343 |
| Java | OpenJDK 11.0.33 (entorno de ejecución de las pruebas) |
| Sistema | Windows (equipo `pcasier`); pruebas ejecutadas con `kitchen.sh`/`pan.sh` en el entorno Linux del mismo equipo |

No se usan bases de datos, JDBC, plugins, Spark ni servicios en la nube.

## Estructura

```
bda-ut1-pentaho-hotel/
├── README.md
├── .gitignore              # excluye /temporal/
├── asignacion.json         # paquete A011 (huellas SHA-256 de las entradas)
├── ejecutar_cierre.bat     # lanza el job con Kitchen y guarda el log
├── entrada/                # CSV originales del paquete A011 (no se modifican)
│   ├── reservas_pdi.csv    # separador coma, 20 reservas
│   ├── cobros_pdi.csv      # separador punto y coma, 15 cobros
│   └── hoteles_pdi.csv     # separador punto y coma, 5 hoteles
├── procesos/
│   ├── informe_cobros.ktr
│   ├── reservas_sin_cobro.ktr
│   ├── validar_informe.ktr
│   ├── validar_sin_cobro.ktr
│   └── cierre_hotel.kjb
├── temporal/               # resultados provisionales (no se suben a GitHub)
├── salida/                 # los dos CSV publicados
└── evidencias/
    ├── sesion-01.md …      # registro de cada sesión
    ├── comprobaciones.md   # tabla de comprobaciones (esperado / obtenido)
    ├── pruebas.md          # las 6 pruebas obligatorias comentadas
    ├── referencia/         # salidas esperadas calculadas a mano para contrastar
    └── logs/               # logs de Kitchen/Pan de cada prueba
```

## Cómo ejecutarlo desde una copia nueva

1. Clonar el repositorio en cualquier carpeta. Todas las rutas son relativas: las transformaciones usan `${Internal.Transformation.Filename.Directory}` y el job usa `${Internal.Job.Filename.Directory}`.
2. Crear las carpetas `temporal/` y `salida/` si no existen. `ejecutar_cierre.bat` las crea automáticamente.
3. Lanzar el job con Kitchen:

   ```bat
   set PDI_HOME=C:\ruta\a\data-integration
   ejecutar_cierre.bat prueba1
   ```

   También se puede lanzar directamente:

   ```bat
   "%PDI_HOME%\Kitchen.bat" /file:"C:\ruta\repo\procesos\cierre_hotel.kjb" /level:Basic /logfile:"C:\ruta\repo\evidencias\logs\prueba1.log"
   ```

   En Linux: `./kitchen.sh -file=/ruta/repo/procesos/cierre_hotel.kjb -level=Basic`.
4. Cada transformación se puede ejecutar sola con Pan, por ejemplo:

   ```bat
   "%PDI_HOME%\Pan.bat" /file:"C:\ruta\repo\procesos\validar_informe.ktr" /level:Basic
   ```

Si todo va bien, el log termina con `CIERRE OK` y en `salida/` aparecen los dos CSV.

## Procedencia de los datos

Los tres CSV de `entrada/` proceden del paquete personal **A011** entregado por el profesor, sin modificar. Sus huellas SHA-256 coinciden con las de `asignacion.json`:

| Archivo | SHA-256 |
|---|---|
| reservas_pdi.csv | `5d4aad30a8d556ef0a3362ccd2ec77ecf8b84ad4fb0adff5ccc0050ea21731a6` |
| cobros_pdi.csv | `79c4a50141c0a4ce3c1ce3d789eed535bc38a02be2a52d620d493d72623facd5` |
| hoteles_pdi.csv | `3b86ba75209a867e1fc28da769a4b64e23db79bd5e81e479187828d07767f0f7` |

Las pruebas de fallo se hacen siempre sobre **copias** del proyecto o de los archivos provisionales, nunca sobre estos originales.

## Diseño de la solución

### `informe_cobros.ktr`: informe principal

- **Lectura con *CSV file input*:** reservas con separador `,`, cobros y hoteles con `;`. Tipos: Integer en `id_reserva`, `id_hotel`, `noches` e `id_cadena`; String en `canal`, `medio`, `hotel` y `comarca`; BigNumber en `importe` y `cobrado`, con el punto como decimal y sin separador de miles. Se usa BigNumber para evitar los errores de redondeo de Number con importes en euros.
- **Ordenar** ambas entradas por `id_reserva` (*Merge join* exige entradas ordenadas) y hacer un ***Merge join* INNER**, que da 15 filas. Se usa INNER porque el informe principal solo incluye reservas con cobro.
- Ordenar por `id_hotel` y hacer otro ***Merge join* INNER** con hoteles: siguen 15 filas.
- **Ordenar por `hotel` y `canal`**, y aplicar ***Group by***: `n_reservas` = número de valores de `id_reserva` y `cobrado_total` = `SUM(cobrado)`. Se suma `cobrado`, no `importe`.
- **Salida con *Text file output*:** `temporal/informe_hotel_canal.csv`, con cabecera, separador `;`, UTF-8 y formato `0.00` en los importes. *Append* está desactivado, así que cada ejecución sobrescribe el archivo y no acumula filas.

### `reservas_sin_cobro.ktr`: control interno

- En la rama de cobros, *Select values* renombra `id_reserva` → `id_reserva_cobro` para que tras la unión se distinga si hubo cobro.
- ***Merge join* LEFT OUTER** con las reservas a la izquierda: 20 filas.
- ***Filter rows*** deja pasar solo las filas con `id_reserva_cobro` **IS NULL**. No se filtra por `cobrado = 0`, porque un cobro de 0 € sería un cobro registrado.
- El hotel se añade con un **LEFT OUTER** para no descartar en silencio ninguna reserva aunque su hotel no existiera. Si eso ocurriera, la validación lo detectaría.
- Se añade la constante `motivo` = "Sin cobro asociado en el archivo recibido". Se seleccionan `id_reserva;hotel;canal;importe;motivo`, se ordena por `id_reserva` y se escribe `temporal/reservas_sin_cobro.csv` sobrescribiendo. `importe` es el precio de la reserva, **no** dinero cobrado.

### `validar_informe.ktr`

- Lee el informe provisional con tipos numéricos y aplica un ***Group by* sin claves** con **"Always give back a result row"**. Así, un archivo con solo cabecera también produce una fila de resumen (0 grupos y sumas nulas) y no "pasa" por no tener filas.
- Las referencias se añaden con *Add constants* (13, 15 y 3965.50 en BigNumber). *Filter rows* exige que no haya nulos y que se cumplan 13 grupos, 15 reservas y 3965.50 €.
- Si la validación pasa, se escribe un mensaje en el log. Si no, se lanza ***Abort* con error (umbral 0)**.

### `validar_sin_cobro.ktr`

1. Cada `id_reserva` debe ser 4, 9, 11, 15 o 18. Si no lo es, o es nulo, va a *Abort*.
2. Se ordena por `id_reserva` y se agrupa contando las filas de cada id. Cada grupo debe tener 1 fila; si no, va a *Abort* por duplicado.
3. Un resumen sin claves ("Always give back a result row") exige **5 identificadores y 5 filas**. Un archivo vacío da 0 y va a *Abort*.

### `cierre_hotel.kjb`

`Start` → *File exists* de las tres entradas (si falta una, *Abort job* indicando cuál) → `informe_cobros` → `reservas_sin_cobro` → *File exists* de las dos salidas provisionales → `validar_informe` → `validar_sin_cobro` → copia de `informe_hotel_canal.csv` a `salida/` → copia de `reservas_sin_cobro.csv` a `salida/` → *Write to log* "CIERRE OK" → `Success`.

- Cualquier fallo de preparación o de validación va a un *Abort* **antes** de copiar, así que `salida/` no se toca.
- Si falla una copia, una rama de error escribe en el log el aviso de **posible estado parcial** y termina en *Abort*.
- Al empezar **no se borra** el último informe publicado. Si el cierre falla, la dirección sigue teniendo el último informe válido.
- El éxito solo se registra después de terminar las dos copias.

Cada proceso lleva una **nota** en Spoon con el autor y la pregunta que resuelve.

## Resultados obtenidos (A011)

| Comprobación | Referencia |
|---|---|
| Lecturas | 20 reservas, 15 cobros, 5 hoteles |
| Filas tras unir reservas y cobros / tras añadir hoteles | 15 / 15 |
| Grupos del informe (sin cabecera) | 13 |
| Suma de `n_reservas` / de `cobrado_total` | 15 / 3965.50 € |
| Laredo, web | 2 reservas, 496.50 € |
| Reservas sin cobro | 5: ids 4, 9, 11, 15 y 18 |
| Reconciliación | 15 cobradas + 5 sin cobro = 20 |

El detalle y lo obtenido en cada ejecución están en [`evidencias/comprobaciones.md`](evidencias/comprobaciones.md).

## Pruebas

Las seis pruebas obligatorias, con lo esperado, lo obtenido y la conclusión, están en [`evidencias/pruebas.md`](evidencias/pruebas.md). Los logs están en [`evidencias/logs/`](evidencias/logs/).

1. Primera ejecución sin informes previos.
2. Repetición con las mismas entradas.
3. Falta una entrada.
4. Salida incompleta (solo cabecera).
5. Total incorrecto.
6. Recuperación.

## Fuentes y ayudas recibidas

- Enunciado de la práctica y materiales de la UT1 (talleres 1 y 2).
- Documentación de Pentaho Data Integration 9.4.
- Asistente de IA (Claude, de Anthropic): ha preparado las transformaciones, el job, este README y las evidencias. También ha lanzado en mi equipo, con mi instalación de PDI 9.4 y bajo mi supervisión, la ejecución de referencia y las seis pruebas; los logs de `evidencias/logs/` son de esas ejecuciones.

## Resumen para gerencia

Este informe corresponde al cierre **`cierre_aula_01`**, un periodo ya seleccionado. No se aplica ningún filtro de fechas. Los importes están en **euros**, con dos decimales, y las cantidades son **número de reservas**.

En este cierre hay **15 reservas con cobro**, que suman **3965.50 €** entre los 5 hoteles, desglosados por hotel y canal (web, OTA y recepción) en `informe_hotel_canal.csv`. Hay además **5 reservas sin un cobro asociado** en el archivo recibido. Se listan aparte en `reservas_sin_cobro.csv` como **control interno**: eso **no significa que estén impagadas**, ya que el cobro puede estar registrado en otro sistema o llegar más tarde. El importe que aparece en ese listado es el precio de la reserva, no dinero cobrado.

El informe solo usa los tres archivos recibidos. **No calcula ocupación** ni compara con otros periodos.
