@echo off
:: ===========================================================================
:: P R I M U S  -  S Y S T E M   U T I L I T Y
:: Version 1.0 (Build 20260424)
:: Repository: https://github.com/R4in84/Primus
:: ===========================================================================
:: Copyright (c) 2026 Chris Martin
:: 
:: Permission is hereby granted, free of charge, to any person obtaining a copy
:: of this software and associated documentation files (the "Software"), to deal
:: in the Software without restriction, including without limitation the rights
:: to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
:: copies of the Software, and to permit persons to whom the Software is
:: furnished to do so, subject to the following conditions:
:: 
:: The above copyright notice and this permission notice shall be included in all
:: copies or substantial portions of the Software.
:: 
:: THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
:: IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
:: FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
:: ===========================================================================

:: ---------------------------------------------------------------------------
:: ADMINISTRATIVE PRIVILEGE CHECK
:: ---------------------------------------------------------------------------
:CHECK_PRIVILEGES
fltmc >nul 2>&1
if errorlevel 1 (echo [SYSTEM] Requesting elevated privileges... & powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Start-Process -FilePath \"%~f0\" -Verb RunAs" & exit /b)

:START_SCRIPT
setlocal EnableDelayedExpansion

:: Version Information
set "PRIMUS_VERSION=1.0"
set "PRIMUS_BUILD=20260424"

:: Define Window Size: 90 Columns, 34 Lines
mode con: cols=90 lines=34
title Primus v!PRIMUS_VERSION! - System Utility
color 0F

:: Fetch OS Info from Registry (Instantaneous)
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v ProductName 2^>nul ^| find "ProductName"') do set "OS_NAME=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v DisplayVersion 2^>nul ^| find "DisplayVersion"') do set "OS_VER=%%B"
for /f "tokens=2,*" %%A in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" /v CurrentBuild 2^>nul ^| find "CurrentBuild"') do set "OS_BUILD=%%B"

:: Guard against registry failure, then apply Win11 fix if build number exists
if not defined OS_NAME set "OS_NAME=Windows"
if not defined OS_BUILD set "OS_BUILD=Unknown"
if "!OS_BUILD!"=="Unknown" goto :SKIP_OS_MATH
echo(!OS_BUILD!| findstr /r "^[0-9][0-9]*$" >nul
if !errorlevel! equ 0 if !OS_BUILD! GEQ 22000 set "OS_NAME=!OS_NAME:Windows 10=Windows 11!"
:SKIP_OS_MATH

:: Gracefully format the OS string depending on if DisplayVersion exists (e.g., LTSC/Server fallback)
set "FULL_OS=!OS_NAME!"
if defined OS_VER set "FULL_OS=!OS_NAME! (!OS_VER!)"

:: Fetch System Uptime, System Drive Free Space, Locale-Safe Time, and File-Safe Timestamp (Combined for speed)
set "SYS_UPTIME=N/A"
set "SYS_FREE=N/A"
set "CURRENT_TIME=00:00"
set "FILE_TIME=00000000_000000"
for /f "tokens=1-4 delims=#" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$u=(New-TimeSpan -Start (Get-CimInstance Win32_OperatingSystem).LastBootUpTime); $d=[math]::Round((Get-CimInstance Win32_LogicalDisk -Filter 'DeviceID=''%SystemDrive%''').FreeSpace/1GB,1); $t=(Get-Date).ToString('HH:mm'); $f=(Get-Date).ToString('yyyyMMdd_HHmmss'); ('{0}d {1}h {2}m#{3} GB#{4}#{5}' -f $u.Days, $u.Hours, $u.Minutes, $d, $t, $f)"') do set "SYS_UPTIME=%%A" & set "SYS_FREE=%%B" & set "CURRENT_TIME=%%C" & set "FILE_TIME=%%D"

:: Determine Boot State (Normal vs Safe Mode)
set "BOOT_STATUS=Normal Boot"
if defined SAFEBOOT_OPTION set "BOOT_STATUS=Safe Mode"

:: Create fixed-width strings for perfect column alignment (30 characters wide)
set "USER_STR=USER: %USERNAME%                              "
set "UPTIME_STR=UPTIME: !SYS_UPTIME!                              "
set "TIME_STR=SESSION: !CURRENT_TIME!                             "

:: ---------------------------------------------------------------------------
:: INITIALIZE LOGGING SYSTEM
:: ---------------------------------------------------------------------------
set "LOG_DIR=%ProgramData%\Primus\Logs"
if not exist "!LOG_DIR!" mkdir "!LOG_DIR!" >nul 2>&1
if not exist "!LOG_DIR!" (set "LOG_DIR=%TEMP%\Primus_Logs" & mkdir "!LOG_DIR!" >nul 2>&1)
if not exist "!LOG_DIR!" set "LOG_DIR=%TEMP%"

:: Enforce 30-Day Rolling Log Retention Policy (Silently purges old logs)
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '!LOG_DIR!' -Filter '*.log' | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force" >nul 2>&1

:: Define initial Log File path
set "LOG_FILE=!LOG_DIR!\Primus_!FILE_TIME!.log"

:: Collision Safety: Prevent overwrites if PS failed or script launched twice in one second
if exist "!LOG_FILE!" set "LOG_FILE=!LOG_DIR!\Primus_!FILE_TIME!_!RANDOM!.log"

(
echo.
echo ======================================================================
echo                               P R I M U S
echo                               SESSION LOG
echo ======================================================================
echo  USER: %USERNAME%
echo  HOST: %COMPUTERNAME%
echo  OS:   !FULL_OS!
echo  SESSION: !CURRENT_TIME! %DATE%
echo ======================================================================
echo.
) >> "!LOG_FILE!"

call :LOG "SYSTEM" "CORE" "Primus v!PRIMUS_VERSION! Session Initialized."

:: ---------------------------------------------------------------------------
:: FIRST-RUN EULA / WARNING CHECK
:: ---------------------------------------------------------------------------
set "EULA_FILE=%ProgramData%\Primus\.eula_accepted"
if exist "!EULA_FILE!" goto :SKIP_EULA

cls
echo.
echo.
echo           ======================================================================
echo                                P R I M U S   U T I L I T Y
echo                                 END USER LICENSE AGREEMENT
echo           ======================================================================
echo.
echo            WARNING: This utility performs deep system modifications, including
echo            file deletion, network resets, and core image adjustments.
echo.
echo            By using this software, you acknowledge that it is provided "AS IS"
echo            without warranties of any kind. You are solely responsible for any
echo            data loss or system instability that may occur.
echo.
echo            Please review the Help ^& Information module [H] before running
echo            destructive commands.
echo.
echo           ======================================================================
:EULA_PROMPT
set "eula_ans="
set /p "eula_ans=           [ ACTION ] Type ACCEPT to continue or EXIT to cancel :> "
if /i "!eula_ans!"=="EXIT" exit /b
if /i "!eula_ans!"=="ACCEPT" (
    echo. > "!EULA_FILE!"
    call :LOG "SYSTEM" "CORE" "User accepted first-run End User License Agreement."
    goto :SKIP_EULA
)
echo            [ ERROR ] Invalid input. Please type ACCEPT or EXIT.
goto :EULA_PROMPT

:SKIP_EULA

cls
echo.
echo.
echo.
echo           ======================================================================
echo                         Initialising Primus v!PRIMUS_VERSION! System Utility...
echo           ======================================================================
timeout /t 2 >nul

:: ---------------------------------------------------------------------------
:: MAIN DASHBOARD
:: ---------------------------------------------------------------------------
:MENU
call :PRINT_HEADER
echo.
echo            -- SYSTEM RECOVERY (CRITICAL) --------------------------------------
echo             [A] Create System Restore Point        [B] Clean Restore Points
echo.
echo            -- SYSTEM MAINTENANCE ----------------------------------------------
echo             [1] General Cleanup                    [2] Advanced Maintenance
echo.
echo            -- NETWORK OPTIMIZATION --------------------------------------------
echo             [3] General Network                    [4] Advanced Network
echo.
echo            -- SYSTEM REPAIR ---------------------------------------------------
echo             [5] Core System Repair (SFC/DISM)
echo.
echo           ======================================================================
echo             [S] SYSTEM INFORMATION     [H] HELP ^& INFO     [X] EXIT APPLICATION
echo.
set "main_choice="
set /p "main_choice=            [Selection] :> "

if /i "!main_choice!"=="A" goto :FUNC_CREATE_RESTORE
if /i "!main_choice!"=="B" goto :FUNC_CLEAN_RESTORE
if "!main_choice!"=="1" goto :SUB_MAINT_GEN
if "!main_choice!"=="2" goto :SUB_MAINT_ADV
if "!main_choice!"=="3" goto :SUB_NET_GEN
if "!main_choice!"=="4" goto :SUB_NET_ADV
if "!main_choice!"=="5" goto :SUB_REPAIR
if /i "!main_choice!"=="S" goto :FUNC_SYSINFO
if /i "!main_choice!"=="H" goto :FUNC_HELP
if /i "!main_choice!"=="X" goto :FUNC_EXIT
goto :MENU

:: ---------------------------------------------------------------------------
:: SUB-MENUS
:: ---------------------------------------------------------------------------

:SUB_MAINT_GEN
call :PRINT_HEADER
echo.
echo            -- GENERAL CLEANUP -------------------------------------------------
echo.
echo             [1] Clean All Temp Files               [2] Clear Prefetch Cache
echo             [3] Clean Update Download Cache        [4] Clean Thumbnail Cache
echo             [5] Empty Recycle Bins                 [6] Disk Cleanup Utility
echo.
echo           ======================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=            [Selection] :> "
if "!choice!"=="1" goto :FUNC_TEMP_CLEAN
if "!choice!"=="2" goto :FUNC_PREFETCH
if "!choice!"=="3" goto :FUNC_UPDATE
if "!choice!"=="4" goto :FUNC_THUMBNAILS
if "!choice!"=="5" goto :FUNC_RECYCLE
if "!choice!"=="6" goto :FUNC_DISKCLEAN
if /i "!choice!"=="R" goto :MENU
goto :SUB_MAINT_GEN

:SUB_MAINT_ADV
call :PRINT_HEADER
echo.
echo            -- ADVANCED MAINTENANCE --------------------------------------------
echo.
echo             [1] Rebuild Icon ^& Thumb Cache         [2] Browser Cache Deep Clean
echo             [3] Reset Windows Store Cache          [4] Clean Component Store (WinSxS)
echo             [5] Clean Error Reports ^& Dumps        [6] Clear System Event Logs
echo.
echo           ======================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=            [Selection] :> "
if "!choice!"=="1" goto :FUNC_ICON_REBUILD
if "!choice!"=="2" goto :FUNC_BROWSER_CLEAN
if "!choice!"=="3" goto :FUNC_WSRESET
if "!choice!"=="4" goto :FUNC_WINSXS
if "!choice!"=="5" goto :FUNC_CRASHDUMPS
if "!choice!"=="6" goto :FUNC_EVENTLOGS
if /i "!choice!"=="R" goto :MENU
goto :SUB_MAINT_ADV

:SUB_NET_GEN
call :PRINT_HEADER
echo.
echo            -- GENERAL NETWORK -------------------------------------------------
echo.
echo             [1] Display DNS Cache                  [2] Flush DNS Cache
echo             [3] Display ARP Cache                  [4] Clear ARP Cache
echo.
echo           ======================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=            [Selection] :> "
if "!choice!"=="1" goto :FUNC_DNS_DISPLAY
if "!choice!"=="2" goto :FUNC_DNS_FLUSH
if "!choice!"=="3" goto :FUNC_ARP_DISPLAY
if "!choice!"=="4" goto :FUNC_ARP_CLEAR
if /i "!choice!"=="R" goto :MENU
goto :SUB_NET_GEN

:SUB_NET_ADV
call :PRINT_HEADER
echo.
echo            -- ADVANCED NETWORK ------------------------------------------------
echo.
echo             [1] Release IP Address                 [2] Renew IP Address
echo             [3] Reset TCP/IP Stack                 [4] Reset Winsock Catalog
echo.
echo           ======================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=            [Selection] :> "
if "!choice!"=="1" goto :FUNC_IP_RELEASE
if "!choice!"=="2" goto :FUNC_IP_RENEW
if "!choice!"=="3" goto :FUNC_TCP_RESET
if "!choice!"=="4" goto :FUNC_WINSOCK_RESET
if /i "!choice!"=="R" goto :MENU
goto :SUB_NET_ADV

:SUB_REPAIR
call :PRINT_HEADER
echo.
echo            -- SYSTEM REPAIR (DISM / SFC) --------------------------------------
echo.
echo             [1] Run System File Checker            [2] DISM Quick Image Check
echo             [3] DISM Deep Image Scan               [4] DISM Deep Image Repair
echo.
echo           ======================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=            [Selection] :> "
if "!choice!"=="1" goto :FUNC_SFC
if "!choice!"=="2" goto :FUNC_DISM_CHECK
if "!choice!"=="3" goto :FUNC_DISM_SCAN
if "!choice!"=="4" goto :FUNC_DISM_RESTORE
if /i "!choice!"=="R" goto :MENU
goto :SUB_REPAIR

:: ---------------------------------------------------------------------------
:: UI HEADER GENERATOR
:: ---------------------------------------------------------------------------
:PRINT_HEADER
cls
echo.
echo           ======================================================================
echo                                         P R I M U S
echo                                            v!PRIMUS_VERSION!
echo           ======================================================================
echo.
echo               [ SYSTEM STATUS ]
echo               --------------------------------------------------------------
echo               HOST: %COMPUTERNAME%
echo               OS:   !FULL_OS!
echo               --------------------------------------------------------------
echo               !USER_STR:~0,30!    STATUS: !BOOT_STATUS!
echo               !UPTIME_STR:~0,30!    %SystemDrive%\ FREE: !SYS_FREE!
echo               !TIME_STR:~0,30!    DATE: %DATE%
echo.
echo           ======================================================================
exit /b

:: ---------------------------------------------------------------------------
:: ISOLATED COMPARTMENTALIZED FUNCTIONS
:: ---------------------------------------------------------------------------
:FUNC_CREATE_RESTORE
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "RECOVERY" "Restore Point aborted due to low disk space." & timeout /t 2 >nul & goto :MENU)
echo  [ INFO ] This will create a manual system state backup.
call :ASK_CONFIRM "Create Restore Point?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to main menu... & call :LOG "WARNING" "RECOVERY" "User cancelled Restore Point creation." & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating manual System Restore Point creation..."
echo  [ PROCESS ] Ensuring VSS and System Restore Services are running...
net start vss >nul 2>&1
net start swprv >nul 2>&1
net start srsvc >nul 2>&1

:: Prevent race conditions on slower systems while VSS writers initialize
timeout /t 2 >nul

echo  [ PROCESS ] Verifying System Protection status on %SystemDrive%\...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$d='%SystemDrive%\'; $sr=Get-CimInstance -Namespace root\default -Class SystemRestoreConfig -ErrorAction SilentlyContinue | Where-Object Drive -eq $d; if (-not $sr) { Enable-ComputerRestore -Drive $d -ErrorAction SilentlyContinue }"

echo  [ PROCESS ] Overriding Windows Restore frequency limit...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1

echo  [ PROCESS ] Creating System Restore Point...
echo  [ INFO ] This may take 30-60 seconds...
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Primus_Manual_Backup' -RestorePointType 'MODIFY_SETTINGS'; exit $LASTEXITCODE"
set "PS_ERR=!errorlevel!"

echo.
call :EVAL_STATUS !PS_ERR! "RECOVERY" "Failed to create Restore Point (Exit Code: !PS_ERR!)." "Restore Point 'Primus_Manual_Backup' created successfully."

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 1440 /f >nul 2>&1
echo.
pause
goto :MENU

:FUNC_CLEAN_RESTORE
cls
echo.
echo  [ INFO ] This will delete all but the LATEST Restore Point.
call :ASK_CONFIRM "Proceed with purge?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to main menu... & call :LOG "WARNING" "RECOVERY" "User cancelled Restore Point purge." & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating purge of old Shadow Copies..."
echo  [ PROCESS ] Identifying VSS Shadow Copies via WMI...
echo  [ INFO ] Only the most recent copy will be preserved.
echo.

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$vol = Get-CimInstance Win32_Volume -Filter \"DriveLetter='%SystemDrive%'\"; " ^
    "if (-not $vol) { Write-Host '  [ ERROR ] OS volume not found.' -ForegroundColor Red; exit; } " ^
    "$shadows = @(Get-CimInstance Win32_ShadowCopy | Where-Object VolumeName -eq $vol.DeviceID | Sort-Object InstallDate); " ^
    "if ($shadows.Count -gt 1) { " ^
    "  $toDelete = $shadows | Select-Object -First ($shadows.Count - 1); " ^
    "  foreach ($s in $toDelete) { " ^
    "    Write-Host \"  [ STATUS ] Purging Shadow ID: $($s.ID)\"; " ^
    "    $s | Remove-CimInstance; " ^
    "  } " ^
    "  Write-Host '  [ STATUS ] Cleanup complete.' -ForegroundColor Green; " ^
    "} else { Write-Host '  [ INFO ] Valid limit reached. Skipping.' -ForegroundColor Cyan; }"

call :LOG "SUCCESS" "RECOVERY" "Shadow Copy cleanup operation completed."
echo.
pause
goto :MENU

:FUNC_TEMP_CLEAN
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating comprehensive Temp file cleanup..."
echo  [ PROCESS ] Purging User Temp folder...
call :PURGE_DIR "%temp%"
echo  [ PROCESS ] Purging Windows System Temp...
call :PURGE_DIR "%WINDIR%\Temp"
echo  [ STATUS ] Comprehensive Temp cleanup complete (In-use files bypassed).
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Temp file cleanup cycle complete."
pause
goto :SUB_MAINT_GEN

:FUNC_PREFETCH
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Prefetch directory cleanup..."
echo  [ INFO ] On very old HDD systems, this may temporarily increase boot time slightly.
echo  [ PROCESS ] Clearing Prefetch directory...
del /q /s /f /a "%WINDIR%\Prefetch\*.*" >nul 2>&1
echo  [ STATUS ] Cleanup cycle complete (In-use files bypassed).
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Prefetch cache cleared."
pause
goto :SUB_MAINT_GEN

:FUNC_UPDATE
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Update Cache reset..."
echo  [ PROCESS ] Halting Windows Update Services...
net stop wuauserv /y >nul 2>&1
net stop bits /y >nul 2>&1
echo  [ PROCESS ] Clearing Update Download Cache...
call :PURGE_DIR "%WINDIR%\SoftwareDistribution\Download"
echo  [ PROCESS ] Restarting Services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
echo  [ STATUS ] Windows Update cache reset.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Windows Update Download Cache successfully cleared."
pause
goto :SUB_MAINT_GEN

:FUNC_THUMBNAILS
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Thumbnail Cache cleanup..."
echo  [ PROCESS ] Purging Windows Thumbnail Cache...
del /q /f "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
echo  [ STATUS ] Thumbnail cache cleanup cycle complete.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Thumbnail Cache database purged."
pause
goto :SUB_MAINT_GEN

:FUNC_RECYCLE
cls
echo.
echo  [ WARNING ] THIS WILL PERMANENTLY DELETE ALL ITEMS IN ALL RECYCLE BINS.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Recycle Bin purge." & timeout /t 1 >nul & goto :SUB_MAINT_GEN)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Emptying system recycle bins..."
echo  [ PROCESS ] Emptying all system recycle bins across all drives...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
echo  [ STATUS ] Operations dispatched to all connected drives.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Recycle Bins emptied successfully."
pause
goto :SUB_MAINT_GEN

:FUNC_DISKCLEAN
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initializing Windows Disk Cleanup Utility..."
echo  [ PROCESS ] Initializing Windows Disk Cleanup Utility...
echo  [ INFO ] Detected Logical Drives:
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Select-Object -ExpandProperty DeviceID"
echo.

:DRIVE_INPUT
set "target_drive="
set /p "target_drive=            [ Selection ] Enter drive letter (e.g. C) :> "

:: Remove accidental leading spaces, then grab only the first character (Optimized)
set "target_drive=!target_drive: =!"
if defined target_drive set "target_drive=!target_drive:~0,1!"

:: Validate that the remaining single character is a letter (A-Z)
:: Note: Using echo( with no space before the pipe prevents trailing whitespace bugs
echo(!target_drive!| findstr /i /r "^[a-z]$" >nul
if errorlevel 1 (echo. & echo             [ ERROR ] Invalid format. Please enter a single drive letter ^(A-Z^). & echo. & goto :DRIVE_INPUT)

:: Convert to uppercase for consistency
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if /i "!target_drive!"=="%%i" set "target_drive=%%i"

if not exist "!target_drive!:\" (echo. & echo             [ ERROR ] Drive !target_drive!: was not found or is inaccessible. & echo             [ INFO ] Please enter a valid drive letter from the list above. & echo. & goto :DRIVE_INPUT)

echo.
echo  [ PROCESS ] Launching CleanMgr GUI for Drive !target_drive!:...
echo  [ INFO ] Script will resume once Cleanup is closed.
echo.
start /wait cleanmgr /d !target_drive!
echo.
echo  [ STATUS ] Disk Cleanup Utility session terminated.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Disk Cleanup Utility completed for Drive !target_drive!:."
pause
goto :SUB_MAINT_GEN

:FUNC_ICON_REBUILD
cls
echo.
echo  [ WARNING ] THIS WILL RESTART THE WINDOWS EXPLORER SHELL.
echo  [ INFO ] Your taskbar and desktop icons will disappear for a few seconds.
echo  [ INFO ] This fixes "white" or "broken" icons and folder thumbnails.
echo.
call :ASK_CONFIRM "Proceed with Rebuild?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Icon Cache rebuild." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Explorer Restart ^& Icon Cache Rebuild..."
echo  [ PROCESS ] Terminating Windows Explorer...
taskkill /f /im explorer.exe >nul 2>&1

echo  [ PROCESS ] Deleting Icon and Thumbnail Cache databases...
del /f /s /q /a "%LocalAppData%\IconCache.db" >nul 2>&1
del /f /s /q /a "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1

echo  [ PROCESS ] Restarting Windows Explorer...
start explorer.exe

echo.
echo  [ STATUS ] Icon and Thumbnail databases have been successfully reset.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Icon and Thumbnail databases reset successfully."
pause
goto :SUB_MAINT_ADV

:FUNC_BROWSER_CLEAN
cls
echo.
echo  [ WARNING ] BROWSERS MUST BE CLOSED TO PERFORM A DEEP CLEAN.
echo  [ INFO ] Targeted: Chrome, Edge, Brave, Vivaldi, Opera, Arc, Firefox, LibreWolf, Waterfox.
call :ASK_CONFIRM "Proceed with Deep Clean?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Browser Deep Clean." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Browser Deep Clean..."
echo  [ PROCESS ] Halting all browser background processes...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-Process 'chrome','msedge','brave','opera','vivaldi','Arc','firefox','librewolf','waterfox' -ErrorAction SilentlyContinue | Stop-Process -Force"

:: 1. Google Chrome
if exist "%LocalAppData%\Google\Chrome\User Data" (echo  [ PROCESS ] Cleaning Google Chrome... & call :CLEAN_CHROMIUM "%LocalAppData%\Google\Chrome\User Data")

:: 2. Microsoft Edge
if exist "%LocalAppData%\Microsoft\Edge\User Data" (echo  [ PROCESS ] Cleaning Microsoft Edge... & call :CLEAN_CHROMIUM "%LocalAppData%\Microsoft\Edge\User Data")

:: 3. Brave Browser
if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data" (echo  [ PROCESS ] Cleaning Brave Browser... & call :CLEAN_CHROMIUM "%LocalAppData%\BraveSoftware\Brave-Browser\User Data")

:: 4. Vivaldi
if exist "%LocalAppData%\Vivaldi\User Data" (echo  [ PROCESS ] Cleaning Vivaldi... & call :CLEAN_CHROMIUM "%LocalAppData%\Vivaldi\User Data")

:: 5. Opera (Standard)
if exist "%LocalAppData%\Opera Software\Opera Stable" (echo  [ PROCESS ] Cleaning Opera Stable... & call :CLEAN_OPERA "%LocalAppData%\Opera Software\Opera Stable")

:: 6. Opera GX
if exist "%LocalAppData%\Opera Software\Opera GX Stable" (echo  [ PROCESS ] Cleaning Opera GX... & call :CLEAN_OPERA "%LocalAppData%\Opera Software\Opera GX Stable")

:: 7. Arc Browser (Special MSIX Path)
for /d %%A in ("%LocalAppData%\Packages\TheBrowserCompany.Arc_*") do if exist "%%A\LocalCache\Local\Arc\User Data\" (echo  [ PROCESS ] Cleaning Arc Browser... & call :CLEAN_CHROMIUM "%%A\LocalCache\Local\Arc\User Data")

:: 8. Mozilla Firefox
if exist "%LocalAppData%\Mozilla\Firefox\Profiles" (echo  [ PROCESS ] Cleaning Mozilla Firefox... & call :CLEAN_GECKO "%LocalAppData%\Mozilla\Firefox\Profiles")

:: 9. LibreWolf
if exist "%LocalAppData%\librewolf\Profiles" (echo  [ PROCESS ] Cleaning LibreWolf... & call :CLEAN_GECKO "%LocalAppData%\librewolf\Profiles")

:: 10. Waterfox
if exist "%LocalAppData%\Waterfox\Profiles" (echo  [ PROCESS ] Cleaning Waterfox... & call :CLEAN_GECKO "%LocalAppData%\Waterfox\Profiles")

echo.
echo  [ STATUS ] Browser Deep Clean cycle complete.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Browser Deep Clean cycle completed successfully."
pause
goto :SUB_MAINT_ADV

:FUNC_WSRESET
cls
echo.

:: LTSC and Server Edition Guard
echo(!FULL_OS!| findstr /i "LTSC Server" >nul
if !errorlevel! equ 0 (
    echo  [ WARNING ] OS DETECTED: !FULL_OS!
    echo  [ WARNING ] This operating system does not natively include the Microsoft Store.
    echo.
    call :ASK_CONFIRM "Force execution anyway (Only if manually sideloaded)?"
    if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User bypassed Store Reset on LTSC/Server." & timeout /t 2 >nul & goto :SUB_MAINT_ADV)
    echo.
) else (
    echo  [ INFO ] This will reset the Microsoft Store cache.
    echo  [ INFO ] A blank command prompt will open temporarily, followed by the Store.
    call :ASK_CONFIRM "Proceed with Store Reset?"
    if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Windows Store Cache reset." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)
    echo.
)

call :LOG "PROCESS" "MAINTENANCE" "Resetting Windows Store Cache (wsreset)..."
echo  [ PROCESS ] Resetting Windows Store Cache...
echo  [ INFO ] The Microsoft Store will open when complete.
echo  [ INFO ] Applying 120-second timeout safeguard...
echo.
:: Start wsreset and monitor with timeout
start "" wsreset.exe
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$proc = Get-Process wsreset -ErrorAction SilentlyContinue; " ^
    "if ($proc) { try { $proc | Wait-Process -Timeout 120 -ErrorAction Stop } catch { exit 1 } }"

set "WS_ERR=!errorlevel!"
if !WS_ERR! neq 0 (taskkill /f /im wsreset.exe >nul 2>&1 & echo  [ WARNING ] Operation timed out and was force-closed. & call :LOG "WARNING" "MAINTENANCE" "wsreset.exe hung and was terminated after 120s.")
if !WS_ERR! equ 0 (echo  [ STATUS ] Windows Store Cache successfully reset. & call :LOG "SUCCESS" "MAINTENANCE" "Windows Store Cache reset completed.")
echo.
pause
goto :SUB_MAINT_ADV

:FUNC_WINSXS
cls
echo.
echo  [ MAINTENANCE ] WINDOWS COMPONENT STORE (WINSXS) CLEANUP
echo            --------------------------------------------------------------------------------
echo.
echo  [1] Standard Cleanup  - Removes superseded files (Safe / Keeps Rollback)
echo  [2] Deep Image Reset  - Full purge (Reclaims Max Space / Locks in Updates)
echo  [R] Cancel            - Return to sub-menu
echo.
:WINSXS_SUB_PROMPT
set "ws_choice="
set /p "ws_choice= [Selection] :> "

if "!ws_choice!"=="1" goto :W_STANDARD
if "!ws_choice!"=="2" goto :W_DEEP
if /i "!ws_choice!"=="R" (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled WinSxS Component Store cleanup." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)
echo  [ ERROR ] Invalid selection.
goto :WINSXS_SUB_PROMPT

:W_STANDARD
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Standard DISM Component Store Cleanup..."
echo  [ PROCESS ] Initiating Standard Component Cleanup...
dism /online /cleanup-image /StartComponentCleanup

set "DISM_ERR=!errorlevel!"
echo.
call :EVAL_STATUS !DISM_ERR! "MAINTENANCE" "Standard Component Store Cleanup failed." "Standard Component Store Cleanup successfully dispatched."
pause
goto :SUB_MAINT_ADV

:W_DEEP
echo.
echo  [ WARNING ] THIS WILL PERMANENTLY REMOVE ALL UPDATE ROLLBACK FILES.
echo  [ WARNING ] YOU WILL NOT BE ABLE TO UNINSTALL CURRENT WINDOWS UPDATES.
call :ASK_CONFIRM "Proceed with Deep Reset?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Deep WinSxS Base Reset." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Deep WinSxS Base Reset..."
echo  [ PROCESS ] Phase 1: Initiating Component Cleanup...
dism /online /cleanup-image /StartComponentCleanup

set "DISM_ERR=!errorlevel!"
if !DISM_ERR! neq 0 (echo. & echo  [ ERROR ] Phase 1 failed. Aborting Phase 2 to prevent inconsistent state. & call :LOG "ERROR" "MAINTENANCE" "Phase 1 Component Cleanup failed. ResetBase aborted." & pause & goto :SUB_MAINT_ADV)

echo.
echo  [ PROCESS ] Phase 2: Performing ResetBase (Deep Purge)...
dism /online /cleanup-image /StartComponentCleanup /ResetBase

set "DISM_ERR=!errorlevel!"
if !DISM_ERR! neq 0 (echo. & echo  [ WARNING ] Phase 2 bypassed. This usually occurs if a restart is pending. & call :LOG "WARNING" "MAINTENANCE" "ResetBase bypassed (pending restart likely).")
if !DISM_ERR! equ 0 (echo. & echo  [ STATUS ] Component Store fully optimized and rollback base reset. & call :LOG "SUCCESS" "MAINTENANCE" "Deep WinSxS Base Reset completed successfully.")
pause
goto :SUB_MAINT_ADV

:FUNC_CRASHDUMPS
cls
echo.
echo  [ WARNING ] THIS WILL DELETE ERROR REPORTS AND CRASH DUMPS (MINIDUMPS).
echo  [ WARNING ] THESE FILES ARE OFTEN NEEDED TO DIAGNOSE SYSTEM CRASHES.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Crash Dump and WER purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Purging Error Reports and Minidumps..."
echo  [ PROCESS ] Purging Windows Error Reporting (WER) and Minidumps...
call :PURGE_DIR "%ProgramData%\Microsoft\Windows\WER"
call :PURGE_DIR "%WINDIR%\Minidump"
echo  [ STATUS ] Crash dumps and error reports successfully cleared.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Crash Dumps and WER cleared."
pause
goto :SUB_MAINT_ADV

:FUNC_EVENTLOGS
cls
echo.
echo  [ WARNING ] THIS WILL PERMANENTLY DELETE ALL HISTORICAL SYSTEM EVENT LOGS.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Event Log purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Clearing all Windows Event Viewer Logs..."
echo  [ PROCESS ] Clearing Windows Event Viewer Logs...
for /f "tokens=*" %%A in ('wevtutil.exe el') do wevtutil.exe cl "%%A" >nul 2>&1
echo  [ STATUS ] All Event Viewer logs have been successfully flushed.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Event Viewer Logs flushed successfully."
pause
goto :SUB_MAINT_ADV

:FUNC_DNS_DISPLAY
cls
echo.
call :LOG "INFO" "NETWORK" "Displayed current DNS Resolver Cache to user."
echo  [ PROCESS ] Retrieving current DNS Resolver Cache...
echo            --------------------------------------------------------------------------------
echo.
ipconfig /displaydns | more
echo.
echo            --------------------------------------------------------------------------------
echo.
echo  [ STATUS ] End of DNS Cache.
echo.
pause
goto :SUB_NET_GEN

:FUNC_DNS_FLUSH
cls
echo.
call :LOG "PROCESS" "NETWORK" "Flushing DNS Resolver Cache..."
echo  [ PROCESS ] Flushing DNS Cache...
ipconfig /flushdns >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to flush DNS cache." "DNS Cache successfully flushed."
echo.
pause
goto :SUB_NET_GEN

:FUNC_ARP_DISPLAY
cls
echo.
call :LOG "INFO" "NETWORK" "Displayed current ARP Cache to user."
echo  [ PROCESS ] Retrieving current ARP Cache (Address Resolution Protocol)...
echo            --------------------------------------------------------------------------------
echo.
arp -a
echo.
echo            --------------------------------------------------------------------------------
echo.
echo  [ STATUS ] End of ARP Cache.
echo.
pause
goto :SUB_NET_GEN

:FUNC_ARP_CLEAR
cls
echo.
call :LOG "PROCESS" "NETWORK" "Clearing ARP Cache..."
echo  [ PROCESS ] Purging ARP Cache (Force re-mapping of local MAC addresses)...
arp -d * >nul 2>&1
set "NET_ERR=!errorlevel!"
echo.
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to clear ARP cache." "ARP Cache successfully cleared."
echo.
pause
goto :SUB_NET_GEN

:FUNC_IP_RELEASE
cls
echo.
echo  [ WARNING ] THIS WILL TEMPORARILY CUT YOUR INTERNET CONNECTION.
echo  [ INFO ] You will remain offline until you run Option 2 (Renew IP).
call :ASK_CONFIRM "Proceed with IP Release?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled IP Address release." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Releasing local IP Address assignments..."
echo  [ PROCESS ] Releasing current IP Address assignments...
ipconfig /release >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to release IP address. Check adapter status." "IP addresses released for all active adapters."
echo.
pause
goto :SUB_NET_ADV

:FUNC_IP_RENEW
cls
echo.
echo  [ INFO ] Your connection will be restored once the DHCP server responds.
call :ASK_CONFIRM "Proceed with IP Renewal?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled IP Address renewal." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Renewing IP Address assignments via DHCP..."
echo  [ PROCESS ] Renewing IP Address assignments...
echo  [ INFO ] This may take a few seconds...
ipconfig /renew >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to renew IP address. Check network connection." "IP renewal request dispatched to DHCP server."
echo.
pause
goto :SUB_NET_ADV

:FUNC_TCP_RESET
cls
echo.
echo  [ WARNING ] THIS WILL RESET THE TCP/IP STACK TO FACTORY DEFAULTS.
echo  [ INFO ] This can fix persistent connection issues but clears custom settings.
echo.
call :ASK_CONFIRM "Proceed with TCP/IP Reset?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled TCP/IP Reset." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Executing netsh TCP/IP reset..."
echo  [ PROCESS ] Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
echo  [ STATUS ] TCP/IP Reset complete.
echo  [ WARNING ] A system REBOOT is required for changes to take effect.
call :LOG "SUCCESS" "NETWORK" "TCP/IP Reset executed. Reboot required."
echo.
call :ASK_REBOOT "TCP/IP"
goto :SUB_NET_ADV

:FUNC_WINSOCK_RESET
cls
echo.
echo  [ WARNING ] THIS WILL RESET THE WINSOCK CATALOG TO A CLEAN STATE.
echo  [ INFO ] This is the #1 fix for "No Internet" issues when Wi-Fi is connected.
echo.
call :ASK_CONFIRM "Proceed with Winsock Reset?"
if !errorlevel! neq 0 (echo. & echo  [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled Winsock Reset." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Executing netsh Winsock reset..."
echo  [ PROCESS ] Resetting Winsock Catalog...
netsh winsock reset >nul 2>&1
echo  [ STATUS ] Winsock Catalog Reset complete.
echo  [ WARNING ] A system REBOOT is required for changes to take effect.
call :LOG "SUCCESS" "NETWORK" "Winsock Catalog Reset executed. Reboot required."
echo.
call :ASK_REBOOT "Winsock"
goto :SUB_NET_ADV

:FUNC_SFC
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "REPAIR" "SFC Scan aborted due to low disk space." & timeout /t 2 >nul & goto :SUB_REPAIR)
call :LOG "PROCESS" "REPAIR" "Initiating System File Checker (SFC /scannow)..."
echo  [ PROCESS ] Initiating System File Checker...
:: Capture the line count of the CBS log before starting (if it exists)
if exist "%WINDIR%\Logs\CBS\CBS.log" for /f %%A in ('find /v /c "" ^< "%WINDIR%\Logs\CBS\CBS.log"') do set "LOG_START=%%A"
if not exist "%WINDIR%\Logs\CBS\CBS.log" set "LOG_START=0"

sfc /scannow
set "SFC_ERR=!errorlevel!"

:: Capture the line count of the CBS log after finishing (if it still exists)
if exist "%WINDIR%\Logs\CBS\CBS.log" for /f %%A in ('find /v /c "" ^< "%WINDIR%\Logs\CBS\CBS.log"') do set "LOG_END=%%A"
if not exist "%WINDIR%\Logs\CBS\CBS.log" set "LOG_END=0"

set /a LOG_DIFF=LOG_END-LOG_START

:: Guard against log rotation (negative diff)
if !LOG_DIFF! lss 0 set /a LOG_DIFF=LOG_END
:: Guard against massive log diffs freezing PowerShell execution
if !LOG_DIFF! gtr 10000 set "LOG_DIFF=10000"
:: Guard against zero lines (no log output captured)
if !LOG_DIFF! leq 0 (echo. & echo  [ WARNING ] Could not read SFC log output. Check CBS.log manually. & echo  [ INFO ] Log located at: %WINDIR%\Logs\CBS\CBS.log & call :LOG "WARNING" "REPAIR" "SFC completed but CBS log output could not be parsed." & echo. & pause & goto :SUB_REPAIR)

echo.
if !SFC_ERR! neq 0 goto :SFC_ERROR

:SFC_SUCCESS
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "try { " ^
    "  $recentLogs = Get-Content '%WINDIR%\Logs\CBS\CBS.log' -ErrorAction Stop | Select-Object -Last %LOG_DIFF%; " ^
    "  if ($recentLogs -match 'Repairing corrupted file') { " ^
    "    Write-Host '  [ STATUS ] SUCCESS: SFC found corrupt files and successfully repaired them.' -ForegroundColor DarkYellow; " ^
    "  } else { " ^
    "    Write-Host '  [ STATUS ] SUCCESS: SFC Scan complete. No integrity violations found.' -ForegroundColor Green; " ^
    "  } " ^
    "} catch { " ^
    "  Write-Host '  [ STATUS ] SUCCESS: SFC Scan complete.' -ForegroundColor Green; " ^
    "  Write-Host '  [ WARNING ] Log file locked. Could not read repair details.' -ForegroundColor DarkYellow; " ^
    "}"
call :LOG "SUCCESS" "REPAIR" "SFC scan completed without unrepairable violations."
goto :SFC_END

:SFC_ERROR
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "try { " ^
    "  $recentLogs = Get-Content '%WINDIR%\Logs\CBS\CBS.log' -ErrorAction Stop | Select-Object -Last %LOG_DIFF%; " ^
    "  if ($recentLogs -match 'Cannot repair member file') { " ^
    "    Write-Host '  [ ERROR ] CRITICAL: SFC found corruptions it could not automatically fix.' -ForegroundColor Red; " ^
    "    Write-Host '  [ INFO ] Please run DISM Deep Image Repair (Option 4) to repair the core image.' -ForegroundColor Gray; " ^
    "  } else { " ^
    "    Write-Host '  [ ERROR ] FAILED: SFC failed to start or complete the requested operation.' -ForegroundColor Red; " ^
    "  } " ^
    "} catch { " ^
    "  Write-Host '  [ ERROR ] FAILED: SFC encountered an error. Check CBS.log manually.' -ForegroundColor Red; " ^
    "  Write-Host '  [ WARNING ] Log file is locked or inaccessible.' -ForegroundColor DarkYellow; " ^
    "}"
call :LOG "ERROR" "REPAIR" "SFC failed or found unrepairable corruption (Exit Code: !SFC_ERR!)."

:SFC_END
echo.
pause
goto :SUB_REPAIR

:FUNC_DISM_CHECK
cls
echo.
call :LOG "PROCESS" "REPAIR" "Initiating DISM Quick Image Check (/CheckHealth)..."
echo  [ PROCESS ] Initiating DISM Quick Image Check (/CheckHealth)...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$state = [string](Repair-WindowsImage -Online -CheckHealth -ErrorAction SilentlyContinue).ImageHealthState; " ^
    "if ($state -eq 'Healthy') { Write-Host '  [ STATUS ] SUCCESS: No component store corruption detected.' -ForegroundColor Green } " ^
    "elseif ($state -eq 'Repairable') { Write-Host '  [ WARNING ] REPAIRABLE: Corruption detected. Please run Deep Image Repair (Option 4).' -ForegroundColor DarkYellow } " ^
    "elseif ($state -eq 'NonRepairable') { Write-Host '  [ CRITICAL ] UNREPAIRABLE: Image is corrupted and cannot be repaired.' -ForegroundColor Red } " ^
    "else { Write-Host '  [ ERROR ] DISM failed to execute or return status.' -ForegroundColor Gray }"
call :LOG "SUCCESS" "REPAIR" "DISM Quick Check execution completed."
echo.
pause
goto :SUB_REPAIR

:FUNC_DISM_SCAN
cls
echo.
call :LOG "PROCESS" "REPAIR" "Initiating DISM Deep Image Scan (/ScanHealth)..."
echo  [ PROCESS ] Initiating DISM Deep Image Scan (/ScanHealth)...
echo  [ INFO ] This will take several minutes. A progress bar will appear soon...
timeout /t 2 >nul
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$state = [string](Repair-WindowsImage -Online -ScanHealth -ErrorAction SilentlyContinue).ImageHealthState; " ^
    "if ($state -eq 'Healthy') { Write-Host '  [ STATUS ] SUCCESS: No component store corruption detected.' -ForegroundColor Green } " ^
    "elseif ($state -eq 'Repairable') { Write-Host '  [ WARNING ] REPAIRABLE: Corruption detected. Please run Deep Image Repair (Option 4).' -ForegroundColor DarkYellow } " ^
    "elseif ($state -eq 'NonRepairable') { Write-Host '  [ CRITICAL ] UNREPAIRABLE: Image is corrupted and cannot be repaired.' -ForegroundColor Red } " ^
    "else { Write-Host '  [ ERROR ] DISM failed to execute or return status.' -ForegroundColor Gray }"
call :LOG "SUCCESS" "REPAIR" "DISM Deep Scan execution completed."
echo.
pause
goto :SUB_REPAIR

:FUNC_DISM_RESTORE
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "REPAIR" "DISM Restore aborted due to low disk space." & timeout /t 2 >nul & goto :SUB_REPAIR)
call :LOG "PROCESS" "REPAIR" "Initiating DISM Deep Image Repair (/RestoreHealth)..."
echo  [ PROCESS ] Initiating DISM Deep Image Repair (/RestoreHealth)...
dism /online /cleanup-image /restorehealth
set "DISM_ERR=!errorlevel!"
echo.
call :EVAL_STATUS !DISM_ERR! "REPAIR" "DISM failed to repair the image (Exit Code: !DISM_ERR!)." "DISM successfully repaired the component store image."
echo.
pause
goto :SUB_REPAIR

:: ---------------------------------------------------------------------------
:: HELP & INFORMATION PAGES
:: ---------------------------------------------------------------------------
:FUNC_HELP
cls
call :PRINT_HEADER
echo.
echo            -- HELP ^& INFORMATION (PAGE 1 OF 2) --------------------------------
echo.
echo             [ ABOUT ]
echo             Primus is a system maintenance utility designed to safely perform
echo             common Windows cleanup tasks, repair and optimizations.
echo.
echo             [ LOGGING SYSTEM ]
echo             Location:  %ProgramData%\Primus\Logs\
echo             Retention: 30 Days (Automatic background cleanup)
echo             Format:    Primus_YYYYMMDD_HHMMSS.log
echo.
echo             [ SAFETY PROTOCOLS ]
echo             * Always create a Restore Point before major operations.
echo             * Active/In-use files are automatically skipped during cleanup.
echo             * All destructive operations require Y/N confirmation.
echo.
echo             [ SUPPORT ]
echo             GitHub: https://github.com/R4in84/Primus
echo.
echo           ======================================================================
echo             [Press any key to view Tool Descriptions...]
pause >nul

cls
call :PRINT_HEADER
echo.
echo            -- TOOL DESCRIPTIONS (PAGE 2 OF 2) ---------------------------------
echo.
echo             [ SYSTEM RECOVERY ]
echo             Safely creates or purges Volume Shadow Copy Service (VSS)
echo             snapshots to protect your system state before major changes.
echo.
echo             [ SYSTEM MAINTENANCE ]
echo             Clears temporary directories, rebuilds broken icon caches, deep
echo             cleans browser telemetry, and optimizes the WinSxS store.
echo.
echo             [ NETWORK OPTIMIZATION ]
echo             Flushes DNS/ARP routing tables and performs deep resets of the 
echo             TCP/IP stack and Winsock catalog to resolve offline bugs.
echo.
echo             [ SYSTEM REPAIR ]
echo             Utilizes native Windows SFC and DISM deployment tools to scan
echo             for and automatically repair deep-level Windows image corruption.
echo.
echo           ======================================================================
call :LOG "INFO" "SYSTEM" "User accessed Help & Information module."
echo             [Press any key to return to Main Menu...]
pause >nul
goto :MENU

:FUNC_SYSINFO
cls
call :PRINT_HEADER
echo.
echo            -- SYSTEM INFORMATION ----------------------------------------------
echo.
call :LOG "PROCESS" "SYSTEM" "Gathering detailed system hardware specifications..."
echo  [ PROCESS ] Interrogating WMI for hardware details...
echo.

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$cpu = (Get-CimInstance Win32_Processor).Name -replace '  ', ' '; " ^
    "$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1); " ^
    "$gpu = (Get-CimInstance Win32_VideoController).Name; " ^
    "$mobo = (Get-CimInstance Win32_BaseBoard).Product; " ^
    "$bios = (Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion; " ^
    "Write-Host '            PROCESSOR: ' -NoNewline; Write-Host $cpu -ForegroundColor Cyan; " ^
    "Write-Host '            MEMORY:    ' -NoNewline; Write-Host \"$ram GB Installed\" -ForegroundColor Cyan; " ^
    "Write-Host '            GRAPHICS:  ' -NoNewline; Write-Host ($gpu -join ' | ') -ForegroundColor Cyan; " ^
    "Write-Host '            BASEBOARD: ' -NoNewline; Write-Host $mobo -ForegroundColor Cyan; " ^
    "Write-Host '            BIOS VER:  ' -NoNewline; Write-Host $bios -ForegroundColor Cyan;"

echo.
echo           ======================================================================
echo.
call :LOG "SUCCESS" "SYSTEM" "Hardware specifications successfully displayed."
pause
goto :MENU

:: ---------------------------------------------------------------------------
:: GLOBAL CLEANUP ENGINES
:: ---------------------------------------------------------------------------
:PURGE_DIR
if not exist "%~1" exit /b
del /q /s /f /a "%~1\*.*" >nul 2>&1
for /f "delims=" %%i in ('dir /a:d /b "%~1" 2^>nul') do rd /s /q "%~1\%%i" >nul 2>&1
exit /b

:CLEAN_CHROMIUM
if exist "%~1" for /d %%i in ("%~1\*") do if exist "%%i\Cache\" (rd /s /q "%%i\Cache" >nul 2>&1 & rd /s /q "%%i\Code Cache" >nul 2>&1 & rd /s /q "%%i\GPUCache" >nul 2>&1)
exit /b

:CLEAN_GECKO
if exist "%~1" for /d %%i in ("%~1\*") do if exist "%%i\cache2\" (rd /s /q "%%i\cache2" >nul 2>&1 & rd /s /q "%%i\jumpListCache" >nul 2>&1 & rd /s /q "%%i\startupCache" >nul 2>&1)
exit /b

:CLEAN_OPERA
if exist "%~1" (rd /s /q "%~1\Cache" >nul 2>&1 & rd /s /q "%~1\Code Cache" >nul 2>&1 & rd /s /q "%~1\GPUCache" >nul 2>&1)
exit /b

:: ---------------------------------------------------------------------------
:: GLOBAL LOGIC ENGINES
:: ---------------------------------------------------------------------------
:ASK_CONFIRM
set "confirm_ans="
set /p "confirm_ans= [ CONFIRM ] %~1 (Y/N) :> "
if /i "!confirm_ans!"=="Y" exit /b 0
if /i "!confirm_ans!"=="N" exit /b 1
echo  [ ERROR ] Invalid input. Please enter Y or N.
goto :ASK_CONFIRM

:ASK_REBOOT
call :ASK_CONFIRM "Restart computer now?"
if !errorlevel! equ 0 (call :LOG "INFO" "CORE" "Initiating system reboot for %~1 changes." & shutdown /r /t 5 /c "Primus: Rebooting to apply %~1 Reset..." & exit)
exit /b

:EVAL_STATUS
if "%~1"=="0" goto :EVAL_SUCCESS
echo  [ ERROR ] %~3
call :LOG "ERROR" "%~2" "%~3"
exit /b

:EVAL_SUCCESS
echo  [ STATUS ] %~4
call :LOG "SUCCESS" "%~2" "%~4"
exit /b

:CHECK_FREE_SPACE
:: Evaluates if %SystemDrive% has at least 2GB of free space to prevent corruption during heavy operations.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$f = (Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='%SystemDrive%'\").FreeSpace; if ($f -lt 2GB) { exit 1 } else { exit 0 }"
if !errorlevel! equ 1 (
    echo.
    echo  [ WARNING ] CRITICAL: Low disk space detected on %SystemDrive%\ ^(!SYS_FREE!^).
    echo  [ WARNING ] This operation requires at least 2GB of free space to run safely.
    echo.
    call :ASK_CONFIRM "Force execution anyway (Not Recommended)?"
    if !errorlevel! neq 0 exit /b 1
)
exit /b 0

:: ---------------------------------------------------------------------------
:: LOGGING ENGINE
:: ---------------------------------------------------------------------------
:LOG
:: Usage: call :LOG "LEVEL" "CATEGORY" "Message"
set "log_lvl=%~1"
set "log_cat=%~2"
set "log_msg=%~3"

:: Escape special characters for safe file writing
set "log_msg=!log_msg:&=^&!"
set "log_msg=!log_msg:|=^|!"
set "log_msg=!log_msg:<=^<!"
set "log_msg=!log_msg:>=^>!"

:: Pad the severity level string (7 characters)
set "log_lvl=!log_lvl!       "
set "log_lvl=!log_lvl:~0,7!"

:: Pad the category string (12 characters)
set "log_cat=!log_cat!            "
set "log_cat=!log_cat:~0,12!"

:: Format time to remove leading spaces (e.g., 9:00 vs 09:00)
set "log_time=!TIME:~0,8!"
set "log_time=!log_time: =0!"

:: Append to log file
echo [%DATE% !log_time!] [!log_cat!] [!log_lvl!] : !log_msg! >> "!LOG_FILE!"
exit /b

:FUNC_EXIT
call :LOG "SYSTEM" "CORE" "Primus v!PRIMUS_VERSION! Session Terminated Safely."
cls
echo.
echo.
echo.
echo            ----------------------------------------------------------------------
echo                  Primus Session Terminated Safely. Closing Application...
echo            ----------------------------------------------------------------------
timeout /t 2 >nul
endlocal
exit