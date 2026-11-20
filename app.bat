@echo off
REM ============================================================
REM  app.bat - Acceso rapido a la App Medident (SIEMPRE release)
REM  Uso:  app [lanzar|estado|stop|watch|limpiar]
REM ============================================================
if not "%~1"=="" (
  powershell -ExecutionPolicy Bypass -File "%~dp0app.ps1" "%~1"
  if /I not "%~1"=="watch" pause
  exit /b
)
powershell -ExecutionPolicy Bypass -File "%~dp0app.ps1"
pause
