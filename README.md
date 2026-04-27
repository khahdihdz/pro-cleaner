# 🧹 Windows Pro Cleaner

> Công cụ dọn rác Windows tự động với Dashboard phân tích trực quan — chạy bằng PowerShell, xem kết quả trên trình duyệt.

---

## 📸 Tính năng

- **Dọn rác tự động** — xóa file tạm hệ thống, Temp, Prefetch, Downloads cũ
- **Ghi log JSON** — mỗi lần dọn lưu dữ liệu vào `cleaner_data.json`
- **Dashboard HTML** — biểu đồ bar/pie, KPI cards, bảng lịch sử, tự động reload 10 giây
- **Chạy 1 click** — double-click `run.cmd`, tự xin quyền Administrator
- **Không cần cài đặt** — chỉ cần PowerShell (có sẵn trên Windows 10/11)

---

## 📁 Cấu trúc thư mục

```
pro-cleaner/
├── cleaner.ps1         # Script PowerShell chính — dọn rác & ghi dữ liệu
├── run.cmd             # Launcher — tự xin quyền Admin & chạy script
├── dashboard.html      # Dashboard phân tích (Bootstrap + Chart.js)
├── cleaner_data.json   # Dữ liệu lịch sử dọn (tự sinh sau lần chạy đầu)
└── README.md
```

---

## 🚀 Cách sử dụng

### Bước 1 — Tải về

```
git clone https://github.com/YOUR_USERNAME/pro-cleaner.git
cd pro-cleaner
```

Hoặc tải ZIP từ nút **Code → Download ZIP** trên GitHub.

### Bước 2 — Chạy cleaner

Double-click vào **`run.cmd`**

> Windows sẽ hỏi xác nhận quyền Administrator → bấm **Yes**

Script sẽ tự động:
1. Quét và xóa file rác (Temp, %TEMP%, Prefetch, v.v.)
2. Ghi kết quả vào `cleaner_data.json`
3. Hiển thị thống kê ngay trên terminal

### Bước 3 — Xem Dashboard

Mở file **`dashboard.html`** bằng trình duyệt bất kỳ (Chrome, Edge, Firefox).

Dashboard sẽ tự động load dữ liệu từ `cleaner_data.json` và làm mới mỗi **10 giây**.

---

## 📊 Dashboard

| Widget | Mô tả |
|--------|--------|
| **KPI Cards** | Tổng lần dọn · Tổng dung lượng · Lần gần nhất · Trung bình/lần |
| **Bar Chart** | Lịch sử dọn rác theo từng lần (Hệ thống vs Downloads) |
| **Donut Chart** | Phân bổ % giữa Hệ thống và Downloads |
| **Top 5** | Bảng xếp hạng 5 lần dọn lớn nhất |
| **Log Table** | Lịch sử chi tiết tất cả các lần dọn |

---

## ⚙️ Yêu cầu hệ thống

| Yêu cầu | Chi tiết |
|---------|----------|
| **OS** | Windows 10 / Windows 11 |
| **PowerShell** | 5.1+ (có sẵn trên Windows 10/11) |
| **Quyền** | Administrator (run.cmd tự xin) |
| **Trình duyệt** | Bất kỳ (để xem Dashboard) |

---

## 📝 Cấu trúc dữ liệu JSON

Mỗi lần chạy cleaner sẽ append một bản ghi vào `cleaner_data.json`:

```json
[
  {
    "time": "2026-04-27 09:00",
    "filesDeleted": 164,
    "sizeFreedMB": 875.4,
    "systemCleanMB": 540.2,
    "downloadsCleanMB": 335.2
  }
]
```

| Field | Kiểu | Mô tả |
|-------|------|--------|
| `time` | string | Thời điểm chạy (yyyy-MM-dd HH:mm) |
| `filesDeleted` | number | Số file đã xóa |
| `sizeFreedMB` | number | Tổng dung lượng giải phóng (MB) |
| `systemCleanMB` | number | Dung lượng từ file hệ thống (MB) |
| `downloadsCleanMB` | number | Dung lượng từ thư mục Downloads (MB) |

---

## 🔒 Bảo mật

- Script **không** gửi dữ liệu ra internet
- Tất cả dữ liệu lưu **local** trong thư mục project
- Chỉ xóa các file tạm thời an toàn (Temp, Prefetch, thumbnail cache, v.v.)

---

## 📄 License

MIT License — tự do sử dụng, chỉnh sửa và phân phối.
