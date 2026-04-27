@echo off
:: ============================================================
:: RUN.CMD - Launcher cho Windows Pro Cleaner
:: Tự động xin quyền Admin + chạy script
:: ============================================================
title Windows Pro Cleaner - Launcher

:: Kiểm tra quyền Admin
net session >nul 2>&1
if %errorlevel% == 0 goto :run_as_admin

:: Chưa có quyền Admin → xin cấp quyền
echo.
echo  [!] Dang xin quyen Administrator...
echo  [!] Requesting Administrator privileges...
echo.

:: Dùng PowerShell để tự relaunch với quyền Admin
powershell -Command "Start-Process -FilePath 'cmd.exe' -ArgumentList '/c \"%~f0\"' -Verb RunAs"
exit /b

:run_as_admin
:: Đã có quyền Admin
echo.
echo  [OK] Da co quyen Administrator!
echo.

:: Đặt thư mục làm việc về nơi chứa file
cd /d "%~dp0"

:: Kiểm tra file cleaner.ps1 tồn tại
if not exist "%~dp0cleaner.ps1" (
    echo  [!] Khong tim thay cleaner.ps1!
    echo  [!] Vui long dat run.cmd cung thu muc voi cleaner.ps1
    pause
    exit /b 1
)

:: Khởi tạo file JSON nếu chưa có
if not exist "%~dp0cleaner_data.json" (
    echo [] > "%~dp0cleaner_data.json"
)

:: Khởi tạo file log nếu chưa có
if not exist "%~dp0cleaner_log.txt" (
    echo. > "%~dp0cleaner_log.txt"
)

echo  Dang khoi dong Pro Cleaner...
echo.

:: Chạy PowerShell với bypass execution policy
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0cleaner.ps1"

echo.
echo  [Pro Cleaner] Da ket thuc. Nhan phim bat ky de dong...
pause >nul
exit /b 0
