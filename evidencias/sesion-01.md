# Sesión 01

- **Fecha:** 25/11/2026
- **Commit al final de la sesión:** _(anotar el hash tras el `git commit`)_

## Qué se ha hecho
- Se ha creado la estructura del repositorio y se han copiado los CSV del paquete **A011** sin modificarlos. Sus huellas SHA-256 coinciden con `asignacion.json` (ver README).
- Se han creado las cuatro transformaciones (`informe_cobros`, `reservas_sin_cobro`, `validar_informe`, `validar_sin_cobro`) y el job `cierre_hotel`, con rutas relativas y una nota con el autor y la pregunta que resuelve cada uno.
- Se ha hecho la ejecución de referencia con Kitchen: 20/15/5 filas leídas, 15 filas tras las uniones, 13 grupos, 15 reservas, 3965.50 €, Laredo-web con 2 reservas y 496.50 €, y 5 reservas sin cobro (4, 9, 11, 15 y 18).
- Se han hecho las seis pruebas obligatorias; todas dan el resultado esperado (ver `pruebas.md`).
- Trabajo hecho con ayuda de un asistente de IA (ver README).

## Problemas encontrados y cómo se han resuelto
- *Merge join* exige que las dos entradas estén ordenadas por la clave: se ha puesto un *Sort rows* antes de cada unión.
- Un archivo con solo cabecera no produciría filas en un *Group by* normal y la validación no fallaría: se ha activado "Always give back a result row".

## Qué queda para la próxima sesión
- Contrastar cada grupo con la tabla de referencia del taller 2.
- Abrir los procesos en Spoon para repasarlos de cara a la defensa.
- Subir el repositorio a GitHub y entregar la URL y el commit en Moodle.
