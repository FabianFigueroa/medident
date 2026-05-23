@echo off
echo ===============================
echo  Actualizando App Web Medident
echo ===============================
echo.

echo Paso 1: Generando version web...
call flutter build web --release
if errorlevel 1 (
    echo.
    echo ERROR: Fallo al generar la version web.
    pause
    exit /b 1
)

echo.
echo Paso 2: Subiendo a internet...
call firebase deploy --only hosting --project ips-medident
if errorlevel 1 (
    echo.
    echo ERROR: Fallo al subir la App.
    pause
    exit /b 1
)

echo.
echo ===============================
echo  App Actualizada con Exito!
echo ===============================
echo.
echo Enlace: https://ips-medident.web.app
echo.
pause
