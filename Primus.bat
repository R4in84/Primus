@echo off
:: ===========================================================================
:: P R I M U S  -  S Y S T E M   U T I L I T Y
:: Version 1.2.0 (Build 20260508)
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

:: Generate an invisible Backspace character for UI alignment
for /f %%A in ('"prompt $H &echo on &for %%B in (1) do rem"') do set "BS=%%A"

:: Version Information
set "PRIMUS_VERSION=1.2.0"
set "PRIMUS_BUILD=20260508"

:: Initialise Session Variables
set "SESSION_TOTAL_BYTES=0"

:: Define Window Size: 100 Columns, 41 Lines
mode con: cols=100 lines=41
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

:: Create fixed-width strings for perfect column alignment (35 characters wide)
set "USER_STR=USER: !USERNAME!                                        "
set "UPTIME_STR=UPTIME: !SYS_UPTIME!                                        "
set "TIME_STR=SESSION: !CURRENT_TIME!                                        "

:: ---------------------------------------------------------------------------
:: INITIALISE LOGGING SYSTEM
:: ---------------------------------------------------------------------------
set "LOG_DIR=%ProgramData%\Primus\Logs"
if not exist "!LOG_DIR!" mkdir "!LOG_DIR!" >nul 2>&1 || (set "LOG_DIR=%TEMP%\Primus_Logs" & mkdir "!LOG_DIR!" >nul 2>&1)
if not exist "!LOG_DIR!" set "LOG_DIR=%TEMP%"

:: Enforce 30-Day Rolling Log Retention Policy (Silently purges old logs)
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-ChildItem -Path '!LOG_DIR!' -Filter '*.log' | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force" >nul 2>&1

:: Define initial Log File path
set "LOG_FILE=!LOG_DIR!\Primus_!FILE_TIME!.log"

:: Collision Safety: Prevent overwrites if PS failed or script launched twice in one second
if exist "!LOG_FILE!" set "LOG_FILE=!LOG_DIR!\Primus_!FILE_TIME!_!RANDOM!.log"

(
echo.
echo ================================================================================
echo                                     P R I M U S
echo                                     SESSION LOG
echo ================================================================================
echo  USER: !USERNAME!
echo  HOST: %COMPUTERNAME%
echo  OS:   !FULL_OS!
echo  SESSION: !CURRENT_TIME! %DATE%
echo ================================================================================
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
echo           ================================================================================
echo                                      P R I M U S   U T I L I T Y
echo                                      END USER LICENCE AGREEMENT
echo           ================================================================================
echo.
echo              WARNING: This utility performs deep system modifications, including
echo              file deletion, network resets, and core image adjustments.
echo.
echo              By using this software, you acknowledge that it is provided "AS IS"
echo              without warranties of any kind. You are solely responsible for any
echo              data loss or system instability that may occur.
echo.
echo              Please review the Help ^& Information module [H] before running
echo              destructive commands.
echo.
echo           ================================================================================
:EULA_PROMPT
set "eula_ans="
set /p "eula_ans=%BS%             [ ACTION ] Type ACCEPT to continue or EXIT to cancel :> "
if /i "!eula_ans!"=="EXIT" exit /b
if /i "!eula_ans!"=="ACCEPT" (
    echo. > "!EULA_FILE!"
    call :LOG "SYSTEM" "CORE" "User accepted first-run End User Licence Agreement."
    goto :SKIP_EULA
)
echo    [ ERROR ] Invalid input. Please type ACCEPT or EXIT.
goto :EULA_PROMPT

:SKIP_EULA

cls
echo.
echo.
echo.
echo           ================================================================================
echo                             Initialising Primus v!PRIMUS_VERSION! System Utility...
echo           ================================================================================
timeout /t 3 >nul

call :CHECK_UPDATES

:: ---------------------------------------------------------------------------
:: MAIN DASHBOARD
:: ---------------------------------------------------------------------------
:MENU
call :PRINT_HEADER
echo.
echo           -- SYSTEM RECOVERY (CRITICAL) --------------------------------------------------
echo            [A] Create System Restore Point            [B] Clean Restore Points
echo            [C] Backup System Registry                 [D] Backup System Drivers
echo.
echo           -- SYSTEM MAINTENANCE ----------------------------------------------------------
echo            [1] General Cleanup                        [2] Deep System Cleanup
echo.
echo           -- SYSTEM DIAGNOSTICS ^& REPAIR -------------------------------------------------
echo            [3] File System Health (CHKDSK)            [4] Core Image Repair (SFC/DISM)
echo.
echo           -- NETWORK OPTIMISATION --------------------------------------------------------
echo            [5] Network Cleanup                        [6] Network Reset/Repair
echo.
echo           -- SYSTEM OPTIMISATION ---------------------------------------------------------
echo            [7] Storage Optimisation                   [8] Memory Management
echo.
echo           -- SECURITY ^& PRIVACY ----------------------------------------------------------
echo            [9] Security Suite                         [10] Privacy ^& Telemetry
echo.
echo           ================================================================================
echo            [S] SYSTEM INFORMATION          [H] HELP ^& INFO           [X] EXIT APPLICATION
echo.
set "main_choice="
set /p "main_choice=%BS%          [Selection] :> "

if /i "!main_choice!"=="A" goto :FUNC_CREATE_RESTORE
if /i "!main_choice!"=="B" goto :FUNC_CLEAN_RESTORE
if /i "!main_choice!"=="C" goto :FUNC_BACKUP_REGISTRY
if /i "!main_choice!"=="D" goto :FUNC_BACKUP_DRIVERS
if "!main_choice!"=="1" goto :SUB_MAINT_GEN
if "!main_choice!"=="2" goto :SUB_MAINT_ADV
if "!main_choice!"=="3" goto :SUB_DIAG_CHKDSK
if "!main_choice!"=="4" goto :SUB_REPAIR
if "!main_choice!"=="5" goto :SUB_NET_GEN
if "!main_choice!"=="6" goto :SUB_NET_ADV
if "!main_choice!"=="7" goto :SUB_STORAGE
if "!main_choice!"=="8" goto :SUB_MEMORY
if "!main_choice!"=="9" goto :SUB_SECURITY
if "!main_choice!"=="10" goto :SUB_TELEMETRY
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
echo           -- GENERAL CLEANUP -------------------------------------------------------------
echo.
echo            [1] Clean All Temp Files                   [2] Clear Prefetch Cache
echo            [3] Clean Update Download Cache            [4] Clean Thumbnail Cache
echo            [5] Empty Recycle Bins                     [6] Disk Cleanup Utility
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
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
echo           -- DEEP SYSTEM CLEANUP ---------------------------------------------------------
echo.
echo            [1] Rebuild Icon ^& Thumb Cache             [2] Rebuild Windows Font Cache
echo            [3] Browser Cache Deep Clean               [4] Clear DirectX Shader Cache
echo            [5] Clean Delivery Optimisation            [6] Clean WinSxS Component Store
echo            [7] Reset Windows Store Cache              [8] Clean Error Reports ^& Dumps
echo            [9] Purge Windows.old Installation        [10] Clear System Event Logs
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_ICON_REBUILD
if "!choice!"=="2" goto :FUNC_FONT_CACHE
if "!choice!"=="3" goto :FUNC_BROWSER_CLEAN
if "!choice!"=="4" goto :FUNC_DIRECTX_CACHE
if "!choice!"=="5" goto :FUNC_DELIVERY_OPT
if "!choice!"=="6" goto :FUNC_WINSXS
if "!choice!"=="7" goto :FUNC_WSRESET
if "!choice!"=="8" goto :FUNC_CRASHDUMPS
if "!choice!"=="9" goto :FUNC_WINDOWS_OLD
if "!choice!"=="10" goto :FUNC_EVENTLOGS
if /i "!choice!"=="R" goto :MENU
goto :SUB_MAINT_ADV

:SUB_DIAG_CHKDSK
call :PRINT_HEADER
echo.
echo           -- FILE SYSTEM HEALTH (CHKDSK) -------------------------------------------------
echo.
echo            [1] Query Volume Dirty Bit                 [2] Read-Only Integrity Scan
echo            [3] Schedule Offline Repair                [4] Cancel Scheduled Repair
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_CHKDSK_DIRTY
if "!choice!"=="2" goto :FUNC_CHKDSK_SCAN
if "!choice!"=="3" goto :FUNC_CHKDSK_SCHED
if "!choice!"=="4" goto :FUNC_CHKDSK_CANCEL
if /i "!choice!"=="R" goto :MENU
goto :SUB_DIAG_CHKDSK

:SUB_REPAIR
call :PRINT_HEADER
echo.
echo           -- CORE IMAGE REPAIR (SFC/DISM) ------------------------------------------------
echo.
echo            [1] Run System File Checker                [2] DISM Quick Image Check
echo            [3] DISM Deep Image Scan                   [4] DISM Deep Image Repair
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_SFC
if "!choice!"=="2" goto :FUNC_DISM_CHECK
if "!choice!"=="3" goto :FUNC_DISM_SCAN
if "!choice!"=="4" goto :FUNC_DISM_RESTORE
if /i "!choice!"=="R" goto :MENU
goto :SUB_REPAIR

:SUB_NET_GEN
call :PRINT_HEADER
echo.
echo           -- NETWORK CLEANUP -------------------------------------------------------------
echo.
echo            [1] Display DNS Cache                      [2] Flush DNS Cache
echo            [3] Display ARP Cache                      [4] Clear ARP Cache
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_DNS_DISPLAY
if "!choice!"=="2" goto :FUNC_DNS_FLUSH
if "!choice!"=="3" goto :FUNC_ARP_DISPLAY
if "!choice!"=="4" goto :FUNC_ARP_CLEAR
if /i "!choice!"=="R" goto :MENU
goto :SUB_NET_GEN

:SUB_NET_ADV
call :PRINT_HEADER
echo.
echo           -- NETWORK RESET/REPAIR --------------------------------------------------------
echo.
echo            [1] Release IP Address                     [2] Renew IP Address
echo            [3] Reset TCP/IP Stack                     [4] Reset Winsock Catalogue
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_IP_RELEASE
if "!choice!"=="2" goto :FUNC_IP_RENEW
if "!choice!"=="3" goto :FUNC_TCP_RESET
if "!choice!"=="4" goto :FUNC_WINSOCK_RESET
if /i "!choice!"=="R" goto :MENU
goto :SUB_NET_ADV

:SUB_STORAGE
call :PRINT_HEADER
echo.
echo           -- STORAGE OPTIMISATION --------------------------------------------------------
echo.
echo            [1] Trim Solid State Drives (SSDs)         [2] Defragment Hard Drives (HDDs)
echo            [3] CompactOS (System Compression)         [4] Hibernation Space Management
echo            [5] Windows Reserved Storage               [6] Shadow Copy Storage Capping
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_TRIM_SSD
if "!choice!"=="2" goto :FUNC_DEFRAG_HDD
if "!choice!"=="3" goto :FUNC_COMPACT_OS
if "!choice!"=="4" goto :FUNC_HIBERNATE
if "!choice!"=="5" goto :FUNC_RESERVED_STORAGE
if "!choice!"=="6" goto :FUNC_VSS_LIMIT
if /i "!choice!"=="R" goto :MENU
goto :SUB_STORAGE

:SUB_MEMORY
call :PRINT_HEADER
echo.
echo           -- MEMORY MANAGEMENT -----------------------------------------------------------
echo.
echo            [1] Analyse Top Memory Consumers           [2] Clear System Clipboard
echo            [3] Quick Memory Dump (Standby Cache)      [4] Flush Active Working Sets
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_MEM_ANALYSE
if "!choice!"=="2" goto :FUNC_MEM_CLIPBOARD
if "!choice!"=="3" goto :FUNC_MEM_DUMP
if "!choice!"=="4" goto :FUNC_MEM_FLUSH
if /i "!choice!"=="R" goto :MENU
goto :SUB_MEMORY

:SUB_SECURITY
call :PRINT_HEADER
echo.
echo           -- SECURITY SUITE --------------------------------------------------------------
echo.
echo            [1] Microsoft Safety Scanner (MSERT)       [2] Reset Windows Firewall
echo            [3] Windows Defender Deep Clean            [4] Force Signature Update
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_MSERT_SCAN
if "!choice!"=="2" goto :FUNC_FIREWALL_RESET
if "!choice!"=="3" goto :FUNC_DEFENDER_CLEAN
if "!choice!"=="4" goto :FUNC_DEFENDER_UPDATE
if /i "!choice!"=="R" goto :MENU
goto :SUB_SECURITY

:SUB_TELEMETRY
call :PRINT_HEADER
echo.
echo           -- PRIVACY ^& TELEMETRY ---------------------------------------------------------
echo.
echo            [1] Windows System Telemetry               [2] Activity History ^& Timeline
echo            [3] Error Reporting (WER)                  [4] CEIP Scheduled Tasks
echo            [5] Cortana ^& Web Search                   [6] App Advertising ID
echo.
echo           ================================================================================
echo            [R] RETURN TO MAIN MENU
echo.
set "choice="
set /p "choice=%BS%          [Selection] :> "
if "!choice!"=="1" goto :FUNC_TEL_WINDOWS
if "!choice!"=="2" goto :FUNC_TEL_TIMELINE
if "!choice!"=="3" goto :FUNC_TEL_WER
if "!choice!"=="4" goto :FUNC_TEL_CEIP
if "!choice!"=="5" goto :FUNC_TEL_CORTANA
if "!choice!"=="6" goto :FUNC_TEL_APPID
if /i "!choice!"=="R" goto :MENU
goto :SUB_TELEMETRY

:: ---------------------------------------------------------------------------
:: UI HEADER GENERATOR
:: ---------------------------------------------------------------------------
:PRINT_HEADER
cls
echo.
echo           ================================================================================
echo                                              P R I M U S 
echo                                                v!PRIMUS_VERSION!
echo           ================================================================================
echo.
echo              [ SYSTEM STATUS ]
echo              --------------------------------------------------------------------------
echo              HOST: %COMPUTERNAME%
echo              OS:   !FULL_OS!
echo              --------------------------------------------------------------------------
echo              !USER_STR:~0,35!      STATUS: !BOOT_STATUS!
echo              !UPTIME_STR:~0,35!      %SystemDrive%\ FREE: !SYS_FREE!
echo              !TIME_STR:~0,35!      DATE: %DATE%
echo.
echo           ================================================================================
exit /b

:: ---------------------------------------------------------------------------
:: ISOLATED COMPARTMENTALIZED FUNCTIONS
:: ---------------------------------------------------------------------------

:: --- RECOVERY MODULES ---
:FUNC_CREATE_RESTORE
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "RECOVERY" "Restore Point aborted due to low disk space." & timeout /t 2 >nul & goto :MENU)
echo    [ INFO ] This will create a manual system state backup.
call :ASK_CONFIRM "Create Restore Point?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to main menu... & call :LOG "WARNING" "RECOVERY" "User cancelled Restore Point creation." & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating manual System Restore Point creation..."
echo    [ PROCESS ] Ensuring VSS and System Restore Services are running...
net start vss >nul 2>&1
net start swprv >nul 2>&1
net start srsvc >nul 2>&1

:: Prevent race conditions on slower systems while VSS writers initialise
timeout /t 2 >nul

echo    [ PROCESS ] Verifying System Protection status on %SystemDrive%\...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$d='%SystemDrive%\'; $sr=Get-CimInstance -Namespace root\default -Class SystemRestoreConfig -ErrorAction SilentlyContinue | Where-Object Drive -eq $d; if (-not $sr) { Enable-ComputerRestore -Drive $d -ErrorAction SilentlyContinue }"

echo    [ PROCESS ] Overriding Windows Restore frequency limit...
reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 0 /f >nul 2>&1

echo    [ PROCESS ] Creating System Restore Point...
echo    [ INFO ] This may take 30-60 seconds...
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Checkpoint-Computer -Description 'Primus_Manual_Backup' -RestorePointType 'MODIFY_SETTINGS'; exit $LASTEXITCODE"
set "PS_ERR=!errorlevel!"

echo.
call :EVAL_STATUS !PS_ERR! "RECOVERY" "Failed to create Restore Point (Exit Code: !PS_ERR!)." "Restore Point 'Primus_Manual_Backup' created successfully."

reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\SystemRestore" /v "SystemRestorePointCreationFrequency" /t REG_DWORD /d 1440 /f >nul 2>&1
echo.
echo    [Press any key to return to Main Menu...] & pause >nul
goto :MENU

:FUNC_CLEAN_RESTORE
cls
echo.
echo    [ INFO ] This will delete all but the LATEST Restore Point.
call :ASK_CONFIRM "Proceed with purge?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to main menu... & call :LOG "WARNING" "RECOVERY" "User cancelled Restore Point purge." & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating purge of old Shadow Copies..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Identifying VSS Shadow Copies via WMI...
echo    [ INFO ] Only the most recent copy will be preserved.
echo.

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$vol = Get-CimInstance Win32_Volume -Filter \"DriveLetter='%SystemDrive%'\"; " ^
    "if (-not $vol) { Write-Host '   [ ERROR ] OS volume not found.' -ForegroundColor Red; exit; } " ^
    "$shadows = @(Get-CimInstance Win32_ShadowCopy | Where-Object VolumeName -eq $vol.DeviceID | Sort-Object InstallDate); " ^
    "if ($shadows.Count -gt 1) { " ^
    "  $toDelete = $shadows | Select-Object -First ($shadows.Count - 1); " ^
    "  foreach ($s in $toDelete) { " ^
    "    Write-Host \"   [ STATUS ] Purging Shadow ID: $($s.ID)\"; " ^
    "    $s | Remove-CimInstance; " ^
    "  } " ^
    "  Write-Host '   [ STATUS ] Cleanup complete.' -ForegroundColor Green; " ^
    "} else { Write-Host '   [ INFO ] Valid limit reached. Skipping.' -ForegroundColor Cyan; }"

call :TRACK_SPACE_END
call :LOG "SUCCESS" "RECOVERY" "Shadow Copy cleanup operation completed."
echo.
echo    [Press any key to return to Main Menu...] & pause >nul
goto :MENU

:FUNC_BACKUP_REGISTRY
cls
echo.
echo    [ INFO ] This will create a bare-metal backup of your core Registry hives.
echo    [ INFO ] Backups are saved to: %ProgramData%\Primus\Backups\Registry\
call :ASK_CONFIRM "Proceed with Registry Backup?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating bare-metal Registry Hive backup..."

:: Create a unique, timestamped folder for this specific backup
set "REG_DIR=%ProgramData%\Primus\Backups\Registry\!FILE_TIME!"
mkdir "!REG_DIR!" >nul 2>&1

:: Initialize Error Counter
set "REG_ERR=0"

echo    [ PROCESS ] Snapshotting HKLM\SYSTEM...
reg save HKLM\SYSTEM "!REG_DIR!\SYSTEM.hiv" /y >nul 2>&1
set /a REG_ERR+=!errorlevel!

echo    [ PROCESS ] Snapshotting HKLM\SOFTWARE...
reg save HKLM\SOFTWARE "!REG_DIR!\SOFTWARE.hiv" /y >nul 2>&1
set /a REG_ERR+=!errorlevel!

echo    [ PROCESS ] Snapshotting HKLM\SAM...
reg save HKLM\SAM "!REG_DIR!\SAM.hiv" /y >nul 2>&1
set /a REG_ERR+=!errorlevel!

echo    [ PROCESS ] Snapshotting HKLM\SECURITY...
reg save HKLM\SECURITY "!REG_DIR!\SECURITY.hiv" /y >nul 2>&1
set /a REG_ERR+=!errorlevel!

echo    [ PROCESS ] Snapshotting HKU\.DEFAULT...
reg save HKU\.DEFAULT "!REG_DIR!\DEFAULT.hiv" /y >nul 2>&1
set /a REG_ERR+=!errorlevel!

echo    [ PROCESS ] Generating WinRE Auto-Restore Script...
(
echo @echo off
echo echo ==================================================
echo echo         PRIMUS EMERGENCY REGISTRY RESTORE
echo echo ==================================================
echo echo.
echo echo Locating Windows installation...
echo set "OS_DRIVE="
echo for %%%%D in ^(C D E F G H I J K L M N O P Q R S T U V W Y Z^) do ^(if exist "%%%%D:\Windows\System32\config\SOFTWARE" set "OS_DRIVE=%%%%D:"^)
echo if not defined OS_DRIVE ^(echo [ERROR] Could not find Windows. ^& pause ^& exit /b^)
echo echo [STATUS] Windows found on drive: %%OS_DRIVE%%
echo echo.
echo echo Backing up corrupted hives ^(.bad^)...
echo ren "%%OS_DRIVE%%\Windows\System32\config\SYSTEM" SYSTEM.bad 2^>nul
echo ren "%%OS_DRIVE%%\Windows\System32\config\SOFTWARE" SOFTWARE.bad 2^>nul
echo ren "%%OS_DRIVE%%\Windows\System32\config\SAM" SAM.bad 2^>nul
echo ren "%%OS_DRIVE%%\Windows\System32\config\SECURITY" SECURITY.bad 2^>nul
echo ren "%%OS_DRIVE%%\Windows\System32\config\DEFAULT" DEFAULT.bad 2^>nul
echo echo.
echo echo Restoring healthy hives...
echo copy /y SYSTEM.hiv "%%OS_DRIVE%%\Windows\System32\config\SYSTEM" ^>nul
echo copy /y SOFTWARE.hiv "%%OS_DRIVE%%\Windows\System32\config\SOFTWARE" ^>nul
echo copy /y SAM.hiv "%%OS_DRIVE%%\Windows\System32\config\SAM" ^>nul
echo copy /y SECURITY.hiv "%%OS_DRIVE%%\Windows\System32\config\SECURITY" ^>nul
echo copy /y DEFAULT.hiv "%%OS_DRIVE%%\Windows\System32\config\DEFAULT" ^>nul
echo echo.
echo echo [SUCCESS] Restore Complete. Please close this window and restart your PC.
echo pause
) > "!REG_DIR!\Restore_Registry.bat"

:: Validate the backup by checking both the cumulative exit codes and file existence
set "BACKUP_OK=0"
if !REG_ERR! equ 0 if exist "!REG_DIR!\SYSTEM.hiv" if exist "!REG_DIR!\SOFTWARE.hiv" if exist "!REG_DIR!\SAM.hiv" if exist "!REG_DIR!\SECURITY.hiv" if exist "!REG_DIR!\DEFAULT.hiv" set "BACKUP_OK=1"

if !BACKUP_OK! equ 1 (
    call :LOG "SUCCESS" "RECOVERY" "Registry backup successfully saved to !REG_DIR!"
    echo    [ STATUS ] SUCCESS: All core registry hives exported with zero errors.
) else (
    call :LOG "ERROR" "RECOVERY" "Registry backup failed or encountered corruption (Exit Code Sum: !REG_ERR!)."
    echo    [ ERROR ] FAILED: One or more registry hives failed to export cleanly.
)

echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :MENU

:FUNC_BACKUP_DRIVERS
cls
echo.
echo    [ INFO ] This will extract and backup all 3rd-party drivers from your system.
echo    [ INFO ] Backups are saved to: %ProgramData%\Primus\Backups\Drivers\
call :ASK_CONFIRM "Proceed with Driver Backup?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :MENU)

echo.
call :LOG "PROCESS" "RECOVERY" "Initiating 3rd-party driver extraction via DISM..."

:: Create a unique, timestamped folder for this specific backup
set "DRV_DIR=%ProgramData%\Primus\Backups\Drivers\!FILE_TIME!"
mkdir "!DRV_DIR!" >nul 2>&1

echo    [ PROCESS ] Exporting drivers... This may take a few minutes.
echo.
dism /online /export-driver /destination:"!DRV_DIR!"
set "DISM_ERR=!errorlevel!"

echo.
if !DISM_ERR! equ 0 (
    call :LOG "SUCCESS" "RECOVERY" "Drivers successfully exported to !DRV_DIR!"
    echo    [ STATUS ] SUCCESS: All 3rd-party drivers safely backed up.
) else (
    call :LOG "ERROR" "RECOVERY" "Driver backup failed (Exit Code: !DISM_ERR!)."
    echo    [ ERROR ] FAILED: DISM encountered an error exporting drivers.
)

echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :MENU

:: --- MAINTENANCE MODULES ---
:FUNC_TEMP_CLEAN
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating comprehensive Temp file cleanup..."
call :TRACK_SPACE_START "%temp%|%WINDIR%\Temp"
echo    [ PROCESS ] Purging User Temp folder...
call :PURGE_DIR "%temp%"
echo    [ PROCESS ] Purging Windows System Temp...
call :PURGE_DIR "%WINDIR%\Temp"
call :TRACK_SPACE_END
echo    [ STATUS ] Comprehensive Temp cleanup complete (In-use files bypassed).
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Temp file cleanup cycle complete."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_PREFETCH
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Prefetch directory cleanup..."
echo    [ INFO ] On very old HDD systems, this may temporarily increase boot time slightly.
call :TRACK_SPACE_START "%WINDIR%\Prefetch"
echo    [ PROCESS ] Clearing Prefetch directory...
del /q /s /f /a "%WINDIR%\Prefetch\*.*" >nul 2>&1
call :TRACK_SPACE_END
echo    [ STATUS ] Cleanup cycle complete (In-use files bypassed).
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Prefetch cache cleared."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_UPDATE
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Update Cache reset..."
call :TRACK_SPACE_START "%WINDIR%\SoftwareDistribution\Download"
echo    [ PROCESS ] Halting Windows Update Services...
net stop wuauserv /y >nul 2>&1
net stop bits /y >nul 2>&1
echo    [ PROCESS ] Clearing Update Download Cache...
call :PURGE_DIR "%WINDIR%\SoftwareDistribution\Download"
echo    [ PROCESS ] Restarting Services...
net start wuauserv >nul 2>&1
net start bits >nul 2>&1
call :TRACK_SPACE_END
echo    [ STATUS ] Windows Update cache reset.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Windows Update Download Cache successfully cleared."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_THUMBNAILS
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Thumbnail Cache cleanup..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Purging Windows Thumbnail Cache...
del /q /f "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1
call :TRACK_SPACE_END
echo    [ STATUS ] Thumbnail cache cleanup cycle complete.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Thumbnail Cache database purged."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_RECYCLE
cls
echo.
echo    [ WARNING ] THIS WILL PERMANENTLY DELETE ALL ITEMS IN ALL RECYCLE BINS.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Recycle Bin purge." & timeout /t 1 >nul & goto :SUB_MAINT_GEN)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Emptying system recycle bins..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Emptying all system recycle bins across all drives...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Clear-RecycleBin -Force -ErrorAction SilentlyContinue"
call :TRACK_SPACE_END
echo    [ STATUS ] Operations dispatched to all connected drives.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Recycle Bins emptied successfully."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_DISKCLEAN
cls
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initialising Windows Disk Cleanup Utility..."
echo    [ PROCESS ] Initialising Windows Disk Cleanup Utility...
echo    [ INFO ] Detected Logical Drives:
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-CimInstance Win32_LogicalDisk | Select-Object -ExpandProperty DeviceID"
echo.

:DRIVE_INPUT
set "target_drive="
set /p "target_drive=%BS%   [ Selection ] Enter drive letter (e.g. C) :> "

:: Remove accidental leading spaces, then grab only the first character (Optimized)
set "target_drive=!target_drive: =!"
if defined target_drive set "target_drive=!target_drive:~0,1!"

:: Validate that the remaining single character is a letter (A-Z)
echo(!target_drive!| findstr /i /r "^[a-z]$" >nul
if errorlevel 1 (echo. & echo    [ ERROR ] Invalid format. Please enter a single drive letter ^(A-Z^). & echo. & goto :DRIVE_INPUT)

:: Convert to uppercase for consistency
for %%i in (A B C D E F G H I J K L M N O P Q R S T U V W X Y Z) do if /i "!target_drive!"=="%%i" set "target_drive=%%i"

if not exist "!target_drive!:\" (echo. & echo    [ ERROR ] Drive !target_drive!: was not found or is inaccessible. & echo    [ INFO ] Please enter a valid drive letter from the list above. & echo. & goto :DRIVE_INPUT)

echo.
call :TRACK_SPACE_START
echo    [ PROCESS ] Launching CleanMgr GUI for Drive !target_drive!:...
echo    [ INFO ] Script will resume once Cleanup is closed.
echo.
start /wait cleanmgr /d !target_drive!
call :TRACK_SPACE_END
echo.
echo    [ STATUS ] Disk Cleanup Utility session terminated.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Disk Cleanup Utility completed for Drive !target_drive!:."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_GEN

:FUNC_ICON_REBUILD
cls
echo.
echo    [ WARNING ] THIS WILL RESTART THE WINDOWS EXPLORER SHELL.
echo    [ INFO ] Your taskbar and desktop icons will disappear for a few seconds.
echo    [ INFO ] This fixes "white" or "broken" icons and folder thumbnails.
echo.
call :ASK_CONFIRM "Proceed with Rebuild?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Icon Cache rebuild." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Explorer Restart & Icon Cache Rebuild..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Terminating Windows Explorer...
taskkill /f /im explorer.exe >nul 2>&1

echo    [ PROCESS ] Deleting Icon and Thumbnail Cache databases...
del /f /s /q /a "%LocalAppData%\IconCache.db" >nul 2>&1
del /f /s /q /a "%LocalAppData%\Microsoft\Windows\Explorer\thumbcache_*.db" >nul 2>&1

echo    [ PROCESS ] Restarting Windows Explorer...
start explorer.exe
call :TRACK_SPACE_END

echo.
echo    [ STATUS ] Icon and Thumbnail databases have been successfully reset.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Icon and Thumbnail databases reset successfully."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_FONT_CACHE
cls
echo.
echo    [ WARNING ] THIS WILL RESTART THE WINDOWS FONT CACHE SERVICE.
echo    [ INFO ] This fixes garbled, corrupted, or missing text in applications.
echo.
call :ASK_CONFIRM "Proceed with Rebuild?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Font Cache rebuild." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows Font Cache Rebuild..."
call :TRACK_SPACE_START "%WINDIR%\ServiceProfiles\LocalService\AppData\Local\FontCache"
echo    [ PROCESS ] Stopping FontCache Service...
net stop FontCache /y >nul 2>&1
echo    [ PROCESS ] Purging Font Cache database files...
call :PURGE_DIR "%WINDIR%\ServiceProfiles\LocalService\AppData\Local\FontCache"
echo    [ PROCESS ] Restarting FontCache Service...
net start FontCache >nul 2>&1
call :TRACK_SPACE_END

echo.
echo    [ STATUS ] Font Cache databases have been successfully reset.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Font Cache reset successfully."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_BROWSER_CLEAN
cls
echo.
echo    [ WARNING ] BROWSERS MUST BE CLOSED TO PERFORM A DEEP CLEAN.
echo    [ INFO ] Targeted: Chrome, Edge, Brave, Vivaldi, Opera, Arc, Thorium, Helium, Firefox, LibreWolf, Waterfox, Floorp, Zen.
call :ASK_CONFIRM "Proceed with Deep Clean?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Browser Deep Clean." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Browser Deep Clean..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Halting all browser background processes...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-Process 'chrome','msedge','brave','opera','vivaldi','Arc','thorium','helium','firefox','librewolf','waterfox','floorp','zen' -ErrorAction SilentlyContinue | Stop-Process -Force"

:: Chromium-Based Cleanups
if exist "%LocalAppData%\Google\Chrome\User Data" (echo    [ PROCESS ] Cleaning Google Chrome... & call :CLEAN_CHROMIUM "%LocalAppData%\Google\Chrome\User Data")
if exist "%LocalAppData%\Microsoft\Edge\User Data" (echo    [ PROCESS ] Cleaning Microsoft Edge... & call :CLEAN_CHROMIUM "%LocalAppData%\Microsoft\Edge\User Data")
if exist "%LocalAppData%\BraveSoftware\Brave-Browser\User Data" (echo    [ PROCESS ] Cleaning Brave Browser... & call :CLEAN_CHROMIUM "%LocalAppData%\BraveSoftware\Brave-Browser\User Data")
if exist "%LocalAppData%\Vivaldi\User Data" (echo    [ PROCESS ] Cleaning Vivaldi... & call :CLEAN_CHROMIUM "%LocalAppData%\Vivaldi\User Data")
if exist "%LocalAppData%\Opera Software\Opera Stable" (echo    [ PROCESS ] Cleaning Opera Stable... & call :CLEAN_OPERA "%LocalAppData%\Opera Software\Opera Stable")
if exist "%LocalAppData%\Opera Software\Opera GX Stable" (echo    [ PROCESS ] Cleaning Opera GX... & call :CLEAN_OPERA "%LocalAppData%\Opera Software\Opera GX Stable")
for /d %%A in ("%LocalAppData%\Packages\TheBrowserCompany.Arc_*") do if exist "%%A\LocalCache\Local\Arc\User Data\" (echo    [ PROCESS ] Cleaning Arc Browser... & call :CLEAN_CHROMIUM "%%A\LocalCache\Local\Arc\User Data")
if exist "%LocalAppData%\Thorium\User Data" (echo    [ PROCESS ] Cleaning Thorium Browser... & call :CLEAN_CHROMIUM "%LocalAppData%\Thorium\User Data")
if exist "%LocalAppData%\imput\Helium\User Data" (echo    [ PROCESS ] Cleaning Helium Browser... & call :CLEAN_CHROMIUM "%LocalAppData%\imput\Helium\User Data")

:: Firefox/Gecko-Based Cleanups
if exist "%LocalAppData%\Mozilla\Firefox\Profiles" (echo    [ PROCESS ] Cleaning Mozilla Firefox... & call :CLEAN_GECKO "%LocalAppData%\Mozilla\Firefox\Profiles")
if exist "%LocalAppData%\librewolf\Profiles" (echo    [ PROCESS ] Cleaning LibreWolf... & call :CLEAN_GECKO "%LocalAppData%\librewolf\Profiles")
if exist "%LocalAppData%\Waterfox\Profiles" (echo    [ PROCESS ] Cleaning Waterfox... & call :CLEAN_GECKO "%LocalAppData%\Waterfox\Profiles")
if exist "%LocalAppData%\Floorp\Profiles" (echo    [ PROCESS ] Cleaning Floorp Browser... & call :CLEAN_GECKO "%LocalAppData%\Floorp\Profiles")
if exist "%LocalAppData%\zen\Profiles" (echo    [ PROCESS ] Cleaning Zen Browser... & call :CLEAN_GECKO "%LocalAppData%\zen\Profiles")
if exist "%LocalAppData%\ZenBrowser\Profiles" (echo    [ PROCESS ] Cleaning Zen Browser... & call :CLEAN_GECKO "%LocalAppData%\ZenBrowser\Profiles")

call :TRACK_SPACE_END

echo.
echo    [ STATUS ] Browser Deep Clean cycle complete.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Browser Deep Clean cycle completed successfully."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_DIRECTX_CACHE
cls
echo.
echo    [ INFO ] Clearing shader caches can fix graphical glitches and stuttering.
echo    [ INFO ] Note: Games may briefly stutter on next launch as shaders recompile.
echo.
call :ASK_CONFIRM "Proceed with Cache Clear?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled DirectX Shader Cache purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating DirectX Shader Cache Purge..."
call :TRACK_SPACE_START "%LocalAppData%\D3DSCache|%LocalAppData%\Microsoft\DirectX Shader Cache"
echo    [ PROCESS ] Purging DirectX and D3D Shader Caches...
call :PURGE_DIR "%LocalAppData%\D3DSCache"
call :PURGE_DIR "%LocalAppData%\Microsoft\DirectX Shader Cache"
call :TRACK_SPACE_END

echo.
echo    [ STATUS ] DirectX Shader Caches successfully cleared.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "DirectX Shader Caches purged."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_DELIVERY_OPT
cls
echo.
echo    [ INFO ] This will clear the peer-to-peer Windows Update delivery cache.
echo    [ INFO ] These files are safe to delete and can consume several gigabytes.
echo.
call :ASK_CONFIRM "Proceed with Cleanup?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Delivery Optimisation cleanup." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Delivery Optimisation Cache Purge..."
call :TRACK_SPACE_START "%WINDIR%\SoftwareDistribution\DeliveryOptimization"

:: Query if the DoSvc service actually exists on this system
sc query dosvc >nul 2>&1
set "DOSVC_EXISTS=!errorlevel!"

if !DOSVC_EXISTS! equ 0 (
    echo    [ PROCESS ] Stopping Delivery Optimisation Service ^(DoSvc^)...
    net stop dosvc /y >nul 2>&1
) else (
    echo    [ INFO ] Delivery Optimisation Service not found. Proceeding with purge...
)

echo    [ PROCESS ] Purging Delivery Optimisation Cache...
call :PURGE_DIR "%WINDIR%\SoftwareDistribution\DeliveryOptimization"

if !DOSVC_EXISTS! equ 0 (
    echo    [ PROCESS ] Restarting Delivery Optimisation Service...
    net start dosvc >nul 2>&1
)

call :TRACK_SPACE_END

echo.
echo    [ STATUS ] Delivery Optimisation Cache successfully cleared.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Delivery Optimisation Cache purged."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_WINSXS
cls
echo.
echo           -- WINDOWS COMPONENT STORE (WINSXS) CLEANUP ------------------------------------
echo.
echo            [1] Standard Cleanup  - Removes superseded files (Safe / Keeps Rollback)
echo            [2] Deep Image Reset  - Full purge (Reclaims Max Space / Locks in Updates)
echo            [R] Cancel            - Return to sub-menu
echo.
:WINSXS_SUB_PROMPT
set "ws_choice="
set /p "ws_choice=%BS%          [Selection] :> "

if "!ws_choice!"=="1" goto :W_STANDARD
if "!ws_choice!"=="2" goto :W_DEEP
if /i "!ws_choice!"=="R" (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled WinSxS Component Store cleanup." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)
echo    [ ERROR ] Invalid selection.
goto :WINSXS_SUB_PROMPT

:W_STANDARD
echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Standard DISM Component Store Cleanup..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Initiating Standard Component Cleanup...
dism /online /cleanup-image /StartComponentCleanup

set "DISM_ERR=!errorlevel!"
if !DISM_ERR! equ 3010 set "DISM_ERR=0"
echo.
if !DISM_ERR! equ 0 call :TRACK_SPACE_END
call :EVAL_STATUS !DISM_ERR! "MAINTENANCE" "Standard Component Store Cleanup failed." "Standard Component Store Cleanup successfully dispatched."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:W_DEEP
echo.
echo    [ WARNING ] THIS WILL PERMANENTLY REMOVE ALL UPDATE ROLLBACK FILES.
echo    [ WARNING ] YOU WILL NOT BE ABLE TO UNINSTALL CURRENT WINDOWS UPDATES.
call :ASK_CONFIRM "Proceed with Deep Reset?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Deep WinSxS Base Reset." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Deep WinSxS Base Reset..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Phase 1: Initiating Component Cleanup...
dism /online /cleanup-image /StartComponentCleanup

set "DISM_ERR=!errorlevel!"

:: Intercept Reboot Pending status
if !DISM_ERR! equ 3010 (
    echo.
    echo    [ WARNING ] Phase 1 completed, but a system restart is pending.
    echo    [ INFO ] Aborting Phase 2 ^(ResetBase^) to prevent component store corruption.
    call :LOG "WARNING" "MAINTENANCE" "Phase 1 returned 3010 (Reboot Pending). Phase 2 safely aborted."
    echo    [Press any key to return to Menu...] & pause >nul
    goto :SUB_MAINT_ADV
)

:: Catch actual hard errors
if !DISM_ERR! neq 0 (
    echo.
    echo    [ ERROR ] Phase 1 failed. Aborting Phase 2 to prevent inconsistent state.
    call :LOG "ERROR" "MAINTENANCE" "Phase 1 Component Cleanup failed (Exit Code: !DISM_ERR!). ResetBase aborted."
    echo    [Press any key to return to Menu...] & pause >nul
    goto :SUB_MAINT_ADV
)

echo.
echo    [ PROCESS ] Phase 2: Performing ResetBase (Deep Purge)...
dism /online /cleanup-image /StartComponentCleanup /ResetBase

set "DISM_ERR=!errorlevel!"

:: Intercept Phase 2 Reboot Pending status
if !DISM_ERR! equ 3010 (
    call :TRACK_SPACE_END
    echo.
    echo    [ STATUS ] Component Store fully optimised. A restart is pending.
    call :LOG "SUCCESS" "MAINTENANCE" "Deep WinSxS Base Reset completed (Reboot Pending)."
) else if !DISM_ERR! neq 0 (
    echo.
    echo    [ WARNING ] Phase 2 encountered an issue or was bypassed.
    call :LOG "WARNING" "MAINTENANCE" "ResetBase encountered an issue (Exit Code: !DISM_ERR!)."
) else (
    call :TRACK_SPACE_END
    echo.
    echo    [ STATUS ] Component Store fully optimised and rollback base reset.
    call :LOG "SUCCESS" "MAINTENANCE" "Deep WinSxS Base Reset completed successfully."
)

echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_WSRESET
cls
echo.

:: LTSC and Server Edition Guard
echo(!FULL_OS!| findstr /i "LTSC Server" >nul
if !errorlevel! equ 0 (
    echo    [ WARNING ] OS DETECTED: !FULL_OS!
    echo    [ WARNING ] This operating system does not natively include the Microsoft Store.
    echo.
    call :ASK_CONFIRM "Force execution anyway (Only if manually sideloaded)?"
    if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User bypassed Store Reset on LTSC/Server." & timeout /t 2 >nul & goto :SUB_MAINT_ADV)
    echo.
) else (
    echo    [ INFO ] This will reset the Microsoft Store cache.
    echo    [ INFO ] A blank command prompt will open temporarily, followed by the Store.
    call :ASK_CONFIRM "Proceed with Store Reset?"
    if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Windows Store Cache reset." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)
    echo.
)

call :LOG "PROCESS" "MAINTENANCE" "Resetting Windows Store Cache (wsreset)..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Resetting Windows Store Cache...
echo    [ INFO ] The Microsoft Store will open when complete.
echo    [ INFO ] Applying 120-second timeout safeguard...
echo.
:: Start wsreset and monitor with timeout
start "" wsreset.exe
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$proc = Get-Process wsreset -ErrorAction SilentlyContinue; " ^
    "if ($proc) { try { $proc | Wait-Process -Timeout 120 -ErrorAction Stop } catch { exit 1 } }"

set "WS_ERR=!errorlevel!"
if !WS_ERR! neq 0 (taskkill /f /im wsreset.exe >nul 2>&1 & echo    [ WARNING ] Operation timed out and was force-closed. & call :LOG "WARNING" "MAINTENANCE" "wsreset.exe hung and was terminated after 120s.")
if !WS_ERR! equ 0 (call :TRACK_SPACE_END & echo    [ STATUS ] Windows Store Cache successfully reset. & call :LOG "SUCCESS" "MAINTENANCE" "Windows Store Cache reset completed.")
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_CRASHDUMPS
cls
echo.
echo    [ WARNING ] THIS WILL DELETE ERROR REPORTS AND CRASH DUMPS (MINIDUMPS).
echo    [ WARNING ] THESE FILES ARE OFTEN NEEDED TO DIAGNOSE SYSTEM CRASHES.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Crash Dump and WER purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Purging Error Reports and Minidumps..."
call :TRACK_SPACE_START "%ProgramData%\Microsoft\Windows\WER|%WINDIR%\Minidump"
echo    [ PROCESS ] Purging Windows Error Reporting (WER) and Minidumps...
call :PURGE_DIR "%ProgramData%\Microsoft\Windows\WER"
call :PURGE_DIR "%WINDIR%\Minidump"
call :TRACK_SPACE_END
echo    [ STATUS ] Crash dumps and error reports successfully cleared.
echo.
call :LOG "SUCCESS" "MAINTENANCE" "Crash Dumps and WER cleared."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_WINDOWS_OLD
cls
echo.
echo            [ WARNING ] THIS WILL PERMANENTLY DELETE YOUR PREVIOUS WINDOWS INSTALLATION.
echo            [ WARNING ] YOU WILL NOT BE ABLE TO ROLL BACK TO YOUR PREVIOUS OS VERSION.
echo.
call :ASK_CONFIRM "Proceed with Windows.old Purge?"
if !errorlevel! neq 0 (echo. & echo            [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Windows.old purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
if not exist "%SystemDrive%\Windows.old" (
    echo            [ INFO ] Windows.old directory not found. System is already clean.
    call :LOG "INFO" "MAINTENANCE" "Windows.old purge skipped. Directory not present."
    echo.
    echo            [Press any key to return to Menu...] & pause >nul
    goto :SUB_MAINT_ADV
)

call :LOG "PROCESS" "MAINTENANCE" "Initiating Windows.old Purge. Bypassing TrustedInstaller..."
call :TRACK_SPACE_START "%SystemDrive%\Windows.old"
echo            [ PROCESS ] Stripping TrustedInstaller permissions from Windows.old...
echo            [ INFO ] This may take several minutes depending on folder size...
echo Y| takeown /F "%SystemDrive%\Windows.old" /A /R >nul 2>&1
icacls "%SystemDrive%\Windows.old" /grant Administrators:F /T /C /Q >nul 2>&1

echo            [ PROCESS ] Deleting previous OS files...
rd /s /q "%SystemDrive%\Windows.old" >nul 2>&1
call :TRACK_SPACE_END

echo.
if exist "%SystemDrive%\Windows.old" (
    echo            [ WARNING ] Some files were locked by the system. Partial deletion achieved.
    echo            [ INFO ] A system reboot and manual deletion may be required to clear the rest.
    call :LOG "WARNING" "MAINTENANCE" "Windows.old partially purged (some files locked)."
) else (
    echo            [ STATUS ] Windows.old previous installation successfully deleted.
    call :LOG "SUCCESS" "MAINTENANCE" "Windows.old directory successfully purged."
)

echo            [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:FUNC_EVENTLOGS
cls
echo.
echo    [ WARNING ] THIS WILL PERMANENTLY DELETE ALL HISTORICAL SYSTEM EVENT LOGS.
call :ASK_CONFIRM "Proceed?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled Event Log purge." & timeout /t 1 >nul & goto :SUB_MAINT_ADV)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Clearing all Windows Event Viewer Logs..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Clearing Windows Event Viewer Logs (This may take a moment)...

:: Initialize Counters
set "LOG_SUCCESS=0"
set "LOG_FAIL=0"

:: Loop through logs and track success/failure rates silently
for /f "tokens=*" %%A in ('wevtutil.exe el') do (
    wevtutil.exe cl "%%A" >nul 2>&1
    if !errorlevel! equ 0 (set /a LOG_SUCCESS+=1) else (set /a LOG_FAIL+=1)
)

call :TRACK_SPACE_END

echo.
if !LOG_FAIL! equ 0 (
    echo    [ STATUS ] All !LOG_SUCCESS! Event Viewer logs have been successfully flushed.
    call :LOG "SUCCESS" "MAINTENANCE" "Event Viewer Logs completely flushed (!LOG_SUCCESS! cleared)."
) else (
    echo    [ WARNING ] Flushed !LOG_SUCCESS! logs. !LOG_FAIL! logs were locked or restricted.
    echo    [ INFO ] Some analytical logs are actively in use by the OS and cannot be cleared.
    call :LOG "WARNING" "MAINTENANCE" "Event Logs partially flushed (!LOG_SUCCESS! cleared, !LOG_FAIL! locked)."
)

echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MAINT_ADV

:: --- DIAGNOSTICS MODULES ---
:FUNC_CHKDSK_DIRTY
cls
echo.
call :LOG "PROCESS" "DIAGNOSTICS" "Querying volume dirty bit for %SystemDrive%..."
echo    [ PROCESS ] Querying %SystemDrive% for file system errors...
echo.
fsutil dirty query %SystemDrive%
echo.
call :LOG "SUCCESS" "DIAGNOSTICS" "Volume dirty bit queried successfully."
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_DIAG_CHKDSK

:FUNC_CHKDSK_SCAN
cls
echo.
echo    [ INFO ] This will run a read-only integrity scan on %SystemDrive%.
echo    [ INFO ] It will not attempt to fix errors and will not lock the drive.
call :ASK_CONFIRM "Proceed with Scan?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :SUB_DIAG_CHKDSK)

echo.
call :LOG "PROCESS" "DIAGNOSTICS" "Initiating read-only CHKDSK scan on %SystemDrive%..."
echo    [ PROCESS ] Running CHKDSK in read-only mode. This may take a few minutes...
echo.
chkdsk %SystemDrive%
set "CHK_ERR=!errorlevel!"
echo.
if !CHK_ERR! equ 0 (call :LOG "SUCCESS" "DIAGNOSTICS" "Read-only CHKDSK completed with no major errors.") else (call :LOG "WARNING" "DIAGNOSTICS" "Read-only CHKDSK detected errors or encountered an issue (Exit Code: !CHK_ERR!).")
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_DIAG_CHKDSK

:FUNC_CHKDSK_SCHED
cls
echo.
echo            [ WARNING ] This will schedule a full repair of %SystemDrive% on the next reboot.
echo            [ WARNING ] The repair can take anywhere from 10 minutes to over an hour.
call :ASK_CONFIRM "Schedule offline repair?"
if !errorlevel! neq 0 (echo. & echo            [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :SUB_DIAG_CHKDSK)

echo.
call :LOG "PROCESS" "DIAGNOSTICS" "Scheduling offline CHKDSK repair for next reboot..."
echo            [ PROCESS ] Injecting schedule command...
echo y| chkdsk %SystemDrive% /f /x >nul 2>&1
echo            [ STATUS ] Repair successfully scheduled for the next system restart.
call :LOG "SUCCESS" "DIAGNOSTICS" "Offline CHKDSK repair scheduled successfully."
echo.
call :ASK_REBOOT "File System Repair"
goto :SUB_DIAG_CHKDSK

:FUNC_CHKDSK_CANCEL
cls
echo.
echo    [ INFO ] This will cancel any pending CHKDSK operations scheduled for boot.
call :ASK_CONFIRM "Cancel scheduled repair?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :SUB_DIAG_CHKDSK)

echo.
call :LOG "PROCESS" "DIAGNOSTICS" "Cancelling scheduled offline CHKDSK repair..."
echo    [ PROCESS ] Restoring default boot behaviour...
chkntfs /d >nul 2>&1
echo    [ STATUS ] Scheduled boot scans have been cancelled.
call :LOG "SUCCESS" "DIAGNOSTICS" "Scheduled CHKDSK operations cancelled."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_DIAG_CHKDSK

:: --- REPAIR MODULES ---
:FUNC_SFC
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "REPAIR" "SFC Scan aborted due to low disk space." & timeout /t 2 >nul & goto :SUB_REPAIR)
call :LOG "PROCESS" "REPAIR" "Initiating System File Checker (SFC /scannow)..."
echo    [ PROCESS ] Initiating System File Checker...
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
if !LOG_DIFF! leq 0 (echo. & echo    [ WARNING ] Could not read SFC log output. Check CBS.log manually. & echo    [ INFO ] Log located at: %WINDIR%\Logs\CBS\CBS.log & call :LOG "WARNING" "REPAIR" "SFC completed but CBS log output could not be parsed." & echo. & echo    [Press any key to return to Menu...] & pause >nul & goto :SUB_REPAIR)

echo.
if !SFC_ERR! neq 0 goto :SFC_ERROR

:SFC_SUCCESS
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "try { " ^
    "  $recentLogs = Get-Content '%WINDIR%\Logs\CBS\CBS.log' -Tail !LOG_DIFF! -ErrorAction Stop; " ^
    "  if ($recentLogs -match 'Repairing corrupted file') { " ^
    "    Write-Host '   [ STATUS ] SUCCESS: SFC found corrupt files and successfully repaired them.' -ForegroundColor DarkYellow; " ^
    "  } else { " ^
    "    Write-Host '   [ STATUS ] SUCCESS: SFC Scan complete. No integrity violations found.' -ForegroundColor Green; " ^
    "  } " ^
    "} catch { " ^
    "  Write-Host '   [ STATUS ] SUCCESS: SFC Scan complete.' -ForegroundColor Green; " ^
    "  Write-Host '   [ WARNING ] Log file locked. Could not read repair details.' -ForegroundColor DarkYellow; " ^
    "}"
call :LOG "SUCCESS" "REPAIR" "SFC scan completed without unrepairable violations."
goto :SFC_END

:SFC_ERROR
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "try { " ^
    "  $recentLogs = Get-Content '%WINDIR%\Logs\CBS\CBS.log' -Tail !LOG_DIFF! -ErrorAction Stop; " ^
    "  if ($recentLogs -match 'Cannot repair member file') { " ^
    "    Write-Host '   [ ERROR ] CRITICAL: SFC found corruptions it could not automatically fix.' -ForegroundColor Red; " ^
    "    Write-Host '   [ INFO ] Please run DISM Deep Image Repair (Option 4) to repair the core image.' -ForegroundColor Gray; " ^
    "  } else { " ^
    "    Write-Host '   [ ERROR ] FAILED: SFC failed to start or complete the requested operation.' -ForegroundColor Red; " ^
    "  } " ^
    "} catch { " ^
    "  Write-Host '   [ ERROR ] FAILED: SFC encountered an error. Check CBS.log manually.' -ForegroundColor Red; " ^
    "  Write-Host '   [ WARNING ] Log file is locked or inaccessible.' -ForegroundColor DarkYellow; " ^
    "}"
call :LOG "ERROR" "REPAIR" "SFC failed or found unrepairable corruption (Exit Code: !SFC_ERR!)."

:SFC_END
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_REPAIR

:FUNC_DISM_CHECK
cls
echo.
call :LOG "PROCESS" "REPAIR" "Initiating DISM Quick Image Check (/CheckHealth)..."
echo    [ PROCESS ] Initiating DISM Quick Image Check (/CheckHealth)...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$state = [string](Repair-WindowsImage -Online -CheckHealth -ErrorAction SilentlyContinue).ImageHealthState; " ^
    "if ($state -eq 'Healthy') { Write-Host '   [ STATUS ] SUCCESS: No component store corruption detected.' -ForegroundColor Green } " ^
    "elseif ($state -eq 'Repairable') { Write-Host '   [ WARNING ] REPAIRABLE: Corruption detected. Please run Deep Image Repair (Option 4).' -ForegroundColor DarkYellow } " ^
    "elseif ($state -eq 'NonRepairable') { Write-Host '   [ CRITICAL ] UNREPAIRABLE: Image is corrupted and cannot be repaired.' -ForegroundColor Red } " ^
    "else { Write-Host '   [ ERROR ] DISM failed to execute or return status.' -ForegroundColor Gray }"
call :LOG "SUCCESS" "REPAIR" "DISM Quick Check execution completed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_REPAIR

:FUNC_DISM_SCAN
cls
echo.
call :LOG "PROCESS" "REPAIR" "Initiating DISM Deep Image Scan (/ScanHealth)..."
echo    [ PROCESS ] Initiating DISM Deep Image Scan (/ScanHealth)...
echo    [ INFO ] This will take several minutes. A progress bar will appear soon...
timeout /t 2 >nul
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$state = [string](Repair-WindowsImage -Online -ScanHealth -ErrorAction SilentlyContinue).ImageHealthState; " ^
    "if ($state -eq 'Healthy') { Write-Host '   [ STATUS ] SUCCESS: No component store corruption detected.' -ForegroundColor Green } " ^
    "elseif ($state -eq 'Repairable') { Write-Host '   [ WARNING ] REPAIRABLE: Corruption detected. Please run Deep Image Repair (Option 4).' -ForegroundColor DarkYellow } " ^
    "elseif ($state -eq 'NonRepairable') { Write-Host '   [ CRITICAL ] UNREPAIRABLE: Image is corrupted and cannot be repaired.' -ForegroundColor Red } " ^
    "else { Write-Host '   [ ERROR ] DISM failed to execute or return status.' -ForegroundColor Gray }"
call :LOG "SUCCESS" "REPAIR" "DISM Deep Scan execution completed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_REPAIR

:FUNC_DISM_RESTORE
cls
echo.
call :CHECK_FREE_SPACE
if !errorlevel! neq 0 (echo. & call :LOG "WARNING" "REPAIR" "DISM Restore aborted due to low disk space." & timeout /t 2 >nul & goto :SUB_REPAIR)
call :LOG "PROCESS" "REPAIR" "Initiating DISM Deep Image Repair (/RestoreHealth)..."
echo    [ PROCESS ] Initiating DISM Deep Image Repair (/RestoreHealth)...
dism /online /cleanup-image /restorehealth
set "DISM_ERR=!errorlevel!"
echo.
call :EVAL_STATUS !DISM_ERR! "REPAIR" "DISM failed to repair the image (Exit Code: !DISM_ERR!)." "DISM successfully repaired the component store image."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_REPAIR

:: --- NETWORK MODULES ---
:FUNC_DNS_DISPLAY
cls
echo.
call :LOG "INFO" "NETWORK" "Displayed current DNS Resolver Cache to user."
echo    [ PROCESS ] Retrieving current DNS Resolver Cache...
echo          --------------------------------------------------------------------------------
echo.
ipconfig /displaydns | more
echo.
echo          --------------------------------------------------------------------------------
echo.
echo    [ STATUS ] End of DNS Cache.
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_GEN

:FUNC_DNS_FLUSH
cls
echo.
call :LOG "PROCESS" "NETWORK" "Flushing DNS Resolver Cache..."
echo    [ PROCESS ] Flushing DNS Cache...
ipconfig /flushdns >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to flush DNS cache." "DNS Cache successfully flushed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_GEN

:FUNC_ARP_DISPLAY
cls
echo.
call :LOG "INFO" "NETWORK" "Displayed current ARP Cache to user."
echo    [ PROCESS ] Retrieving current ARP Cache (Address Resolution Protocol)...
echo          --------------------------------------------------------------------------------
echo.
arp -a
echo.
echo          --------------------------------------------------------------------------------
echo.
echo    [ STATUS ] End of ARP Cache.
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_GEN

:FUNC_ARP_CLEAR
cls
echo.
call :LOG "PROCESS" "NETWORK" "Clearing ARP Cache..."
echo    [ PROCESS ] Purging ARP Cache (Force re-mapping of local MAC addresses)...
arp -d * >nul 2>&1
set "NET_ERR=!errorlevel!"
echo.
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to clear ARP cache." "ARP Cache successfully cleared."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_GEN

:FUNC_IP_RELEASE
cls
echo.
echo    [ WARNING ] THIS WILL TEMPORARILY CUT YOUR INTERNET CONNECTION.
echo    [ INFO ] You will remain offline until you run Option 2 (Renew IP).
call :ASK_CONFIRM "Proceed with IP Release?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled IP Address release." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Releasing local IP Address assignments..."
echo    [ PROCESS ] Releasing current IP Address assignments...
ipconfig /release >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to release IP address. Check adapter status." "IP addresses released for all active adapters."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_ADV

:FUNC_IP_RENEW
cls
echo.
echo    [ INFO ] Your connection will be restored once the DHCP server responds.
call :ASK_CONFIRM "Proceed with IP Renewal?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled IP Address renewal." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Renewing IP Address assignments via DHCP..."
echo    [ PROCESS ] Renewing IP Address assignments...
echo    [ INFO ] This may take a few seconds...
ipconfig /renew >nul 2>&1
set "NET_ERR=!errorlevel!"
call :EVAL_STATUS !NET_ERR! "NETWORK" "Failed to renew IP address. Check network connection." "IP renewal request dispatched to DHCP server."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_NET_ADV

:FUNC_TCP_RESET
cls
echo.
echo    [ WARNING ] THIS WILL RESET THE TCP/IP STACK TO FACTORY DEFAULTS.
echo    [ INFO ] This can fix persistent connection issues but clears custom settings.
echo    [ INFO ] Your config will be backed up to: %ProgramData%\Primus\Backups\NetConfig\
echo.
call :ASK_CONFIRM "Proceed with TCP/IP Reset?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled TCP/IP Reset." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Executing netsh TCP/IP reset..."
echo    [ PROCESS ] Exporting network configuration...
set "NET_DIR=%ProgramData%\Primus\Backups\NetConfig"
if not exist "!NET_DIR!" mkdir "!NET_DIR!" >nul 2>&1
if not exist "!NET_DIR!\Primus_NetConfig_!FILE_TIME!.txt" ipconfig /all > "!NET_DIR!\Primus_NetConfig_!FILE_TIME!.txt"
echo    [ PROCESS ] Resetting TCP/IP stack...
netsh int ip reset >nul 2>&1
echo    [ STATUS ] TCP/IP Reset complete.
echo    [ WARNING ] A system REBOOT is required for changes to take effect.
call :LOG "SUCCESS" "NETWORK" "TCP/IP Reset executed. Reboot required."
echo.
call :ASK_REBOOT "TCP/IP"
goto :SUB_NET_ADV

:FUNC_WINSOCK_RESET
cls
echo.
echo    [ WARNING ] THIS WILL RESET THE WINSOCK CATALOGUE TO A CLEAN STATE.
echo    [ INFO ] This is the #1 fix for "No Internet" issues when Wi-Fi is connected.
echo    [ INFO ] Your config will be backed up to: %ProgramData%\Primus\Backups\NetConfig\
echo.
call :ASK_CONFIRM "Proceed with Winsock Reset?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "NETWORK" "User cancelled Winsock Reset." & timeout /t 1 >nul & goto :SUB_NET_ADV)

echo.
call :LOG "PROCESS" "NETWORK" "Executing netsh Winsock reset..."
echo    [ PROCESS ] Exporting network configuration...
set "NET_DIR=%ProgramData%\Primus\Backups\NetConfig"
if not exist "!NET_DIR!" mkdir "!NET_DIR!" >nul 2>&1
if not exist "!NET_DIR!\Primus_NetConfig_!FILE_TIME!.txt" ipconfig /all > "!NET_DIR!\Primus_NetConfig_!FILE_TIME!.txt"
echo    [ PROCESS ] Resetting Winsock Catalogue...
netsh winsock reset >nul 2>&1
echo    [ STATUS ] Winsock Catalogue Reset complete.
echo    [ WARNING ] A system REBOOT is required for changes to take effect.
call :LOG "SUCCESS" "NETWORK" "Winsock Catalogue Reset executed. Reboot required."
echo.
call :ASK_REBOOT "Winsock"
goto :SUB_NET_ADV

:: --- STORAGE & MEMORY MODULES ---

:FUNC_TRIM_SSD
cls
echo.
echo    [ INFO ] This will send the TRIM command to all connected Solid State Drives.
call :ASK_CONFIRM "Proceed with SSD Trim?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled SSD Trim." & timeout /t 1 >nul & goto :SUB_STORAGE)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating TRIM on all connected SSDs..."
echo    [ PROCESS ] Identifying SSDs and sending TRIM commands...
echo    [ INFO ] This may take a moment depending on drive sizes...
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$vols = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.DriveLetter }; $c = 0; foreach ($v in $vols) { try { Optimize-Volume -DriveLetter $v.DriveLetter -ReTrim -ErrorAction Stop | Out-Null; $c++ } catch {} }; if ($c -gt 0) { Write-Host '   [ STATUS ] TRIM commands completed.' -ForegroundColor Green } else { Write-Host '   [ INFO ] No standard SSDs detected or TRIM unsupported.' -ForegroundColor DarkYellow }"

call :LOG "SUCCESS" "MAINTENANCE" "SSD TRIM operations completed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_STORAGE

:FUNC_DEFRAG_HDD
cls
echo.
echo    [ WARNING ] Defragmenting large Hard Drives (HDDs) can take several hours.
echo    [ INFO ] SSDs will be safely ignored during this operation.
call :ASK_CONFIRM "Proceed with HDD Defrag?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning to sub-menu... & call :LOG "WARNING" "MAINTENANCE" "User cancelled HDD Defrag." & timeout /t 1 >nul & goto :SUB_STORAGE)

echo.
call :LOG "PROCESS" "MAINTENANCE" "Initiating Defragmentation on all connected HDDs..."
echo    [ PROCESS ] Identifying HDDs and initiating defragmentation...
echo    [ INFO ] This window will remain active until the process finishes...
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$vols = Get-Volume | Where-Object { $_.DriveType -eq 'Fixed' -and $_.MediaType -eq 'HDD' -and $_.DriveLetter }; if ($vols) { foreach ($v in $vols) { Optimize-Volume -DriveLetter $v.DriveLetter -Defrag -ErrorAction SilentlyContinue | Out-Null }; Write-Host '   [ STATUS ] HDD Defragmentation completed.' -ForegroundColor Green } else { Write-Host '   [ INFO ] No standard HDDs detected.' -ForegroundColor DarkYellow }"

call :LOG "SUCCESS" "MAINTENANCE" "HDD Defragmentation operations completed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_STORAGE

:FUNC_COMPACT_OS
cls
call :PRINT_HEADER
echo.
echo            -- COMPACT OS (SYSTEM COMPRESSION) ---------------------------------------------
echo.
echo            [ PROCESS ] Querying current CompactOS state...

:: Silently determine current state by parsing compact.exe output
set "COMP_STATE=Enabled"
compact.exe /compactos:query 2>nul | find /i "not in the Compact state" >nul
if !errorlevel! equ 0 set "COMP_STATE=Disabled"

cls
call :PRINT_HEADER
echo.
echo            -- COMPACT OS (SYSTEM COMPRESSION) ---------------------------------------------
echo.
echo            [ INFO ] CompactOS is currently: !COMP_STATE!
echo.
echo            [1] Enable System Compression (Reclaim Space)
echo            [2] Disable System Compression (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO STORAGE MENU
echo.
set "comp_choice="
set /p "comp_choice=%BS%          [Selection] :> "

if "!comp_choice!"=="1" goto :COMPACT_ENABLE
if "!comp_choice!"=="2" goto :COMPACT_DISABLE
if /i "!comp_choice!"=="R" goto :SUB_STORAGE
goto :FUNC_COMPACT_OS

:COMPACT_ENABLE
cls
echo.
echo            -- COMPACT OS (SYSTEM COMPRESSION) ---------------------------------------------
echo.
echo    [ INFO ] This will compress OS binaries. It may take 5-15 minutes.
call :ASK_CONFIRM "Proceed with Compression?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled... & timeout /t 1 >nul & goto :FUNC_COMPACT_OS)
echo.
call :LOG "PROCESS" "OPTIMISATION" "Enabling CompactOS..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Compressing system files... Please wait...
compact.exe /compactos:always >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "CompactOS enabled."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:COMPACT_DISABLE
cls
echo.
echo            -- COMPACT OS (SYSTEM COMPRESSION) ---------------------------------------------
echo.
echo    [ INFO ] This will uncompress the OS. It may take 5-15 minutes.
call :ASK_CONFIRM "Proceed with Decompression?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled... & timeout /t 1 >nul & goto :FUNC_COMPACT_OS)
echo.
call :LOG "PROCESS" "OPTIMISATION" "Disabling CompactOS..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Decompressing system files... Please wait...
compact.exe /compactos:never >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "CompactOS disabled."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:FUNC_HIBERNATE
cls
call :PRINT_HEADER
echo.
echo            -- HIBERNATION SPACE MANAGEMENT ------------------------------------------------
echo.
echo            [1] Disable Hibernation (Reclaims Maximum Space)
echo            [2] Reduced Mode (Fast Startup only, reclaims ~50%%)
echo            [3] Enable Full Hibernation (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO STORAGE MENU
echo.
set "hib_choice="
set /p "hib_choice=%BS%          [Selection] :> "

if "!hib_choice!"=="1" goto :HIB_DISABLE
if "!hib_choice!"=="2" goto :HIB_REDUCED
if "!hib_choice!"=="3" goto :HIB_ENABLE
if /i "!hib_choice!"=="R" goto :SUB_STORAGE
goto :FUNC_HIBERNATE

:HIB_DISABLE
cls
echo.
echo            -- HIBERNATION SPACE MANAGEMENT ------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Disabling Hibernation..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Disabling system hibernation and deleting hiberfil.sys...
powercfg /h off >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "Hibernation disabled."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:HIB_REDUCED
cls
echo.
echo            -- HIBERNATION SPACE MANAGEMENT ------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Setting Hibernation to Reduced Mode..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Enabling Fast Startup and shrinking hiberfil.sys...
powercfg /h on >nul 2>&1
powercfg /h /type reduced >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "Hibernation reduced."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:HIB_ENABLE
cls
echo.
echo            -- HIBERNATION SPACE MANAGEMENT ------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Enabling Full Hibernation..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Restoring full hibernation file size...
powercfg /h on >nul 2>&1
powercfg /h /type full >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "Hibernation restored."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:FUNC_RESERVED_STORAGE
cls
call :PRINT_HEADER
echo.
echo            -- WINDOWS RESERVED STORAGE ----------------------------------------------------
echo.

:: OS Build Guard (Requires Windows 10 1903 / Build 18362+)
set "RES_SUPPORTED=1"
if "!OS_BUILD!"=="Unknown" set "RES_SUPPORTED=0"
echo(!OS_BUILD!| findstr /r "^[0-9][0-9]*$" >nul
if !errorlevel! neq 0 set "RES_SUPPORTED=0"
if !RES_SUPPORTED! equ 1 if !OS_BUILD! lss 18362 set "RES_SUPPORTED=0"

if !RES_SUPPORTED! equ 0 (
    echo            [ WARNING ] Reserved Storage management is not supported on this OS.
    echo            [ INFO ] Requires Windows 10 Version 1903 ^(Build 18362^) or later.
    echo            [ INFO ] Your Current Build: !OS_BUILD!
    echo.
    call :LOG "WARNING" "OPTIMISATION" "Reserved Storage menu blocked (Unsupported OS Build: !OS_BUILD!)."
    echo           ================================================================================
    echo            [Press any key to return...] & pause >nul
    goto :SUB_STORAGE
)

echo            [1] Disable Reserved Storage (Reclaims ~7GB Space)
echo            [2] Enable Reserved Storage  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO STORAGE MENU
echo.
set "res_choice="
set /p "res_choice=%BS%          [Selection] :> "

if "!res_choice!"=="1" goto :RES_DISABLE
if "!res_choice!"=="2" goto :RES_ENABLE
if /i "!res_choice!"=="R" goto :SUB_STORAGE
goto :FUNC_RESERVED_STORAGE

:RES_DISABLE
cls
echo.
echo            -- WINDOWS RESERVED STORAGE ----------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Disabling Windows Reserved Storage..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Modifying DISM Reserved Storage State...
dism /online /Set-ReservedStorageState /State:Disabled >nul 2>&1
set "RES_ERR=!errorlevel!"
call :TRACK_SPACE_END
echo.
if !RES_ERR! equ 0 (
    call :LOG "SUCCESS" "OPTIMISATION" "Reserved Storage disabled."
) else (
    echo    [ WARNING ] Feature may not be supported on your exact OS build.
    call :LOG "WARNING" "OPTIMISATION" "Reserved Storage toggle failed or unsupported."
)
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:RES_ENABLE
cls
echo.
echo            -- WINDOWS RESERVED STORAGE ----------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Enabling Windows Reserved Storage..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Restoring DISM Reserved Storage State...
dism /online /Set-ReservedStorageState /State:Enabled >nul 2>&1
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "Reserved Storage restored."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:FUNC_VSS_LIMIT
cls
call :PRINT_HEADER
echo.
echo            -- SHADOW COPY STORAGE CAPPING -------------------------------------------------
echo.
echo            [1] Cap at 5 GB   (Low Usage / Minimal History)
echo            [2] Cap at 10 GB  (Standard Usage)
echo            [3] Cap at 15 GB  (Moderate Usage)
echo            [4] Cap at 20 GB  (Heavy Usage / Deep History)
echo.
echo           ================================================================================
echo            [R] RETURN TO STORAGE MENU
echo.
set "vss_choice="
set /p "vss_choice=%BS%          [Selection] :> "

if "!vss_choice!"=="1" set "VSS_CAP=5GB" & goto :VSS_APPLY
if "!vss_choice!"=="2" set "VSS_CAP=10GB" & goto :VSS_APPLY
if "!vss_choice!"=="3" set "VSS_CAP=15GB" & goto :VSS_APPLY
if "!vss_choice!"=="4" set "VSS_CAP=20GB" & goto :VSS_APPLY
if /i "!vss_choice!"=="R" goto :SUB_STORAGE
goto :FUNC_VSS_LIMIT

:VSS_APPLY
cls
echo.
echo            -- SHADOW COPY STORAGE CAPPING -------------------------------------------------
echo.
call :LOG "PROCESS" "OPTIMISATION" "Capping Shadow Copy Storage at !VSS_CAP!..."
call :TRACK_SPACE_START
echo    [ PROCESS ] Ensuring VSS service is running...
net start vss >nul 2>&1

echo    [ PROCESS ] Resizing Shadow Storage on %SystemDrive% to !VSS_CAP!...
:: vssadmin fails if no shadow storage is configured yet, so we catch it gracefully or add it
vssadmin resize shadowstorage /for=%SystemDrive% /on=%SystemDrive% /maxsize=!VSS_CAP! >nul 2>&1
if !errorlevel! neq 0 (
    vssadmin add shadowstorage /for=%SystemDrive% /on=%SystemDrive% /maxsize=!VSS_CAP! >nul 2>&1
)
call :TRACK_SPACE_END
echo.
call :LOG "SUCCESS" "OPTIMISATION" "Shadow Copy storage capped at !VSS_CAP!."
echo    [Press any key to return...] & pause >nul
goto :SUB_STORAGE

:FUNC_MEM_ANALYSE
cls
echo.
call :LOG "PROCESS" "OPTIMISATION" "Analysing top memory consumers..."
echo    [ PROCESS ] Scanning active processes for physical memory usage...
echo          --------------------------------------------------------------------------------
echo.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 | Format-Table -Property Name, @{Name='Memory (MB)';Expression={[math]::Round($_.WorkingSet64 / 1MB, 2)};Align='Right'}, Id -AutoSize"
echo.
echo          --------------------------------------------------------------------------------
echo.
echo    [ STATUS ] Memory analysis complete.
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MEMORY

:FUNC_MEM_CLIPBOARD
cls
echo.
call :LOG "PROCESS" "OPTIMISATION" "Clearing system clipboard..."
echo    [ PROCESS ] Emptying system clipboard contents...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Set-Clipboard -Value $null"
echo    [ STATUS ] System clipboard successfully cleared.
call :LOG "SUCCESS" "OPTIMISATION" "System clipboard cleared."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MEMORY

:FUNC_MEM_DUMP
cls
echo.
echo    [ INFO ] This will forcefully flush the Standby RAM Cache.
echo    [ INFO ] This reclaims "Cached" memory without closing active programs.
call :ASK_CONFIRM "Proceed with Memory Dump?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :SUB_MEMORY)

echo.
call :LOG "PROCESS" "OPTIMISATION" "Initiating Standby RAM Cache flush..."
echo    [ PROCESS ] Injecting native API token privileges...
echo    [ PROCESS ] Flushing SystemMemoryListInformation (Standby List)...

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "try { $c='using System;using System.Runtime.InteropServices;public class MemFlush{[DllImport(\"advapi32.dll\",SetLastError=true)]internal static extern bool OpenProcessToken(IntPtr ProcessHandle,uint DesiredAccess,out IntPtr TokenHandle);[DllImport(\"advapi32.dll\",SetLastError=true,CharSet=CharSet.Auto)]internal static extern bool LookupPrivilegeValue(string lpSystemName,string lpName,out long lpLuid);[DllImport(\"advapi32.dll\",SetLastError=true)]internal static extern bool AdjustTokenPrivileges(IntPtr TokenHandle,bool DisableAllPrivileges,ref TOKEN_PRIVILEGES NewState,uint BufferLength,IntPtr PreviousState,IntPtr ReturnLength);[DllImport(\"ntdll.dll\")]internal static extern uint NtSetSystemInformation(int InfoClass,IntPtr Info,int Length);[StructLayout(LayoutKind.Sequential,Pack=1)]internal struct TOKEN_PRIVILEGES{public int PrivilegeCount;public long Luid;public int Attributes;}public static void ClearStandby(){IntPtr token;OpenProcessToken(System.Diagnostics.Process.GetCurrentProcess().Handle,0x0028,out token);TOKEN_PRIVILEGES tp=new TOKEN_PRIVILEGES{PrivilegeCount=1,Attributes=2};LookupPrivilegeValue(null,\"SeProfileSingleProcessPrivilege\",out tp.Luid);AdjustTokenPrivileges(token,false,ref tp,0,IntPtr.Zero,IntPtr.Zero);IntPtr info=Marshal.AllocHGlobal(4);Marshal.WriteInt32(info,4);NtSetSystemInformation(80,info,4);Marshal.FreeHGlobal(info);}}';Add-Type $c -ErrorAction Stop;[MemFlush]::ClearStandby() } catch { exit 1 }" >nul 2>&1

if !errorlevel! equ 0 (
    echo    [ STATUS ] Standby memory successfully purged.
    call :LOG "SUCCESS" "OPTIMISATION" "Standby RAM Cache successfully flushed."
) else (
    echo    [ WARNING ] Standby memory flush failed or is restricted on this system.
    call :LOG "WARNING" "OPTIMISATION" "Standby RAM Cache flush failed (API injection blocked)."
)

echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MEMORY

:FUNC_MEM_FLUSH
cls
echo.
echo    [ INFO ] This will force all active programs to release unused memory.
echo    [ INFO ] Applications will shrink their RAM footprint immediately.
call :ASK_CONFIRM "Proceed with Active Working Set Flush?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 1 >nul & goto :SUB_MEMORY)

echo.
call :LOG "PROCESS" "OPTIMISATION" "Flushing Active Working Sets..."
echo    [ PROCESS ] Instructing active processes to empty working sets...
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$c='using System;using System.Runtime.InteropServices;public class WorkSet{[DllImport(\"psapi.dll\")]public static extern int EmptyWorkingSet(IntPtr hwProc);}';Add-Type $c;foreach($p in Get-Process){try{[void][WorkSet]::EmptyWorkingSet($p.Handle)}catch{}}"
echo    [ STATUS ] Active application memory footprints minimised.
call :LOG "SUCCESS" "OPTIMISATION" "Active Working Sets successfully flushed."
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_MEMORY

:: --- SECURITY & PRIVACY MODULES ---

:FUNC_MSERT_SCAN
cls
echo.
echo            -- MICROSOFT SAFETY SCANNER (MSERT) --------------------------------------------
echo.
echo    [ INFO ] MSERT is a standalone malware removal tool provided by Microsoft.
echo    [ INFO ] It requires a fresh download every 10 days to ensure latest definitions.
echo.
call :ASK_CONFIRM "Launch Microsoft Safety Scanner?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)

echo.
call :LOG "PROCESS" "SECURITY" "Checking Microsoft Safety Scanner (MSERT) status..."
set "MSERT_DIR=%ProgramData%\Primus\Tools"
set "MSERT_EXE=!MSERT_DIR!\msert.exe"
set "DOWNLOAD_REQUIRED=1"

:: Ensure the Tools directory exists
if not exist "!MSERT_DIR!" mkdir "!MSERT_DIR!" >nul 2>&1

:: Check if MSERT exists and evaluate expiration (10-day limit)
if exist "!MSERT_EXE!" (
    powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$f=Get-Item '!MSERT_EXE!'; if ($f.LastWriteTime -lt (Get-Date).AddDays(-9)) { exit 1 } else { exit 0 }"
    if !errorlevel! equ 0 (
        set "DOWNLOAD_REQUIRED=0"
        echo    [ INFO ] Valid MSERT executable found locally. Skipping download...
    ) else (
        echo    [ INFO ] Local MSERT executable is expired ^(Older than 10 days^).
        echo    [ PROCESS ] Removing expired scanner...
        del /f /q "!MSERT_EXE!" >nul 2>&1
    )
)

if !DOWNLOAD_REQUIRED! equ 1 (
    echo    [ PROCESS ] Fetching the latest MSERT executable from Microsoft...
    echo    [ INFO ] This is a large file ^(~200MB+^).
    echo    [ INFO ] Note: Download speeds are often limited by Microsoft's servers.
    echo    [ INFO ] This may take several minutes. Please wait...
    
    :: Uses Invoke-WebRequest to fetch the payload dynamically based on architecture
    if /i "%PROCESSOR_ARCHITECTURE%"=="AMD64" (set "MSERT_URL=https://go.microsoft.com/fwlink/?LinkId=212732") else (set "MSERT_URL=https://go.microsoft.com/fwlink/?LinkId=212733")
    powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -Command "try { Invoke-WebRequest -Uri '!MSERT_URL!' -OutFile '!MSERT_EXE!' -UseBasicParsing -ErrorAction Stop } catch { exit 1 }"
    
    if !errorlevel! neq 0 (
        echo.
        echo    [ ERROR ] Failed to download MSERT. Check your internet connection or firewall.
        call :LOG "ERROR" "SECURITY" "MSERT automated download failed."
        echo.
        echo    [Press any key to return to Menu...] & pause >nul
        goto :SUB_SECURITY
    )
    echo    [ STATUS ] Download complete.
    call :LOG "SUCCESS" "SECURITY" "MSERT successfully downloaded to !MSERT_DIR!."
)

echo.
echo    [ PROCESS ] Verifying Scanner Engine Version...
for /f "delims=" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "(Get-Item '!MSERT_EXE!').VersionInfo.FileVersion"') do (
    echo    [ INFO ] MSERT Engine Version: %%A
    call :LOG "INFO" "SECURITY" "MSERT Engine Version Extracted: %%A"
)

echo.
echo    [ PROCESS ] Launching Microsoft Safety Scanner GUI...
call :LOG "INFO" "SECURITY" "Launched MSERT GUI for user interaction."
start "" "!MSERT_EXE!"

echo.
echo    [ STATUS ] MSERT launched successfully. Follow the on-screen instructions.
echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_SECURITY

:FUNC_FIREWALL_RESET
cls
echo.
echo           -- WINDOWS FIREWALL RESET ------------------------------------------------------
echo.
echo    [ WARNING ] THIS WILL RESTORE THE WINDOWS FIREWALL TO FACTORY DEFAULTS.
echo    [ INFO ] All custom rules and port exceptions will be permanently deleted.
echo    [ INFO ] A backup will be saved to: %ProgramData%\Primus\Backups\Firewall\
echo.
call :ASK_CONFIRM "Proceed with Firewall Reset?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)

echo.
call :LOG "PROCESS" "SECURITY" "Initiating Windows Firewall Reset..."

:: Create backup directory
set "FW_DIR=%ProgramData%\Primus\Backups\Firewall"
if not exist "!FW_DIR!" mkdir "!FW_DIR!" >nul 2>&1

echo    [ PROCESS ] Exporting current firewall rules...
netsh advfirewall export "!FW_DIR!\Firewall_!FILE_TIME!.wfw" >nul 2>&1
set "FW_BK_ERR=!errorlevel!"

if !FW_BK_ERR! equ 0 (
    echo    [ STATUS ] Backup successfully saved.
) else (
    echo    [ WARNING ] Failed to export firewall backup.
    call :LOG "WARNING" "SECURITY" "Firewall export failed before reset (Exit Code: !FW_BK_ERR!)."
    call :ASK_CONFIRM "Continue with reset anyway?"
    if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)
    echo.
)

echo    [ PROCESS ] Restoring default Windows Firewall policy...
netsh advfirewall reset >nul 2>&1
set "FW_ERR=!errorlevel!"

echo.
call :EVAL_STATUS !FW_ERR! "SECURITY" "Failed to reset Windows Firewall." "Windows Firewall successfully restored to default settings."

echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_SECURITY


:FUNC_DEFENDER_CLEAN
cls
echo.
echo           -- WINDOWS DEFENDER DEEP CLEAN -------------------------------------------------
echo.

:: Route based on the global boot variable detected at script launch
if /i "!BOOT_STATUS!"=="Safe Mode" goto :DEFENDER_SAFE_MODE

:: ===========================================================================
:: NORMAL BOOT PATH (Rejection & Safe Mode Entry)
:: ===========================================================================
echo    [ WARNING ] Windows Defender logs and history are protected by ELAM
echo    [ WARNING ] and Tamper Protection. They cannot be deleted in Normal Boot.
echo.
echo    [ INFO ] Primus can automatically configure your system to reboot into
echo    [ INFO ] Safe Mode to safely bypass these locks and perform the clean.
echo.
call :ASK_CONFIRM "Configure Safe Mode and Restart now?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)

echo.
call :LOG "PROCESS" "SECURITY" "Configuring BCD for Safe Mode reboot..."
echo    [ PROCESS ] Setting BCD safeboot flag...
bcdedit /set {current} safeboot minimal >nul 2>&1
if !errorlevel! neq 0 (
    echo    [ ERROR ] Failed to configure Safe Mode. Your Boot Configuration Data ^(BCD^) may be locked.
    echo    [Press any key to return...] & pause >nul
    goto :SUB_SECURITY
)

call :LOG "INFO" "SECURITY" "System rebooting into Safe Mode for Defender cleanup."
echo    [ STATUS ] System will now restart. Please re-run Primus after booting.
shutdown /r /t 5 /c "Primus: Rebooting into Safe Mode..."
exit

:: ===========================================================================
:: SAFE MODE PATH (Execution & Safe Mode Exit)
:: ===========================================================================
:DEFENDER_SAFE_MODE
echo    [ INFO ] Safe Mode environment detected. File protection locks bypassed.
call :ASK_CONFIRM "Proceed with Deep Defender Cleanup?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)

echo.
call :LOG "PROCESS" "SECURITY" "Initiating Deep Windows Defender Cleanup..."
call :TRACK_SPACE_START "%ProgramData%\Microsoft\Windows Defender\Scans\History\Service"

echo    [ PROCESS ] Purging Defender Service History and Scan Logs...
call :PURGE_DIR "%ProgramData%\Microsoft\Windows Defender\Scans\History\Service"
call :PURGE_DIR "%ProgramData%\Microsoft\Windows Defender\Scans\History\Results"

echo    [ PROCESS ] Resetting Defender Threat Signatures...
if exist "%ProgramFiles%\Windows Defender\MpCmdRun.exe" (
    "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -RemoveDefinitions -All >nul 2>&1
)

call :TRACK_SPACE_END
echo.
echo    [ STATUS ] Windows Defender History and Signatures completely purged.
call :LOG "SUCCESS" "SECURITY" "Defender deep clean successfully executed in Safe Mode."

:: CRITICAL: Infinite Safe Mode Loop Prevention
echo.
echo    [ INFO ] Your system is currently configured to always boot into Safe Mode.
call :ASK_CONFIRM "Remove Safe Mode flag and restart into Normal Windows?"
if !errorlevel! equ 0 (
    echo.
    echo    [ PROCESS ] Restoring normal boot sequence...
    bcdedit /deletevalue {current} safeboot >nul 2>&1
    call :LOG "INFO" "SECURITY" "Safe Mode flag removed. Rebooting to Normal Boot."
    shutdown /r /t 5 /c "Primus: Rebooting back to normal Windows..."
    exit
) else (
    echo.
    echo    [ WARNING ] Safe Mode flag remains active. You must remove it manually.
    echo    [ FIX ] Press Win+R, type "msconfig", go to the Boot tab, and uncheck "Safe boot".
)

echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_SECURITY

:FUNC_DEFENDER_UPDATE
cls
echo.
echo           -- FORCE DEFENDER SIGNATURE UPDATE ---------------------------------------------
echo.
echo    [ INFO ] This will force Windows Defender to immediately connect to Microsoft
echo    [ INFO ] servers and download the latest Security Intelligence updates.
echo.
call :ASK_CONFIRM "Force Signature Update now?"
if !errorlevel! neq 0 (echo. & echo    [ INFO ] Operation cancelled. Returning... & timeout /t 2 >nul & goto :SUB_SECURITY)

echo.
call :LOG "PROCESS" "SECURITY" "Initiating forced Defender signature update..."
echo    [ PROCESS ] Connecting to Microsoft Update Servers...
echo    [ INFO ] This may take a minute or two depending on your connection.
echo.

if exist "%ProgramFiles%\Windows Defender\MpCmdRun.exe" (
    "%ProgramFiles%\Windows Defender\MpCmdRun.exe" -SignatureUpdate
    set "DEF_ERR=!errorlevel!"
) else (
    set "DEF_ERR=1"
    echo    [ ERROR ] MpCmdRun.exe not found in the expected directory.
)

echo.
call :EVAL_STATUS !DEF_ERR! "SECURITY" "Failed to update Defender signatures (Exit Code: !DEF_ERR!)." "Windows Defender Security Intelligence successfully updated."

echo.
echo    [Press any key to return to Menu...] & pause >nul
goto :SUB_SECURITY

:: --- PRIVACY & TELEMETRY MODULES ---

:FUNC_TEL_WINDOWS
cls
call :PRINT_HEADER
echo.
echo           -- WINDOWS SYSTEM TELEMETRY ----------------------------------------------------
echo.
echo            [1] Disable Telemetry (Privacy Mode)
echo            [2] Enable Telemetry  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_WIN_DISABLE
if "!tel_choice!"=="2" goto :TEL_WIN_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_WINDOWS

:TEL_WIN_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling Windows System Telemetry..."
echo            [ PROCESS ] Stopping DiagTrack and dmwappush services...
net stop DiagTrack /y >nul 2>&1
net stop dmwappushservice /y >nul 2>&1
sc config DiagTrack start= disabled >nul 2>&1
sc config dmwappushservice start= disabled >nul 2>&1

echo            [ PROCESS ] Injecting Privacy Registry Keys...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /t REG_DWORD /d 0 /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Application...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" 2>nul | find /i "0x0" >nul
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Value may be locked by Domain/Local Group Policy.
    call :LOG "WARNING" "PRIVACY" "Telemetry disable verification failed (Possible GPO override)."
) else (
    echo            [ STATUS ] Windows System Telemetry successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "Windows Telemetry disabled via Registry and Services."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_WIN_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring Windows System Telemetry..."
echo            [ PROCESS ] Restoring DiagTrack and dmwappush services...
sc config DiagTrack start= auto >nul 2>&1
sc config dmwappushservice start= delayed-auto >nul 2>&1
net start DiagTrack >nul 2>&1
net start dmwappushservice >nul 2>&1

echo            [ PROCESS ] Restoring Default Registry Keys...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Removal...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\DataCollection" /v "AllowTelemetry" >nul 2>&1
if !errorlevel! equ 0 (
    echo            [ WARNING ] Verification failed. Registry lock or active Group Policy detected.
    call :LOG "WARNING" "PRIVACY" "Telemetry enable verification failed (Possible GPO override)."
) else (
    echo            [ STATUS ] Windows System Telemetry successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "Windows Telemetry restored to factory defaults."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:FUNC_TEL_TIMELINE
cls
call :PRINT_HEADER
echo.
echo           -- ACTIVITY HISTORY ^& TIMELINE ------------------------------------------------
echo.
echo            [1] Disable Activity History (Privacy Mode)
echo            [2] Enable Activity History  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_TIME_DISABLE
if "!tel_choice!"=="2" goto :TEL_TIME_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_TIMELINE

:TEL_TIME_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling Activity History and Timeline Sync..."
echo            [ PROCESS ] Injecting Privacy Registry Keys...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /t REG_DWORD /d 0 /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Application...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" 2>nul | find /i "0x0" >nul
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Value may be locked by Domain/Local Group Policy.
    call :LOG "WARNING" "PRIVACY" "Activity History disable verification failed."
) else (
    echo            [ STATUS ] Activity History and Timeline Sync successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "Activity History disabled via Registry."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_TIME_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring Activity History and Timeline Sync..."
echo            [ PROCESS ] Restoring Default Registry Keys...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "UploadUserActivities" /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Removal...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\System" /v "PublishUserActivities" >nul 2>&1
if !errorlevel! equ 0 (
    echo            [ WARNING ] Verification failed. Registry lock or active Group Policy detected.
    call :LOG "WARNING" "PRIVACY" "Activity History enable verification failed."
) else (
    echo            [ STATUS ] Activity History successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "Activity History restored to factory defaults."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:FUNC_TEL_WER
cls
call :PRINT_HEADER
echo.
echo           -- ERROR REPORTING (WER) -------------------------------------------------------
echo.
echo            [1] Disable Error Reporting Uploads (Privacy Mode)
echo            [2] Enable Error Reporting Uploads  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_WER_DISABLE
if "!tel_choice!"=="2" goto :TEL_WER_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_WER

:TEL_WER_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling Windows Error Reporting (WER)..."
echo            [ PROCESS ] Injecting Privacy Registry Keys...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /t REG_DWORD /d 1 /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Application...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" 2>nul | find /i "0x1" >nul
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Value may be locked by Domain/Local Group Policy.
    call :LOG "WARNING" "PRIVACY" "WER disable verification failed."
) else (
    echo            [ STATUS ] Windows Error Reporting uploads successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "WER disabled via Registry."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_WER_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring Windows Error Reporting (WER)..."
echo            [ PROCESS ] Restoring Default Registry Keys...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Removal...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Error Reporting" /v "Disabled" >nul 2>&1
if !errorlevel! equ 0 (
    echo            [ WARNING ] Verification failed. Registry lock or active Group Policy detected.
    call :LOG "WARNING" "PRIVACY" "WER enable verification failed."
) else (
    echo            [ STATUS ] Windows Error Reporting successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "WER restored to factory defaults."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:FUNC_TEL_CEIP
cls
call :PRINT_HEADER
echo.
echo           -- CEIP SCHEDULED TASKS --------------------------------------------------------
echo.
echo            [1] Disable CEIP Data Collection (Privacy Mode)
echo            [2] Enable CEIP Data Collection  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_CEIP_DISABLE
if "!tel_choice!"=="2" goto :TEL_CEIP_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_CEIP

:TEL_CEIP_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling CEIP Scheduled Tasks..."
echo            [ PROCESS ] Unregistering Customer Experience Improvement Tasks...
for %%T in (
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
) do schtasks /Change /TN %%T /Disable >nul 2>&1

echo            [ PROCESS ] Verifying Task States...
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "if ((Get-ScheduledTask -TaskName '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator' -ErrorAction SilentlyContinue).State -eq 'Disabled') { exit 0 } else { exit 1 }"
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Tasks may be locked by system permissions.
    call :LOG "WARNING" "PRIVACY" "CEIP tasks disable verification failed."
) else (
    echo            [ STATUS ] CEIP Scheduled Tasks successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "CEIP Scheduled Tasks disabled via schtasks."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_CEIP_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring CEIP Scheduled Tasks..."
echo            [ PROCESS ] Restoring Customer Experience Improvement Tasks...
for %%T in (
    "\Microsoft\Windows\Customer Experience Improvement Program\Consolidator"
    "\Microsoft\Windows\Customer Experience Improvement Program\BthSQM"
    "\Microsoft\Windows\Customer Experience Improvement Program\KernelCeipTask"
    "\Microsoft\Windows\Customer Experience Improvement Program\UsbCeip"
    "\Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser"
    "\Microsoft\Windows\Application Experience\ProgramDataUpdater"
    "\Microsoft\Windows\Application Experience\StartupAppTask"
) do schtasks /Change /TN %%T /Enable >nul 2>&1

echo            [ PROCESS ] Verifying Task States...
powershell -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "if ((Get-ScheduledTask -TaskName '\Microsoft\Windows\Customer Experience Improvement Program\Consolidator' -ErrorAction SilentlyContinue).State -eq 'Ready') { exit 0 } else { exit 1 }"
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Tasks may be locked by system permissions.
    call :LOG "WARNING" "PRIVACY" "CEIP tasks enable verification failed."
) else (
    echo            [ STATUS ] CEIP Scheduled Tasks successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "CEIP Scheduled Tasks restored to default state."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:FUNC_TEL_CORTANA
cls
call :PRINT_HEADER
echo.
echo           -- CORTANA ^& WEB SEARCH -------------------------------------------------------
echo.
echo            [1] Disable Cortana ^& Web Search (Privacy Mode)
echo            [2] Enable Cortana ^& Web Search  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_CORTANA_DISABLE
if "!tel_choice!"=="2" goto :TEL_CORTANA_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_CORTANA

:TEL_CORTANA_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling Cortana and Web Search..."
echo            [ PROCESS ] Injecting Privacy Registry Keys...
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /t REG_DWORD /d 1 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /t REG_DWORD /d 0 /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Application...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" 2>nul | find /i "0x1" >nul
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Value may be locked by Domain/Local Group Policy.
    call :LOG "WARNING" "PRIVACY" "Cortana disable verification failed."
) else (
    echo            [ PROCESS ] Restarting Windows Explorer to apply changes...
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe
    echo            [ STATUS ] Cortana and Web Search successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "Cortana and Web Search disabled via Registry. Explorer restarted."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_CORTANA_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring Cortana and Web Search..."
echo            [ PROCESS ] Restoring Default Registry Keys...
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "AllowCortana" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "ConnectedSearchUseWeb" /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Removal...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\Windows Search" /v "DisableWebSearch" >nul 2>&1
if !errorlevel! equ 0 (
    echo            [ WARNING ] Verification failed. Registry lock or active Group Policy detected.
    call :LOG "WARNING" "PRIVACY" "Cortana enable verification failed."
) else (
    echo            [ PROCESS ] Restarting Windows Explorer to apply changes...
    taskkill /f /im explorer.exe >nul 2>&1
    start explorer.exe
    echo            [ STATUS ] Cortana and Web Search successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "Cortana and Web Search restored to factory defaults. Explorer restarted."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:FUNC_TEL_APPID
cls
call :PRINT_HEADER
echo.
echo           -- APP ADVERTISING ID ----------------------------------------------------------
echo.
echo            [1] Disable App Advertising ID (Privacy Mode)
echo            [2] Enable App Advertising ID  (Windows Default)
echo.
echo           ================================================================================
echo            [R] RETURN TO PRIVACY MENU
echo.
set "tel_choice="
set /p "tel_choice=%BS%          [Selection] :> "

if "!tel_choice!"=="1" goto :TEL_APPID_DISABLE
if "!tel_choice!"=="2" goto :TEL_APPID_ENABLE
if /i "!tel_choice!"=="R" goto :SUB_TELEMETRY
goto :FUNC_TEL_APPID

:TEL_APPID_DISABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Disabling App Advertising ID..."
echo            [ PROCESS ] Injecting Privacy Registry Keys...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 0 /f >nul 2>&1
reg add "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /t REG_DWORD /d 1 /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Application...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" 2>nul | find /i "0x1" >nul
if !errorlevel! neq 0 (
    echo            [ WARNING ] Verification failed. Value may be locked by Domain/Local Group Policy.
    call :LOG "WARNING" "PRIVACY" "App Advertising ID disable verification failed."
) else (
    echo            [ STATUS ] App Advertising ID successfully disabled.
    call :LOG "SUCCESS" "PRIVACY" "Advertising ID disabled via Registry."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:TEL_APPID_ENABLE
cls
call :PRINT_HEADER
echo.
call :LOG "PROCESS" "PRIVACY" "Restoring App Advertising ID..."
echo            [ PROCESS ] Restoring Default Registry Keys...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" /v "Enabled" /t REG_DWORD /d 1 /f >nul 2>&1
reg delete "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" /f >nul 2>&1

echo            [ PROCESS ] Verifying Policy Removal...
reg query "HKLM\SOFTWARE\Policies\Microsoft\Windows\AdvertisingInfo" /v "DisabledByGroupPolicy" >nul 2>&1
if !errorlevel! equ 0 (
    echo            [ WARNING ] Verification failed. Registry lock or active Group Policy detected.
    call :LOG "WARNING" "PRIVACY" "App Advertising ID enable verification failed."
) else (
    echo            [ STATUS ] App Advertising ID successfully restored to defaults.
    call :LOG "SUCCESS" "PRIVACY" "Advertising ID restored to factory defaults."
)
echo.
echo            [Press any key to return...] & pause >nul
goto :SUB_TELEMETRY

:: ---------------------------------------------------------------------------
:: System Info
:: ---------------------------------------------------------------------------
:FUNC_SYSINFO
cls
call :PRINT_HEADER
echo.
echo           -- SYSTEM INFORMATION ----------------------------------------------------------
echo.
call :LOG "PROCESS" "SYSTEM" "Gathering detailed system hardware specifications..."
echo            [ PROCESS ] Interrogating WMI for hardware details...
echo.

powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "$cpu = (Get-CimInstance Win32_Processor).Name -replace '  ', ' '; " ^
    "$ram = [math]::Round((Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory / 1GB, 1); " ^
    "$gpu = (Get-CimInstance Win32_VideoController).Name; " ^
    "$mobo = (Get-CimInstance Win32_BaseBoard).Product; " ^
    "$bios = (Get-CimInstance Win32_BIOS).SMBIOSBIOSVersion; " ^
    "Write-Host '             PROCESSOR: ' -NoNewline; Write-Host $cpu -ForegroundColor Cyan; " ^
    "Write-Host '             MEMORY:    ' -NoNewline; Write-Host \"$ram GB Installed\" -ForegroundColor Cyan; " ^
    "Write-Host '             GRAPHICS:  ' -NoNewline; Write-Host ($gpu -join ' | ') -ForegroundColor Cyan; " ^
    "Write-Host '             BASEBOARD: ' -NoNewline; Write-Host $mobo -ForegroundColor Cyan; " ^
    "Write-Host '             BIOS VER:  ' -NoNewline; Write-Host $bios -ForegroundColor Cyan;"

echo.
echo           ================================================================================
echo.
call :LOG "SUCCESS" "SYSTEM" "Hardware specifications successfully displayed."
echo            [Press any key to return to Main Menu...]
pause >nul
goto :MENU

:: ---------------------------------------------------------------------------
:: HELP & INFORMATION PAGES
:: ---------------------------------------------------------------------------
:FUNC_HELP
cls
call :PRINT_HEADER
echo.
echo            -- HELP ^& INFORMATION (PAGE 1 OF 3) --------------------------------------------
echo.
echo             [ ABOUT ]
echo              Primus is a system maintenance utility designed to safely perform
echo              common Windows cleanup tasks, repair and optimisations.
echo.
echo             [ LOGGING SYSTEM ]
echo              Location:  %ProgramData%\Primus\Logs\
echo              Retention: 30 Days (Automatic background cleanup)
echo              Format:    Primus_YYYYMMDD_HHMMSS.log
echo.
echo             [ SAFETY PROTOCOLS ]
echo              * Always create a Restore Point before major operations.
echo              * Active/In-use files are automatically skipped during cleanup.
echo              * All destructive operations require Y/N confirmation.
echo.
echo             [ SUPPORT ]
echo              GitHub: https://github.com/R4in84/Primus
echo.
echo           ================================================================================
echo            [Press any key to view Tool Descriptions...]
pause >nul

cls
call :PRINT_HEADER
echo.
echo            -- TOOL DESCRIPTIONS (PAGE 2 OF 3) ---------------------------------------------
echo.
echo             [ SYSTEM RECOVERY ]
echo              Creates VSS snapshots, purges old backups, and performs bare-metal
echo              exports of core registry hives and 3rd-party hardware drivers.
echo.
echo             [ SYSTEM MAINTENANCE ]
echo              Clears temporary directories, rebuilds broken icon caches, deep
echo              cleans browser telemetry, and optimises the WinSxS store.
echo.
echo             [ SYSTEM DIAGNOSTICS ^& REPAIR ]
echo              Queries file system dirty bits, schedules offline volume repairs,
echo              and utilises native SFC/DISM tools to fix core image corruption.
echo.
echo             [ NETWORK OPTIMISATION ]
echo              Flushes DNS/ARP routing tables and performs deep resets of the 
echo              TCP/IP stack and Winsock catalogue to resolve offline bugs.
echo.
echo           ================================================================================
echo            [Press any key to view Next Page...]
pause >nul

cls
call :PRINT_HEADER
echo.
echo            -- TOOL DESCRIPTIONS (PAGE 3 OF 3) ---------------------------------------------
echo.
echo             [ SYSTEM OPTIMISATION ]
echo              Optimises drives via SSD trimming and HDD defragmentation, manages
echo              System Compression (CompactOS), and caps VSS/Reserved Storage.
echo.
echo             [ SECURITY SUITE ]
echo              Downloads Microsoft Safety Scanner, resets Firewall configurations,
echo              and utilizes Safe Mode to deep-clean Defender scan history.
echo.
echo             [ PRIVACY ^& TELEMETRY ]
echo              Disables OS data collection, Cortana web integration, CEIP tasks,
echo              and Activity History via secure, native registry injections.
echo.
echo           ================================================================================
call :LOG "INFO" "SYSTEM" "User accessed Help & Information module."
echo            [Press any key to return to Main Menu...]
pause >nul
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
:CHECK_UPDATES
:: Actively queries GitHub API with a 3-second timeout to prevent script freezing if offline.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command ^
    "try { " ^
    "  $latest = (Invoke-RestMethod -Uri 'https://api.github.com/repos/r4in84/primus/releases/latest' -TimeoutSec 3 -ErrorAction Stop).tag_name; " ^
    "  if ($latest) { " ^
    "    $rStr = $latest.ToLower().Replace('v', ''); " ^
    "    $lStr = '%PRIMUS_VERSION%'.ToLower().Replace('v', ''); " ^
    "    if ([version]$rStr -gt [version]$lStr) { " ^
    "      Write-Host ''; " ^
    "      Write-Host '   [ ALERT ] ' -NoNewline -ForegroundColor DarkYellow; " ^
    "      Write-Host 'A new version of Primus is available ' -NoNewline; " ^
    "      Write-Host \"($latest) \" -NoNewline -ForegroundColor Green; " ^
    "      Write-Host 'https://github.com/R4in84/Primus/releases/latest' -ForegroundColor Cyan; " ^
    "      Write-Host ''; " ^
    "      Start-Sleep -Seconds 3; " ^
    "    } " ^
    "  } " ^
    "} catch { }"
exit /b

:ASK_CONFIRM
set "confirm_ans="
set /p "confirm_ans=%BS%   [ CONFIRM ] %~1 (Y/N) :> "
if /i "!confirm_ans!"=="Y" exit /b 0
if /i "!confirm_ans!"=="N" exit /b 1
echo    [ ERROR ] Invalid input. Please enter Y or N.
goto :ASK_CONFIRM

:ASK_REBOOT
call :ASK_CONFIRM "Restart computer now?"
if !errorlevel! equ 0 (call :LOG "INFO" "CORE" "Initiating system reboot for %~1 changes." & shutdown /r /t 5 /c "Primus: Rebooting to apply %~1 Reset..." & exit)
exit /b

:EVAL_STATUS
if "%~1"=="0" goto :EVAL_SUCCESS
echo    [ ERROR ] %~3
call :LOG "ERROR" "%~2" "%~3"
exit /b

:EVAL_SUCCESS
echo    [ STATUS ] %~4
call :LOG "SUCCESS" "%~2" "%~4"
exit /b

:CHECK_FREE_SPACE
:: Evaluates if %SystemDrive% has at least 2GB of free space to prevent corruption during heavy operations.
powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$f = (Get-CimInstance Win32_LogicalDisk -Filter \"DeviceID='%SystemDrive%'\").FreeSpace; if ($f -lt 2GB) { exit 1 } else { exit 0 }"
if !errorlevel! equ 1 (
    echo.
    echo    [ WARNING ] CRITICAL: Low disk space detected on %SystemDrive%\ ^(!SYS_FREE!^).
    echo    [ WARNING ] This operation requires at least 2GB of free space to run safely.
    echo.
    call :ASK_CONFIRM "Force execution anyway (Not Recommended)?"
    if !errorlevel! neq 0 exit /b 1
)
exit /b 0

:TRACK_SPACE_START
set "TRACK_TARGET=%~1"
if "%~1"=="" (
    :: MODE: GLOBAL
    set "TRACK_MODE=GLOBAL"
    for /f "delims=" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "[long]([System.IO.DriveInfo]'%SystemDrive%\').AvailableFreeSpace"') do set "SPACE_BEFORE=%%A"
) else (
    :: MODE: PRECISION
    set "TRACK_MODE=FOLDER"
    for /f "delims=" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$paths = $env:TRACK_TARGET.Split([char]124); [long]$total = 0; foreach($p in $paths){ if(Test-Path -LiteralPath $p){ $sum = (Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; if($sum) { $total += [long]$sum } } }; $total"') do set "SPACE_BEFORE=%%A"
)
set "SPACE_BEFORE=%SPACE_BEFORE: =%"
exit /b

:TRACK_SPACE_END
if not defined SPACE_BEFORE set "SPACE_BEFORE=0"
if not defined SESSION_TOTAL_BYTES set "SESSION_TOTAL_BYTES=0"

if "!TRACK_MODE!"=="GLOBAL" (
    :: GLOBAL CALCULATION
    for /f "tokens=1,2 delims=#" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "Start-Sleep -Seconds 2; [long]$sb = $env:SPACE_BEFORE; [long]$st = $env:SESSION_TOTAL_BYTES; $rawSaved = [long]([System.IO.DriveInfo]'%SystemDrive%\').AvailableFreeSpace - $sb; $saved = [math]::Max([long]0, $rawSaved); $newTotal = $st + $saved; $formatted = if ($rawSaved -le 0) { '0.00 KB' } elseif ($rawSaved -ge 1GB) { '{0:N2} GB' -f ($rawSaved/1GB) } elseif ($rawSaved -ge 1MB) { '{0:N2} MB' -f ($rawSaved/1MB) } else { '{0:N2} KB' -f ($rawSaved/1KB) }; '{0}#{1}' -f $newTotal, $formatted"') do (
        set "SESSION_TOTAL_BYTES=%%A"
        set "SPACE_SAVED=%%B"
    )
) else (
    :: PRECISION CALCULATION 
    for /f "tokens=1,2 delims=#" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "$paths = $env:TRACK_TARGET.Split([char]124); [long]$after = 0; foreach($p in $paths){ if(Test-Path -LiteralPath $p){ $sum = (Get-ChildItem -LiteralPath $p -Recurse -File -Force -ErrorAction SilentlyContinue | Measure-Object -Property Length -Sum).Sum; if($sum) { $after += [long]$sum } } }; [long]$sb = $env:SPACE_BEFORE; [long]$st = $env:SESSION_TOTAL_BYTES; $rawSaved = $sb - $after; $saved = [math]::Max([long]0, $rawSaved); $newTotal = $st + $saved; $formatted = if ($rawSaved -le 0) { '0.00 KB' } elseif ($rawSaved -ge 1GB) { '{0:N2} GB' -f ($rawSaved/1GB) } elseif ($rawSaved -ge 1MB) { '{0:N2} MB' -f ($rawSaved/1MB) } else { '{0:N2} KB' -f ($rawSaved/1KB) }; '{0}#{1}' -f $newTotal, $formatted"') do (
        set "SESSION_TOTAL_BYTES=%%A"
        set "SPACE_SAVED=%%B"
    )
)
echo    [ STATUS ] Reclaimed Disk Space: !SPACE_SAVED!
call :LOG "INFO" "MAINTENANCE" "Operation reclaimed !SPACE_SAVED! of disk space."
exit /b

:: ---------------------------------------------------------------------------
:: LOGGING ENGINE
:: ---------------------------------------------------------------------------
:LOG
:: Usage: call :LOG "LEVEL" "CATEGORY" "Message"
set "log_lvl=%~1"
set "log_cat=%~2"
set "log_msg=%~3"

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
:: Calculate formatted totals and exact end time simultaneously via PowerShell
if not defined SESSION_TOTAL_BYTES set "SESSION_TOTAL_BYTES=0"
for /f "tokens=1,2 delims=#" %%A in ('powershell -NoLogo -NoProfile -NonInteractive -ExecutionPolicy Bypass -Command "[long]$t = $env:SESSION_TOTAL_BYTES; $fmt = if ($t -le 0) { '0.00 KB' } elseif ($t -ge 1GB) { '{0:N2} GB' -f ($t/1GB) } elseif ($t -ge 1MB) { '{0:N2} MB' -f ($t/1MB) } else { '{0:N2} KB' -f ($t/1KB) }; $end = (Get-Date).ToString('HH:mm'); '{0}#{1}' -f $fmt, $end"') do (
    set "SESSION_TOTAL_FORMATTED=%%A"
    set "SESSION_END_TIME=%%B"
)

call :LOG "SYSTEM" "CORE" "Primus v!PRIMUS_VERSION! Session Terminated Safely."
call :LOG "INFO" "CORE" "Session Duration: !CURRENT_TIME! to !SESSION_END_TIME!. Total Space Reclaimed: !SESSION_TOTAL_FORMATTED!"

:: Append the visual summary footer directly to the log file
(
echo.
echo ================================================================================
echo                               P R I M U S   S U M M A R Y
echo ================================================================================
echo  Session Start:   !CURRENT_TIME!
echo  Session End:     !SESSION_END_TIME!
echo  Space Reclaimed: !SESSION_TOTAL_FORMATTED!
echo ================================================================================
echo.
) >> "!LOG_FILE!"

cls
echo.
echo.
echo.
echo           ================================================================================
echo                                   Primus Session Terminated Safely                        
echo           ================================================================================
echo.
echo              Session Start:   !CURRENT_TIME!
echo              Session End:     !SESSION_END_TIME!
echo              Space Reclaimed: !SESSION_TOTAL_FORMATTED!
echo              Log File:        !LOG_FILE!
echo.
echo           ================================================================================
echo                                        Closing Application...
echo           ================================================================================
timeout /t 3 >nul
endlocal
exit