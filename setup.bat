@echo off
REM Fresh setup: configure .claude junction, sync skills, then generate settings.json.
REM Run once after cloning the repo on a new machine.

echo === Claude Code Setup ===
echo.

echo Step 1/2: Configure links...
call "%~dp0setup-links.bat"
if errorlevel 1 goto :error

echo.
echo Step 2/2: Configure settings...
powershell -ExecutionPolicy Bypass -File "%~dp0setup-settings.ps1"
if errorlevel 1 goto :error

echo.
echo === Setup complete! ===
goto :end

:error
echo.
echo [ERROR] Setup failed. Check errors above.

:end
pause
