@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================================
REM WPS Robot Open API 日志查看工具 (Windows)
REM ============================================================================

set "SCRIPT_DIR=%~dp0"
set "LOGS_DIR=%SCRIPT_DIR%logs"
set "EXPORT_DIR=%SCRIPT_DIR%logs_export"

echo.
echo ================================================================
echo     WPS Robot Open API 日志查看工具
echo ================================================================
echo.

REM 检查日志目录
if not exist "%LOGS_DIR%" (
    echo [警告] 日志目录不存在: %LOGS_DIR%
    echo [信息] 正在创建日志目录...
    mkdir "%LOGS_DIR%"
    echo [成功] 日志目录已创建
    echo.
    pause
    exit /b 1
)

:MENU
echo.
echo 请选择操作:
echo.
echo [1] 查看Django日志 (最后100行)
echo [2] 查看错误日志 (最后100行)
echo [3] 查看Webhook日志 (最后100行)
echo [4] 导出所有日志
echo [5] 导出错误日志
echo [6] 打开日志目录
echo [7] 清理旧日志
echo [0] 退出
echo.
set /p choice="请输入选项 [0-7]: "

if "%choice%"=="1" goto VIEW_DJANGO
if "%choice%"=="2" goto VIEW_ERROR
if "%choice%"=="3" goto VIEW_WEBHOOK
if "%choice%"=="4" goto EXPORT_ALL
if "%choice%"=="5" goto EXPORT_ERROR
if "%choice%"=="6" goto OPEN_DIR
if "%choice%"=="7" goto CLEAN_LOGS
if "%choice%"=="0" goto END
goto MENU

:VIEW_DJANGO
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   Django日志 (最后100行)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
if exist "%LOGS_DIR%\django.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\django.log' -Tail 100 -Encoding UTF8"
) else (
    echo [警告] 日志文件不存在: django.log
)
echo.
pause
goto MENU

:VIEW_ERROR
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   错误日志 (最后100行)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
if exist "%LOGS_DIR%\error.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\error.log' -Tail 100 -Encoding UTF8"
) else (
    echo [警告] 日志文件不存在: error.log
)
echo.
pause
goto MENU

:VIEW_WEBHOOK
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   Webhook日志 (最后100行)
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
if exist "%LOGS_DIR%\webhook.log" (
    powershell -Command "Get-Content '%LOGS_DIR%\webhook.log' -Tail 100 -Encoding UTF8"
) else (
    echo [警告] 日志文件不存在: webhook.log
)
echo.
pause
goto MENU

:EXPORT_ALL
echo.
echo [信息] 正在导出所有日志...
if not exist "%EXPORT_DIR%" mkdir "%EXPORT_DIR%"

set "timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "export_path=%EXPORT_DIR%\logs_%timestamp%"

mkdir "%export_path%"

if exist "%LOGS_DIR%\django.log" (
    copy "%LOGS_DIR%\django.log*" "%export_path%\" >nul 2>&1
    echo [成功] 已导出 django.log
)

if exist "%LOGS_DIR%\error.log" (
    copy "%LOGS_DIR%\error.log*" "%export_path%\" >nul 2>&1
    echo [成功] 已导出 error.log
)

if exist "%LOGS_DIR%\webhook.log" (
    copy "%LOGS_DIR%\webhook.log*" "%export_path%\" >nul 2>&1
    echo [成功] 已导出 webhook.log
)

echo.
echo [成功] 日志已导出到: %export_path%
echo.
pause
goto MENU

:EXPORT_ERROR
echo.
echo [信息] 正在导出错误日志...
if not exist "%EXPORT_DIR%" mkdir "%EXPORT_DIR%"

set "timestamp=%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%%time:~6,2%"
set "timestamp=%timestamp: =0%"
set "export_path=%EXPORT_DIR%\error_logs_%timestamp%"

mkdir "%export_path%"

if exist "%LOGS_DIR%\error.log" (
    copy "%LOGS_DIR%\error.log*" "%export_path%\" >nul 2>&1
    echo [成功] 已导出 error.log
) else (
    echo [警告] 错误日志文件不存在
)

echo.
echo [成功] 错误日志已导出到: %export_path%
echo.
pause
goto MENU

:OPEN_DIR
echo.
echo [信息] 打开日志目录...
explorer "%LOGS_DIR%"
goto MENU

:CLEAN_LOGS
echo.
echo [警告] 即将清理30天前的旧日志文件
set /p confirm="确认清理? (Y/N): "
if /i not "%confirm%"=="Y" goto MENU

echo.
echo [信息] 正在清理旧日志...
powershell -Command "Get-ChildItem '%LOGS_DIR%' -Filter *.log.* | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force"
echo [成功] 清理完成
echo.
pause
goto MENU

:END
echo.
echo 感谢使用！
echo.
exit /b 0
