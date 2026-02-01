@echo off
REM Docker镜像构建问题快速修复脚本 (Windows)
chcp 65001 >nul
setlocal enabledelayedexpansion

echo ==========================================
echo Docker镜像构建问题修复工具 (Windows)
echo ==========================================
echo.

REM 1. 检查Docker Desktop是否运行
echo 1. 检查Docker Desktop...
docker version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] Docker Desktop未运行，请先启动Docker Desktop
    pause
    exit /b 1
)
echo [√] Docker Desktop正常运行
echo.

REM 2. 清理Docker缓存
echo 2. 清理Docker缓存和未使用资源...
echo    - 清理构建缓存...
docker builder prune -a -f >nul 2>&1
echo    - 清理未使用的镜像...
docker image prune -a -f >nul 2>&1
echo    - 清理未使用的容器...
docker container prune -f >nul 2>&1
echo [√] 清理完成
echo.

REM 3. 删除可能损坏的Python镜像
echo 3. 删除可能损坏的Python镜像...
docker images | findstr /C:"python" | findstr /C:"3.12" >nul 2>&1
if %errorlevel% equ 0 (
    docker rmi python:3.12 -f >nul 2>&1
    echo [√] 已删除旧的Python镜像
) else (
    echo [!] 未找到需要删除的镜像
)
echo.

REM 4. 手动拉取基础镜像
echo 4. 手动拉取Python基础镜像...
echo    尝试拉取 python:3.12（标准版）...
docker pull python:3.12
if %errorlevel% equ 0 (
    echo [√] 成功拉取 python:3.12
    set "BASE_IMAGE=python:3.12"
) else (
    echo [!] python:3.12 拉取失败，尝试 python:3.11...
    docker pull python:3.11
    if !errorlevel! equ 0 (
        echo [√] 成功拉取 python:3.11
        set "BASE_IMAGE=python:3.11"
        
        REM 修改Dockerfile
        echo    正在修改Dockerfile使用python:3.11...
        if exist "Dockerfile" (
            powershell -Command "(Get-Content Dockerfile) -replace 'FROM python:3.12', 'FROM python:3.11' | Set-Content Dockerfile"
            echo [√] Dockerfile已更新
        )
    ) else (
        echo [X] 无法拉取Python镜像，请检查网络连接
        pause
        exit /b 1
    )
)
echo.

REM 5. 检查磁盘空间
echo 5. 检查磁盘空间...
for /f "tokens=3" %%a in ('dir /-c ^| findstr /C:"bytes free"') do set BYTES_FREE=%%a
set /a GB_FREE=%BYTES_FREE:~0,-9%
if %GB_FREE% lss 5 (
    echo [!] 警告：可用磁盘空间不足5GB，可能导致构建失败
    echo    当前可用空间: %GB_FREE%GB
    set /p continue_choice="   是否继续？(y/n): "
    if /i not "!continue_choice!"=="y" exit /b 1
) else (
    echo [√] 磁盘空间充足 (%GB_FREE%GB可用)
)
echo.

REM 6. 重新构建项目
echo 6. 重新构建项目镜像...
echo    这可能需要几分钟时间，请耐心等待...
echo.

docker compose build --no-cache
if %errorlevel% equ 0 (
    echo.
    echo [√] 镜像构建成功！
) else (
    echo.
    echo [X] 镜像构建失败
    echo.
    echo 可能的原因：
    echo   1. 网络问题 - 尝试使用VPN或配置代理
    echo   2. 磁盘空间不足 - 清理磁盘空间
    echo   3. Docker Desktop异常 - 重启Docker Desktop
    echo.
    echo 详细排查指南：
    echo   查看文档: FIX_DOCKER_BUILD_ERROR.md
    pause
    exit /b 1
)
echo.

REM 7. 启动容器
echo 7. 启动容器...
docker compose up -d
if %errorlevel% equ 0 (
    echo [√] 容器启动成功
) else (
    echo [X] 容器启动失败
    pause
    exit /b 1
)
echo.

REM 8. 等待服务就绪
echo 8. 等待服务就绪...
timeout /t 10 /nobreak >nul

REM 9. 检查容器状态
echo 9. 检查容器状态...
docker compose ps | findstr /C:"Up" >nul 2>&1
if %errorlevel% equ 0 (
    echo [√] 容器运行正常
) else (
    echo [X] 容器未正常运行
    echo 查看日志: docker compose logs web
    pause
    exit /b 1
)
echo.

REM 完成
echo ==========================================
echo [√] 修复完成！
echo ==========================================
echo.
echo 访问信息:
echo   URL: http://localhost:8080
echo   用户名: admin
echo   密码: admin123456
echo.
echo 常用命令:
echo   查看状态: docker compose ps
echo   查看日志: docker compose logs -f web
echo   停止服务: docker compose stop
echo   重启服务: docker compose restart
echo   进入容器: docker compose exec web bash
echo.
echo ==========================================
echo.
pause
