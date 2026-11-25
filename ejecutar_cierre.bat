@echo off
rem ------------------------------------------------------------------
rem  Lanza el job cierre_hotel.kjb con Kitchen y guarda el log.
rem  Uso:  ejecutar_cierre.bat [nombre_log]      (por defecto: ejecucion)
rem  Requiere PDI_HOME apuntando a la carpeta data-integration.
rem ------------------------------------------------------------------
setlocal
if "%PDI_HOME%"=="" set "PDI_HOME=C:\pentaho\data-integration"
set "REPO=%~dp0"
set "LOG=%~1"
if "%LOG%"=="" set "LOG=ejecucion"

if not exist "%REPO%temporal" mkdir "%REPO%temporal"
if not exist "%REPO%salida" mkdir "%REPO%salida"
if not exist "%REPO%evidencias\logs" mkdir "%REPO%evidencias\logs"

call "%PDI_HOME%\Kitchen.bat" /file:"%REPO%procesos\cierre_hotel.kjb" /level:Basic /logfile:"%REPO%evidencias\logs\%LOG%.log"
echo.
echo Kitchen ha terminado con codigo %ERRORLEVEL% (0 = exito). Log: evidencias\logs\%LOG%.log
endlocal
