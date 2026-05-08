# 🛠️ Primus - System Utility

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4?logo=windows)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.2.0-success)](https://github.com/R4in84/Primus/releases)
[![Batch Script](https://img.shields.io/badge/Language-Batch-4EAA25?logo=windowsterminal)](https://en.wikipedia.org/wiki/Batch_file)

> Primus is a comprehensive command-line system maintenance utility for Windows 10/11 designed to consolidate common system maintenance, cleanup, repair, optimisation, security, and privacy tasks into a single, easy-to-use interface with intelligent safety protocols, error verification, and comprehensive logging.

> It utilizes native Windows tools (such as SFC, DISM, CHKDSK, PowerShell WMI, and Windows Defender) to help maintain system health, diagnose file system issues, resolve common operating system or network problems, and provide granular control over telemetry and privacy settings.

![Primus Main Menu](Media/Main.png)

---

## ⚡ Features

### **System Recovery** 🔄
- ✅ Create manual System Restore Points with VSS
- ✅ Intelligent Shadow Copy cleanup (preserves most recent)
- ✅ Bare-metal Registry hive backup (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT)
- ✅ Emergency Registry restore script generation
- ✅ 3rd-party driver backup via DISM export
- ✅ Automatic disk space validation before operations

### **System Maintenance** 🧹
- ✅ Deep cleanup of temporary files (User + System)
- ✅ Prefetch cache optimisation
- ✅ Windows Update download cache reset
- ✅ Thumbnail database regeneration
- ✅ Recycle Bin purge (all drives)
- ✅ Native Disk Cleanup integration
- ✅ Icon and thumbnail cache rebuild (fixes broken icons)
- ✅ Windows Font Cache rebuild (fixes garbled text)
- ✅ **Multi-browser cache deep clean** (14 browsers supported)
  - Chromium: Chrome, Edge, Brave, Vivaldi, Opera, Opera GX, Arc, Thorium, Helium
  - Firefox: Mozilla Firefox, LibreWolf, Waterfox, Floorp, Zen
- ✅ DirectX shader cache cleanup
- ✅ Delivery Optimisation peer cache cleanup
- ✅ Windows Store cache reset (with LTSC/Server detection)
- ✅ WinSxS Component Store cleanup (Standard + Deep modes with error handling)
- ✅ Crash dump and Windows Error Reporting cleanup
- ✅ Event log clearing with success/failure tracking
- ✅ Windows.old installation purge (with verification)

### **System Diagnostics & Repair** 🔧
- ✅ CHKDSK volume dirty bit query
- ✅ CHKDSK read-only integrity scan
- ✅ CHKDSK offline repair scheduling
- ✅ Scheduled repair cancellation
- ✅ System File Checker (SFC) with intelligent log parsing
- ✅ DISM Image Health Check (Quick)
- ✅ DISM Deep Image Scan
- ✅ DISM restoration with 3010 reboot-pending handling
- ✅ Phase-based Deep WinSxS reset with safety locks

### **Network Optimisation** 🌐
- ✅ DNS cache display and flush
- ✅ ARP cache display and clear
- ✅ IP address release and renew
- ✅ TCP/IP stack reset with configuration backup
- ✅ Winsock catalog reset with configuration backup

### **System Optimisation** ⚙️
- ✅ SSD TRIM command (all connected drives)
- ✅ HDD defragmentation (with SSD detection)
- ✅ **[NEW]** CompactOS system compression (Enable/Disable with status display)
- ✅ **[NEW]** Hibernation space management (Disable / Reduced / Full modes)
- ✅ **[NEW]** Windows Reserved Storage control (requires Build 18362+)
- ✅ **[NEW]** Shadow Copy storage capping (5GB / 10GB / 15GB / 20GB presets)
- ✅ Top memory consumer analysis
- ✅ System clipboard clear
- ✅ Standby RAM cache flush (with error handling)
- ✅ Active working set flush (forces memory release)

### **Security Suite** 🛡️ **[NEW CATEGORY]**
- ✅ **[NEW]** Microsoft Safety Scanner (MSERT) integration
  - Automated download with 10-day expiration enforcement
  - Architecture-aware (x86/x64 auto-detection)
  - Version validation and management
- ✅ **[NEW]** Windows Firewall reset to factory defaults
  - Automatic rule backup before reset
  - Timestamped `.wfw` export for restoration
- ✅ **[NEW]** Windows Defender Deep Clean
  - Safe Mode automation for ELAM/Tamper Protection bypass
  - Service history and scan log purge
  - Threat signature reset
  - Automatic Safe Mode entry/exit with visual warnings
- ✅ **[NEW]** Force Defender signature update

### **Privacy & Telemetry** 🔒 **[NEW CATEGORY]**
- ✅ **[NEW]** Windows System Telemetry (Enable/Disable)
  - DiagTrack service control
  - Registry policy enforcement
- ✅ **[NEW]** Activity History & Timeline (Enable/Disable)
  - Cloud sync control
  - User activity logging
- ✅ **[NEW]** Error Reporting (WER) (Enable/Disable)
  - Crash report uploads
- ✅ **[NEW]** CEIP Scheduled Tasks (Enable/Disable)
  - Customer Experience Improvement Program
  - Application Experience tasks
- ✅ **[NEW]** Cortana & Web Search (Enable/Disable)
  - Start menu web integration
  - Connected search
- ✅ **[NEW]** App Advertising ID (Enable/Disable)
  - Cross-app tracking prevention

### **User Experience** ✨
- ✅ Automatic update checker (GitHub API integration, 3s timeout)
- ✅ Real-time space reclamation display after each operation
- ✅ Session cumulative space tracking across all operations
- ✅ Session summary on exit (start time, end time, total space freed)
- ✅ Enhanced logging with operation-level detail
- ✅ Intuitive menu-driven interface with visual hierarchy
- ✅ Clear operation status indicators (PROCESS, STATUS, WARNING, ERROR)
- ✅ **[NEW]** CompactOS status display before compression changes
- ✅ **[NEW]** Enhanced visual warnings with box-drawing characters
- ✅ **[NEW]** Build version validation for feature compatibility

---

## 🛡️ Safety Features

| Feature | Description |
|---------|-------------|
| **Admin Enforcement** | Automatic UAC elevation if not running as admin |
| **First-Run EULA** | Mandatory acknowledgment of risks on initial launch |
| **Disk Space Validation** | Prevents operations when <2GB free (prevents corruption) |
| **Cumulative Error Tracking** | Registry hive backups validated against all `reg save` exit codes |
| **Locked File Protection** | Automatically skips in-use files (no forced deletions) |
| **Post-Operation Verification** | Windows.old deletion, Registry backups, and Driver exports all verified |
| **Error-Level Reporting** | Detailed feedback on partial failures (e.g., locked event logs) |
| **Session Logging** | Every action logged with timestamp, category, and severity |
| **Safe Mode Detection** | Displays boot status in header for awareness |
| **Edition-Specific Guards** | Warns when attempting unsupported operations (LTSC, Server) |
| **Service Detection** | Validates service existence before stop/start (DoSvc) |
| **Reboot State Handling** | Gracefully handles DISM 3010 (reboot pending) status codes |
| **Non-blocking Update Checks** | GitHub API queries timeout after 3 seconds |
| **Controlled Timeouts** | 120-second safeguard on hung processes (wsreset.exe) |
| **Build Version Validation** | **[NEW]** Prevents execution of unsupported features on older builds (Reserved Storage) |
| **Automated Backups** | **[NEW]** Firewall rules and network configs backed up before destructive resets |
| **Safe Mode Automation** | **[NEW]** Intelligent BCD management with clear manual override instructions |
| **MSERT Expiration Enforcement** | **[NEW]** 10-day signature validity check with auto-download |

---

## 💻 System Requirements

| Requirement | Specification |
|-------------|---------------|
| **Operating System** | Windows 10 (Build 19041+) or Windows 11 |
| **Edition** | Pro, Enterprise, or Education (Home limited support) |
| **Privileges** | Administrator rights **required** |
| **PowerShell** | Version 5.1 or higher (pre-installed) |
| **Disk Space** | Minimum 2GB free for repair operations |
| **Architecture** | x64 or ARM64 (tested on x64) |
| **Internet** | Optional (update checking, MSERT download, non-blocking) |
| **NTFS Drive** | Required for System Restore and CHKDSK operations |
| **Windows Defender** | Required for Security Suite features (MSERT, signature updates) |

---

### ⚠️ Disclaimer

**Primus is provided "AS-IS" without any warranty, either expressed or implied.** 

While this utility includes numerous safety checks and requires administrative privileges to execute, it performs deep system modifications, including file deletion, network resets, core image adjustments, security policy changes, and privacy setting modifications.

By choosing to run this script, you acknowledge that you are doing so at your own risk. The author (@R4in84) is not responsible for any unexpected data loss, system instability, privacy implications, or critical failures that may result from its use. **Always ensure you have backed up important data and created a System Restore Point (Option A) before running deep maintenance tasks.**

---

## 📥 Installation

### **Option 1: Direct Download** ⬇️
1. Visit the [Releases](https://github.com/R4in84/Primus/releases) page
2. Download `Primus.bat` from the latest release
3. Save to a permanent location (e.g., `C:\Tools\Primus\`)
4. Right-click → **Run as administrator**

### **Option 2: Git Clone** 🔄
```bash
git clone https://github.com/R4in84/Primus.git
cd Primus
# Run the script
.\Primus.bat
