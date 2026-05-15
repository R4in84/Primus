# 🛠️ Primus - System Utility

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-0078D4?logo=windows)](https://www.microsoft.com/windows)
[![Version](https://img.shields.io/badge/Version-1.2.1-success)](https://github.com/R4in84/Primus/releases)

> Primus is a collection of scripts I use to maintain, clean, and optimize Windows 10/11. It consolidates various system tasks into a single interface with built-in safety checks and logging.

> It uses native Windows tools (SFC, DISM, CHKDSK, and PowerShell) to help with system health, file system issues, and privacy settings.

![Primus Main Menu](Media/Main.png)

---

## ⚡ Features

### **System Recovery** 🔄
- Create manual System Restore Points
- Basic Shadow Copy cleanup (keeps the most recent)
- Registry hive backups (SYSTEM, SOFTWARE, SAM, etc.)
- Emergency Registry restore script generation
- Driver backups via DISM export
- Checks for disk space before running tasks

### **System Maintenance** 🧹
- Organized sub-menus for General and Deep cleanup tasks
- Clean up temporary files (User + System)
- Reset Windows Update download cache
- Clear crash dumps and error reports
- Rebuild icon and font caches (fixes visual glitches)
- Browser cleanup (supports Chromium, Firefox, and Opera variants)
- Reset Windows Store cache
- WinSxS Component Store cleanup (Standard + Deep modes)
- Clear system event logs

### **System Diagnostics & Repair** 🔧
- Query volume dirty bits
- Read-only integrity scans
- Schedule and cancel offline repairs
- System File Checker (SFC) with basic log parsing
- DISM health checks and image scans
- DISM image repair with reboot-pending detection

### **Network Tools** 🌐
- Display and flush DNS/ARP caches
- Release and renew IP addresses
- Reset TCP/IP stack and Winsock (includes config backups)

### **System Optimization** ⚙️
- SSD TRIM and HDD defragmentation
- CompactOS system compression (Enable/Disable)
- Manage Hibernation file size (Disable / Reduced / Full)
- Toggle Windows Reserved Storage (Build 18362+)
- Shadow Copy storage limits (5GB to 20GB)
- Basic memory usage analysis (grouped by application)
- Clear clipboard and flush standby RAM cache

### **Security & Privacy** 🛡️
- Microsoft Safety Scanner (MSERT) integration
- Reset Windows Firewall to default settings (includes rule backup)
- Windows Defender history and scan log cleanup (requires Safe Mode)
- Force Defender signature updates
- Toggle System Telemetry and Activity History
- Disable Cortana web search and App Advertising ID
- Manage CEIP and Error Reporting tasks

### **User Experience** ✨
- Detection for Windows Insider / Dev Builds
- Consistent UI alignment using variable expansion
- Basic update checker via GitHub API
- Displays reclaimed space after cleanup tasks
- Session summary showing total space freed and duration
- Straightforward logging for all operations

---

## 🛡️ Safety Checks

| Feature | Description |
|---------|-------------|
| **Admin Check** | Automatically requests elevation if not running as admin |
| **First-Run EULA** | Requires acknowledgment of risks on first launch |
| **Space Validation** | Skips heavy operations if <2GB free to prevent errors |
| **Backup Scripts** | Automatically backs up Registry, Firewall, and Network configs |
| **Locked Files** | Bypasses in-use files without forced deletion |
| **Safe Mode Support** | Identifies boot status and handles Safe Mode transitions for Defender tasks |
| **Build Awareness** | Checks build versions to prevent running unsupported features |

---

## 💻 System Requirements

| Requirement | Specification |
|-------------|---------------|
| **Operating System** | Windows 10 (Build 19041+) or Windows 11 |
| **Edition** | Pro, Enterprise, or Education (Home has limited support) |
| **Privileges** | Administrator rights required |
| **Disk Space** | Minimum 2GB free for repair tasks |

---

### ⚠️ Disclaimer

**Primus is provided "AS-IS" without any warranty.** While I've included safety checks, this utility performs modifications to system files, network settings, and security policies. 

By using this script, you acknowledge you are doing so at your own risk. I am not responsible for any data loss or system instability. **Always create a Restore Point (Option A) before running deep maintenance tasks.**

---

## 📥 Installation

1. Download `Primus.bat` from the [Releases](https://github.com/R4in84/Primus/releases) page.
2. Save it to a folder of your choice.
3. Right-click and **Run as administrator**.
