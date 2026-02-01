@echo off
chcp 65001 >nul
echo ========================================
echo WPS 机器人管理系统 - 快速启动
echo (使用Python虚拟环境 venv)
echo ========================================
echo.
echo 正在启动Django服务器 (端口: 8080)...
echo.

cd /d "%~dp0"
call venv\Scripts\activate.bat
python manage.py runserver 8080

pause
