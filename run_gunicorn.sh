#!/bin/bash
# 使用 Gunicorn 运行 Django 项目（前台运行，适合开发/调试）

set -e
cd "$(dirname "$0")"

# 优先使用虚拟环境
if [ -d "venv" ]; then
    GUNICORN="venv/bin/gunicorn"
else
    GUNICORN="gunicorn"
fi

if ! command -v $GUNICORN &> /dev/null; then
    echo "未找到 gunicorn，请先安装: pip install gunicorn"
    exit 1
fi

# 创建日志目录（与 Django settings.LOGS_DIR 一致）
mkdir -p logs

# 默认: 0.0.0.0:80，4 workers
HOST="${HOST:-0.0.0.0}"
PORT="${PORT:-80}"
WORKERS="${WORKERS:-4}"

# 明确指定工作目录，保证 Web 管理的系统日志路径与 Django 一致
PROJECT_DIR="$(pwd)"

echo "启动 Gunicorn: $HOST:$PORT, workers=$WORKERS"
echo "按 Ctrl+C 停止"
exec $GUNICORN \
    --chdir "$PROJECT_DIR" \
    --bind "$HOST:$PORT" \
    --workers "$WORKERS" \
    --worker-class sync \
    --timeout 60 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    wps_robot.wsgi:application
