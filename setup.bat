@echo off
REM ============================================================
REM  DSP Monthly Checks — One-time Setup
REM  Run this ONCE as Administrator to install everything.
REM ============================================================

echo.
echo === DSP Monthly Checks Setup ===
echo.

REM ── 1. Check for Python ──────────────────────────────────────
python --version >nul 2>&1
if %errorlevel% neq 0 (
    echo Python is not installed. Installing via Windows Package Manager...
    winget install --id Python.Python.3.11 -e --silent
    if %errorlevel% neq 0 (
        echo.
        echo ERROR: Could not auto-install Python.
        echo Please download and install Python 3.11 manually from:
        echo   https://www.python.org/downloads/
        echo Then re-run this setup.bat
        pause
        exit /b 1
    )
    echo Python installed successfully.
    REM Refresh PATH
    call refreshenv >nul 2>&1
) else (
    echo Python found: OK
)

REM ── 2. Install Python packages ────────────────────────────────
echo.
echo Installing Python packages...
python -m pip install --upgrade pip --quiet
python -m pip install -r "%~dp0requirements.txt"
if %errorlevel% neq 0 (
    echo ERROR: pip install failed. See output above.
    pause
    exit /b 1
)
echo Packages installed: OK

REM ── 3. Install Playwright browsers ────────────────────────────
echo.
echo Installing Playwright browsers (Chromium) ...
python -m playwright install chromium
if %errorlevel% neq 0 (
    echo ERROR: Playwright browser install failed. See output above.
    pause
    exit /b 1
)
echo Playwright browser installed: OK

REM ── 4. Register the monthly scheduled task ────────────────────
echo.
echo Registering Windows Scheduled Task (runs on 1st of each month)...
powershell -ExecutionPolicy Bypass -File "%~dp0schedule_task.ps1"
if %errorlevel% neq 0 (
    echo WARNING: Task Scheduler registration failed.
    echo You can register it manually — see README.txt for instructions.
) else (
    echo Scheduled task registered: OK
)

echo.
echo ============================================================
echo  Setup complete!
echo  The script will run automatically on the 1st of each month.
echo  To run a test RIGHT NOW:  double-click run_checks.bat
echo ============================================================
echo.
pause
