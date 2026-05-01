# 🧹 Windows 11 Cleaner Pro — v2.5

Công cụ dọn rác hệ thống Windows 11 viết bằng Batch Script, kèm Dashboard HTML trực quan hiển thị thống kê sau mỗi lần dọn.

---

## 📦 Nội dung bộ cài

```
CleanerPro/
├── Cleaner.bat       ← Script chính, chạy file này
├── dashboard.html    ← Giao diện dashboard (mở qua Cleaner.bat)
├── stats.json        ← Dữ liệu thống kê (tự tạo sau lần dọn đầu)
└── README.md         ← Tài liệu này
```

---

## ✅ Yêu cầu hệ thống

| Thành phần | Yêu cầu |
|---|---|
| Hệ điều hành | Windows 10 / 11 |
| Python | 3.6 trở lên (để mở Dashboard) |
| Quyền | Chạy với quyền **Administrator** |
| PowerShell | Có sẵn trên Windows (dùng để ghi file, tắt server) |

> **Tải Python:** https://www.python.org/downloads/  
> Khi cài, nhớ tick **"Add Python to PATH"**

---

## 🚀 Cách sử dụng

1. Chuột phải vào `Cleaner.bat` → **Run as administrator**
2. Chọn chức năng từ menu:

```
[1]  Dọn Temp       — Xóa %TEMP% và C:\Windows\Temp
[2]  Dọn Cache      — Prefetch, Recent, DNS cache
[3]  Dọn Downloads  — Xóa file rác trong thư mục Downloads
[4]  Dọn Recycle Bin— Làm sạch thùng rác
[5]  Chạy toàn bộ  — Thực hiện tất cả 4 bước trên
[6]  Mở Dashboard   — Xem thống kê trên trình duyệt
[0]  Thoát
```

---

## 🗂️ Chi tiết từng chức năng

### [1] Dọn Temp
- Xóa toàn bộ file trong `%TEMP%` (thư mục temp của người dùng)
- Xóa file trong `C:\Windows\Temp`
- Tự tạo lại thư mục sau khi xóa để Windows không bị lỗi

### [2] Dọn Cache
- Xóa file `*.pf` trong `C:\Windows\Prefetch`
- Xóa Recent files (`%APPDATA%\Microsoft\Windows\Recent`)
- Xóa DNS cache (`ipconfig /flushdns`)

### [3] Dọn Downloads
- **Giữ nguyên toàn bộ cấu trúc thư mục con** trong `Downloads`
- Chỉ xóa các file rác (`.tmp`, `.log`, `.bak`, `.old`) trong:
  - Thư mục gốc `Downloads\`
  - Từng thư mục con hiện có (1 cấp)
- Hỏi xác nhận từng file cài đặt (`.exe`, `.msi`, `.zip`) cũ hơn 30 ngày

### [4] Dọn Recycle Bin
- Hỏi xác nhận trước khi xóa
- Dùng PowerShell `Clear-RecycleBin` để dọn sạch

### [5] Chạy toàn bộ
- Thực hiện tuần tự bước 1→4 không hỏi từng bước
- Sau khi xong hiển thị tổng kết và hỏi có mở Dashboard không

### [6] Mở Dashboard
- Khởi động HTTP server Python trên port tự do (8700–8800) qua **PowerShell ẩn**
- Mở trình duyệt tại `http://localhost:<port>/dashboard.html`
- Server **tự tắt** khi bạn đóng tab trình duyệt
- Server cũng bị dừng khi chọn `[0] Thoát` từ menu

---

## 📊 Dashboard

Dashboard đọc file `stats.json` và hiển thị:

- Tổng số file đã xóa & dung lượng giải phóng
- Phân tích theo danh mục: Temp / Downloads / Cache / Recycle Bin
- Biểu đồ tròn (Doughnut chart)
- Nhật ký hoạt động
- Tự động làm mới mỗi 30 giây

**Lưu ý quan trọng:** Luôn mở Dashboard qua menu `[6]` trong `Cleaner.bat`.  
Không mở `dashboard.html` trực tiếp bằng đôi click — trình duyệt sẽ chặn tải `stats.json` do giới hạn bảo mật `file://`.

---

## 🔧 Cơ chế tự tắt server

Khi đóng tab trình duyệt, JavaScript trong dashboard gửi request `GET /shutdown` đến Python server. Server nhận được tín hiệu này và tắt gracefully.

Nếu tab bị đóng đột ngột mà server chưa tắt, chọn `[0] Thoát` trong Cleaner.bat để dừng thủ công.

---

## 📝 File stats.json

Được ghi tự động sau mỗi lần dọn. Ví dụ nội dung:

```json
{
  "files_deleted": 142,
  "space_saved_mb": 28,
  "last_run": "2025-05-01 14:30",
  "status": "Hoan tat",
  "temp": 95,
  "downloads": 12,
  "cache": 35,
  "recycle": 50,
  "logs": [
    "Da don Temp (95 file)",
    "Da don Cache (35 muc)",
    "Da don Downloads (12 file)",
    "Da xoa Recycle Bin"
  ]
}
```

---

## ⚠️ Lưu ý

- Luôn chạy với quyền **Administrator** để xóa được `C:\Windows\Temp` và `Prefetch`
- Dung lượng giải phóng hiển thị là **ước tính**, không phải số chính xác tuyệt đối
- Không xóa file đang được chương trình khác sử dụng (Windows tự bảo vệ)
- Thư mục con trong `Downloads` được **giữ nguyên** — chỉ file rác bị xóa

---

## 🔄 Lịch sử phiên bản

| Phiên bản | Thay đổi |
|---|---|
| v2.5 | Python server chạy qua PowerShell; Dọn Downloads giữ thư mục con; Font tiếng Việt UTF-8 đầy đủ |
| v2.4 | Dashboard với auto-refresh, countdown bar, biểu đồ Chart.js |
| v2.0 | Thêm HTTP server Python, endpoint `/shutdown`, ghi stats.json UTF-8 |
| v1.0 | Script dọn rác cơ bản |

---

*Windows 11 Cleaner Pro — Made with ❤️ for Windows users*
