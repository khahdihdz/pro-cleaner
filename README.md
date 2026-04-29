# 🧹 Windows 11 Cleaner Pro

> Bộ công cụ dọn rác hệ thống Windows 11 chuyên nghiệp — giao diện CMD đẹp, Dashboard hiện đại, thống kê trực quan.

---

## 📁 Cấu trúc thư mục

```
CleanerPro/
├── Cleaner.bat       ← Script dọn rác chính (chạy bằng CMD)
├── dashboard.html    ← Dashboard thống kê (mở bằng trình duyệt)
├── stats.json        ← File dữ liệu thống kê (tự động cập nhật)
└── README.md         ← Hướng dẫn này
```

---

## ⚙️ Yêu cầu hệ thống

| Yêu cầu | Chi tiết |
|---|---|
| Hệ điều hành | Windows 10 / 11 |
| Quyền | **Administrator** (bắt buộc) |
| Trình duyệt | Chrome / Edge / Firefox (để xem Dashboard) |
| Cài thêm | ❌ Không cần cài gì thêm |

---

## 🚀 Hướng dẫn sử dụng

### Bước 1 — Giải nén
Giải nén toàn bộ file vào **cùng một thư mục**, ví dụ:
```
D:\CleanerPro\
```

> ⚠️ **Quan trọng:** Ba file `Cleaner.bat`, `dashboard.html`, `stats.json` phải nằm **cùng thư mục** với nhau.

### Bước 2 — Chạy với quyền Admin
Chuột phải vào `Cleaner.bat` → chọn **"Run as administrator"**

```
Bắt buộc chạy quyền Admin để:
  • Dọn C:\Windows\Temp
  • Dọn C:\Windows\Prefetch
  • Làm sạch Recycle Bin
```

### Bước 3 — Chọn chức năng
Giao diện menu hiện ra trong CMD:

```
╔══════════════════════════════════════════════════════════╗
║         🧹  WINDOWS 11 CLEANER PRO  v2.0               ║
║           Công Cụ Dọn Rác Hệ Thống Chuyên Nghiệp       ║
╠══════════════════════════════════════════════════════════╣
║                                                          ║
║   [1]  🗑  Dọn Temp  (%temp% + C:\Windows\Temp)         ║
║   [2]  ⚡  Dọn Cache  (Prefetch + Recent + DNS)         ║
║   [3]  📂  Dọn Downloads  (file rác + file cũ)          ║
║   [4]  🗑  Dọn Recycle Bin  (Thùng rác)                 ║
║   [5]  🚀  Chạy toàn bộ  (Tất cả các bước trên)        ║
║   [6]  📊  Mở Dashboard  (Xem thống kê)                 ║
║   [0]  ❌  Thoát                                         ║
║                                                          ║
╚══════════════════════════════════════════════════════════╝
```

### Bước 4 — Xem Dashboard
Chọn `[6]` trong menu **hoặc** mở thẳng file `dashboard.html` bằng trình duyệt.

Dashboard tự động làm mới mỗi **10 giây**.

---

## 🔍 Chi tiết chức năng

### [1] Dọn Temp
Xóa toàn bộ file tạm thời trong:
- `%TEMP%` — thư mục temp của người dùng hiện tại
- `C:\Windows\Temp` — thư mục temp hệ thống

### [2] Dọn Cache
- **Prefetch** (`C:\Windows\Prefetch\*.pf`) — cache khởi động ứng dụng
- **Recent** (`%AppData%\Microsoft\Windows\Recent`) — danh sách file gần đây
- **DNS Cache** — xóa bộ nhớ đệm DNS (`ipconfig /flushdns`)

### [3] Dọn Downloads
**Tự động xóa** (không cần xác nhận):
- `*.tmp` — file tạm
- `*.log` — file nhật ký
- `*.bak` — file sao lưu
- `*.old` — file cũ

**Hỏi xác nhận từng file** (nếu cũ quá 30 ngày):
- `*.exe` — file cài đặt
- `*.msi` — gói cài đặt Windows
- `*.zip` — file nén

> ℹ️ Không xóa thư mục con, chỉ xóa file trực tiếp trong Downloads.

### [4] Dọn Recycle Bin
Làm sạch hoàn toàn thùng rác Windows. Yêu cầu xác nhận trước khi thực hiện.

### [5] Chạy toàn bộ
Thực hiện tuần tự tất cả 4 bước trên. File rác trong Downloads được xóa tự động (không hỏi từng file để chạy nhanh).

### [6] Mở Dashboard
Mở `dashboard.html` bằng trình duyệt mặc định để xem thống kê trực quan.

---

## 📊 Dashboard — Tính năng

| Tính năng | Mô tả |
|---|---|
| Stat Cards | Tổng file xóa, MB giải phóng, trạng thái, thời gian |
| Progress Bars | Tỉ lệ % từng module (Temp / Downloads / Cache / Recycle) |
| Donut Chart | Biểu đồ tròn phân bổ file đã xóa (Chart.js) |
| Nhật ký | Bảng log chi tiết từng thao tác, có thanh cuộn |
| Auto Refresh | Tự làm mới mỗi 10 giây, có countdown bar |
| Dark Mode | Giao diện tối dịu mắt, responsive mọi màn hình |

---

## 📄 stats.json — Cấu trúc dữ liệu

File này do `Cleaner.bat` tự động ghi sau mỗi lần chạy. **Không cần chỉnh tay.**

```json
{
  "files_deleted": 245,
  "space_saved_mb": 1530,
  "last_run": "2026-04-27 15:20",
  "status": "Hoàn tất",
  "temp": 420,
  "downloads": 650,
  "cache": 260,
  "recycle": 200,
  "logs": [
    "Đã dọn Temp (420 file)",
    "Đã dọn Cache (260 mục)",
    "Đã dọn Downloads (650 file)",
    "Đã xóa Recycle Bin"
  ]
}
```

---

## ❓ Câu hỏi thường gặp

**Q: Tại sao phải chạy quyền Administrator?**
> Một số thư mục hệ thống như `C:\Windows\Temp` và `Prefetch` yêu cầu quyền admin để xóa file.

**Q: Dashboard không load dữ liệu?**
> Đảm bảo `dashboard.html` và `stats.json` nằm **cùng thư mục**. Một số trình duyệt chặn `fetch()` từ file local — hãy dùng **Microsoft Edge** hoặc **Google Chrome**.

**Q: File trong Downloads không bị xóa?**
> Chỉ xóa file có đuôi `.tmp .log .bak .old`. File `.exe/.msi/.zip` chỉ bị hỏi khi cũ hơn 30 ngày.

**Q: Có thể chạy tự động theo lịch không?**
> Có. Dùng **Task Scheduler** của Windows, tạo task chạy `Cleaner.bat` với tùy chọn **[5] Chạy toàn bộ** và đặt lịch hàng tuần.

**Q: Dung lượng giải phóng có chính xác không?**
> Con số MB là ước tính dựa trên số lượng file. Dung lượng thực tế có thể khác tùy kích thước từng file.

---

## 📝 Ghi chú

- Script **không** xóa file hệ thống quan trọng.
- Luôn **sao lưu dữ liệu** trước khi dọn Downloads nếu có file quan trọng.
- Dọn Temp và Cache là hoàn toàn an toàn, Windows sẽ tự tạo lại khi cần.

---

## 📜 License

Miễn phí sử dụng cho mục đích cá nhân và học tập.

---

*Windows 11 Cleaner Pro v2.0 — Được tạo với ❤️*
