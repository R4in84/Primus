# 🛠️ Primus - System Utility

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4?logo=windows)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.1-success)](https://github.com/R4in84/Primus/releases)
[![Batch Script](https://img.shields.io/badge/Language-Batch-4EAA25?logo=windowsterminal)](https://en.wikipedia.org/wiki/Batch_file)

> Primus is a comprehensive command-line system maintenance utility for Windows 10/11 designed to consolidate common system maintenance, cleanup, repair, and optimization tasks into a single, easy-to-use interface with intelligent safety protocols, error verification, and comprehensive logging.

> It utilizes native Windows tools (such as SFC, DISM, CHKDSK, and PowerShell WMI) to help maintain system health, diagnose file system issues, and resolve common operating system or network problems.

![Primus Main Menu](Media/Main.png)

---

## ⚡ Features

### **System Recovery** 🔄
- ✅ Create manual System Restore Points with VSS
- ✅ Intelligent Shadow Copy cleanup (preserves most recent)
- ✅ **[NEW]** Bare-metal Registry hive backup (SYSTEM, SOFTWARE, SAM, SECURITY, DEFAULT)
- ✅ **[NEW]** Emergency Registry restore script generation
- ✅ **[NEW]** 3rd-party driver backup via DISM export
- ✅ Automatic disk space validation before operations

### **System Maintenance** 🧹
- ✅ Deep cleanup of temporary files (User + System)
- ✅ Prefetch cache optimization
- ✅ Windows Update download cache reset
- ✅ Thumbnail database regeneration
- ✅ Recycle Bin purge (all drives)
- ✅ Native Disk Cleanup integration
- ✅ Icon and thumbnail cache rebuild (fixes broken icons)
- ✅ **[NEW]** Windows Font Cache rebuild (fixes garbled text)
- ✅ **Multi-browser cache deep clean** (14 browsers supported)
  - Chromium: Chrome, Edge, Brave, Vivaldi, Opera, Opera GX, Arc, Thorium, Helium
  - Firefox: Mozilla Firefox, LibreWolf, Waterfox, Floorp, Zen
- ✅ **[NEW]** DirectX shader cache cleanup
- ✅ **[NEW]** Delivery Optimization peer cache cleanup
- ✅ Windows Store cache reset (with LTSC/Server detection)
- ✅ WinSxS Component Store cleanup (Standard + Deep modes with error handling)
- ✅ Crash dump and Windows Error Reporting cleanup
- ✅ **[NEW]** Event log clearing with success/failure tracking
- ✅ **[NEW]** Windows.old installation purge (with verification)

### **System Diagnostics & Repair** 🔧
- ✅ **[NEW]** CHKDSK volume dirty bit query
- ✅ **[NEW]** CHKDSK read-only integrity scan
- ✅ **[NEW]** CHKDSK offline repair scheduling
- ✅ **[NEW]** Scheduled repair cancellation
- ✅ System File Checker (SFC) with intelligent log parsing
- ✅ DISM Image Health Check (Quick)
- ✅ DISM Deep Image Scan
- ✅ **[NEW]** DISM restoration with 3010 reboot-pending handling
- ✅ **[NEW]** Phase-based Deep WinSxS reset with safety locks

### **Network Optimization** 🌐
- ✅ DNS cache display and flush
- ✅ ARP cache display and clear
- ✅ IP address release and renew
- ✅ **[NEW]** TCP/IP stack reset with configuration backup
- ✅ **[NEW]** Winsock catalog reset with configuration backup

### **System Optimization** ⚙️
- ✅ **[NEW]** SSD TRIM command (all connected drives)
- ✅ **[NEW]** HDD defragmentation (with SSD detection)
- ✅ **[NEW]** Top memory consumer analysis
- ✅ **[NEW]** System clipboard clear
- ✅ **[NEW]** Standby RAM cache flush (with error handling)
- ✅ **[NEW]** Active working set flush (forces memory release)

### **User Experience** ✨
- ✅ Automatic update checker (GitHub API integration, 3s timeout)
- ✅ Real-time space reclamation display after each operation
- ✅ Session cumulative space tracking across all operations
- ✅ Session summary on exit (start time, end time, total space freed)
- ✅ Enhanced logging with operation-level detail
- ✅ Intuitive menu-driven interface with visual hierarchy
- ✅ Clear operation status indicators (PROCESS, STATUS, WARNING, ERROR)

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
| **Internet** | Optional (update checking only, non-blocking) |
| **NTFS Drive** | Required for System Restore and CHKDSK operations |

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
Primus.bat
