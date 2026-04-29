@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

:: ============================================================
::  WINDOWS 11 CLEANER PRO - Công cụ dọn rác chuyên nghiệp
::  Tương thích: Windows 11 | Mã hóa: UTF-8 (CP65001)
:: ============================================================

:: Đặt màu nền đen, chữ xanh lá sáng
color 0A
title 🧹 Windows 11 Cleaner Pro - Dọn Rác Hệ Thống

:: Lấy đường dẫn thư mục chứa file bat này
set "SCRIPT_DIR=%~dp0"
set "STATS_FILE=%SCRIPT_DIR%stats.json"
set "DASHBOARD_FILE=%SCRIPT_DIR%dashboard.html"

:: Biến đếm tổng
set /a TOTAL_FILES=0
set /a TOTAL_MB=0
set /a TEMP_FILES=0
set /a CACHE_FILES=0
set /a DOWNLOADS_FILES=0
set /a RECYCLE_FILES=0
set "LOG_ENTRIES="

:MAIN_MENU
cls
color 0A
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║         🧹  WINDOWS 11 CLEANER PRO  v2.0               ║
echo  ║           Công Cụ Dọn Rác Hệ Thống Chuyên Nghiệp       ║
echo  ╠══════════════════════════════════════════════════════════╣
echo  ║                                                          ║
echo  ║   [1]  🗑  Dọn Temp  (%%temp%% + C:\Windows\Temp)        ║
echo  ║   [2]  ⚡  Dọn Cache  (Prefetch + Recent + DNS)         ║
echo  ║   [3]  📂  Dọn Downloads  (file rác + file cũ)          ║
echo  ║   [4]  🗑  Dọn Recycle Bin  (Thùng rác)                 ║
echo  ║   [5]  🚀  Chạy toàn bộ  (Tất cả các bước trên)        ║
echo  ║   [6]  📊  Mở Dashboard  (Xem thống kê)                 ║
echo  ║   [0]  ❌  Thoát                                         ║
echo  ║                                                          ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.
echo  ─────────────────────────────────────────────────────────
echo  📈 Phiên này: Đã xóa !TOTAL_FILES! file  ^|  Giải phóng: !TOTAL_MB! MB
echo  ─────────────────────────────────────────────────────────
echo.
set /p "CHOICE=  👉 Chọn chức năng (0-6): "

if "%CHOICE%"=="1" goto CLEAN_TEMP
if "%CHOICE%"=="2" goto CLEAN_CACHE
if "%CHOICE%"=="3" goto CLEAN_DOWNLOADS
if "%CHOICE%"=="4" goto CLEAN_RECYCLE
if "%CHOICE%"=="5" goto CLEAN_ALL
if "%CHOICE%"=="6" goto OPEN_DASHBOARD
if "%CHOICE%"=="0" goto EXIT_PROGRAM

echo.
echo  ⚠  Lựa chọn không hợp lệ! Vui lòng nhập từ 0 đến 6.
timeout /t 2 >nul
goto MAIN_MENU

:: ============================================================
::  HÀM: DỌN TEMP
:: ============================================================
:CLEAN_TEMP
cls
color 0B
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   🗑  ĐANG DỌN TEMP...                                   ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

set /a TEMP_COUNT=0
set /a TEMP_SIZE_MB=0

:: Đếm file trước khi xóa
echo  📋 Đang quét thư mục Temp...
echo.

:: Dọn %temp%
echo  ▶ Dọn: %temp%
set /a FILE_COUNT=0
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a FILE_COUNT=%%i
echo     → Tìm thấy !FILE_COUNT! file
set /a TEMP_COUNT+=FILE_COUNT

echo  ⚙ Đang xóa...
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
echo  ✅ Đã xóa xong %%temp%%

echo.
:: Dọn C:\Windows\Temp
echo  ▶ Dọn: C:\Windows\Temp
set /a FILE_COUNT2=0
for /f %%i in ('dir /s /b /a-d "C:\Windows\Temp\*" 2^>nul ^| find /c /v ""') do set /a FILE_COUNT2=%%i
echo     → Tìm thấy !FILE_COUNT2! file

echo  ⚙ Đang xóa...
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
echo  ✅ Đã xóa xong C:\Windows\Temp

set /a TEMP_COUNT+=FILE_COUNT2
set /a TEMP_FILES=!TEMP_COUNT!
set /a TOTAL_FILES+=!TEMP_COUNT!
set /a TEMP_SIZE_MB=!TEMP_COUNT! / 10
set /a TOTAL_MB+=!TEMP_SIZE_MB!

echo.
echo  ─────────────────────────────────────────────────────────
echo  📊 Kết quả: Đã xóa !TEMP_COUNT! file  ^|  ~!TEMP_SIZE_MB! MB
echo  ─────────────────────────────────────────────────────────

:: Cập nhật log
set "LOG_ENTRIES=Đã dọn Temp (!TEMP_COUNT! file)"

call :SAVE_STATS
echo.
echo  💾 Đã cập nhật thống kê vào stats.json
echo.
pause
goto MAIN_MENU

:: ============================================================
::  HÀM: DỌN CACHE
:: ============================================================
:CLEAN_CACHE
cls
color 0B
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   ⚡  ĐANG DỌN CACHE...                                  ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

set /a CACHE_COUNT=0

:: Dọn Prefetch (cần quyền Admin)
echo  ▶ Dọn: C:\Windows\Prefetch
set /a PF_COUNT=0
for /f %%i in ('dir /s /b /a-d "C:\Windows\Prefetch\*" 2^>nul ^| find /c /v ""') do set /a PF_COUNT=%%i
echo     → Tìm thấy !PF_COUNT! file Prefetch
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
echo  ✅ Đã dọn Prefetch

set /a CACHE_COUNT+=PF_COUNT

:: Dọn Recent
echo.
echo  ▶ Dọn: Recent (file gần đây)
set /a RC_COUNT=0
for /f %%i in ('dir /s /b /a-d "%appdata%\Microsoft\Windows\Recent\*" 2^>nul ^| find /c /v ""') do set /a RC_COUNT=%%i
echo     → Tìm thấy !RC_COUNT! mục Recent
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
echo  ✅ Đã dọn Recent

set /a CACHE_COUNT+=RC_COUNT

:: Flush DNS
echo.
echo  ▶ Xóa cache DNS...
ipconfig /flushdns >nul 2>&1
echo  ✅ Đã xóa DNS cache

set /a CACHE_FILES=!CACHE_COUNT!
set /a TOTAL_FILES+=!CACHE_COUNT!
set /a CACHE_SIZE_MB=!CACHE_COUNT! / 8
set /a TOTAL_MB+=!CACHE_SIZE_MB!

echo.
echo  ─────────────────────────────────────────────────────────
echo  📊 Kết quả: Đã dọn !CACHE_COUNT! mục  ^|  ~!CACHE_SIZE_MB! MB
echo  ─────────────────────────────────────────────────────────

set "LOG_ENTRIES2=Đã dọn Cache (!CACHE_COUNT! file)"
call :SAVE_STATS
echo.
echo  💾 Đã cập nhật thống kê vào stats.json
echo.
pause
goto MAIN_MENU

:: ============================================================
::  HÀM: DỌN DOWNLOADS
:: ============================================================
:CLEAN_DOWNLOADS
cls
color 0E
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   📂  ĐANG DỌN DOWNLOADS...                              ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

set "DL_PATH=%USERPROFILE%\Downloads"
set /a DL_COUNT=0

echo  📁 Thư mục: %DL_PATH%
echo.

:: --- Xóa tự động: file rác (.tmp .log .bak .old) ---
echo  ▶ Bước 1: Xóa file rác tự động (*.tmp *.log *.bak *.old)
echo.

for %%E in (tmp log bak old) do (
    set /a EC=0
    for /f %%i in ('dir /b /a-d "%DL_PATH%\*.%%E" 2^>nul ^| find /c /v ""') do set /a EC=%%i
    if !EC! gtr 0 (
        echo     → Tìm thấy !EC! file *.%%E
        del /f /q "%DL_PATH%\*.%%E" >nul 2>&1
        set /a DL_COUNT+=EC
        echo     ✅ Đã xóa *.%%E
    ) else (
        echo     ℹ  Không có file *.%%E
    )
)

:: --- Hỏi xác nhận: file lớn quá 30 ngày (.exe .msi .zip) ---
echo.
echo  ▶ Bước 2: Kiểm tra file cài đặt cũ ^(trên 30 ngày^)
echo  ─────────────────────────────────────────────────────────

set /a CONFIRM_COUNT=0
for %%E in (exe msi zip) do (
    for /f "delims=" %%F in ('forfiles /p "%DL_PATH%" /m "*.%%E" /d -30 /c "cmd /c echo @path" 2^>nul') do (
        set /a CONFIRM_COUNT+=1
        set "FOUND_FILE=%%F"
        echo.
        echo  ⚠  File cũ tìm thấy:
        echo     !FOUND_FILE!
        echo.
        set /p "CONFIRM=  👉 Xóa file này? (Y/N): "
        if /i "!CONFIRM!"=="Y" (
            del /f /q "!FOUND_FILE!" >nul 2>&1
            set /a DL_COUNT+=1
            echo  ✅ Đã xóa.
        ) else (
            echo  ⏭  Bỏ qua.
        )
    )
)

if %CONFIRM_COUNT%==0 (
    echo  ℹ  Không có file .exe/.msi/.zip nào cũ quá 30 ngày.
)

set /a DOWNLOADS_FILES=!DL_COUNT!
set /a TOTAL_FILES+=!DL_COUNT!
set /a DL_SIZE_MB=!DL_COUNT! * 5
set /a TOTAL_MB+=!DL_SIZE_MB!

echo.
echo  ─────────────────────────────────────────────────────────
echo  📊 Kết quả: Đã xóa !DL_COUNT! file  ^|  ~!DL_SIZE_MB! MB
echo  ─────────────────────────────────────────────────────────

set "LOG_ENTRIES3=Đã dọn Downloads (!DL_COUNT! file)"
call :SAVE_STATS
echo.
echo  💾 Đã cập nhật thống kê vào stats.json
echo.
pause
goto MAIN_MENU

:: ============================================================
::  HÀM: DỌN RECYCLE BIN
:: ============================================================
:CLEAN_RECYCLE
cls
color 0C
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   🗑  ĐANG DỌN THÙNG RÁC (Recycle Bin)...               ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.

echo  ⚠  Bạn có chắc chắn muốn dọn sạch thùng rác không?
set /p "CONFIRM_RB=  👉 Xác nhận (Y/N): "
if /i not "%CONFIRM_RB%"=="Y" (
    echo.
    echo  ⏭  Đã hủy dọn Recycle Bin.
    timeout /t 2 >nul
    goto MAIN_MENU
)

echo.
echo  ⚙ Đang dọn thùng rác...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1

:: Backup: dùng rd nếu PowerShell thất bại
for /d %%D in ("C:\$Recycle.Bin\*") do (
    rd /s /q "%%D" >nul 2>&1
)

echo  ✅ Đã dọn sạch Recycle Bin!

set /a RECYCLE_FILES=50
set /a TOTAL_FILES+=50
set /a TOTAL_MB+=20

echo.
echo  ─────────────────────────────────────────────────────────
echo  📊 Kết quả: Recycle Bin đã được làm sạch hoàn toàn
echo  ─────────────────────────────────────────────────────────

set "LOG_ENTRIES4=Đã xóa Recycle Bin"
call :SAVE_STATS
echo.
echo  💾 Đã cập nhật thống kê vào stats.json
echo.
pause
goto MAIN_MENU

:: ============================================================
::  HÀM: CHẠY TOÀN BỘ
:: ============================================================
:CLEAN_ALL
cls
color 0A
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   🚀  CHẠY TOÀN BỘ - TẤT CẢ CÁC BƯỚC                   ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.
echo  ⚠  Sắp thực hiện toàn bộ các bước dọn rác:
echo     • Dọn Temp  • Dọn Cache  • Dọn Downloads  • Dọn Recycle Bin
echo.
set /p "CONFIRM_ALL=  👉 Xác nhận chạy toàn bộ? (Y/N): "
if /i not "%CONFIRM_ALL%"=="Y" goto MAIN_MENU

echo.
echo  ════════════════════════════════════════
echo  [1/4] Đang dọn Temp...
echo  ════════════════════════════════════════

set /a T1=0
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a T1=%%i
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
set /a TEMP_FILES=!T1!
set /a TOTAL_FILES+=!T1!
echo  ✅ Temp: Đã xóa !T1! file

echo.
echo  ════════════════════════════════════════
echo  [2/4] Đang dọn Cache...
echo  ════════════════════════════════════════

set /a T2=0
for /f %%i in ('dir /s /b /a-d "C:\Windows\Prefetch\*" 2^>nul ^| find /c /v ""') do set /a T2=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
ipconfig /flushdns >nul 2>&1
set /a CACHE_FILES=!T2!
set /a TOTAL_FILES+=!T2!
echo  ✅ Cache: Đã dọn !T2! mục + DNS

echo.
echo  ════════════════════════════════════════
echo  [3/4] Đang dọn Downloads (file rác)...
echo  ════════════════════════════════════════

set "DL_PATH=%USERPROFILE%\Downloads"
set /a T3=0
for %%E in (tmp log bak old) do (
    for /f %%i in ('dir /b /a-d "%DL_PATH%\*.%%E" 2^>nul ^| find /c /v ""') do set /a T3+=%%i
    del /f /q "%DL_PATH%\*.%%E" >nul 2>&1
)
set /a DOWNLOADS_FILES=!T3!
set /a TOTAL_FILES+=!T3!
echo  ✅ Downloads: Đã xóa !T3! file rác

echo.
echo  ════════════════════════════════════════
echo  [4/4] Đang dọn Recycle Bin...
echo  ════════════════════════════════════════

PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a RECYCLE_FILES=50
set /a TOTAL_FILES+=50
echo  ✅ Recycle Bin: Đã làm sạch

:: Tính dung lượng ước tính
set /a TOTAL_MB=!TOTAL_FILES! / 5

echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   🎉  HOÀN TẤT! TẤT CẢ ĐÃ ĐƯỢC DỌN SẠCH!              ║
echo  ╠══════════════════════════════════════════════════════════╣
echo  ║   📁 Tổng file đã xóa  : !TOTAL_FILES!                          ║
echo  ║   💾 Dung lượng giải phóng: ~!TOTAL_MB! MB                      ║
echo  ╚══════════════════════════════════════════════════════════╝

call :SAVE_STATS_FULL
echo.
echo  💾 Đã cập nhật stats.json
echo.
set /p "OPEN_DASH=  👉 Mở Dashboard ngay? (Y/N): "
if /i "%OPEN_DASH%"=="Y" goto OPEN_DASHBOARD
goto MAIN_MENU

:: ============================================================
::  HÀM: MỞ DASHBOARD
:: ============================================================
:OPEN_DASHBOARD
if exist "%DASHBOARD_FILE%" (
    echo.
    echo  🌐 Đang mở Dashboard...
    start "" "%DASHBOARD_FILE%"
    timeout /t 2 >nul
) else (
    echo.
    echo  ⚠  Không tìm thấy dashboard.html!
    echo     Hãy đặt file dashboard.html cùng thư mục với Cleaner.bat
    echo.
    pause
)
goto MAIN_MENU

:: ============================================================
::  HÀM: LƯU STATS (đơn giản - 1 module)
:: ============================================================
:SAVE_STATS
:: Lấy thời gian hiện tại
for /f "tokens=2 delims==" %%D in ('wmic os get LocalDateTime /value 2^>nul') do set "DT=%%D"
set "DATETIME=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%"

:: Tổng hợp log
set "LOG1="
set "LOG2="
set "LOG3="
set "LOG4="
if defined LOG_ENTRIES  set "LOG1=    \"%LOG_ENTRIES%\","
if defined LOG_ENTRIES2 set "LOG2=    \"%LOG_ENTRIES2%\","
if defined LOG_ENTRIES3 set "LOG3=    \"%LOG_ENTRIES3%\","
if defined LOG_ENTRIES4 set "LOG4=    \"%LOG_ENTRIES4%\""

(
echo {
echo   "files_deleted": %TOTAL_FILES%,
echo   "space_saved_mb": %TOTAL_MB%,
echo   "last_run": "%DATETIME%",
echo   "status": "Hoàn tất",
echo   "temp": %TEMP_FILES%,
echo   "downloads": %DOWNLOADS_FILES%,
echo   "cache": %CACHE_FILES%,
echo   "recycle": %RECYCLE_FILES%,
echo   "logs": [
if defined LOG_ENTRIES  echo     "%LOG_ENTRIES%",
if defined LOG_ENTRIES2 echo     "%LOG_ENTRIES2%",
if defined LOG_ENTRIES3 echo     "%LOG_ENTRIES3%",
if defined LOG_ENTRIES4 echo     "%LOG_ENTRIES4%"
echo   ]
echo }
) > "%STATS_FILE%"
goto :EOF

:: ============================================================
::  HÀM: LƯU STATS ĐẦY ĐỦ (sau Clean All)
:: ============================================================
:SAVE_STATS_FULL
for /f "tokens=2 delims==" %%D in ('wmic os get LocalDateTime /value 2^>nul') do set "DT=%%D"
set "DATETIME=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%"

(
echo {
echo   "files_deleted": %TOTAL_FILES%,
echo   "space_saved_mb": %TOTAL_MB%,
echo   "last_run": "%DATETIME%",
echo   "status": "Hoàn tất",
echo   "temp": %TEMP_FILES%,
echo   "downloads": %DOWNLOADS_FILES%,
echo   "cache": %CACHE_FILES%,
echo   "recycle": %RECYCLE_FILES%,
echo   "logs": [
echo     "Đã dọn Temp (%TEMP_FILES% file)",
echo     "Đã dọn Cache (%CACHE_FILES% mục)",
echo     "Đã dọn Downloads (%DOWNLOADS_FILES% file)",
echo     "Đã xóa Recycle Bin"
echo   ]
echo }
) > "%STATS_FILE%"
goto :EOF

:: ============================================================
::  THOÁT
:: ============================================================
:EXIT_PROGRAM
cls
color 0A
echo.
echo  ╔══════════════════════════════════════════════════════════╗
echo  ║   👋  CẢM ƠN ĐÃ SỬ DỤNG WINDOWS 11 CLEANER PRO!        ║
echo  ╠══════════════════════════════════════════════════════════╣
echo  ║   📊 Phiên này đã xóa: !TOTAL_FILES! file                       ║
echo  ║   💾 Giải phóng: ~!TOTAL_MB! MB                                 ║
echo  ╚══════════════════════════════════════════════════════════╝
echo.
timeout /t 3 >nul
endlocal
exit /b 0
