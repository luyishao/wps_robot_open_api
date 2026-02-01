@echo off
chcp 65001 >nul
echo ========================================
echo WPS 机器人管理系统 - HTTPS启动 (443端口)
echo (使用Python虚拟环境 venv)
echo ========================================
echo.
echo 注意：HTTPS需要SSL证书
echo 请确保已配置证书文件：
echo   - cert.pem (证书文件)
echo   - key.pem (私钥文件)
echo.
echo 如果没有证书，请使用 启动服务器_venv.bat (8080端口)
echo.
pause
echo.
echo 正在启动Django HTTPS服务器 (端口: 443)...
echo.

cd /d "%~dp0"
call venv\Scripts\activate.bat

REM 检查证书文件是否存在
if not exist "cert.pem" (
    echo 错误: 找不到证书文件 cert.pem
    pause
    exit /b 1
)

if not exist "key.pem" (
    echo 错误: 找不到私钥文件 key.pem
    pause
    exit /b 1
)

REM 使用Django扩展的runserver_plus启动HTTPS服务器
REM 或者使用nginx/apache作为反向代理
echo.
echo 提示：Django开发服务器不直接支持HTTPS
echo 建议使用以下方式之一：
echo   1. 使用nginx/apache作为反向代理
echo   2. 安装django-extensions: pip install django-extensions
echo      然后使用: python manage.py runserver_plus --cert-file cert.pem --key-file key.pem 0.0.0.0:443
echo.
echo 当前将启动HTTP服务器在8080端口...
python manage.py runserver 8080

pause
