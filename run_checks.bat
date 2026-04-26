@echo off
REM ============================================================
REM  DSP Monthly Checks — Runner
REM  Double-click to run manually, or used by Task Scheduler.
REM ============================================================
cd /d "%~dp0"
python dsp_monthly_checks.py
if %errorlevel% neq 0 (
    echo.
    echo Script exited with an error. Check dsp_checks.log for details.
    pause
)
