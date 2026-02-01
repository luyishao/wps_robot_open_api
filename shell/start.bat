@echo off
chcp 65001 >nul
echo ========================================
echo WPS 机器人管理系统启动脚本
echo ========================================
echo.

REM 激活conda环境
echo [正在激活conda环境...]
call conda activate wps_robot
if errorlevel 1 (
    echo.
    echo [错误] 无法激活conda环境 'wps_robot'
    echo 请先创建环境: conda create -n wps_robot python=3.11 -y
    echo 然后再次运行此脚本
    pause
    exit /b 1
)

echo [环境已激活: wps_robot]
echo.

REM 检查是否需要初始化数据库
if not exist "db.sqlite3" (
    echo [1/4] 首次运行，正在安装依赖...
    pip install -r requirements.txt
    echo.
    
    echo [2/4] 创建数据库迁移...
    python manage.py makemigrations
    echo.
    
    echo [3/4] 应用数据库迁移...
    python manage.py migrate
    echo.
    
    echo [4/4] 创建默认管理员账号...
    python manage.py create_default_admin
    echo.
    echo ========================================
    echo 初始化完成！
    echo ========================================
)

echo.
echo [启动Django服务器...]
echo.
echo ========================================
echo 系统已启动！
echo ----------------------------------------
echo 访问地址: http://127.0.0.1:8000/
echo 默认账号: admin
echo 默认密码: admin123456
echo ----------------------------------------
echo 按 Ctrl+C 可停止服务器
echo ========================================
echo.

REM 启动服务器
python manage.py runserver

pause
