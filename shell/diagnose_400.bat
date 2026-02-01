@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

REM ============================================================================
REM 快速诊断400错误
REM ============================================================================

echo.
echo ================================================================
echo     WPS Robot - 400错误快速诊断工具
echo ================================================================
echo.

set "SCRIPT_DIR=%~dp0"
set "LOGS_DIR=%SCRIPT_DIR%logs"

REM 检查日志目录
if not exist "%LOGS_DIR%" (
    echo [错误] 日志目录不存在，请先启动服务生成日志
    pause
    exit /b 1
)

echo [1/5] 检查错误日志...
echo.
if exist "%LOGS_DIR%\error.log" (
    echo === 最近的400错误 ===
    powershell -Command "Get-Content '%LOGS_DIR%\error.log' -Encoding UTF8 | Select-String '400' | Select-Object -Last 10"
    echo.
) else (
    echo [信息] 暂无错误日志
    echo.
)

echo [2/5] 检查Webhook日志...
echo.
if exist "%LOGS_DIR%\webhook.log" (
    echo === 最近的Webhook请求 ===
    powershell -Command "Get-Content '%LOGS_DIR%\webhook.log' -Tail 20 -Encoding UTF8"
    echo.
) else (
    echo [信息] 暂无Webhook日志
    echo.
)

echo [3/5] 检查Django日志...
echo.
if exist "%LOGS_DIR%\django.log" (
    echo === 最近的错误和警告 ===
    powershell -Command "Get-Content '%LOGS_DIR%\django.log' -Encoding UTF8 | Select-String 'ERROR|WARNING|400' | Select-Object -Last 10"
    echo.
) else (
    echo [信息] 暂无Django日志
    echo.
)

echo [4/5] 测试服务连接...
echo.
powershell -Command "try { $response = Invoke-WebRequest -Uri 'http://localhost:80/at_robot/admin/test' -Method GET -TimeoutSec 5; Write-Host '[成功] GET请求正常: ' $response.StatusCode } catch { Write-Host '[错误] GET请求失败: ' $_.Exception.Message }"
echo.

echo [5/5] 生成诊断报告...
echo.
set "report_file=%SCRIPT_DIR%diagnostic_report.txt"
(
    echo ================================================================
    echo WPS Robot 诊断报告
    echo 生成时间: %date% %time%
    echo ================================================================
    echo.
    echo === 系统信息 ===
    echo 操作系统: %OS%
    echo 计算机名: %COMPUTERNAME%
    echo 用户名: %USERNAME%
    echo.
    echo === 错误信息 ===
    if exist "%LOGS_DIR%\error.log" (
        powershell -Command "Get-Content '%LOGS_DIR%\error.log' -Tail 50 -Encoding UTF8"
    ) else (
        echo 无错误日志
    )
    echo.
    echo === Webhook日志 ===
    if exist "%LOGS_DIR%\webhook.log" (
        powershell -Command "Get-Content '%LOGS_DIR%\webhook.log' -Tail 50 -Encoding UTF8"
    ) else (
        echo 无Webhook日志
    )
) > "%report_file%"

echo [成功] 诊断报告已生成: %report_file%
echo.

echo ================================================================
echo 诊断完成！
echo ================================================================
echo.
echo 💡 针对400错误的建议:
echo.
echo 1. 检查WPS Webhook URL是否正确
echo    格式: http://your-server:80/at_robot/用户名/机器人名
echo.
echo 2. 确认WPS发送的数据格式
echo    - Content-Type应为 application/json
echo    - 请求体应为有效的JSON
echo.
echo 3. 查看详细日志
echo    运行: view_logs.bat
echo.
echo 4. 启用DEBUG模式查看详细信息
echo    编辑.env文件，设置 DEBUG=True
echo.
echo 5. 测试webhook地址
echo    GET测试: curl http://localhost:80/at_robot/admin/test
echo    POST测试: curl -X POST http://localhost:80/at_robot/admin/test -H "Content-Type: application/json" -d "{\"msgtype\":\"text\",\"text\":{\"content\":\"test\"}}"
echo.
pause
