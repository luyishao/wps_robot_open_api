@echo off
chcp 65001 >nul
echo ========================================
echo WPS 机器人管理系统 - 初始化并运行
echo ========================================
echo.
echo 请确保已在 Anaconda Prompt 中激活了 wps_robot 环境
echo 如果还没激活，请先运行: conda activate wps_robot
echo.
pause
echo.

echo [1/5] 升级pip...
python -m pip install --upgrade pip
echo.

echo [2/5] 安装项目依赖...
pip install -r requirements.txt
echo.

echo [3/5] 创建数据库迁移...
python manage.py makemigrations
echo.

echo [4/5] 应用数据库迁移...
python manage.py migrate
echo.

echo [5/5] 创建默认管理员账号...
python manage.py create_default_admin
echo.

echo ========================================
echo 初始化完成！现在启动服务器...
echo ========================================
echo.
echo 访问地址: http://127.0.0.1:8000/
echo 用户名: admin
echo 密码: admin123456
echo.
echo 按 Ctrl+C 可停止服务器
echo ========================================
echo.

python manage.py runserver

pause
