@echo off
chcp 65001 >nul
setlocal

echo.
echo ================================================================
echo     WPS Robot Open API - Waitress服务器启动
echo ================================================================
echo.

REM 检查Python
where python >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [错误] 未找到Python，请先安装Python
    pause
    exit /b 1
)

REM 检查waitress
python -c "import waitress" >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [警告] waitress未安装，正在安装...
    pip install waitress
    if %ERRORLEVEL% neq 0 (
        echo [错误] waitress安装失败
        pause
        exit /b 1
    )
    echo [成功] waitress安装完成
    echo.
)

echo [信息] 正在启动WPS Robot服务器...
echo [信息] 监听地址: 0.0.0.0:80
echo [信息] 工作线程: 4
echo [信息] 访问地址: http://localhost/
echo.
echo [提示] 按 Ctrl+C 停止服务器
echo ================================================================
echo.

REM 启动服务器
waitress-serve --host=0.0.0.0 --port=80 --threads=4 --channel-timeout=60 wps_robot.wsgi:application

pause
