@echo off
REM Inicia el laboratorio del examen desde su propia carpeta y abre Jenkins si todo responde.
setlocal
cd /d "%~dp0"
echo Iniciando el laboratorio desde: %CD%
echo.
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0iniciar-y-verificar.ps1"
echo.
if errorlevel 1 (
  echo Revisa el mensaje anterior. Ayuda: docker compose logs --tail=80
) else (
  echo Todo listo. Abriendo Jenkins...
  start "" "http://localhost:8080"
)
pause
