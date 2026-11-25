@echo off
rem ------------------------------------------------------------------
rem  Lanza el job cierre_hotel.kjb con Kitchen y guarda el log.
rem  Uso:  ejecutar_cierre.bat [nombre_log]      (por defecto: ejecucion)
rem  Pentaho: usa PDI_HOME si esta definida; si no, prueba
rem  C:\pentaho\data-integration y Descargas\pdi-ce-9.4.0.0-343\data-integration
rem ------------------------------------------------------------------
setlocal
set "REPO=%~dp0"
set "LOG=%~1"
if "%LOG%"=="" set "LOG=ejecucion"

if "%PDI_HOME%"=="" if exist "C:\pentaho\data-integration\Kitchen.bat" set "PDI_HOME=C:\pentaho\data-integration"
if "%PDI_HOME%"=="" if exist "%USERPROFILE%\Downloads\pdi-ce-9.4.0.0-343\data-integration\Kitchen.bat" set "PDI_HOME=%USERPROFILE%\Downloads\pdi-ce-9.4.0.0-343\data-integration"
if not exist "%PDI_HOME%\Kitchen.bat" (
  echo ERROR: no encuentro Kitchen.bat. Define PDI_HOME con la carpeta data-integration de Pentaho.
  pause
  exit /b 1
)

if not exist "%REPO%temporal" mkdir "%REPO%temporal"
if not exist "%REPO%salida" mkdir "%REPO%salida"
if not exist "%REPO%evidencias\logs" mkdir "%REPO%evidencias\logs"

echo Pentaho: %PDI_HOME%
echo Ejecutando procesos\cierre_hotel.kjb ...
call "%PDI_HOME%\Kitchen.bat" /file:"%REPO%procesos\cierre_hotel.kjb" /level:Basic /logfile:"%REPO%evidencias\logs\%LOG%.log"
set "RC=%ERRORLEVEL%"
echo.
if "%RC%"=="0" (echo RESULTADO: CIERRE OK - informes publicados en salida\) else (echo RESULTADO: ERROR codigo %RC% - no se ha publicado. Revisa el log.)
echo Log: evidencias\logs\%LOG%.log
pause
endlocal & exit /b %RC%
