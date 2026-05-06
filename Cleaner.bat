@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

color 0A
title Windows 11 Cleaner Pro v3.0 by https://khahdihdz.github.io

set "SCRIPT_DIR=%~dp0"
set "STATS_FILE=%SCRIPT_DIR%stats.json"
set "DASHBOARD_FILE=%SCRIPT_DIR%dashboard.html"

set /a TOTAL_FILES=0
set /a TOTAL_MB=0
set /a TEMP_FILES=0
set /a CACHE_FILES=0
set /a DL_FILES=0
set /a RC_FILES=0

rem -- Kiem tra che do tu dong (Scheduled Task goi: Cleaner.bat AUTO) --
if /i "%~1"=="AUTO" goto AUTO_MODE

goto MENU

rem ============================================================
rem  HAM IN DUONG KE NGANG
rem ============================================================
:LINE
echo  +==============================================================+
goto :EOF

:LINE2
echo  +--------------------------------------------------------------+
goto :EOF

rem ============================================================
rem  MENU CHINH
rem ============================================================
:MENU
cls
color 0A
call :LINE
echo  ^|  WINDOWS 11 CLEANER PRO  v3.0 - KHAHDIHDZ.GITHUB.IO                              ^|
echo  ^|  Cong Cu Don Rac He Thong - Windows 11                     ^|
call :LINE
echo  ^|                                                            ^|
echo  ^|   [1]  Don Temp     ( %%TEMP%% + C:\Windows\Temp )          ^|
echo  ^|   [2]  Don Cache    ( Prefetch, Recent, DNS )              ^|
echo  ^|   [3]  Don Downloads( file rac .tmp .log .bak .old )       ^|
echo  ^|   [4]  Don Recycle Bin ( Thung rac )                       ^|
echo  ^|   [5]  Chay toan bo ( Tat ca buoc tren )                   ^|
echo  ^|   [6]  Mo Dashboard ( Xem thong ke trinh duyet )           ^|
echo  ^|   [7]  Dinh ky tu dong ( Cai / Xem / Xoa lich )           ^|
echo  ^|   [0]  Thoat                                               ^|
echo  ^|                                                            ^|
call :LINE
echo.
echo    Phien nay: !TOTAL_FILES! file da xoa  ^|  Giai phong: !TOTAL_MB! MB
echo.
set /p "CHOICE=  >> Chon (0-7): "

if "!CHOICE!"=="1" goto CLEAN_TEMP
if "!CHOICE!"=="2" goto CLEAN_CACHE
if "!CHOICE!"=="3" goto CLEAN_DOWNLOADS
if "!CHOICE!"=="4" goto CLEAN_RECYCLE
if "!CHOICE!"=="5" goto CLEAN_ALL
if "!CHOICE!"=="6" goto OPEN_DASHBOARD
if "!CHOICE!"=="7" goto SCHEDULE_MENU
if "!CHOICE!"=="0" goto EXIT_PROGRAM

echo.
echo    [!] Lua chon khong hop le. Vui long chon tu 0 den 7.
timeout /t 2 >nul
goto MENU

rem ============================================================
rem  [1] DON TEMP
rem ============================================================
:CLEAN_TEMP
cls
color 0B
call :LINE
echo  ^|  [1] DON TEMP                                              ^|
call :LINE
echo.

set /a CNT=0
set /a CNT2=0

echo    Dang quet: %%TEMP%%
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a CNT=%%i
echo    Tim thay: !CNT! file
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
echo    [OK] Da xoa %%TEMP%%
echo.

echo    Dang quet: C:\Windows\Temp
for /f %%i in ('dir /s /b /a-d "C:\Windows\Temp\*" 2^>nul ^| find /c /v ""') do set /a CNT2=%%i
echo    Tim thay: !CNT2! file
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
echo    [OK] Da xoa C:\Windows\Temp

set /a TEMP_FILES=CNT+CNT2
set /a TOTAL_FILES+=TEMP_FILES
set /a TOTAL_MB+=TEMP_FILES/10

echo.
call :LINE2
echo    KET QUA: Da xoa !TEMP_FILES! file temp
call :LINE2
call :SAVE_STATS
echo    [OK] Da ghi stats.json
echo.
pause
goto MENU

rem ============================================================
rem  [2] DON CACHE
rem ============================================================
:CLEAN_CACHE
cls
color 0B
call :LINE
echo  ^|  [2] DON CACHE                                             ^|
call :LINE
echo.

set /a CC=0
set /a CC2=0

echo    Dang don: C:\Windows\Prefetch
for /f %%i in ('dir /b "C:\Windows\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set /a CC=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
echo    [OK] Da don Prefetch ( !CC! file )
echo.

echo    Dang don: Recent
for /f %%i in ('dir /b "%appdata%\Microsoft\Windows\Recent\*" 2^>nul ^| find /c /v ""') do set /a CC2=%%i
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
echo    [OK] Da don Recent ( !CC2! file )
echo.

echo    Dang xoa DNS cache...
ipconfig /flushdns >nul 2>&1
echo    [OK] Da xoa DNS cache

set /a CACHE_FILES=CC+CC2
set /a TOTAL_FILES+=CACHE_FILES
set /a TOTAL_MB+=CACHE_FILES/8

echo.
call :LINE2
echo    KET QUA: Da don !CACHE_FILES! muc cache
call :LINE2
call :SAVE_STATS
echo    [OK] Da ghi stats.json
echo.
pause
goto MENU

rem ============================================================
rem  [3] DON DOWNLOADS
rem ============================================================
:CLEAN_DOWNLOADS
cls
color 0E
call :LINE
echo  ^|  [3] DON DOWNLOADS                                         ^|
call :LINE
echo.

set "DLP=%USERPROFILE%\Downloads"
set /a DC=0
set /a ASK=0

echo    Thu muc: !DLP!
echo.
echo    [i] Xoa TOAN BO noi dung ben trong moi thu muc con.
echo    [i] Ban than thu muc con se DUOC GIU LAI.
echo    [i] Cau truc: Downloads\thu_muc_con\ (giu) -- noi dung ben trong (xoa).
echo.

rem -- Hoi xac nhan truoc khi xoa --
set /p "CFDL=    >> Xac nhan lam sach noi dung ben trong cac thu muc con? (Y/N): "
if /i not "!CFDL!"=="Y" (
    echo    [--] Da huy.
    timeout /t 2 >nul
    goto MENU
)
echo.

rem -------------------------------------------------------
rem  Xoa TOAN BO noi dung ben trong tung thu muc con cap 1
rem  - Xoa file truc tiep: del /f /s /q "%%D\*"
rem  - Xoa thu muc con long nhau: for /d rd /s /q
rem  - Giu nguyen ban than thu muc con cap 1
rem -------------------------------------------------------
echo    -- Lam sach noi dung thu muc con --
echo.
set /a FOLDER_COUNT=0
for /d %%D in ("!DLP!\*") do (
    set /a FOLDER_COUNT+=1
    set /a FC=0
    for /f %%i in ('dir /s /b "%%D" 2^>nul ^| find /c /v ""') do set /a FC=%%i
    rem Xoa tat ca file ben trong (de quy)
    del /f /s /q "%%D\*" >nul 2>&1
    rem Xoa tat ca thu muc con long nhau ben trong
    for /d /r "%%D" %%S in (*) do rd /s /q "%%S" >nul 2>&1
    set /a DC+=FC
    echo    [OK] [%%~nxD]: Da xoa !FC! muc - thu muc giu lai
)

if !FOLDER_COUNT!==0 (
    echo    [--] Khong co thu muc con nao trong Downloads
)

echo.
echo    -- File rac o thu muc goc (.tmp .log .bak .old) --
echo.

rem Xoa file rac trong thu muc goc Downloads (chi extension rac)
for %%E in (tmp log bak old) do (
    set /a EC=0
    for /f %%i in ('dir /b /a-d "!DLP!\*.%%E" 2^>nul ^| find /c /v ""') do set /a EC=%%i
    if !EC! gtr 0 (
        del /f /q "!DLP!\*.%%E" >nul 2>&1
        set /a DC+=EC
        echo    [OK] Goc: Xoa !EC! file *.%%E
    )
)

set /a DL_FILES=DC
set /a TOTAL_FILES+=DC
set /a TOTAL_MB+=DC*5

echo.
call :LINE2
echo    KET QUA: !FOLDER_COUNT! thu muc con da duoc lam sach, !DC! muc da xoa
call :LINE2
call :SAVE_STATS
echo    [OK] Da ghi stats.json
echo.
pause
goto MENU

rem ============================================================
rem  [4] DON RECYCLE BIN
rem ============================================================
:CLEAN_RECYCLE
cls
color 0C
call :LINE
echo  ^|  [4] DON RECYCLE BIN                                       ^|
call :LINE
echo.

set /p "CRB=    >> Xac nhan don Recycle Bin? (Y/N): "
if /i not "!CRB!"=="Y" (
    echo    [--] Da huy.
    timeout /t 2 >nul
    goto MENU
)

echo.
echo    Dang don thung rac...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo    [OK] Da lam sach Recycle Bin

set /a RC_FILES=50
set /a TOTAL_FILES+=50
set /a TOTAL_MB+=20

echo.
call :LINE2
echo    KET QUA: Recycle Bin da sach hoan toan
call :LINE2
call :SAVE_STATS
echo    [OK] Da ghi stats.json
echo.
pause
goto MENU

rem ============================================================
rem  [5] CHAY TOAN BO
rem ============================================================
:CLEAN_ALL
cls
color 0A
call :LINE
echo  ^|  [5] CHAY TOAN BO                                          ^|
call :LINE
echo.

set /p "CAL=    >> Xac nhan chay tat ca? (Y/N): "
if /i not "!CAL!"=="Y" goto MENU

echo.
echo    [1/4] Dang don Temp...
set /a T1=0
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a T1=%%i
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
set /a TEMP_FILES=T1
set /a TOTAL_FILES+=T1
echo    [OK] Temp: !T1! file

echo.
echo    [2/4] Dang don Cache...
set /a T2=0
for /f %%i in ('dir /b "C:\Windows\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set /a T2=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
ipconfig /flushdns >nul 2>&1
set /a CACHE_FILES=T2
set /a TOTAL_FILES+=T2
echo    [OK] Cache: !T2! muc

echo.
echo    [3/4] Dang don Downloads...
set /a T3=0
for %%E in (tmp log bak old) do (
    for /f %%i in ('dir /b /a-d "%USERPROFILE%\Downloads\*.%%E" 2^>nul ^| find /c /v ""') do set /a T3+=%%i
    del /f /q "%USERPROFILE%\Downloads\*.%%E" >nul 2>&1
)
rem Lam sach noi dung ben trong tung thu muc con (giu ban than thu muc con)
set /a T3_FOLDERS=0
for /d %%D in ("%USERPROFILE%\Downloads\*") do (
    set /a T3_FOLDERS+=1
    del /f /s /q "%%D\*" >nul 2>&1
    for /d /r "%%D" %%S in (*) do rd /s /q "%%S" >nul 2>&1
)
set /a DL_FILES=T3+T3_FOLDERS
set /a TOTAL_FILES+=T3+T3_FOLDERS
echo    [OK] Downloads: !T3_FOLDERS! thu muc con lam sach + !T3! file rac xoa

echo.
echo    [4/4] Dang don Recycle Bin...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a RC_FILES=50
set /a TOTAL_FILES+=50
echo    [OK] Recycle Bin: Sach

set /a TOTAL_MB=TOTAL_FILES/5

echo.
call :LINE
echo  ^|  HOAN TAT TOAN BO                                          ^|
call :LINE
echo    Tong file da xoa  : !TOTAL_FILES!
echo    Dung luong uoc tinh: ~!TOTAL_MB! MB
call :LINE2
call :SAVE_STATS
echo    [OK] Da ghi stats.json
echo.
set /p "OD=    >> Mo Dashboard ngay? (Y/N): "
if /i "!OD!"=="Y" goto OPEN_DASHBOARD
goto MENU

rem ============================================================
rem  [6] MO DASHBOARD
rem ============================================================
:OPEN_DASHBOARD
cls
color 0B
call :LINE
echo  ^|  [6] MO DASHBOARD                                          ^|
call :LINE
echo.

if not exist "%DASHBOARD_FILE%" (
    echo    [!] Khong tim thay dashboard.html
    echo    Hay dat dashboard.html cung thu muc voi Cleaner.bat
    echo.
    pause
    goto MENU
)

rem -- [1/3] Kiem tra Python --
echo    [1/3] Kiem tra Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo    [!] Khong tim thay Python. Vui long cai Python va thu lai.
    echo    Tai: https://www.python.org/downloads/
    echo.
    pause
    goto MENU
)
for /f "tokens=*" %%V in ('python --version 2^>^&1') do echo    [OK] %%V
echo.

rem -- [2/3] Mo PowerShell chay python -m http.server 8000 tu thu muc chua Cleaner.bat --
echo    [2/3] Khoi dong PowerShell chay server...
set "DASHBOARD_PORT=8000"

PowerShell -NoProfile -Command ^
  "Start-Process powershell -ArgumentList '-NoExit', '-NoProfile', '-Command', 'cd \"%SCRIPT_DIR%\"; Write-Host \"  [Windows 11 Cleaner Pro] Dashboard Server\" -ForegroundColor Cyan; Write-Host \"  ========================================\" -ForegroundColor Cyan; Write-Host \"  Lenh: python -m http.server 8000 --bind 127.0.0.1\" -ForegroundColor Yellow; Write-Host \"  Thu muc: %SCRIPT_DIR%\" -ForegroundColor Yellow; Write-Host \"\"; python -m http.server 8000 --bind 127.0.0.1' -WindowStyle Normal"

echo    [OK] Cua so PowerShell da mo - dang khoi dong server...
echo.

rem -- [3/3] Cho server san sang roi mo trinh duyet --
echo    [3/3] Cho server san sang (toi da 8 giay)...
set /a WAIT=0
:WAIT_SERVER
timeout /t 1 >nul
set /a WAIT+=1
PowerShell -NoProfile -Command ^
  "try{(New-Object Net.Sockets.TcpClient).Connect('localhost',8000);exit 0}catch{exit 1}" >nul 2>&1
if not errorlevel 1 goto SERVER_READY
if !WAIT! lss 8 goto WAIT_SERVER
echo    [i] Server chua phan hoi nhung van thu mo trinh duyet...

:SERVER_READY
start "" "http://localhost:8000/dashboard.html"

echo.
call :LINE
echo  ^|  DASHBOARD DA KHOI DONG THANH CONG                         ^|
call :LINE
echo    URL    : http://localhost:8000/dashboard.html
echo    Lenh   : python -m http.server 8000 --bind 127.0.0.1
echo    Thu muc: %SCRIPT_DIR%
call :LINE2
echo    [i] Cua so PowerShell dang chay server - KHONG dong cua so do.
echo    [i] Dong cua so PowerShell khi muon tat server.
echo.
timeout /t 3 >nul
goto MENU


rem ============================================================
rem  GHI SCHEDULE_INFO VAO STATS.JSON (giu nguyen so lieu don rac)
rem ============================================================
:SAVE_SCHEDULE_ONLY
set "_SF2=!STATS_FILE!"
PowerShell -NoProfile -Command ^
  "$sf='!_SF2!';" ^
  "$existing = '{}';" ^
  "if (Test-Path $sf) { try { $existing = [IO.File]::ReadAllText($sf) } catch {} };" ^
  "try { $data = $existing | ConvertFrom-Json } catch { $data = [PSCustomObject]@{} };" ^
  "$schedInfo = @{ enabled=$false; frequency='Chua thiet lap'; next_run='N/A'; last_auto='N/A' };" ^
  "try {" ^
  "  $t = Get-ScheduledTask -TaskName 'Win11CleanerPro' -ErrorAction Stop;" ^
  "  $ti = $t | Get-ScheduledTaskInfo -ErrorAction SilentlyContinue;" ^
  "  $tr = $t.Triggers[0];" ^
  "  $freq = switch ($tr.CimClass.CimClassName) {" ^
  "    'MSFT_TaskDailyTrigger'   { 'Hang ngay luc 3:00 SA' }" ^
  "    'MSFT_TaskWeeklyTrigger'  { 'Hang tuan (CN) luc 3:00 SA' }" ^
  "    'MSFT_TaskMonthlyDOWTrigger' { 'Hang thang (ngay 1) luc 3:00 SA' }" ^
  "    'MSFT_TaskMonthlyTrigger' { 'Hang thang (ngay 1) luc 3:00 SA' }" ^
  "    default { 'Dinh ky' }" ^
  "  };" ^
  "  $nextRun = if ($ti -and $ti.NextRunTime -and $ti.NextRunTime.Year -gt 2000) { $ti.NextRunTime.ToString('yyyy-MM-dd HH:mm') } else { 'N/A' };" ^
  "  $lastRun = if ($ti -and $ti.LastRunTime -and $ti.LastRunTime.Year -gt 2000) { $ti.LastRunTime.ToString('yyyy-MM-dd HH:mm') } else { 'Chua chay lan nao' };" ^
  "  $schedInfo = @{ enabled=$true; frequency=$freq; next_run=$nextRun; last_auto=$lastRun }" ^
  "} catch {};" ^
  "$out = [ordered]@{" ^
  "  files_deleted  = if ($data.files_deleted)  { $data.files_deleted  } else { 0 };" ^
  "  space_saved_mb = if ($data.space_saved_mb) { $data.space_saved_mb } else { 0 };" ^
  "  last_run       = if ($data.last_run)       { $data.last_run       } else { 'Chua chay' };" ^
  "  status         = if ($data.status)         { $data.status         } else { 'Chua chay' };" ^
  "  temp           = if ($data.temp)           { $data.temp           } else { 0 };" ^
  "  downloads      = if ($data.downloads)      { $data.downloads      } else { 0 };" ^
  "  cache          = if ($data.cache)          { $data.cache          } else { 0 };" ^
  "  recycle        = if ($data.recycle)        { $data.recycle        } else { 0 };" ^
  "  schedule_info  = $schedInfo;" ^
  "  logs           = if ($data.logs)           { $data.logs           } else { @() }" ^
  "};" ^
  "$utf8NoBom = New-Object System.Text.UTF8Encoding $false;" ^
  "[IO.File]::WriteAllText($sf, (ConvertTo-Json $out -Depth 5), $utf8NoBom)"
goto :EOF

rem ============================================================
rem  GHI STATS.JSON  (dung PowerShell de dam bao UTF-8 va escape dung)
rem ============================================================
:SAVE_STATS
rem -- Lay thoi gian hien tai qua PowerShell (tranh loi wmic) --
for /f "usebackq delims=" %%T in (`PowerShell -NoProfile -Command "Get-Date -Format 'yyyy-MM-dd HH:mm'"`) do set "DTS=%%T"

rem -- Lay gia tri bien vao local de dung ben trong PowerShell --
set "_TF=!TEMP_FILES!"
set "_CF=!CACHE_FILES!"
set "_DL=!DL_FILES!"
set "_RC=!RC_FILES!"
set "_TT=!TOTAL_FILES!"
set "_MB=!TOTAL_MB!"
set "_DT=!DTS!"
set "_SF=!STATS_FILE!"

rem -- Ghi UTF-8 khong BOM bang StreamWriter (JSON.parse yeu cau khong co BOM) --
PowerShell -NoProfile -Command ^
  "$tf=[int]'!_TF!'; $cf=[int]'!_CF!'; $dl=[int]'!_DL!'; $rc=[int]'!_RC!'; $tt=[int]'!_TT!'; $mb=[int]'!_MB!';" ^
  "$dt='!_DT!'; $sf='!_SF!';" ^
  "$schedInfo = @{ enabled=$false; frequency='Chua thiet lap'; next_run='N/A'; last_auto='N/A' };" ^
  "try {" ^
  "  $t = Get-ScheduledTask -TaskName 'Win11CleanerPro' -ErrorAction Stop;" ^
  "  $ti = $t | Get-ScheduledTaskInfo -ErrorAction SilentlyContinue;" ^
  "  $tr = $t.Triggers[0];" ^
  "  $freq = switch ($tr.CimClass.CimClassName) {" ^
  "    'MSFT_TaskDailyTrigger'   { 'Hang ngay luc 3:00 SA' }" ^
  "    'MSFT_TaskWeeklyTrigger'  { 'Hang tuan (CN) luc 3:00 SA' }" ^
  "    'MSFT_TaskMonthlyTrigger' { 'Hang thang (ngay 1) luc 3:00 SA' }" ^
  "    default { 'Khac' }" ^
  "  };" ^
  "  $nextRun = if ($ti.NextRunTime) { $ti.NextRunTime.ToString('yyyy-MM-dd HH:mm') } else { 'N/A' };" ^
  "  $lastRun = if ($ti.LastRunTime -and $ti.LastRunTime.Year -gt 2000) { $ti.LastRunTime.ToString('yyyy-MM-dd HH:mm') } else { 'Chua chay lan nao' };" ^
  "  $schedInfo = @{ enabled=$true; frequency=$freq; next_run=$nextRun; last_auto=$lastRun }" ^
  "} catch {};" ^
  "$json = [ordered]@{" ^
  "  files_deleted = $tt;" ^
  "  space_saved_mb = $mb;" ^
  "  last_run = $dt;" ^
  "  status = 'Hoan tat';" ^
  "  temp = $tf;" ^
  "  downloads = $dl;" ^
  "  cache = $cf;" ^
  "  recycle = $rc;" ^
  "  schedule_info = $schedInfo;" ^
  "  logs = @(" ^
  "    \"Da don Temp ($tf file)\"," ^
  "    \"Da don Cache ($cf muc)\"," ^
  "    \"Da don Downloads ($dl file)\"," ^
  "    'Da xoa Recycle Bin'" ^
  "  )" ^
  "};" ^
  "$content = ConvertTo-Json $json -Depth 5;" ^
  "$utf8NoBom = New-Object System.Text.UTF8Encoding $false;" ^
  "[System.IO.File]::WriteAllText($sf, $content, $utf8NoBom)"

goto :EOF

rem ============================================================
rem  [7] DINH KY TU DONG - SCHEDULED TASK
rem ============================================================
:SCHEDULE_MENU
cls
color 0D
call :LINE
echo  ^|  [7] DINH KY TU DONG ( Scheduled Task )                    ^|
call :LINE
echo.
echo    [1]  Cai dat lich dinh ky moi
echo    [2]  Xem lich dang chay
echo    [3]  Xoa lich da cai
echo    [0]  Quay lai menu chinh
echo.
call :LINE2
set /p "SC=    >> Chon (0-3): "

if "!SC!"=="1" goto SCHEDULE_CREATE
if "!SC!"=="2" goto SCHEDULE_VIEW
if "!SC!"=="3" goto SCHEDULE_DELETE
if "!SC!"=="0" goto MENU

echo.
echo    [!] Lua chon khong hop le.
timeout /t 2 >nul
goto SCHEDULE_MENU

rem ---- CAI DAT LICH MOI ----
:SCHEDULE_CREATE
cls
color 0D
call :LINE
echo  ^|  [7.1] CAI DAT LICH DINH KY                                ^|
call :LINE
echo.
echo    Chon tan suat don rac:
echo.
echo    [1]  Hang ngay
echo    [2]  Hang tuan   ( Chu Nhat )
echo    [3]  Hang thang  ( ngay 1 )
echo    [0]  Quay lai
echo.
call :LINE2
set /p "SF=    >> Chon tan suat (0-3): "

if "!SF!"=="0" goto SCHEDULE_MENU
if "!SF!"=="1" goto SCHED_DAILY
if "!SF!"=="2" goto SCHED_WEEKLY
if "!SF!"=="3" goto SCHED_MONTHLY

echo    [!] Lua chon khong hop le.
timeout /t 2 >nul
goto SCHEDULE_CREATE

:SCHED_DAILY
set "SCHED_TRIGGER=DAILY"
set "SCHED_PS=Daily"
goto SCHED_ASK_TIME

:SCHED_WEEKLY
set "SCHED_TRIGGER=WEEKLY"
set "SCHED_PS=Weekly"
goto SCHED_ASK_TIME

:SCHED_MONTHLY
set "SCHED_TRIGGER=MONTHLY"
set "SCHED_PS=Monthly"
goto SCHED_ASK_TIME

rem ---- NHAP GIO THU CONG ----
:SCHED_ASK_TIME
cls
color 0D
call :LINE
echo  ^|  [7.1] THIET LAP GIO CHAY                                  ^|
call :LINE
echo.
echo    Nhap gio chay dinh ky (dinh dang 24h, vi du: 3 / 15 / 03:00 / 14:30)
echo.
echo    Goi y: chon gio may tinh it hoat dong (ban dem / trua) de tranh lam cham may.
echo.
call :LINE2
set /p "SCHED_TIME=    >> Nhap gio (HH hoac HH:MM): "

rem -- Kiem tra de trong --
if "!SCHED_TIME!"=="" (
    echo    [!] Khong duoc de trong. Nhap lai.
    timeout /t 2 >nul
    goto SCHED_ASK_TIME
)

rem -- Reset bien MM truoc khi parse --
set "_HH="
set "_MM="

rem -- Neu input KHONG chua dau ":" -> chi nhap gio, gan MM=00 --
echo !SCHED_TIME! | find ":" >nul 2>&1
if errorlevel 1 (
    set "_HH=!SCHED_TIME!"
    set "_MM=00"
) else (
    for /f "tokens=1,2 delims=:" %%A in ("!SCHED_TIME!") do (
        set "_HH=%%A"
        set "_MM=%%B"
    )
)

rem -- Kiem tra HH va MM co phai so hop le khong --
set /a "_HH_N=!_HH!" 2>nul
set /a "_MM_N=!_MM!" 2>nul

if "!_HH!"=="" goto SCHED_TIME_ERR
if "!_MM!"=="" goto SCHED_TIME_ERR
if !_HH_N! LSS 0  goto SCHED_TIME_ERR
if !_HH_N! GTR 23 goto SCHED_TIME_ERR
if !_MM_N! LSS 0  goto SCHED_TIME_ERR
if !_MM_N! GTR 59 goto SCHED_TIME_ERR

rem -- Chuan hoa thanh HH:MM (2 chu so) --
if !_HH_N! LSS 10 (set "_HH_F=0!_HH_N!") else (set "_HH_F=!_HH_N!")
if !_MM_N! LSS 10 (set "_MM_F=0!_MM_N!") else (set "_MM_F=!_MM_N!")
set "SCHED_TIME_FMT=!_HH_F!:!_MM_F!"

rem -- Gan mo ta theo tan suat + gio da nhap --
if "!SCHED_PS!"=="Daily"   set "SCHED_DESC=Hang ngay luc !SCHED_TIME_FMT!"
if "!SCHED_PS!"=="Weekly"  set "SCHED_DESC=Hang tuan (CN) luc !SCHED_TIME_FMT!"
if "!SCHED_PS!"=="Monthly" set "SCHED_DESC=Hang thang (ngay 1) luc !SCHED_TIME_FMT!"
goto SCHED_DO

:SCHED_TIME_ERR
echo    [!] Gio khong hop le. Phai nhap so gio (0-23) hoac HH:MM (00:00-23:59). Nhap lai.
timeout /t 2 >nul
goto SCHED_ASK_TIME

:SCHED_DO
cls
color 0D
call :LINE
echo  ^|  [7.1] XAC NHAN CAI DAT                                    ^|
call :LINE
echo.
echo    Tan suat : !SCHED_DESC!
echo    Gio chay : !SCHED_TIME_FMT!
echo    Chay voi : SYSTEM (quyen cao nhat, khong can dang nhap)
echo.
set /p "CFSC=    >> Xac nhan cai dat? (Y/N): "
if /i not "!CFSC!"=="Y" goto SCHEDULE_MENU

rem Xoa task cu neu co
schtasks /delete /tn "Win11CleanerPro" /f >nul 2>&1

rem Dat duong dan vao bien de tranh nested quotes trong /tr
set "BAT_CMD=cmd.exe /c !SCRIPT_DIR!Cleaner.bat AUTO"

rem Tao task bang schtasks truc tiep voi gio nguoi dung nhap
if "!SCHED_PS!"=="Daily"   schtasks /create /tn "Win11CleanerPro" /tr "!BAT_CMD!" /sc DAILY   /st !SCHED_TIME_FMT! /ru SYSTEM /rl HIGHEST /f >nul 2>&1
if "!SCHED_PS!"=="Weekly"  schtasks /create /tn "Win11CleanerPro" /tr "!BAT_CMD!" /sc WEEKLY  /d SUN /st !SCHED_TIME_FMT! /ru SYSTEM /rl HIGHEST /f >nul 2>&1
if "!SCHED_PS!"=="Monthly" schtasks /create /tn "Win11CleanerPro" /tr "!BAT_CMD!" /sc MONTHLY /d 1   /st !SCHED_TIME_FMT! /ru SYSTEM /rl HIGHEST /f >nul 2>&1

if errorlevel 1 (
    echo    [!] Cai dat that bai - can chay Cleaner.bat voi quyen Administrator!
    echo    [i] Chuot phai vao Cleaner.bat chon "Run as administrator" roi thu lai.
) else (
    echo    [OK] Da cai lich thanh cong: !SCHED_DESC!
    call :SAVE_SCHEDULE_ONLY
    echo    [OK] Da cap nhat stats.json - Dashboard se hien thi trang thai moi.
)

echo.
call :LINE2
echo    KET QUA: Lich dinh ky da duoc cai dat!
echo    Ten task  : Win11CleanerPro
echo    Tan suat  : !SCHED_DESC!
echo    Gio chay  : !SCHED_TIME_FMT!
echo    Chay voi  : SYSTEM (quyen cao nhat)
echo    Bat dau   : Lan toi theo lich
call :LINE2
echo.
echo    [i] Kiem tra tai: Task Scheduler ^> Win11CleanerPro
echo    [i] Hoac chon [2] Xem lich trong menu Dinh Ky.
echo.
pause
goto SCHEDULE_MENU

rem ---- XEM LICH DANG CHAY ----
:SCHEDULE_VIEW
cls
color 0B
call :LINE
echo  ^|  [7.2] XEM LICH DANG CAI                                   ^|
call :LINE
echo.

schtasks /query /tn "Win11CleanerPro" /fo LIST 2>nul
if errorlevel 1 (
    echo    [!] Chua co lich nao duoc cai dat.
    echo    [i] Chon [1] de cai dat lich moi.
) else (
    echo.
    echo    [OK] Task tren la lich hien tai dang hoat dong.
)

echo.
pause
goto SCHEDULE_MENU

rem ---- XOA LICH ----
:SCHEDULE_DELETE
cls
color 0C
call :LINE
echo  ^|  [7.3] XOA LICH DINH KY                                    ^|
call :LINE
echo.

schtasks /query /tn "Win11CleanerPro" >nul 2>&1
if errorlevel 1 (
    echo    [!] Khong co lich nao de xoa.
    timeout /t 2 >nul
    goto SCHEDULE_MENU
)

echo    [!] Se xoa lich: Win11CleanerPro
echo.
set /p "CFDEL=    >> Xac nhan xoa? (Y/N): "
if /i not "!CFDEL!"=="Y" goto SCHEDULE_MENU

schtasks /delete /tn "Win11CleanerPro" /f >nul 2>&1
if errorlevel 1 (
    echo    [!] Xoa that bai - can quyen Admin.
) else (
    echo    [OK] Da xoa lich Win11CleanerPro thanh cong!
    call :SAVE_SCHEDULE_ONLY
    echo    [OK] Da cap nhat stats.json - Dashboard se hien thi Chua cai dat.
)

echo.
pause
goto SCHEDULE_MENU

rem ============================================================
rem  CHE DO TU DONG (chay qua Scheduled Task - tham so AUTO)
rem ============================================================
:AUTO_MODE
rem -- Khi Scheduled Task goi: Cleaner.bat AUTO --
rem -- Chay sach toan bo khong can xac nhan --
set /a T1=0
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a T1=%%i
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
set /a TEMP_FILES=T1

set /a T2=0
for /f %%i in ('dir /b "C:\Windows\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set /a T2=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
ipconfig /flushdns >nul 2>&1
set /a CACHE_FILES=T2

set /a T3=0
for %%E in (tmp log bak old) do (
    for /f %%i in ('dir /b /a-d "%USERPROFILE%\Downloads\*.%%E" 2^>nul ^| find /c /v ""') do set /a T3+=%%i
    del /f /q "%USERPROFILE%\Downloads\*.%%E" >nul 2>&1
)
set /a DL_FILES=T3

PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a RC_FILES=50

set /a TOTAL_FILES=T1+T2+T3+50
set /a TOTAL_MB=TOTAL_FILES/5
call :SAVE_STATS
goto :EOF

rem ============================================================
rem  THOAT
rem ============================================================
:EXIT_PROGRAM
cls
color 0A
echo  +==============================================================+
echo  ^|                                                            ^|
echo  ^|   WINDOWS 11 CLEANER PRO  v3.0  -  By khahdihdz          ^|
echo  ^|                                                            ^|
echo  +==============================================================+
echo  ^|                                                            ^|
echo  ^|   CAM ON BAN DA SU DUNG CHUONG TRINH!                     ^|
echo  ^|   Hope you enjoyed it  ^^_^^                                  ^|
echo  ^|                                                            ^|
echo  +==============================================================+
echo.
echo    KET QUA PHIEN NAY:
echo.
echo    +------------------------------------------+
echo    ^|  Temp files    : !TEMP_FILES! file
echo    ^|  Cache / Recent: !CACHE_FILES! muc
echo    ^|  Downloads     : !DL_FILES! file / muc
echo    ^|  Recycle Bin   : !RC_FILES! muc
echo    ^|  ----------------------------------------
echo    ^|  Tong cong     : !TOTAL_FILES! file da xoa
echo    ^|  Giai phong    : ~!TOTAL_MB! MB
echo    +------------------------------------------+
echo.
if defined DASHBOARD_PORT (
    echo    [i] Neu server van dang chay, dong cua so PowerShell de tat.
    echo.
)
echo    [*] Se mo trang tac gia va dong sau 8 giay...
echo.
ping -n 9 127.0.0.1 >nul
start "" "https://khahdihdz.github.io"
endlocal
exit /b 0
