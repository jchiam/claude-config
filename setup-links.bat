@echo off
REM Sets up:
REM   1. %USERPROFILE%\.claude junction -> this repo directory
REM   2. Skill junctions from .claude\skills to .qoderwork\skills and .qwen\skills

setlocal EnableDelayedExpansion

REM Repo directory = script location (strip trailing backslash)
set "REPO_DIR=%~dp0"
if "%REPO_DIR:~-1%"=="\" set "REPO_DIR=%REPO_DIR:~0,-1%"

set "CLAUDE_DIR=%USERPROFILE%\.claude"
set "SKILLS_DIR=%REPO_DIR%\skills"
set "QODERWORK_SKILLS_DIR=%USERPROFILE%\.qoderwork\skills"
set "QWEN_SKILLS_DIR=%USERPROFILE%\.qwen\skills"

echo [INFO]  Setting up Claude Code links...

REM === Step 1: %%USERPROFILE%%\.claude junction -> this repo ===
echo.
echo [INFO]  Configuring %CLAUDE_DIR% ^> %REPO_DIR%

if exist "%CLAUDE_DIR%" (
    REM Use PowerShell to check if it already points to this repo
    powershell -NoProfile -Command ^
        "$item = Get-Item '%CLAUDE_DIR%' -Force -ErrorAction SilentlyContinue; ^
         if ($item -and $item.LinkType -in @('Junction','SymbolicLink') -and $item.Target -eq '%REPO_DIR%') { exit 0 } else { exit 1 }" >nul 2>&1
    if !ERRORLEVEL! == 0 (
        echo [INFO]  .claude already points to this repo. Skipping.
        goto :sync_skills
    )

    echo [WARN]  %CLAUDE_DIR% already exists.
    set /p CONFIRM="Replace with junction to this repo? [y/N] "
    if /i "!CONFIRM!"=="y" (
        rmdir /s /q "%CLAUDE_DIR%" 2>nul || del /f /q "%CLAUDE_DIR%" 2>nul
    ) else (
        echo [INFO]  Skipped .claude link.
        goto :sync_skills
    )
)

mklink /J "%CLAUDE_DIR%" "%REPO_DIR%" >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Failed to create junction for .claude. Try running as Administrator.
) else (
    echo [INFO]  Created junction: .claude ^> %REPO_DIR%
)

:sync_skills
REM === Step 2: Sync skills to other tool directories ===
echo.
echo [INFO]  Syncing skills to other tool directories...

if not exist "%SKILLS_DIR%" (
    echo [WARN]  Skills directory not found: %SKILLS_DIR%
    goto :done
)

if not exist "%QODERWORK_SKILLS_DIR%" mkdir "%QODERWORK_SKILLS_DIR%"
if not exist "%QWEN_SKILLS_DIR%" mkdir "%QWEN_SKILLS_DIR%"

for /d %%D in ("%SKILLS_DIR%\*") do (
    set "SKILL_NAME=%%~nxD"

    if exist "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!" (
        rmdir /s /q "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!"
    )
    mklink /J "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!" "%%D" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed junction: !SKILL_NAME! ^> QoderWork
    ) else (
        echo [INFO]  Linked: !SKILL_NAME! ^> QoderWork
    )

    if exist "%QWEN_SKILLS_DIR%\!SKILL_NAME!" (
        rmdir /s /q "%QWEN_SKILLS_DIR%\!SKILL_NAME!"
    )
    mklink /J "%QWEN_SKILLS_DIR%\!SKILL_NAME!" "%%D" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed junction: !SKILL_NAME! ^> Qwen
    ) else (
        echo [INFO]  Linked: !SKILL_NAME! ^> Qwen
    )
)

:done
echo.
echo [INFO]  Links configured.
