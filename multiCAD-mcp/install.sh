#!/usr/bin/env bash
# multiCAD-mcp installer สำหรับ Linux / macOS (Dev mode)
# CAD ต้องใช้บน Windows เท่านั้น script นี้ใช้สำหรับพัฒนา/ทดสอบ

set -e

cd "$(dirname "$0")"

echo "============================================"
echo "  multiCAD-mcp - ติดตั้ง (Dev mode)"
echo "============================================"
echo

if [ ! -f "src/server.py" ]; then
    echo "[ERROR] กรุณารัน install.sh จากใน folder multiCAD-mcp"
    exit 1
fi

# ตรวจสอบ uv
if ! command -v uv &> /dev/null; then
    echo "[INFO] ติดตั้ง uv package manager..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    export PATH="$HOME/.local/bin:$PATH"
fi

echo "[INFO] ติดตั้ง Python dependencies..."
uv sync --dev

echo "[INFO] ทดสอบ import modules..."
uv run python -c "
import sys
sys.path.insert(0, 'src')
import server
print('[OK] server module โหลดได้')
print('[OK] MCP instance:', server.mcp)
"

echo "[INFO] รัน unit tests..."
uv run --with pytest python -m pytest tests/unit \
    --ignore=tests/unit/test_adapters.py -q 2>&1 | tail -5

echo
echo "============================================"
echo "  ติดตั้งเสร็จ (Dev mode)"
echo "============================================"
echo
echo "การใช้งาน:"
echo "  - รัน MCP server (stdio):  uv run python src/server.py"
echo "  - รัน Dashboard อย่างเดียว: uv run uvicorn web.api:api_app --app-dir src --port 8888"
echo "  - รัน tests:               uv run --with pytest python -m pytest tests/unit"
echo
echo "หมายเหตุ: CAD adapter ทำงานได้เฉพาะบน Windows เท่านั้น"
echo "        สำหรับ production บน Windows ให้ใช้ install.bat"
echo
