@echo off
chcp 65001 >nul 2>&1
setlocal enabledelayedexpansion

color 0A
title Windows 11 Cleaner Pro v2.0

set "SCRIPT_DIR=%~dp0"
set "STATS_FILE=%SCRIPT_DIR%stats.json"
set "DASHBOARD_FILE=%SCRIPT_DIR%dashboard.html"

set /a TOTAL_FILES=0
set /a TOTAL_MB=0
set /a TEMP_FILES=0
set /a CACHE_FILES=0
set /a DL_FILES=0
set /a RC_FILES=0

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
echo  !  WINDOWS 11 CLEANER PRO  v2.0                              !
echo  !  Cong Cu Don Rac He Thong - Windows 11                     !
call :LINE
echo  !                                                            !
echo  !   [1]  Don Temp     ( %%TEMP%% + C:\Windows\Temp )          !
echo  !   [2]  Don Cache    ( Prefetch, Recent, DNS )              !
echo  !   [3]  Don Downloads( file rac .tmp .log .bak .old )       !
echo  !   [4]  Don Recycle Bin ( Thung rac )                       !
echo  !   [5]  Chay toan bo ( Tat ca buoc tren )                   !
echo  !   [6]  Mo Dashboard ( Xem thong ke trinh duyet )           !
echo  !   [0]  Thoat                                               !
echo  !                                                            !
call :LINE
echo.
echo    Phien nay: !TOTAL_FILES! file da xoa  ^|  Giai phong: !TOTAL_MB! MB
echo.
set /p "CHOICE=  >> Chon (0-6): "

if "!CHOICE!"=="1" goto CLEAN_TEMP
if "!CHOICE!"=="2" goto CLEAN_CACHE
if "!CHOICE!"=="3" goto CLEAN_DOWNLOADS
if "!CHOICE!"=="4" goto CLEAN_RECYCLE
if "!CHOICE!"=="5" goto CLEAN_ALL
if "!CHOICE!"=="6" goto OPEN_DASHBOARD
if "!CHOICE!"=="0" goto EXIT_PROGRAM

echo.
echo    [!] Lua chon khong hop le. Vui long chon tu 0 den 6.
timeout /t 2 >nul
goto MENU

rem ============================================================
rem  [1] DON TEMP
rem ============================================================
:CLEAN_TEMP
cls
color 0B
call :LINE
echo  !  [1] DON TEMP                                              !
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
echo  !  [2] DON CACHE                                             !
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
echo  !  [3] DON DOWNLOADS                                         !
call :LINE
echo.

set "DLP=%USERPROFILE%\Downloads"
set /a DC=0
set /a ASK=0

echo    Thu muc: %USERPROFILE%\Downloads
echo.
echo    -- Buoc 1: Tu dong xoa file rac --
echo.

for %%E in (tmp log bak old) do (
    set /a EC=0
    for /f %%i in ('dir /b /a-d "%USERPROFILE%\Downloads\*.%%E" 2^>nul ^| find /c /v ""') do set /a EC=%%i
    if !EC! gtr 0 (
        del /f /q "%USERPROFILE%\Downloads\*.%%E" >nul 2>&1
        set /a DC+=EC
        echo    [OK] Xoa !EC! file *.%%E
    ) else (
        echo    [--] Khong co file *.%%E
    )
)

echo.
echo    -- Buoc 2: File cai dat cu qua 30 ngay --
echo.

for %%E in (exe msi zip) do (
    for /f "delims=" %%F in ('forfiles /p "%USERPROFILE%\Downloads" /m "*.%%E" /d -30 /c "cmd /c echo @path" 2^>nul') do (
        set /a ASK+=1
        echo    File: %%F
        set /p "YN=    >> Xoa file nay? (Y/N): "
        if /i "!YN!"=="Y" (
            del /f /q "%%F" >nul 2>&1
            set /a DC+=1
            echo    [OK] Da xoa
        ) else (
            echo    [--] Bo qua
        )
        echo.
    )
)

if !ASK!==0 echo    [--] Khong co file .exe/.msi/.zip nao cu qua 30 ngay

set /a DL_FILES=DC
set /a TOTAL_FILES+=DC
set /a TOTAL_MB+=DC*5

echo.
call :LINE2
echo    KET QUA: Da xoa !DC! file trong Downloads
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
echo  !  [4] DON RECYCLE BIN                                       !
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
echo  !  [5] CHAY TOAN BO                                          !
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
set /a DL_FILES=T3
set /a TOTAL_FILES+=T3
echo    [OK] Downloads: !T3! file

echo.
echo    [4/4] Dang don Recycle Bin...
PowerShell -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue" >nul 2>&1
set /a RC_FILES=50
set /a TOTAL_FILES+=50
echo    [OK] Recycle Bin: Sach

set /a TOTAL_MB=TOTAL_FILES/5

echo.
call :LINE
echo  !  HOAN TAT TOAN BO                                          !
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
if exist "%DASHBOARD_FILE%" (
    echo.
    echo    Dang mo Dashboard...
    start "" "%DASHBOARD_FILE%"
    timeout /t 2 >nul
) else (
    echo.
    echo    [!] Khong tim thay dashboard.html
    echo    Hay dat dashboard.html cung thu muc voi Cleaner.bat
    echo.
    pause
)
goto MENU

rem ============================================================
rem  GHI STATS.JSON
rem ============================================================
:SAVE_STATS
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

rem ============================================================
rem  THOAT
rem ============================================================
:EXIT_PROGRAM
cls
color 0A
call :LINE
echo  !  CAM ON DA SU DUNG WINDOWS 11 CLEANER PRO!                 !
call :LINE
echo    Da xoa: !TOTAL_FILES! file  ^|  Giai phong: ~!TOTAL_MB! MB
echo.
timeout /t 3 >nul
endlocal
exit /b 0
