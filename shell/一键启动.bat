@echo off
chcp 65001 >nul

REM 检查是否在Anaconda Prompt中运行
where conda >nul 2>nul
if errorlevel 1 (
    echo ========================================
    echo 请在 Anaconda Prompt 中运行此脚本！
    echo ========================================
    echo.
    echo 操作步骤：
    echo 1. 打开 "Anaconda Prompt" 或 "Anaconda PowerShell Prompt"
    echo 2. 进入项目目录: cd d:\WorkSpace\cursor\wps_open_api
    echo 3. 运行脚本: 一键启动.bat
    echo.
    pause
    exit /b 1
)

REM 检查环境是否存在
conda env list | findstr "wps_robot" >nul 2>nul
if errorlevel 1 (
    echo ========================================
    echo 首次运行，正在配置环境...
    echo ========================================
    call setup_env.bat
    if errorlevel 1 exit /b 1
)

REM 启动项目
call start.bat
