@echo off
REM Claude Workflow Installation Script for Windows Command Prompt
REM This script launches the PowerShell installer

echo Claude Workflow Installation
echo ==========================================
echo.
echo This script will launch PowerShell to complete the installation.
echo.

REM Check if PowerShell is available
where powershell >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo Error: PowerShell not found. Please install PowerShell or run install.ps1 directly.
    pause
    exit /b 1
)

REM Get the directory where this script is located
set "SCRIPT_DIR=%~dp0"

REM Run the PowerShell installer
powershell -ExecutionPolicy Bypass -File "%SCRIPT_DIR%install.ps1" %*

if %ERRORLEVEL% neq 0 (
    echo.
    echo Installation failed. Please check the error messages above.
    pause
    exit /b 1
)

echo.
echo Installation complete!
echo.
echo Note: The shell functions are installed for PowerShell.
echo For Command Prompt, consider using Git Bash or WSL instead.
echo.
pause
