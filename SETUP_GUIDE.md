# คู่มือติดตั้ง multiCAD-mcp สำหรับ Claude Desktop

## ภาพรวม

**multiCAD-mcp** คือ MCP Server ที่ทำให้ AI อย่าง Claude สามารถควบคุมโปรแกรม CAD ได้โดยตรงผ่านคำสั่งภาษาธรรมชาติ

### โปรแกรม CAD ที่รองรับ
- AutoCAD 2018+
- ZWCAD 2020+
- GstarCAD 2020+
- BricsCAD 21+

### ความสามารถหลัก (7 MCP Tools / 55+ คำสั่ง)
- วาดรูปทรง: เส้น, วงกลม, ส่วนโค้ง, สี่เหลี่ยม, polyline, spline
- จัดการ Layer: สร้าง, เปลี่ยนชื่อ, ลบ, ซ่อน/แสดง
- จัดการ Block: สร้าง, แทรก, ตรวจสอบ (รองรับ Attribute)
- จัดการ Entity: ย้าย, หมุน, ปรับขนาด, คัดลอก, เลือก
- Export ข้อมูล: JSON และ Excel
- บันทึกไฟล์: DWG, DXF, PDF

---

## ข้อกำหนดระบบ

| รายการ | ข้อกำหนด |
|--------|----------|
| ระบบปฏิบัติการ | **Windows เท่านั้น** (ต้องการ COM Technology) |
| Python | 3.10 ขึ้นไป |
| Claude Desktop | เวอร์ชันล่าสุด |
| โปรแกรม CAD | อย่างน้อย 1 โปรแกรมที่รองรับ |

---

## ขั้นตอนการติดตั้ง (Windows)

### ขั้นตอนที่ 1: ติดตั้ง `uv` Package Manager

เปิด **PowerShell** แล้วรันคำสั่ง:

```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

หากเจอ Execution Policy Error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### ขั้นตอนที่ 2: ดาวน์โหลด multiCAD-mcp

```powershell
# Clone repository นี้ (ถ้ายังไม่ได้ clone)
git clone https://github.com/boyvsk-hub/rungkijcon.git
cd rungkijcon

# เข้าไปที่โฟลเดอร์ multiCAD-mcp
cd multiCAD-mcp
```

หรือ Clone ตรงจากต้นทาง:
```powershell
git clone https://github.com/AnCode666/multiCAD-mcp.git
cd multiCAD-mcp
```

### ขั้นตอนที่ 3: ติดตั้ง Dependencies

```powershell
# ติดตั้ง dependencies ทั้งหมด (สร้าง .venv อัตโนมัติ)
uv sync --dev

# อัพเกรด pywin32 (จำเป็นสำหรับการเชื่อมต่อ CAD)
uv run python -m pip install --upgrade pywin32
```

### ขั้นตอนที่ 4: ตรวจสอบการติดตั้ง

```powershell
# รัน tests เพื่อตรวจสอบ
uv run pytest tests/ -v

# ทดสอบ server (Ctrl+C เพื่อหยุด)
uv run python src/server.py
```

---

## การตั้งค่า Claude Desktop

### ขั้นตอนที่ 5: แก้ไข claude_desktop_config.json

เปิดไฟล์ config ของ Claude Desktop ที่:
```
%APPDATA%\Claude\claude_desktop_config.json
```

วิธีเปิดด้วย PowerShell:
```powershell
notepad "$env:APPDATA\Claude\claude_desktop_config.json"
```

### ขั้นตอนที่ 6: เพิ่ม MCP Server Configuration

แทรกโค้ดต่อไปนี้ (แทนที่ `YOUR_USERNAME` ด้วยชื่อผู้ใช้ Windows ของคุณ):

```json
{
  "mcpServers": {
    "multiCAD": {
      "command": "C:\\Users\\YOUR_USERNAME\\rungkijcon\\multiCAD-mcp\\.venv\\Scripts\\python.exe",
      "args": ["C:\\Users\\YOUR_USERNAME\\rungkijcon\\multiCAD-mcp\\src\\server.py"]
    }
  }
}
```

**สำคัญมาก**: ใช้ path เต็มไปยัง `.venv\Scripts\python.exe` เสมอ ห้ามใช้คำสั่ง `py` หรือ `python` ทั่วไป

หากติดตั้งที่โฟลเดอร์อื่น ให้ปรับ path ตามนั้น เช่น:
```json
{
  "mcpServers": {
    "multiCAD": {
      "command": "C:\\multiCAD-mcp\\.venv\\Scripts\\python.exe",
      "args": ["C:\\multiCAD-mcp\\src\\server.py"]
    }
  }
}
```

### ขั้นตอนที่ 7: รีสตาร์ท Claude Desktop

ปิดและเปิด Claude Desktop ใหม่เพื่อให้การตั้งค่ามีผล

---

## การตั้งค่า config.json (ขั้นสูง)

แก้ไขไฟล์ `multiCAD-mcp/src/config.json` เพื่อปรับแต่งการทำงาน:

```json
{
  "debug": false,
  "logging_level": "INFO",
  "cad": {
    "autocad": {
      "startup_wait_time": 20.0,
      "command_delay": 0.5
    },
    "zwcad": {
      "startup_wait_time": 15.0,
      "command_delay": 0.5
    }
  },
  "output": {
    "directory": "~/Documents/multiCAD Exports"
  },
  "dashboard": {
    "port": 8888,
    "host": "127.0.0.1"
  }
}
```

| ค่า | คำอธิบาย |
|-----|----------|
| `logging_level` | ระดับ log: DEBUG, INFO, WARNING, ERROR |
| `startup_wait_time` | เวลารอ CAD เปิด (วินาที) เพิ่มหาก CAD เปิดช้า |
| `command_delay` | ระยะเวลาระหว่างคำสั่ง (วินาที) |
| `dashboard.port` | พอร์ต Web Dashboard (ค่าเริ่มต้น: 8888) |
| `output.directory` | โฟลเดอร์บันทึกไฟล์ export |

---

## การใช้งาน

### เปิด CAD ก่อน แล้วบอก Claude

หลังติดตั้งเสร็จ เปิดโปรแกรม CAD ก่อน แล้วใช้ Claude Desktop สั่งงาน:

```
วาดวงกลมสีแดง ที่ตำแหน่ง 50,50 รัศมี 25
```

```
สร้าง layer ชื่อ "โครงสร้าง" สีน้ำเงิน
```

```
วาดกราฟ y = sin(x) พร้อมระบุแกน
```

```
export ข้อมูลทั้งหมดเป็น Excel
```

### Web Dashboard

เปิด browser ไปที่ `http://127.0.0.1:8888` เพื่อดูสถานะ CAD แบบ real-time

---

## การแก้ปัญหา

### ดู Log

```powershell
# ดู log ล่าสุด 50 บรรทัด
Get-Content logs\multicad_mcp.log -Tail 50

# ดู log แบบ real-time
Get-Content logs\multicad_mcp.log -Wait -Tail 20
```

### ปัญหาที่พบบ่อย

| ปัญหา | วิธีแก้ |
|-------|---------|
| Claude ไม่เห็น multiCAD tool | ตรวจสอบ path ใน claude_desktop_config.json และ restart Claude |
| เชื่อมต่อ CAD ไม่ได้ | เปิด CAD ก่อนใช้งาน, ตรวจสอบว่า CAD ที่ติดตั้งรองรับ |
| pywin32 error | รัน `uv run python -m pip install --upgrade pywin32` ใหม่ |
| Timeout error | เพิ่มค่า `startup_wait_time` ใน config.json |

---

## โครงสร้างไฟล์

```
multiCAD-mcp/
├── src/
│   ├── server.py              # Entry point หลัก
│   ├── config.json            # ไฟล์ตั้งค่า (แก้ไขได้)
│   ├── core/                  # Interface หลัก
│   ├── adapters/              # การเชื่อมต่อ CAD แต่ละโปรแกรม
│   └── mcp_tools/             # 7 MCP Tools
├── logs/                      # Log files (สร้างอัตโนมัติ)
├── tests/                     # Tests
└── .venv/                     # Virtual environment (สร้างโดย uv)
```

---

## ลิงก์ที่เกี่ยวข้อง

- [multiCAD-mcp GitHub](https://github.com/AnCode666/multiCAD-mcp)
- [เอกสาร multiCAD-mcp](https://AnCode666.github.io/multiCAD-mcp/)
- [Claude Desktop](https://claude.ai/download)
- [MCP Documentation](https://modelcontextprotocol.io/)
