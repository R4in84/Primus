# 📝 Changelog

All notable changes to Primus will be documented in this file.

## [1.2.1] - 2026-05-14

### ✨ Major Features

**Advanced Memory Analysis**
- ✅ Upgraded top memory consumer module with intelligent application grouping
- ✅ Consolidates multi-process applications (e.g., Firefox, Discord) into single combined entries
- ✅ Added "Instances" tracking to display child process counts per application
- ✅ Implemented dynamic PowerShell string formatting for pixel-perfect, right-aligned data columns
- ✅ Auto-truncates long process names to preserve UI boundaries

**Dynamic Multi-Browser Deep Clean**
- ✅ Re-architected browser cleaning engine to use dynamic `for` loops
- ✅ Auto-detects active profiles and directories before execution (eliminates ghost commands)
- ✅ Seamlessly supports 14 browsers across Chromium, Firefox, and Opera architectures

### 🔧 Quality & Reliability Improvements

**Menu & Workflow Reorganization**
- 🔧 Rebalanced maintenance categories into logical groupings:
  - **General Cleanup**: 6 safe, routine options (added Error Reports & Dumps here)
  - **Deep System Cleanup**: 10 advanced, interactive options (moved Disk Cleanup here)
- 🔧 Physically re-ordered all script subroutines to chronologically match the UI flow for easier codebase maintenance

**Pixel-Perfect UI Engine**
- 🔧 Implemented "Ghost Caret" (`^&`) awareness to ensure all category headers render at exactly 80 characters
- 🔧 Recalibrated main menu and sub-menu margins (`%M0%` / `%M1%`) for absolute vertical symmetry
- 🔧 Standardized the horizontal separator (`%BAR%`) alignment across all module footers

**Codebase Optimization & OS Detection**
- 🔧 Condensed complex PowerShell modules (like Memory Analysis) into ultra-lean, single-line execution strings utilizing command aliases
- 🔧 Added dynamic `Dev Build` detection tag for Windows Insider releases (Build 26300+)

---

## [1.2.0] - 2026-05-08

### ✨ Major Features

**Security Suite Category** 🛡️ **(NEW)**
- ✅ Microsoft Safety Scanner (MSERT) integration
  - Automated download from Microsoft CDN with architecture detection (x86/x64)
  - 10-day expiration enforcement with automatic re-download
  - Version validation and intelligent caching
  - ~150MB payload with graceful offline handling
- ✅ Windows Firewall reset to factory defaults
  - Automatic rule backup to timestamped `.wfw` files
  - Pre-reset confirmation with abort option if backup fails
  - Backup location: `%ProgramData%\Primus\Backups\Firewall\`
- ✅ Windows Defender Deep Clean
  - Safe Mode automation for ELAM/Tamper Protection bypass
  - Intelligent BCD management (automatic entry/exit)
  - Service history and scan log purge
  - Threat signature reset via `MpCmdRun.exe`
  - Enhanced visual warnings with box-drawing characters
  - Manual override instructions if user declines auto-reboot
- ✅ Force Windows Defender signature update
  - Direct `MpCmdRun.exe -SignatureUpdate` execution
  - Real-time connection feedback

**Privacy & Telemetry Category** 🔒 **(NEW)**
- ✅ Windows System Telemetry (Enable/Disable)
  - DiagTrack and dmwappushservice control
  - Registry policy enforcement (`AllowTelemetry`)
- ✅ Activity History & Timeline (Enable/Disable)
  - Cloud sync control (`PublishUserActivities`, `UploadUserActivities`)
  - User activity logging prevention
- ✅ Error Reporting / WER (Enable/Disable)
  - Crash report upload blocking
- ✅ CEIP Scheduled Tasks (Enable/Disable)
  - Customer Experience Improvement Program tasks
  - Application Experience Appraiser tasks
  - Consolidator, BthSQM, KernelCeipTask, UsbCeip control
- ✅ Cortana & Web Search (Enable/Disable)
  - Start menu web integration blocking
  - Connected search prevention
  - Windows Explorer restart for immediate effect
- ✅ App Advertising ID (Enable/Disable)
  - Cross-app tracking prevention (HKCU + HKLM)

**Storage Optimisation Expansion**
- ✅ CompactOS system compression (Enable/Disable)
  - `compact.exe /compactos:always` integration
  - Status query before user selection
  - Typical savings: 2-4GB
- ✅ Hibernation space management
  - Three modes: Disable / Reduced / Full
  - Reduced mode: ~50% hiberfil.sys size reduction
  - Full control via `powercfg /h` commands
- ✅ Windows Reserved Storage control (Enable/Disable)
  - DISM-based state management
  - Build 18362+ validation (Windows 10 1903+)
  - Typical savings: ~7GB
  - Graceful unsupported build handling
- ✅ Shadow Copy storage capping
  - Four preset limits: 5GB / 10GB / 15GB / 20GB
  - `vssadmin resize shadowstorage` integration
  - Automatic fallback to `vssadmin add` if unconfigured

### 🔧 Quality & Reliability Improvements

**Build Version Validation**
- 🔧 Reserved Storage feature gated behind Build 18362+ check
  - Prevents execution on Windows 10 1809 and earlier
  - Clear messaging with detected build number
  - Automatic return to menu on unsupported systems

**Enhanced Backup Systems**
- 🔧 Firewall rule export with validation
  - Pre-reset `.wfw` backup with error checking
  - User confirmation required if backup fails
  - Timestamped backups: `Firewall_YYYYMMDD_HHMMSS.wfw`
- 🔧 Network configuration snapshots
  - `ipconfig /all` exports before TCP/IP and Winsock resets
  - Stored in `%ProgramData%\Primus\Backups\NetConfig\`

**Safe Mode Automation**
- 🔧 Intelligent BCD management for Defender cleanup
  - Automatic `bcdedit /set {current} safeboot minimal` on Normal Boot
  - Automatic `bcdedit /deletevalue {current} safeboot` after Safe Mode cleanup
  - Clear visual warnings if user declines auto-exit from Safe Mode
  - Manual recovery instructions via `msconfig` displayed
  - Prevents infinite Safe Mode boot loops

**Space Tracking Integration**
- 🔧 All new storage functions now integrated with session tracking
  - CompactOS enable/disable operations
  - Hibernation mode changes
  - Reserved Storage state toggles
  - Shadow Copy storage resizing
  - Session summary accurately reflects total space impact

**Visual Enhancements**
- 🔧 Box-drawing character warnings for critical operations
  - Safe Mode override instructions
  - Enhanced readability and visibility
- 🔧 CompactOS status display before menu
  - `compact.exe /compactos:query` execution
  - Shows current compression state to user

**Service Management Improvements**
- 🔧 Privacy toggles properly handle service states
  - DiagTrack and dmwappushservice stopped before disable
  - Services restarted when re-enabling telemetry
  - Scheduled task manipulation via `schtasks /Change`

**Error Handling Refinements**
- 🔧 MSERT download failure handling
  - Clear error messaging on network failures
  - Graceful return to menu without crash
- 🔧 Firewall reset abort on backup failure
  - Prevents destructive reset without safety net
- 🔧 Reserved Storage DISM error detection
  - Warns if feature unsupported on exact build variant

### 🛡️ New Safety Protocols

| Feature | Description |
|---------|-------------|
| **Build Version Validation** | Prevents execution of unsupported features on older builds (Reserved Storage requires 18362+) |
| **Automated Backups** | Firewall rules and network configs backed up before destructive resets |
| **Safe Mode Automation** | Intelligent BCD management with clear manual override instructions to prevent boot loops |
| **MSERT Expiration Enforcement** | 10-day signature validity check with automatic re-download from Microsoft CDN |
| **Privacy Change Logging** | All telemetry and privacy toggles logged with category "PRIVACY" |
| **Service State Preservation** | Telemetry services only restarted if they were successfully stopped |
| **Visual Warning Escalation** | Box-drawing character warnings for operations requiring manual intervention |

### 📊 Expanded Logging

- ✅ New log categories: `SECURITY`, `PRIVACY`, `TELEMETRY`
- ✅ MSERT download status and version validation logged
- ✅ Firewall backup success/failure logged before reset
- ✅ Safe Mode entry/exit transitions logged with timestamps
- ✅ Privacy toggle state changes logged (Enable/Disable)
- ✅ Reserved Storage build validation logged on unsupported systems
- ✅ CompactOS compression state changes logged
- ✅ Hibernation mode transitions logged

### 📈 Statistics & Metrics

**New Operation Count**: +14 major features
- 4 Security Suite utilities
- 6 Privacy & Telemetry dual-state toggles (12 functions)
- 4 Storage Optimisation Utilities

**New Categories**: +2
- **Security Suite** (4 operations)
- **Privacy & Telemetry** (6 operations)

**Total Categories**: 7 (up from 5)
- System Recovery
- System Maintenance
- System Diagnostics & Repair
- Network Optimisation
- System Optimisation
- **Security Suite** (NEW)
- **Privacy & Telemetry** (NEW)

**Total Operations**: 56+ utilities across all categories (up from 42)

**Lines of Code**: ~2,400 (up from ~1,800)

**Supported Privacy Controls**: 6 independent toggles affecting 15+ system components

### 🐛 Bug Fixes

- 🐛 Fixed `echo Y |` spacing in Windows.old deletion (now `echo Y|`)
  - Prevents potential "Y " string injection causing takeown failures
- 🐛 Corrected SFC log parsing to use `-Tail` instead of `Select-Object -Last`
  - Improves performance on systems with large CBS.log files (10,000+ lines)
  - Prevents PowerShell timeout on older hardware

### 📚 Documentation

- 📚 Updated README with Security Suite and Privacy & Telemetry categories
- 📚 Added usage examples for privacy hardening and MSERT scanning
- 📚 Expanded file structure documentation to include Firewall and Tools directories
- 📚 Updated system requirements to note Windows Defender dependency
- 📚 Added disclaimer clarifications for security and privacy modifications

---

## [1.1.0] - 2026-05-05

### ✨ Major Features

**System Diagnostics & Repair Category**
- ✅ CHKDSK volume dirty bit query (detects file system errors)
- ✅ CHKDSK read-only integrity scan (non-destructive analysis)
- ✅ CHKDSK offline repair scheduling (auto-fixes on next boot)
- ✅ Scheduled repair cancellation (removes pending repairs)
- ✅ Intelligent DISM 3010 handling (reboot-pending state)
- ✅ Phase-based Deep WinSxS reset with safety locks

**System Optimisation Category**
- ✅ SSD TRIM command execution (all connected drives)
- ✅ HDD defragmentation with SSD auto-detection
- ✅ Top memory consumer analysis (top 10 processes)
- ✅ System clipboard clear utility
- ✅ Standby RAM cache flush (native API injection)
- ✅ Active working set flush (forces app memory release)

**System Recovery Enhancements**
- ✅ Bare-metal Registry hive backup (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT)
- ✅ Auto-generated emergency Registry restore script
- ✅ 3rd-party driver backup via DISM export
- ✅ Timestamped backup organization

**System Maintenance Expansions**
- ✅ Windows Font Cache rebuild (fixes garbled/corrupted text)
- ✅ DirectX shader cache cleanup (fixes graphical glitches)
- ✅ Delivery Optimisation peer cache purge (reclaims GBs)
- ✅ Windows.old installation purge with post-deletion verification
- ✅ Event log clearing with success/failure tracking (reports locked logs)

### 🔧 Quality & Reliability Improvements

**Error Handling & Verification**
- 🔧 Cumulative error tracking for Registry hive backups
  - Validates all 5 hives with summed exit codes
  - Distinguishes between "1 hive failed" vs "all hives failed"
- 🔧 Post-operation verification for destructive tasks
  - Windows.old: Checks if folder still exists after deletion
  - Registry backups: Validates file existence + error codes combined
  - Driver exports: Reports actual DISM outcome
- 🔧 Error-level feedback for partial failures
  - Event logs: Reports X succeeded, Y were locked
  - Windows.old: Warns if some files remain locked
  - DoSvc: Informs if service not found

**Robust Service Management**
- 🔧 Service existence detection before stop/start (DoSvc)
  - Uses `sc query` to verify service availability
  - Gracefully handles missing services on LTSC/Server editions
  - Only restarts service if it was successfully stopped

**DISM State Handling**
- 🔧 Exit code 3010 (reboot pending) explicitly handled
  - Phase 1: Detects and aborts Phase 2 safely
  - Phase 2: Reports reboot requirement with appropriate severity
  - Prevents component store corruption from inconsistent state
- 🔧 Hard error detection (code != 3010 and != 0)
  - Aborting Phase 2 if Phase 1 critically fails
  - Clear messaging distinguishing reboot vs actual failure

**Memory Operation Safety**
- 🔧 Standby memory flush with error handling
  - Try-catch wraps P/Invoke code
  - Exit code propagates to user (success vs warning)
  - No false success messages
  - Graceful failure on restricted systems

**Session Tracking Improvements**
- 🔧 Cumulative space reclamation across all operation types
  - Accounts for Registry backups (not just deletions)
  - Precise calculation for partial failures
  - Session total reflects actual net effect

### 🛡️ New Safety Protocols

| Feature | Description |
|---------|-------------|
| **Cumulative Error Tracking** | Registry backups validated against all `reg save` exit codes |
| **Post-Operation Verification** | Windows.old deletion, Registry exports, Driver backups all verified |
| **Service Detection** | Validates DoSvc existence before attempting stop/start |
| **Reboot State Handling** | Gracefully handles DISM 3010 (reboot pending) status codes |
| **Error Breakdown Reporting** | Event logs show X succeeded, Y locked/restricted |
| **Partial Deletion Detection** | Windows.old verifies complete removal, warns on locked files |
| **P/Invoke Error Wrapping** | Memory operations include try-catch with appropriate messaging |
| **Phase Safety Locks** | Deep WinSxS reset aborts Phase 2 if Phase 1 fails critically |

### 📊 Expanded Logging

- ✅ Registry backup validation logged with cumulative error codes
- ✅ Windows.old partial deletion tracked with WARNING level
- ✅ DoSvc availability logged before service operations
- ✅ Event log breakdown logged (X cleared, Y locked)
- ✅ DISM 3010 reboot pending logged as WARNING (not ERROR)
- ✅ Standby memory flush outcome logged (success vs warning)
- ✅ Phase-based Deep WinSxS status tracked per phase

### 📈 Statistics & Metrics

**New Operation Count**: +9 major features
- 4 CHKDSK Utilities
- 6 System Optimisation Utilities
- Plus Registry/Driver backups and expanded maintenance

**Expanded Browser Support**: Unchanged (14 browsers)
- Added validation for Firefox-based variants
- Better path handling for multi-install scenarios

**Total Categories**: 5 (up from 4)
- System Recovery
- System Maintenance
- Network Optimisation
- **System Diagnostics & Repair** (NEW)
- **System Optimisation** (NEW)

**Total Operations**: 42 utilities across all categories

---

## [1.0.1] - 2026-04-28

### ✨ New Features

**Automatic Update Checker**
- ✅ GitHub API integration checks for new releases on startup
- ✅ Non-blocking 3-second timeout (won't freeze if offline)
- ✅ Semantic version comparison (v1.0.1 vs v1.0.2)
- ✅ Visual alert with download link when updates available

**Space Reclamation Tracking**
- ✅ Real-time disk space display after each cleanup operation
- ✅ Cumulative session total across all operations
- ✅ Dual-mode calculation (Global vs Precision)
- ✅ Session summary on exit
- ✅ Auto-scaling units (KB → MB → GB)

**Extended Browser Support**
- ✅ Added Thorium Browser (Chromium-based)
- ✅ Added Helium Browser (Chromium-based)
- ✅ Added Floorp Browser (Firefox fork)
- ✅ Added Zen Browser (Firefox fork with dual path support)
- ✅ **Total: 14 browsers now supported**

**Enhanced Exit Summary**
- ✅ Session duration tracking (start time → end time)
- ✅ Total space reclaimed this session
- ✅ Log file path display
- ✅ Professional summary footer in console
- ✅ Session recap appended to log file

### 🔧 Technical Improvements

- Intelligent version comparison using semantic versioning
- Graceful API timeout handling for offline scenarios
- Session statistics persisted to log files
- Improved PowerShell variable handling in space tracking

---

## [1.0.0] - 2026-04-15

### 🎉 Initial Release

A command-line system maintenance utility for Windows 10/11 with intelligent safety protocols and comprehensive logging.

---

### ✨ What's Included

#### **💾 System Recovery**
- ✅ Create manual System Restore Points with VSS integration
- ✅ Intelligent Shadow Copy cleanup (keeps most recent)
- ✅ Automatic disk space validation before operations

#### **🧹 System Maintenance**
- ✅ Deep cleanup of temporary files (User + System)
- ✅ Prefetch cache optimisation
- ✅ Windows Update download cache reset
- ✅ Thumbnail database regeneration
- ✅ Recycle Bin purge (all drives)
- ✅ Native Disk Cleanup integration
- ✅ Icon cache rebuild (fixes broken icons)
- ✅ **Multi-browser cache purge** (Chrome, Edge, Firefox, Brave, Opera, Arc, Vivaldi, LibreWolf, Waterfox)
- ✅ Windows Store cache reset
- ✅ WinSxS Component Store cleanup (Standard + Deep modes)
- ✅ Crash dump and error report cleanup
- ✅ Event log clearing

#### **🌐 Network Optimisation**
- ✅ DNS cache display/flush
- ✅ ARP cache display/clear
- ✅ IP address release/renew
- ✅ TCP/IP stack reset
- ✅ Winsock catalog reset

#### **🔧 System Repair**
- ✅ System File Checker (SFC) with intelligent log parsing
- ✅ DISM Image Health Check (Quick)
- ✅ DISM Deep Image Scan
- ✅ DISM Restore Health (automatic repair)

### 🛡️ Safety Features

| Feature | Description |
|---------|-------------|
| **Admin Enforcement** | Automatic UAC elevation request if not running as admin |
| **First-Run EULA** | Mandatory acknowledgment of risks on initial launch |
| **Disk Space Validation** | Prevents operations when <2GB free to avoid corruption |
| **User Confirmations** | All destructive operations require Y/N confirmation |
| **Locked File Protection** | Automatically skips in-use files (no forced deletions) |
| **Session Logging** | Every action is logged with timestamp and categorization |
| **Safe Mode Detection** | Displays boot status in header for awareness |
| **LTSC/Server Guards** | Warns when attempting incompatible operations |

### 📊 Logging System

- **Location**: `C:\ProgramData\Primus\Logs\`
- **Retention**: 30 days (automatic cleanup)
- **Format**: `Primus_YYYYMMDD_HHMMSS.log`
- **Categories**: SYSTEM, MAINTENANCE, NETWORK, REPAIR
- **Fallback**: `%TEMP%\Primus_Logs\` if ProgramData is inaccessible

### 🎯 Supported Browsers (Deep Clean)

1. Google Chrome
2. Microsoft Edge
3. Brave Browser
4. Vivaldi
5. Opera Stable
6. Opera GX
7. Arc Browser (MSIX package)
8. Mozilla Firefox
9. LibreWolf
10. Waterfox

---

## Legend

| Icon | Meaning |
|------|---------|
| 🎉 | Major Release |
| ✨ | New Feature |
| 🐛 | Bug Fix |
| 🔧 | Technical Improvement |
| 🔒 | Security Update |
| 📚 | Documentation |
| ⚡ | Performance Improvement |
| 🗑️ | Deprecated |
| 💥 | Breaking Change |
| 🛡️ | Safety Enhancement |

---

**Project**: [Primus](https://github.com/R4in84/Primus)  
**Author**: Chris Martin ([@R4in84](https://github.com/R4in84))  
**License**: [MIT](LICENSE)
