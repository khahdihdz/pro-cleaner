# ============================================================
# WINDOWS PRO CLEANER - cleaner.ps1
# Tác giả: Pro Cleaner Tool
# ============================================================

param(
    [switch]$auto
)

# ── Màu sắc ──────────────────────────────────────────────────
$ESC = [char]27
function Write-Color {
    param([string]$Text, [string]$Color = "White", [switch]$NoNewline)
    $colors = @{
        "Red"     = "Red"
        "Green"   = "Green"
        "Yellow"  = "Yellow"
        "Cyan"    = "Cyan"
        "Magenta" = "Magenta"
        "White"   = "White"
        "Gray"    = "Gray"
        "Blue"    = "Blue"
        "DarkRed" = "DarkRed"
    }
    $c = if ($colors.ContainsKey($Color)) { $colors[$Color] } else { "White" }
    if ($NoNewline) { Write-Host $Text -ForegroundColor $c -NoNewline }
    else            { Write-Host $Text -ForegroundColor $c }
}

# ── Đường dẫn file ───────────────────────────────────────────
$ScriptDir   = Split-Path -Parent $MyInvocation.MyCommand.Path
$JsonFile    = Join-Path $ScriptDir "cleaner_data.json"
$LogFile     = Join-Path $ScriptDir "cleaner_log.txt"
$DashFile    = Join-Path $ScriptDir "dashboard.html"

# ── Kiểm tra Admin ───────────────────────────────────────────
function Test-Admin {
    $id = [System.Security.Principal.WindowsIdentity]::GetCurrent()
    $p  = New-Object System.Security.Principal.WindowsPrincipal($id)
    return $p.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)
}

# ── Ghi Log ──────────────────────────────────────────────────
function Write-Log {
    param([string]$Message)
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Add-Content -Path $LogFile -Value "[$ts] $Message" -Encoding UTF8
}

# ── Hiển thị Progress Bar ────────────────────────────────────
function Show-Progress {
    param([string]$Activity, [int]$Duration = 20)
    Write-Color "" "White"
    for ($i = 0; $i -le 100; $i += 5) {
        $bar = "#" * ($i / 5) + "-" * (20 - $i / 5)
        Write-Color "`r  [$bar] $i% - $Activity" "Cyan" -NoNewline
        Start-Sleep -Milliseconds $Duration
    }
    Write-Color "" "White"
}

# ── Format kích thước ────────────────────────────────────────
function Format-Size {
    param([long]$Bytes)
    if ($Bytes -ge 1GB) { return "{0:N2} GB" -f ($Bytes / 1GB) }
    if ($Bytes -ge 1MB) { return "{0:N2} MB" -f ($Bytes / 1MB) }
    if ($Bytes -ge 1KB) { return "{0:N2} KB" -f ($Bytes / 1KB) }
    return "$Bytes B"
}

# ── Lấy dung lượng thư mục ───────────────────────────────────
function Get-FolderSize {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return 0 }
    try {
        $size = (Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
                 Where-Object { -not $_.PSIsContainer } |
                 Measure-Object -Property Length -Sum).Sum
        return [long]($size ?? 0)
    } catch { return 0 }
}

# ── Xóa thư mục an toàn ──────────────────────────────────────
function Remove-SafeFolder {
    param([string]$Path, [switch]$DryRun)
    if (-not (Test-Path $Path)) { return @{ Files = 0; Bytes = 0 } }

    $files   = Get-ChildItem -Path $Path -Recurse -Force -ErrorAction SilentlyContinue |
               Where-Object { -not $_.PSIsContainer }
    $count   = 0
    $deleted = 0L

    foreach ($f in $files) {
        try {
            if (-not $DryRun) {
                Remove-Item -Path $f.FullName -Force -ErrorAction Stop
                Write-Log "Đã xóa: $($f.FullName) ($( Format-Size $f.Length ))"
            }
            $count++
            $deleted += $f.Length
        } catch {
            # Bỏ qua file đang dùng
        }
    }
    return @{ Files = $count; Bytes = $deleted }
}

# ── Hiển thị dung lượng ổ đĩa ───────────────────────────────
function Show-DiskInfo {
    $drive = Get-PSDrive C
    $used  = $drive.Used
    $free  = $drive.Free
    $total = $used + $free
    $pct   = [int](($used / $total) * 100)
    $bar   = "█" * [int]($pct / 5) + "░" * (20 - [int]($pct / 5))

    Write-Color "`n  💾 Ổ đĩa C: " "Cyan" -NoNewline
    Write-Color "[$bar] $pct%" "Yellow"
    Write-Color "     Đã dùng : $(Format-Size $used)   Còn trống: $(Format-Size $free)   Tổng: $(Format-Size $total)" "Gray"
}

# ── Lưu JSON ─────────────────────────────────────────────────
function Save-Session {
    param([int]$FilesDeleted, [long]$TotalBytes, [long]$SystemBytes, [long]$DownloadsBytes)

    $entry = [PSCustomObject]@{
        time              = (Get-Date -Format "yyyy-MM-dd HH:mm")
        filesDeleted      = $FilesDeleted
        sizeFreedMB       = [math]::Round($TotalBytes / 1MB, 2)
        systemCleanMB     = [math]::Round($SystemBytes / 1MB, 2)
        downloadsCleanMB  = [math]::Round($DownloadsBytes / 1MB, 2)
    }

    $data = @()
    if (Test-Path $JsonFile) {
        try { $data = Get-Content $JsonFile -Raw | ConvertFrom-Json } catch {}
        if ($null -eq $data) { $data = @() }
    }

    $data += $entry
    $data | ConvertTo-Json -Depth 5 | Set-Content -Path $JsonFile -Encoding UTF8
    Write-Log "Session saved: $FilesDeleted files, $(Format-Size $TotalBytes) freed"
}

# ════════════════════════════════════════════════════════════
# 3. DỌN RÁC HỆ THỐNG
# ════════════════════════════════════════════════════════════
function Clean-System {
    param([switch]$DryRun)

    $targets = @(
        $env:TEMP,
        "C:\Windows\Temp",
        "C:\Windows\Prefetch",
        "$env:APPDATA\Microsoft\Windows\Recent",
        "C:\Windows\SoftwareDistribution\Download"
    )

    Write-Color "`n  🔍 Đang quét rác hệ thống..." "Cyan"
    Show-Progress "Quét hệ thống..." 15

    $totalFiles = 0
    $totalBytes = 0L

    foreach ($t in $targets) {
        if (Test-Path $t) {
            $r = Remove-SafeFolder -Path $t -DryRun:$DryRun
            $totalFiles += $r.Files
            $totalBytes += $r.Bytes
            Write-Color "    ✓ $t" "Green" -NoNewline
            Write-Color " → $($r.Files) files, $(Format-Size $r.Bytes)" "Gray"
        }
    }

    # Recycle Bin
    try {
        if (-not $DryRun) {
            Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        }
        Write-Color "    ✓ Thùng Rác đã xóa" "Green"
    } catch {}

    Write-Color "`n  ✅ Hệ thống: $totalFiles files | $(Format-Size $totalBytes)" "Yellow"
    return @{ Files = $totalFiles; Bytes = $totalBytes }
}

# ════════════════════════════════════════════════════════════
# 4. DỌN DOWNLOADS THÔNG MINH
# ════════════════════════════════════════════════════════════
function Clean-Downloads {
    param([switch]$DryRun, [switch]$Interactive)

    $dlPath = [System.Environment]::GetFolderPath("MyDocuments")
    $dlPath = Join-Path ([System.Environment]::GetFolderPath("UserProfile")) "Downloads"

    if (-not (Test-Path $dlPath)) {
        Write-Color "  ⚠ Không tìm thấy thư mục Downloads!" "Yellow"
        return @{ Files = 0; Bytes = 0 }
    }

    $groups = @{
        "Ảnh"     = @("jpg","jpeg","png","gif","webp","bmp","svg","ico","tiff")
        "Video"   = @("mp4","mkv","avi","mov","wmv","flv","webm","m4v")
        "Nén"     = @("zip","rar","7z","tar","gz","bz2","xz")
        "Cài đặt" = @("exe","msi","dmg","pkg","deb","rpm","appx")
        "Khác"    = @()
    }

    Write-Color "`n  🔍 Phân tích thư mục Downloads..." "Cyan"
    Show-Progress "Quét Downloads..." 10

    $allFiles   = Get-ChildItem -Path $dlPath -File -Recurse -ErrorAction SilentlyContinue
    $classified = @{}
    foreach ($g in $groups.Keys) { $classified[$g] = @() }

    foreach ($f in $allFiles) {
        $ext   = $f.Extension.TrimStart(".").ToLower()
        $found = $false
        foreach ($g in $groups.Keys) {
            if ($g -eq "Khác") { continue }
            if ($groups[$g] -contains $ext) {
                $classified[$g] += $f
                $found = $true
                break
            }
        }
        if (-not $found) { $classified["Khác"] += $f }
    }

    Write-Color "`n  📂 Phân loại Downloads:" "Cyan"
    $colors = @{ "Ảnh" = "Magenta"; "Video" = "Blue"; "Nén" = "Yellow"; "Cài đặt" = "Red"; "Khác" = "Gray" }
    $icons  = @{ "Ảnh" = "🖼"; "Video" = "🎬"; "Nén" = "📦"; "Cài đặt" = "⚙"; "Khác" = "📄" }

    $groupStats = @{}
    foreach ($g in @("Ảnh","Video","Nén","Cài đặt","Khác")) {
        $sz = ($classified[$g] | Measure-Object -Property Length -Sum).Sum ?? 0
        $groupStats[$g] = @{ Files = $classified[$g].Count; Bytes = [long]$sz }
        $line = "    $($icons[$g])  {0,-12} {1,6} files   {2}" -f $g, $classified[$g].Count, (Format-Size $sz)
        Write-Color $line $colors[$g]
    }

    $totalFiles = 0
    $totalBytes = 0L

    if ($Interactive -and -not $DryRun) {
        Write-Color "`n  Chọn nhóm để xóa (VD: 1 3 4 hoặc Enter để bỏ qua):" "Cyan"
        $opts = @("Ảnh","Video","Nén","Cài đặt","Khác")
        for ($i=0; $i -lt $opts.Count; $i++) {
            Write-Color "    [$($i+1)] $($opts[$i])" "White"
        }
        Write-Color "    [6] Xóa file cũ hơn X ngày" "White"
        Write-Color "    [0] Bỏ qua" "Gray"
        Write-Color "`n  Lựa chọn: " "Yellow" -NoNewline
        $choice = Read-Host

        if ($choice -match "6") {
            Write-Color "  Nhập số ngày (VD: 30): " "Yellow" -NoNewline
            $days = [int](Read-Host)
            $cutoff = (Get-Date).AddDays(-$days)
            $oldFiles = $allFiles | Where-Object { $_.LastWriteTime -lt $cutoff }
            foreach ($f in $oldFiles) {
                try {
                    if (-not $DryRun) { Remove-Item $f.FullName -Force -ErrorAction Stop }
                    $totalFiles++
                    $totalBytes += $f.Length
                } catch {}
            }
            Write-Color "  ✅ Đã xóa $totalFiles file cũ hơn $days ngày" "Green"
        } else {
            $selections = $choice -split " " | ForEach-Object { $_.Trim() } | Where-Object { $_ -match "^[1-5]$" }
            foreach ($sel in $selections) {
                $gName = $opts[[int]$sel - 1]
                foreach ($f in $classified[$gName]) {
                    try {
                        if (-not $DryRun) { Remove-Item $f.FullName -Force -ErrorAction Stop }
                        $totalFiles++
                        $totalBytes += $f.Length
                    } catch {}
                }
            }
        }
    } elseif (-not $Interactive) {
        # Auto mode: xóa exe, msi, zip cũ hơn 30 ngày
        $cutoff = (Get-Date).AddDays(-30)
        foreach ($g in @("Nén","Cài đặt")) {
            foreach ($f in $classified[$g]) {
                if ($f.LastWriteTime -lt $cutoff) {
                    try {
                        if (-not $DryRun) { Remove-Item $f.FullName -Force -ErrorAction Stop }
                        $totalFiles++
                        $totalBytes += $f.Length
                    } catch {}
                }
            }
        }
    }

    Write-Color "`n  ✅ Downloads: $totalFiles files | $(Format-Size $totalBytes)" "Yellow"
    return @{ Files = $totalFiles; Bytes = $totalBytes }
}

# ════════════════════════════════════════════════════════════
# 6. TẠO LỊCH TỰ ĐỘNG
# ════════════════════════════════════════════════════════════
function Tao-LichTuDong {
    $scriptPath = $MyInvocation.ScriptName
    if (-not $scriptPath) { $scriptPath = Join-Path $ScriptDir "cleaner.ps1" }

    $action  = New-ScheduledTaskAction -Execute "powershell.exe" `
                -Argument "-ExecutionPolicy Bypass -WindowStyle Hidden -File `"$scriptPath`" -auto"
    $trigger = New-ScheduledTaskTrigger -Weekly -DaysOfWeek Sunday -At "09:00"
    $settings= New-ScheduledTaskSettingsSet -RunOnlyIfIdle:$false -StartWhenAvailable

    try {
        Register-ScheduledTask -TaskName "ProCleaner-Weekly" `
            -Action $action -Trigger $trigger -Settings $settings `
            -RunLevel Highest -Force | Out-Null
        Write-Color "`n  ✅ Đã tạo lịch: Chủ Nhật 9:00 sáng hàng tuần!" "Green"
        Write-Log "Scheduled task created: ProCleaner-Weekly"
    } catch {
        Write-Color "`n  ❌ Lỗi tạo lịch: $_" "Red"
    }
}

# ════════════════════════════════════════════════════════════
# HEADER
# ════════════════════════════════════════════════════════════
function Show-Header {
    Clear-Host
    Write-Color "╔══════════════════════════════════════════════╗" "Cyan"
    Write-Color "║     🧹  WINDOWS PRO CLEANER  v2.0           ║" "Cyan"
    Write-Color "║         Tool Dọn Rác Chuyên Nghiệp          ║" "Cyan"
    Write-Color "╚══════════════════════════════════════════════╝" "Cyan"
    $ts = Get-Date -Format "dd/MM/yyyy HH:mm:ss"
    Write-Color "  📅 $ts" "Gray"
    if (Test-Admin) {
        Write-Color "  🛡  Chế độ: ADMIN" "Green"
    } else {
        Write-Color "  ⚠  Chế độ: Thường (một số tính năng bị hạn chế)" "Yellow"
    }
    Show-DiskInfo
    Write-Color "" "White"
}

function Show-Menu {
    Write-Color "  ┌─────────────────────────────────────────┐" "Blue"
    Write-Color "  │              MENU CHÍNH                 │" "Blue"
    Write-Color "  ├─────────────────────────────────────────┤" "Blue"
    Write-Color "  │  [1] 🗑  Dọn rác hệ thống               │" "White"
    Write-Color "  │  [2] 📂 Dọn thư mục Downloads           │" "White"
    Write-Color "  │  [3] 🚀 Dọn tất cả (nhanh)              │" "White"
    Write-Color "  │  [4] 🔍 Quét trước (Dry-Run)            │" "White"
    Write-Color "  │  [5] 📊 Mở Dashboard thống kê           │" "White"
    Write-Color "  │  [6] ⏰ Bật auto dọn hàng tuần          │" "White"
    Write-Color "  │  [0] 🚪 Thoát                           │" "Gray"
    Write-Color "  └─────────────────────────────────────────┘" "Blue"
    Write-Color "`n  Nhập lựa chọn: " "Yellow" -NoNewline
}

# ════════════════════════════════════════════════════════════
# CHẾ ĐỘ AUTO
# ════════════════════════════════════════════════════════════
if ($auto) {
    Write-Log "=== AUTO MODE STARTED ==="
    $sys = Clean-System
    $dl  = Clean-Downloads
    $total = $sys.Files + $dl.Files
    $bytes = $sys.Bytes + $dl.Bytes
    Save-Session -FilesDeleted $total -TotalBytes $bytes -SystemBytes $sys.Bytes -DownloadsBytes $dl.Bytes
    Write-Log "=== AUTO MODE DONE: $total files, $(Format-Size $bytes) freed ==="
    exit 0
}

# ════════════════════════════════════════════════════════════
# MAIN LOOP
# ════════════════════════════════════════════════════════════
Write-Log "=== SESSION STARTED ==="

do {
    Show-Header
    Show-Menu
    $choice = Read-Host

    switch ($choice) {
        "1" {
            Write-Color "`n  🗑  Bắt đầu dọn rác hệ thống..." "Cyan"
            $sys = Clean-System
            Save-Session -FilesDeleted $sys.Files -TotalBytes $sys.Bytes -SystemBytes $sys.Bytes -DownloadsBytes 0
            Write-Color "`n  Nhấn Enter để tiếp tục..." "Gray"
            Read-Host | Out-Null
        }
        "2" {
            Write-Color "`n  📂 Bắt đầu dọn Downloads..." "Cyan"
            $dl = Clean-Downloads -Interactive
            Save-Session -FilesDeleted $dl.Files -TotalBytes $dl.Bytes -SystemBytes 0 -DownloadsBytes $dl.Bytes
            Write-Color "`n  Nhấn Enter để tiếp tục..." "Gray"
            Read-Host | Out-Null
        }
        "3" {
            Write-Color "`n  🚀 Dọn toàn bộ hệ thống..." "Cyan"
            $sys = Clean-System
            $dl  = Clean-Downloads
            $total = $sys.Files + $dl.Files
            $bytes = $sys.Bytes + $dl.Bytes
            Save-Session -FilesDeleted $total -TotalBytes $bytes -SystemBytes $sys.Bytes -DownloadsBytes $dl.Bytes
            Write-Color "`n  🎉 HOÀN TẤT! Đã giải phóng: $(Format-Size $bytes)" "Green"
            Write-Color "  Mở Dashboard? (Y/N): " "Yellow" -NoNewline
            if ((Read-Host) -eq "Y") { Start-Process $DashFile }
        }
        "4" {
            Write-Color "`n  🔍 CHẾ ĐỘ DRY-RUN (không xóa thật)..." "Magenta"
            $sys = Clean-System -DryRun
            $dl  = Clean-Downloads -DryRun
            $total = $sys.Files + $dl.Files
            $bytes = $sys.Bytes + $dl.Bytes
            Write-Color "`n  ═══════════════════════════════════" "Magenta"
            Write-Color "  📊 KẾT QUẢ QUÉT:" "Magenta"
            Write-Color "     🗑 Hệ thống   : $($sys.Files) files | $(Format-Size $sys.Bytes)" "White"
            Write-Color "     📂 Downloads  : $($dl.Files) files | $(Format-Size $dl.Bytes)" "White"
            Write-Color "     📦 Tổng cộng  : $total files | $(Format-Size $bytes)" "Yellow"
            Write-Color "  ═══════════════════════════════════" "Magenta"
            Write-Color "`n  Nhấn Enter để tiếp tục..." "Gray"
            Read-Host | Out-Null
        }
        "5" {
            if (Test-Path $DashFile) {
                Start-Process $DashFile
                Write-Color "  ✅ Đã mở Dashboard!" "Green"
            } else {
                Write-Color "  ❌ Không tìm thấy dashboard.html!" "Red"
            }
            Start-Sleep -Seconds 1
        }
        "6" {
            if (-not (Test-Admin)) {
                Write-Color "  ❌ Cần quyền Admin để tạo lịch!" "Red"
            } else {
                Tao-LichTuDong
            }
            Write-Color "`n  Nhấn Enter để tiếp tục..." "Gray"
            Read-Host | Out-Null
        }
        "0" {
            Write-Color "`n  👋 Tạm biệt! Cảm ơn đã dùng Pro Cleaner." "Cyan"
            Write-Log "=== SESSION ENDED ==="
        }
        default {
            Write-Color "  ⚠  Lựa chọn không hợp lệ!" "Red"
            Start-Sleep -Seconds 1
        }
    }
} while ($choice -ne "0")
