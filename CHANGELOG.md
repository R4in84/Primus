# 📝 Changelog

All notable changes to Primus will be documented in this file.

## [1.1] - 2026-05-05

### ✨ Major Features

**System Diagnostics & Repair Category**
- ✅ CHKDSK volume dirty bit query (detects file system errors)
- ✅ CHKDSK read-only integrity scan (non-destructive analysis)
- ✅ CHKDSK offline repair scheduling (auto-fixes on next boot)
- ✅ Scheduled repair cancellation (removes pending repairs)
- ✅ Intelligent DISM 3010 handling (reboot-pending state)
- ✅ Phase-based Deep WinSxS reset with safety locks

**System Optimization Category**
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
- ✅ Delivery Optimization peer cache purge (reclaims GBs)
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
- 4 CHKDSK utilities
- 6 System Optimization utilities
- Plus Registry/Driver backups and expanded maintenance

**Expanded Browser Support**: Unchanged (14 browsers)
- Added validation for Firefox-based variants
- Better path handling for multi-install scenarios

**Total Categories**: 5 (up from 4)
- System Recovery
- System Maintenance
- Network Optimization
- **System Diagnostics & Repair** (NEW)
- **System Optimization** (NEW)

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
- ✅ Prefetch cache optimization
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

#### **🌐 Network Optimization**
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
