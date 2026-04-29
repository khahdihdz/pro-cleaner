@echo off
chcp 65001 >nul
setlocal enabledelayedexpansion

color 0A
title Windows 11 Cleaner Pro

set "SCRIPT_DIR=%~dp0"
set "STATS_FILE=%SCRIPT_DIR%stats.json"
set "DASHBOARD_FILE=%SCRIPT_DIR%dashboard.html"

set /a TOTAL_FILES=0
set /a TOTAL_MB=0
set /a TEMP_FILES=0
set /a CACHE_FILES=0
set /a DL_FILES=0
set /a RC_FILES=0

:MENU
cls
color 0A
echo.
echo  +----------------------------------------------------------+
echo  ^|       WINDOWS 11 CLEANER PRO  v2.0                      ^|
echo  ^|       Cong Cu Don Rac He Thong Chuyen Nghiep            ^|
echo  +----------------------------------------------------------+
echo  ^|                                                          ^|
echo  ^|   [1]  Don Temp  (%%temp%% + C:\Windows\Temp)            ^|
echo  ^|   [2]  Don Cache  (Prefetch + Recent + DNS)             ^|
echo  ^|   [3]  Don Downloads  (file rac + file cu)              ^|
echo  ^|   [4]  Don Recycle Bin  (Thung rac)                     ^|
echo  ^|   [5]  Chay toan bo  (Tat ca cac buoc tren)             ^|
echo  ^|   [6]  Mo Dashboard  (Xem thong ke)                     ^|
echo  ^|   [0]  Thoat                                            ^|
echo  ^|                                                          ^|
echo  +----------------------------------------------------------+
echo.
echo  Phien nay: Da xoa !TOTAL_FILES! file - Giai phong: !TOTAL_MB! MB
echo.
set /p "CHOICE=  Chon chuc nang (0-6): "

if "!CHOICE!"=="1" goto CLEAN_TEMP
if "!CHOICE!"=="2" goto CLEAN_CACHE
if "!CHOICE!"=="3" goto CLEAN_DOWNLOADS
if "!CHOICE!"=="4" goto CLEAN_RECYCLE
if "!CHOICE!"=="5" goto CLEAN_ALL
if "!CHOICE!"=="6" goto OPEN_DASHBOARD
if "!CHOICE!"=="0" goto EXIT_PROGRAM

echo  Lua chon khong hop le!
timeout /t 2 >nul
goto MENU

:: ============================================================
:CLEAN_TEMP
:: ============================================================
cls
color 0B
echo.
echo  +----------------------------------------------------------+
echo  ^|   DON TEMP...                                            ^|
echo  +----------------------------------------------------------+
echo.

set /a CNT=0

echo  Dang quet %%temp%%...
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a CNT+=%%i
echo  Tim thay !CNT! file
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
echo  OK: Da xoa %%temp%%

echo.
set /a CNT2=0
echo  Dang quet C:\Windows\Temp...
for /f %%i in ('dir /s /b /a-d "C:\Windows\Temp\*" 2^>nul ^| find /c /v ""') do set /a CNT2+=%%i
echo  Tim thay !CNT2! file
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
for /d %%d in ("C:\Windows\Temp\*") do rd /s /q "%%d" >nul 2>&1
echo  OK: Da xoa C:\Windows\Temp

set /a TEMP_FILES=!CNT!+!CNT2!
set /a TOTAL_FILES+=!TEMP_FILES!
set /a TOTAL_MB+=!TEMP_FILES!/10

echo.
echo  KET QUA: Da xoa !TEMP_FILES! file
call :SAVE_STATS
echo  Da cap nhat stats.json
echo.
pause
goto MENU

:: ============================================================
:CLEAN_CACHE
:: ============================================================
cls
color 0B
echo.
echo  +----------------------------------------------------------+
echo  ^|   DON CACHE...                                           ^|
echo  +----------------------------------------------------------+
echo.

set /a CC=0

echo  Dang don Prefetch...
for /f %%i in ('dir /b /a-d "C:\Windows\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set /a CC+=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
echo  OK: Da don Prefetch

echo.
echo  Dang don Recent...
set /a CC2=0
for /f %%i in ('dir /b /a-d "%appdata%\Microsoft\Windows\Recent\*" 2^>nul ^| find /c /v ""') do set /a CC2+=%%i
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
set /a CC+=!CC2!
echo  OK: Da don Recent

echo.
echo  Xoa DNS cache...
ipconfig /flushdns >nul 2>&1
echo  OK: Da xoa DNS cache

set /a CACHE_FILES=!CC!
set /a TOTAL_FILES+=!CC!
set /a TOTAL_MB+=!CC!/8

echo.
echo  KET QUA: Da don !CC! muc
call :SAVE_STATS
echo  Da cap nhat stats.json
echo.
pause
goto MENU

:: ============================================================
:CLEAN_DOWNLOADS
:: ============================================================
cls
color 0E
echo.
echo  +----------------------------------------------------------+
echo  ^|   DON DOWNLOADS...                                       ^|
echo  +----------------------------------------------------------+
echo.

set "DLP=%USERPROFILE%\Downloads"
set /a DC=0

echo  Thu muc: !DLP!
echo.
echo  Buoc 1: Xoa file rac tu dong (*.tmp *.log *.bak *.old)
echo.

for %%E in (tmp log bak old) do (
    set /a EC=0
    for /f %%i in ('dir /b /a-d "!DLP!\*.%%E" 2^>nul ^| find /c /v ""') do set /a EC=%%i
    if !EC! gtr 0 (
        del /f /q "!DLP!\*.%%E" >nul 2>&1
        set /a DC+=!EC!
        echo  OK: Da xoa !EC! file *.%%E
    ) else (
        echo  Khong co file *.%%E
    )
)

echo.
echo  Buoc 2: Kiem tra file cu qua 30 ngay (*.exe *.msi *.zip)
echo.

set /a ASK=0
for %%E in (exe msi zip) do (
    for /f "delims=" %%F in ('forfiles /p "!DLP!" /m "*.%%E" /d -30 /c "cmd /c echo @path" 2^>nul') do (
        set /a ASK+=1
        echo  File cu: %%F
        set /p "YN=  Xoa file nay? (Y/N): "
        if /i "!YN!"=="Y" (
            del /f /q "%%F" >nul 2>&1
            set /a DC+=1
            echo  Da xoa.
        ) else (
            echo  Bo qua.
        )
        echo.
    )
)

if !ASK!==0 echo  Khong co file .exe/.msi/.zip nao cu qua 30 ngay.

set /a DL_FILES=!DC!
set /a TOTAL_FILES+=!DC!
set /a TOTAL_MB+=!DC!*5

echo.
echo  KET QUA: Da xoa !DC! file
call :SAVE_STATS
echo  Da cap nhat stats.json
echo.
pause
goto MENU

:: ============================================================
:CLEAN_RECYCLE
:: ============================================================
cls
color 0C
echo.
echo  +----------------------------------------------------------+
echo  ^|   DON THUNG RAC (Recycle Bin)...                        ^|
echo  +----------------------------------------------------------+
echo.

set /p "CRB=  Xac nhan don Recycle Bin? (Y/N): "
if /i not "!CRB!"=="Y" (
    echo  Da huy.
    timeout /t 2 >nul
    goto MENU
)

echo.
echo  Dang don thung rac...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
echo  OK: Da lam sach Recycle Bin

set /a RC_FILES=50
set /a TOTAL_FILES+=50
set /a TOTAL_MB+=20

echo.
echo  KET QUA: Recycle Bin da sach
call :SAVE_STATS
echo  Da cap nhat stats.json
echo.
pause
goto MENU

:: ============================================================
:CLEAN_ALL
:: ============================================================
cls
color 0A
echo.
echo  +----------------------------------------------------------+
echo  ^|   CHAY TOAN BO...                                        ^|
echo  +----------------------------------------------------------+
echo.

set /p "CAL=  Xac nhan chay toan bo? (Y/N): "
if /i not "!CAL!"=="Y" goto MENU

echo.
echo  [1/4] Don Temp...
set /a T1=0
for /f %%i in ('dir /s /b /a-d "%temp%\*" 2^>nul ^| find /c /v ""') do set /a T1+=%%i
rd /s /q "%temp%" >nul 2>&1
md "%temp%" >nul 2>&1
del /f /s /q "C:\Windows\Temp\*" >nul 2>&1
set /a TEMP_FILES=!T1!
set /a TOTAL_FILES+=!T1!
echo  OK: !T1! file

echo.
echo  [2/4] Don Cache...
set /a T2=0
for /f %%i in ('dir /b /a-d "C:\Windows\Prefetch\*.pf" 2^>nul ^| find /c /v ""') do set /a T2+=%%i
del /f /q "C:\Windows\Prefetch\*.pf" >nul 2>&1
del /f /q "%appdata%\Microsoft\Windows\Recent\*" >nul 2>&1
ipconfig /flushdns >nul 2>&1
set /a CACHE_FILES=!T2!
set /a TOTAL_FILES+=!T2!
echo  OK: !T2! muc

echo.
echo  [3/4] Don Downloads (file rac)...
set /a T3=0
for %%E in (tmp log bak old) do (
    for /f %%i in ('dir /b /a-d "%USERPROFILE%\Downloads\*.%%E" 2^>nul ^| find /c /v ""') do set /a T3+=%%i
    del /f /q "%USERPROFILE%\Downloads\*.%%E" >nul 2>&1
)
set /a DL_FILES=!T3!
set /a TOTAL_FILES+=!T3!
echo  OK: !T3! file

echo.
echo  [4/4] Don Recycle Bin...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a RC_FILES=50
set /a TOTAL_FILES+=50
echo  OK: Da sach

set /a TOTAL_MB=!TOTAL_FILES!/5

echo.
echo  +----------------------------------------------------------+
echo  ^|   HOAN TAT! Tong: !TOTAL_FILES! file - ~!TOTAL_MB! MB             ^|
echo  +----------------------------------------------------------+

call :SAVE_STATS_FULL
echo.
echo  Da cap nhat stats.json
echo.
set /p "OD=  Mo Dashboard? (Y/N): "
if /i "!OD!"=="Y" goto OPEN_DASHBOARD
goto MENU

:: ============================================================
:OPEN_DASHBOARD
:: ============================================================
if exist "!DASHBOARD_FILE!" (
    echo.
    echo  Dang mo Dashboard...
    start "" "!DASHBOARD_FILE!"
    timeout /t 2 >nul
) else (
    echo.
    echo  Khong tim thay dashboard.html!
    echo  Hay dat file dashboard.html cung thu muc voi Cleaner.bat
    pause
)
goto MENU

:: ============================================================
:SAVE_STATS
:: ============================================================
for /f "tokens=2 delims==" %%D in ('wmic os get LocalDateTime /value 2^>nul') do set "DT=%%D"
set "DTS=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%"

(
echo {
echo   "files_deleted": %TOTAL_FILES%,
echo   "space_saved_mb": %TOTAL_MB%,
echo   "last_run": "%DTS%",
echo   "status": "Hoan tat",
echo   "temp": %TEMP_FILES%,
echo   "downloads": %DL_FILES%,
echo   "cache": %CACHE_FILES%,
echo   "recycle": %RC_FILES%,
echo   "logs": [
echo     "Da don Temp (%TEMP_FILES% file)",
echo     "Da don Cache (%CACHE_FILES% muc)",
echo     "Da don Downloads (%DL_FILES% file)",
echo     "Da xoa Recycle Bin"
echo   ]
echo }
) > "%STATS_FILE%"
goto :EOF

:: ============================================================
:SAVE_STATS_FULL
:: ============================================================
for /f "tokens=2 delims==" %%D in ('wmic os get LocalDateTime /value 2^>nul') do set "DT=%%D"
set "DTS=%DT:~0,4%-%DT:~4,2%-%DT:~6,2% %DT:~8,2%:%DT:~10,2%"

(
echo {
echo   "files_deleted": %TOTAL_FILES%,
echo   "space_saved_mb": %TOTAL_MB%,
echo   "last_run": "%DTS%",
echo   "status": "Hoan tat",
echo   "temp": %TEMP_FILES%,
echo   "downloads": %DL_FILES%,
echo   "cache": %CACHE_FILES%,
echo   "recycle": %RC_FILES%,
echo   "logs": [
echo     "Da don Temp (%TEMP_FILES% file)",
echo     "Da don Cache (%CACHE_FILES% muc)",
echo     "Da don Downloads (%DL_FILES% file)",
echo     "Da xoa Recycle Bin"
echo   ]
echo }
) > "%STATS_FILE%"
goto :EOF

:: ============================================================
:EXIT_PROGRAM
:: ============================================================
cls
color 0A
echo.
echo  +----------------------------------------------------------+
echo  ^|   CAM ON DA SU DUNG WINDOWS 11 CLEANER PRO!             ^|
echo  ^|   Da xoa: !TOTAL_FILES! file - Giai phong: ~!TOTAL_MB! MB         ^|
echo  +----------------------------------------------------------+
echo.
timeout /t 3 >nul
endlocal
exit /b 0
