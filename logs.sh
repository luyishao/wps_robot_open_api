#!/bin/bash

###############################################################################
# WPS Robot Open API 日志管理脚本
#
# 功能：
# - 查看实时日志
# - 导出日志文件
# - 清理旧日志
# - 分析错误日志
#
# 使用方法：
#   chmod +x logs.sh
#   ./logs.sh [选项]
#
# 选项：
#   --view         查看实时日志（默认）
#   --view-error   查看错误日志
#   --view-webhook 查看webhook日志
#   --export       导出所有日志
#   --export-error 仅导出错误日志
#   --tail=N       查看最后N行日志（默认100）
#   --clean        清理30天前的日志
#   --help         显示帮助信息
###############################################################################

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 配置
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOGS_DIR="${SCRIPT_DIR}/logs"
EXPORT_DIR="${SCRIPT_DIR}/logs_export"
TAIL_LINES=100
ACTION="view"

# 日志函数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

# 打印标题
print_banner() {
    echo -e "${GREEN}"
    echo "================================================================"
    echo "    WPS Robot Open API 日志管理"
    echo "================================================================"
    echo -e "${NC}"
}

# 显示帮助信息
show_help() {
    cat << EOF
WPS Robot Open API 日志管理脚本

使用方法：
    ./logs.sh [选项]

选项：
    --view              查看实时日志（默认）
    --view-error        查看错误日志
    --view-webhook      查看webhook日志
    --export            导出所有日志
    --export-error      仅导出错误日志
    --tail=N            查看最后N行日志（默认100）
    --clean             清理30天前的日志
    --follow            实时跟踪日志（tail -f）
    --help              显示帮助信息

示例：
    # 查看最后100行日志
    ./logs.sh

    # 查看最后500行日志
    ./logs.sh --tail=500

    # 查看错误日志
    ./logs.sh --view-error

    # 实时跟踪webhook日志
    ./logs.sh --view-webhook --follow

    # 导出所有日志
    ./logs.sh --export

    # 清理旧日志
    ./logs.sh --clean

EOF
}

# 检查日志目录
check_logs_dir() {
    if [ ! -d "$LOGS_DIR" ]; then
        log_warning "日志目录不存在: $LOGS_DIR"
        log_info "正在创建日志目录..."
        mkdir -p "$LOGS_DIR"
        log_success "日志目录已创建"
        return 1
    fi
    return 0
}

# 查看日志
view_logs() {
    local log_file="$1"
    local log_name="$2"
    local follow="$3"

    if [ ! -f "$log_file" ]; then
        log_warning "${log_name}日志文件不存在: $log_file"
        return 1
    fi

    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  ${log_name}日志 (最后 ${TAIL_LINES} 行)${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    if [ "$follow" = "true" ]; then
        log_info "实时跟踪模式（按Ctrl+C退出）..."
        tail -f "$log_file"
    else
        tail -n "$TAIL_LINES" "$log_file"
    fi
}

# 导出日志
export_logs() {
    local export_all="$1"
    
    # 创建导出目录
    local timestamp=$(date +"%Y%m%d_%H%M%S")
    local export_path="${EXPORT_DIR}/logs_${timestamp}"
    mkdir -p "$export_path"
    
    log_info "导出日志到: $export_path"
    
    if [ "$export_all" = "true" ]; then
        # 导出所有日志
        if [ -f "${LOGS_DIR}/django.log" ]; then
            cp "${LOGS_DIR}/django.log"* "$export_path/" 2>/dev/null
            log_success "已导出 django.log"
        fi
        
        if [ -f "${LOGS_DIR}/error.log" ]; then
            cp "${LOGS_DIR}/error.log"* "$export_path/" 2>/dev/null
            log_success "已导出 error.log"
        fi
        
        if [ -f "${LOGS_DIR}/webhook.log" ]; then
            cp "${LOGS_DIR}/webhook.log"* "$export_path/" 2>/dev/null
            log_success "已导出 webhook.log"
        fi
    else
        # 仅导出错误日志
        if [ -f "${LOGS_DIR}/error.log" ]; then
            cp "${LOGS_DIR}/error.log"* "$export_path/" 2>/dev/null
            log_success "已导出 error.log"
        else
            log_warning "错误日志文件不存在"
            return 1
        fi
    fi
    
    # 创建压缩包
    cd "$EXPORT_DIR"
    tar -czf "logs_${timestamp}.tar.gz" "logs_${timestamp}"
    rm -rf "logs_${timestamp}"
    
    log_success "日志已导出并压缩: ${EXPORT_DIR}/logs_${timestamp}.tar.gz"
    
    # 显示文件大小
    local size=$(du -h "${EXPORT_DIR}/logs_${timestamp}.tar.gz" | cut -f1)
    log_info "压缩包大小: $size"
}

# 清理旧日志
clean_logs() {
    log_info "正在清理30天前的日志..."
    
    local count=0
    
    # 清理旧的轮转日志文件
    if [ -d "$LOGS_DIR" ]; then
        find "$LOGS_DIR" -name "*.log.*" -type f -mtime +30 -print | while read file; do
            log_info "删除: $(basename "$file")"
            rm -f "$file"
            ((count++))
        done
    fi
    
    # 清理旧的导出文件
    if [ -d "$EXPORT_DIR" ]; then
        find "$EXPORT_DIR" -name "logs_*.tar.gz" -type f -mtime +30 -print | while read file; do
            log_info "删除: $(basename "$file")"
            rm -f "$file"
            ((count++))
        done
    fi
    
    if [ $count -eq 0 ]; then
        log_success "没有需要清理的旧日志"
    else
        log_success "已清理 $count 个旧日志文件"
    fi
}

# 分析错误日志
analyze_errors() {
    local error_log="${LOGS_DIR}/error.log"
    
    if [ ! -f "$error_log" ]; then
        log_warning "错误日志文件不存在"
        return 1
    fi
    
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}  错误日志分析${NC}"
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    echo -e "\n${YELLOW}最近的错误（最后10条）:${NC}"
    tail -n 10 "$error_log"
    
    echo -e "\n${YELLOW}错误统计:${NC}"
    echo "总错误数: $(wc -l < "$error_log")"
    
    if command -v awk &> /dev/null; then
        echo -e "\n${YELLOW}错误类型分布:${NC}"
        grep -E "\[ERROR\]" "$error_log" | awk '{print $4}' | sort | uniq -c | sort -rn | head -10
    fi
}

# 解析命令行参数
FOLLOW_MODE=false

while [ $# -gt 0 ]; do
    case "$1" in
        --view)
            ACTION="view"
            shift
            ;;
        --view-error)
            ACTION="view_error"
            shift
            ;;
        --view-webhook)
            ACTION="view_webhook"
            shift
            ;;
        --export)
            ACTION="export"
            shift
            ;;
        --export-error)
            ACTION="export_error"
            shift
            ;;
        --clean)
            ACTION="clean"
            shift
            ;;
        --analyze)
            ACTION="analyze"
            shift
            ;;
        --tail=*)
            TAIL_LINES="${1#*=}"
            shift
            ;;
        --follow)
            FOLLOW_MODE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "未知选项: $1"
            show_help
            exit 1
            ;;
    esac
done

# 主程序
main() {
    print_banner
    
    # 检查日志目录
    check_logs_dir
    
    case "$ACTION" in
        view)
            view_logs "${LOGS_DIR}/django.log" "Django" "$FOLLOW_MODE"
            ;;
        view_error)
            view_logs "${LOGS_DIR}/error.log" "错误" "$FOLLOW_MODE"
            ;;
        view_webhook)
            view_logs "${LOGS_DIR}/webhook.log" "Webhook" "$FOLLOW_MODE"
            ;;
        export)
            export_logs true
            ;;
        export_error)
            export_logs false
            ;;
        clean)
            clean_logs
            ;;
        analyze)
            analyze_errors
            ;;
        *)
            log_error "未知操作: $ACTION"
            exit 1
            ;;
    esac
    
    echo ""
    log_success "操作完成"
}

# 运行主程序
main
