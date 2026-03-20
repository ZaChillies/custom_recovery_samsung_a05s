@echo off
TITLE ChilleeeZDevments - Hot DEVMENTS ONLY (One-Click Deploy)
COLOR 0B

echo ===================================================
echo Company NAme : ChilleeeZDevments
echo Solgan : Hot DEVMENTS ONLY
echo ===================================================
echo Loading the Ultimate 1-Click Builder...
echo.

PowerShell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0ChilleeeZ_Ultimate_Deploy.ps1"

IF %ERRORLEVEL% NEQ 0 (
    echo [ERROR] The build script failed.
    pause
)
