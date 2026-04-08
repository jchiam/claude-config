@echo off
REM Windows batch script to create skill symlinks/junctions
REM Run as Administrator for best results

setlocal EnableDelayedExpansion

REM Configuration
set "CLAUDE_SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "QODERWORK_SKILLS_DIR=%USERPROFILE%\.qoderwork\skills"
set "QWEN_SKILLS_DIR=%USERPROFILE%\.qwen\skills"

echo [INFO] Setting up skill symlinks...
echo [INFO] Source: %CLAUDE_SKILLS_DIR%

REM Check if source exists
if not exist "%CLAUDE_SKILLS_DIR%" (
    echo [ERROR] Claude skills directory not found: %CLAUDE_SKILLS_DIR%
    exit /b 1
)

REM Create target directories if they don't exist
if not exist "%QODERWORK_SKILLS_DIR%" mkdir "%QODERWORK_SKILLS_DIR%"
if not exist "%QWEN_SKILLS_DIR%" mkdir "%QWEN_SKILLS_DIR%"

REM Process each skill in the Claude skills directory
for /d %%D in ("%CLAUDE_SKILLS_DIR%\*") do (
    set "SKILL_NAME=%%~nxD"
    echo [INFO] Processing skill: !SKILL_NAME!

    REM Remove existing junctions/symlinks if they exist
    if exist "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!" (
        echo [WARN] Removing existing %QODERWORK_SKILLS_DIR%\!SKILL_NAME!
        rmdir /s /q "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!"
    )
    if exist "%QWEN_SKILLS_DIR%\!SKILL_NAME!" (
        echo [WARN] Removing existing %QWEN_SKILLS_DIR%\!SKILL_NAME!
        rmdir /s /q "%QWEN_SKILLS_DIR%\!SKILL_NAME!"
    )

    REM Create junctions (don't require admin privileges)
    mklink /J "%QODERWORK_SKILLS_DIR%\!SKILL_NAME!" "%%D" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create junction for !SKILL_NAME! in QoderWork
    ) else (
        echo [INFO] Created junction: !SKILL_NAME! -^> QoderWork
    )

    mklink /J "%QWEN_SKILLS_DIR%\!SKILL_NAME!" "%%D" >nul 2>&1
    if errorlevel 1 (
        echo [ERROR] Failed to create junction for !SKILL_NAME! in Qwen
    ) else (
        echo [INFO] Created junction: !SKILL_NAME! -^> Qwen
    )
)

echo [INFO] Setup complete!
pause
