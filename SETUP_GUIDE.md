# คู่มือติดตั้ง multiCAD-mcp สำหรับ Claude Desktop

## ภาพรวม

**multiCAD-mcp** คือ MCP Server ที่ทำให้ AI อย่าง Claude สามารถควบคุมโปรแกรม CAD ได้โดยตรงผ่านคำสั่งภาษาธรรมชาติ

### โปรแกรม CAD ที่รองรับ
| โปรแกรม | เวอร์ชันขั้นต่ำ |
|---------|----------------|
| AutoCAD | 2018+ |
| ZWCAD | 2020+ |
| GstarCAD | 2020+ |
| BricsCAD | 21+ |

### ความสามารถหลัก (7 MCP Tools / 55+ คำสั่ง)
- **Drawing**: วาดเส้น, วงกลม, ส่วนโค้ง, สี่เหลี่ยม, polyline, spline
- **Layer**: สร้าง, เปลี่ยนชื่อ, ลบ, ซ่อน/แสดง
- **Block**: สร้าง, แทรก, ตรวจสอบ (รองรับ Attribute)
- **Entity**: ย้าย, หมุน, ปรับขนาด, คัดลอก, เลือก
- **Export**: JSON และ Excel
- **File**: บันทึก DWG, DXF, PDF
- **Session**: เชื่อมต่อ/ตัดการเชื่อมต่อ CAD, ดูประวัติ

---

## ข้อกำหนดระบบ

| รายการ | ข้อกำหนด |
|--------|----------|
| ระบบปฏิบัติการ | **Windows เท่านั้น** (ต้องการ COM Technology) |
| Python | 3.10 ขึ้นไป |
| uv | Package manager (ติดตั้งอัตโนมัติโดย install.bat) |
| Claude Desktop | เวอร์ชันล่าสุด |
| โปรแกรม CAD | อย่างน้อย 1 โปรแกรมที่รองรับ |

---

## วิธีติดตั้งแบบ 1 คลิก (แนะนำ)

### ขั้นตอนที่ 1: เปิด Folder multiCAD-mcp

เปิด File Explorer ไปที่ folder ที่ clone โปรเจกต์นี้มา แล้วเข้าไปใน:
```
RungkijCon\multiCAD-mcp\
```

### ขั้นตอนที่ 2: รัน install.bat

ดับเบิ้ลคลิก **`install.bat`** (หรือคลิกขวา → Run as Administrator)

Script จะทำทุกอย่างอัตโนมัติ:
- ✅ ติดตั้ง uv (ถ้ายังไม่มี)
- ✅ ติดตั้ง dependencies ทั้งหมด
- ✅ อัพเกรด pywin32
- ✅ สร้าง claude_desktop_config.json อัตโนมัติ
- ✅ ทดสอบว่าทุก package พร้อมใช้งาน

### ขั้นตอนที่ 3: Restart Claude Desktop

ปิดและเปิด Claude Desktop ใหม่ — multiCAD tools จะปรากฏทันที

### ขั้นตอนที่ 4: ใช้งาน

เปิด CAD แล้วสั่ง Claude:
```
วาดวงกลมสีแดง ที่ตำแหน่ง 50,50 รัศมี 25
```

---

## วิธีติดตั้งแบบ Manual (ถ้า install.bat ไม่ทำงาน)

### 1. ติดตั้ง uv

เปิด **PowerShell** แล้วรัน:
```powershell
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

หากเจอ Execution Policy Error:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. ติดตั้ง Dependencies

```powershell
cd multiCAD-mcp
uv sync --dev
uv run python -m pip install --upgrade pywin32
```

### 3. ตั้งค่า Claude Desktop

เปิดไฟล์ `%APPDATA%\Claude\claude_desktop_config.json` แล้วเพิ่ม:

```json
{
  "mcpServers": {
    "multiCAD": {
      "command": "C:\\Users\\ชื่อผู้ใช้\\RungkijCon\\multiCAD-mcp\\.venv\\Scripts\\python.exe",
      "args": ["C:\\Users\\ชื่อผู้ใช้\\RungkijCon\\multiCAD-mcp\\src\\server.py"]
    }
  }
}
```

ดูชื่อผู้ใช้ได้โดยรัน `echo %USERNAME%` ใน Command Prompt

---

## การตั้งค่า config.json (ขั้นสูง)

แก้ไขไฟล์ `multiCAD-mcp\src\config.json`:

```json
{
  "debug": false,
  "logging_level": "INFO",
  "cad": {
    "autocad": {
      "startup_wait_time": 20.0,
      "command_delay": 0.5
    }
  },
  "output": {
    "directory": "~/Documents/multiCAD Exports"
  },
  "dashboard": {
    "port": 8888
  }
}
```

| ค่า | คำอธิบาย |
|-----|----------|
| `logging_level` | DEBUG / INFO / WARNING / ERROR |
| `startup_wait_time` | วินาทีรอ CAD เปิด (เพิ่มถ้า CAD เปิดช้า) |
| `command_delay` | หน่วงเวลาระหว่างคำสั่ง (วินาที) |
| `dashboard.port` | พอร์ต Web Dashboard (ค่าเริ่มต้น: 8888) |
| `output.directory` | โฟลเดอร์บันทึกไฟล์ export |

---

## ตัวอย่างการใช้งาน

### วาดรูป
```
วาดวงกลมสีแดง ที่ตำแหน่ง 50,50 รัศมี 25
วาดเส้นจากจุด 0,0 ไปจุด 100,100
สร้างสี่เหลี่ยมที่ 10,10 ขนาด 80x60
```

### จัดการ Layer
```
สร้าง layer ชื่อ "โครงสร้าง" สีน้ำเงิน
ซ่อน layer ชื่อ "Dimension"
แสดง layer ทั้งหมด
```

### Block
```
สร้าง block จากที่เลือกไว้ ชื่อ "เสา-กลม"
แทรก block "เสา-กลม" ที่ตำแหน่ง 0,0
```

### Export
```
export ข้อมูลทั้งหมดเป็น Excel
export เฉพาะที่เลือกเป็น JSON
```

### งานซับซ้อน
```
วาดกราฟ y = sin(x) ตั้งแต่ -2π ถึง 2π พร้อมระบุแกน
สร้าง title block มาตรฐาน A3
```

---

## Web Dashboard

เปิด browser ไปที่ **http://127.0.0.1:8888** เพื่อดู:
- สถานะการเชื่อมต่อ CAD
- ประวัติคำสั่งที่รัน
- Entity และ Layer ใน Drawing ปัจจุบัน

---

## การแก้ปัญหา

### ดู Log
```powershell
# ดู log ล่าสุด 50 บรรทัด
Get-Content multiCAD-mcp\logs\multicad_mcp.log -Tail 50

# ดู log แบบ real-time
Get-Content multiCAD-mcp\logs\multicad_mcp.log -Wait -Tail 20
```

### ปัญหาที่พบบ่อย

| ปัญหา | วิธีแก้ |
|-------|---------|
| Claude ไม่เห็น multiCAD tool | Restart Claude Desktop หลังแก้ config |
| เชื่อมต่อ CAD ไม่ได้ | เปิด CAD ก่อนสั่ง Claude |
| pywin32 error | รัน `uv run python -m pip install --upgrade pywin32` |
| Timeout | เพิ่ม `startup_wait_time` ใน config.json |
| Execution Policy Error | รัน `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |

---

## โครงสร้างไฟล์

```
RungkijCon/
├── multiCAD-mcp/
│   ├── install.bat            ← รันตัวนี้เพื่อติดตั้ง (Windows)
│   ├── src/
│   │   ├── server.py          ← Entry point ของ MCP Server
│   │   ├── config.json        ← ตั้งค่าการทำงาน (แก้ไขได้)
│   │   ├── core/              ← Interface หลัก
│   │   ├── adapters/          ← ตัวเชื่อมต่อ CAD แต่ละโปรแกรม
│   │   └── mcp_tools/         ← 7 MCP Tools
│   ├── .venv/                 ← Virtual environment (สร้างโดย install.bat)
│   └── logs/                  ← Log files (สร้างอัตโนมัติ)
├── claude_desktop_config.json ← Template config สำหรับ Claude Desktop
└── SETUP_GUIDE.md             ← ไฟล์นี้
```

---

## ลิงก์ที่เกี่ยวข้อง

- [multiCAD-mcp GitHub](https://github.com/AnCode666/multiCAD-mcp)
- [เอกสาร multiCAD-mcp](https://AnCode666.github.io/multiCAD-mcp/)
- [Claude Desktop Download](https://claude.ai/download)
- [MCP Protocol](https://modelcontextprotocol.io/)
