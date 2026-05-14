@echo off
setlocal EnableDelayedExpansion

echo ============================================
echo   multiCAD-mcp - ติดตั้ง Dependencies
echo ============================================
echo.

:: ตรวจสอบว่าอยู่ใน folder ที่ถูกต้อง
if not exist "src\server.py" (
    echo [ERROR] กรุณารัน install.bat จากใน folder multiCAD-mcp
    pause
    exit /b 1
)

:: ตรวจสอบ uv
where uv >nul 2>&1
if errorlevel 1 (
    echo [INFO] ติดตั้ง uv package manager...
    powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
    set "PATH=%USERPROFILE%\.local\bin;%PATH%"
)

echo [INFO] ติดตั้ง Python dependencies...
uv sync --dev
if errorlevel 1 (
    echo [ERROR] uv sync ล้มเหลว
    pause
    exit /b 1
)

echo [INFO] อัพเกรด pywin32...
uv run python -m pip install --upgrade pywin32
if errorlevel 1 (
    echo [ERROR] pywin32 ติดตั้งไม่สำเร็จ
    pause
    exit /b 1
)

:: หา path ของ Python ใน .venv
set "PYTHON_PATH=%CD%\.venv\Scripts\python.exe"
set "SERVER_PATH=%CD%\src\server.py"

echo.
echo ============================================
echo   ตั้งค่า Claude Desktop
echo ============================================
echo.
echo เพิ่มโค้ดนี้ใน: %%APPDATA%%\Claude\claude_desktop_config.json
echo.
echo {
echo   "mcpServers": {
echo     "multiCAD": {
echo       "command": "%PYTHON_PATH:\=\\%",
echo       "args": ["%SERVER_PATH:\=\\%"]
echo     }
echo   }
echo }
echo.

:: สร้าง claude_desktop_config.json อัตโนมัติ
set "CONFIG_DIR=%APPDATA%\Claude"
set "CONFIG_FILE=%CONFIG_DIR%\claude_desktop_config.json"

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

if exist "%CONFIG_FILE%" (
    echo [WARNING] พบไฟล์ claude_desktop_config.json อยู่แล้ว
    echo          กรุณาเพิ่ม multiCAD block เข้าไปด้วยตนเอง
    echo          หรือกด Y เพื่อสร้างไฟล์ใหม่ (จะทับของเดิม)
    set /p OVERWRITE="Overwrite? (Y/N): "
    if /i "!OVERWRITE!" neq "Y" goto :skip_config
)

echo { > "%CONFIG_FILE%"
echo   "mcpServers": { >> "%CONFIG_FILE%"
echo     "multiCAD": { >> "%CONFIG_FILE%"
echo       "command": "%PYTHON_PATH:\=\\%", >> "%CONFIG_FILE%"
echo       "args": ["%SERVER_PATH:\=\\%"] >> "%CONFIG_FILE%"
echo     } >> "%CONFIG_FILE%"
echo   } >> "%CONFIG_FILE%"
echo } >> "%CONFIG_FILE%"

echo [OK] สร้าง claude_desktop_config.json สำเร็จ: %CONFIG_FILE%

:skip_config
echo.
echo ============================================
echo   ทดสอบการติดตั้ง
echo ============================================
echo.
uv run python -c "import fastmcp, mcp, openpyxl, PIL, fastapi, uvicorn, pydantic; print('[OK] ทุก package พร้อมใช้งาน')"

echo.
echo ============================================
echo   ติดตั้งเสร็จสมบูรณ์!
echo ============================================
echo.
echo ขั้นตอนถัดไป:
echo  1. Restart Claude Desktop
echo  2. เปิดโปรแกรม CAD (AutoCAD / ZWCAD / GstarCAD / BricsCAD)
echo  3. ใช้ Claude สั่งงาน เช่น: "วาดวงกลมสีแดง ที่ 50,50 รัศมี 25"
echo  4. ดู Dashboard ได้ที่: http://127.0.0.1:8888
echo.
pause
