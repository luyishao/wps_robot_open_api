#!/bin/bash

# WPS Robot Open API - Ubuntu启动脚本
# 支持多种方式启动服务

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 配置
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV_DIR="$PROJECT_DIR/venv"
LOG_DIR="$PROJECT_DIR/logs"
PID_FILE="$PROJECT_DIR/gunicorn.pid"

# 默认配置
HOST="0.0.0.0"
PORT="80"
WORKERS="4"
TIMEOUT="60"

# 打印带颜色的消息
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查虚拟环境
check_venv() {
    if [ -d "$VENV_DIR" ]; then
        PYTHON="$VENV_DIR/bin/python"
        GUNICORN="$VENV_DIR/bin/gunicorn"
    else
        PYTHON="python3"
        GUNICORN="gunicorn"
    fi
}

# 检查Gunicorn
check_gunicorn() {
    if ! command -v $GUNICORN &> /dev/null; then
        print_error "Gunicorn未安装"
        print_info "安装命令: pip install gunicorn"
        exit 1
    fi
}

# 检查端口占用
check_port() {
    if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null 2>&1; then
        print_warning "端口 $PORT 已被占用"
        print_info "占用进程："
        lsof -Pi :$PORT -sTCP:LISTEN
        return 1
    fi
    return 0
}

# 检查服务状态
check_status() {
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            print_success "服务正在运行 (PID: $PID)"
            print_info "端口: $PORT"
            print_info "工作进程: $(pgrep -P $PID | wc -l)"
            return 0
        else
            print_warning "PID文件存在但进程不存在"
            rm -f "$PID_FILE"
        fi
    fi
    
    # 检查是否有gunicorn进程
    if pgrep -f "gunicorn.*wps_robot.wsgi" > /dev/null; then
        print_warning "发现运行中的Gunicorn进程："
        ps aux | grep "[g]unicorn.*wps_robot.wsgi"
        return 0
    fi
    
    print_info "服务未运行"
    return 1
}

# 启动服务 - nohup方式
start_nohup() {
    print_info "使用nohup启动服务..."
    
    # 创建日志目录
    mkdir -p "$LOG_DIR"
    
    cd "$PROJECT_DIR"
    nohup $GUNICORN \
        --bind $HOST:$PORT \
        --workers $WORKERS \
        --timeout $TIMEOUT \
        --access-logfile "$LOG_DIR/gunicorn-access.log" \
        --error-logfile "$LOG_DIR/gunicorn-error.log" \
        --log-level info \
        --pid "$PID_FILE" \
        wps_robot.wsgi:application > "$LOG_DIR/nohup.log" 2>&1 &
    
    sleep 2
    
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        print_success "服务启动成功 (PID: $PID)"
        print_info "访问地址: http://localhost:$PORT"
        print_info "日志文件: $LOG_DIR/gunicorn-access.log"
    else
        print_error "服务启动失败"
        print_info "查看日志: tail -f $LOG_DIR/nohup.log"
        exit 1
    fi
}

# 启动服务 - screen方式
start_screen() {
    if ! command -v screen &> /dev/null; then
        print_error "screen未安装"
        print_info "安装命令: sudo apt install screen"
        exit 1
    fi
    
    print_info "使用screen启动服务..."
    
    mkdir -p "$LOG_DIR"
    
    screen -dmS wps-robot bash -c "cd $PROJECT_DIR && $GUNICORN \
        --bind $HOST:$PORT \
        --workers $WORKERS \
        --timeout $TIMEOUT \
        --access-logfile $LOG_DIR/gunicorn-access.log \
        --error-logfile $LOG_DIR/gunicorn-error.log \
        --log-level info \
        --pid $PID_FILE \
        wps_robot.wsgi:application"
    
    sleep 2
    
    if screen -list | grep -q "wps-robot"; then
        print_success "服务已在screen会话中启动"
        print_info "访问地址: http://localhost:$PORT"
        print_info "重新连接: screen -r wps-robot"
        print_info "查看会话: screen -ls"
    else
        print_error "服务启动失败"
        exit 1
    fi
}

# 启动服务 - systemd方式
start_systemd() {
    if ! systemctl list-unit-files | grep -q "wps-robot.service"; then
        print_error "systemd服务未配置"
        print_info "请先运行: sudo ./deploy_ubuntu.sh"
        exit 1
    fi
    
    print_info "使用systemd启动服务..."
    sudo systemctl start wps-robot
    
    sleep 2
    
    if sudo systemctl is-active --quiet wps-robot; then
        print_success "服务启动成功"
        sudo systemctl status wps-robot --no-pager
    else
        print_error "服务启动失败"
        sudo journalctl -u wps-robot -n 20 --no-pager
        exit 1
    fi
}

# 停止服务
stop_service() {
    print_info "正在停止服务..."
    
    # 停止systemd服务
    if systemctl list-unit-files | grep -q "wps-robot.service" 2>/dev/null; then
        if sudo systemctl is-active --quiet wps-robot 2>/dev/null; then
            sudo systemctl stop wps-robot
            print_success "systemd服务已停止"
        fi
    fi
    
    # 停止screen会话
    if command -v screen &> /dev/null; then
        if screen -list | grep -q "wps-robot"; then
            screen -X -S wps-robot quit
            print_success "screen会话已停止"
        fi
    fi
    
    # 停止nohup进程
    if [ -f "$PID_FILE" ]; then
        PID=$(cat "$PID_FILE")
        if ps -p $PID > /dev/null 2>&1; then
            kill $PID
            sleep 2
            if ps -p $PID > /dev/null 2>&1; then
                kill -9 $PID
            fi
            rm -f "$PID_FILE"
            print_success "nohup进程已停止 (PID: $PID)"
        else
            rm -f "$PID_FILE"
        fi
    fi
    
    # 强制停止所有gunicorn进程
    if pgrep -f "gunicorn.*wps_robot.wsgi" > /dev/null; then
        print_warning "发现残留的Gunicorn进程，正在清理..."
        pkill -f "gunicorn.*wps_robot.wsgi"
        print_success "残留进程已清理"
    fi
    
    print_success "所有服务已停止"
}

# 重启服务
restart_service() {
    print_info "正在重启服务..."
    stop_service
    sleep 2
    
    if [ "$1" = "systemd" ]; then
        start_systemd
    elif [ "$1" = "screen" ]; then
        start_screen
    else
        start_nohup
    fi
}

# 查看日志
view_logs() {
    if [ ! -d "$LOG_DIR" ]; then
        print_error "日志目录不存在: $LOG_DIR"
        exit 1
    fi
    
    echo ""
    echo "可用的日志文件："
    echo "  1) gunicorn-access.log - 访问日志"
    echo "  2) gunicorn-error.log - 错误日志"
    echo "  3) django.log - Django日志"
    echo "  4) nohup.log - nohup输出"
    echo ""
    read -p "选择日志文件 (1-4): " choice
    
    case $choice in
        1) tail -f "$LOG_DIR/gunicorn-access.log" ;;
        2) tail -f "$LOG_DIR/gunicorn-error.log" ;;
        3) tail -f "$LOG_DIR/django.log" ;;
        4) tail -f "$LOG_DIR/nohup.log" ;;
        *) print_error "无效选择" ;;
    esac
}

# 显示帮助
show_help() {
    cat << EOF

WPS Robot Open API - Ubuntu启动脚本

用法: $0 [command] [options]

命令:
  start [method]    启动服务
                    method: nohup (默认), screen, systemd
  stop              停止服务
  restart [method]  重启服务
  status            查看服务状态
  logs              查看日志
  help              显示帮助信息

示例:
  $0 start              # 使用nohup启动
  $0 start screen       # 使用screen启动
  $0 start systemd      # 使用systemd启动
  $0 stop               # 停止服务
  $0 restart            # 重启服务
  $0 status             # 查看状态
  $0 logs               # 查看日志

环境变量:
  PORT      - 监听端口 (默认: 80)
  WORKERS   - 工作进程数 (默认: 4)
  TIMEOUT   - 超时时间 (默认: 60)

示例:
  PORT=8000 WORKERS=2 $0 start

EOF
}

# 主逻辑
main() {
    echo ""
    echo "========================================"
    echo "  WPS Robot Open API - Ubuntu管理"
    echo "========================================"
    echo ""
    
    # 读取环境变量
    PORT="${PORT:-80}"
    WORKERS="${WORKERS:-4}"
    TIMEOUT="${TIMEOUT:-60}"
    
    check_venv
    
    case "$1" in
        start)
            check_gunicorn
            if check_status; then
                print_warning "服务已在运行"
                exit 0
            fi
            
            if ! check_port; then
                print_error "无法启动服务，端口已被占用"
                exit 1
            fi
            
            case "$2" in
                screen)
                    start_screen
                    ;;
                systemd)
                    start_systemd
                    ;;
                *)
                    start_nohup
                    ;;
            esac
            ;;
        
        stop)
            stop_service
            ;;
        
        restart)
            restart_service "$2"
            ;;
        
        status)
            check_status
            ;;
        
        logs)
            view_logs
            ;;
        
        help|--help|-h)
            show_help
            ;;
        
        *)
            print_error "未知命令: $1"
            show_help
            exit 1
            ;;
    esac
}

# 运行主程序
main "$@"
