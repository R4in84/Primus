# 📝 Changelog

All notable changes to Primus will be documented in this file.

---

## [1.0.0] - 2026-04-24

### 🎉 Initial Release

A command-line system maintenance utility... for Windows 10/11 with intelligent safety protocols and comprehensive logging.

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

---

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

---

### 📊 Logging System

- **Location**: `C:\ProgramData\Primus\Logs\`
- **Retention**: 30 days (automatic cleanup)
- **Format**: `Primus_YYYYMMDD_HHMMSS.log`
- **Categories**: SYSTEM, MAINTENANCE, NETWORK, REPAIR
- **Fallback**: `%TEMP%\Primus_Logs\` if ProgramData is inaccessible

---

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

## [Unreleased]

### 🚀 Planned Features
- 🔄 Automatic update checker (GitHub Releases API)
- 🌍 Extended browser support 

---

## Legend

| Icon | Meaning |
|------|---------|
| 🎉 | Major Release |
| ✨ | New Feature |
| 🐛 | Bug Fix |
| 🔒 | Security Update |
| 📚 | Documentation |
| ⚡ | Performance Improvement |
| 🗑️ | Deprecated |
| 💥 | Breaking Change |

> **Note**: Future releases will use these icons to categorize changes.

---

**Project**: [Primus](https://github.com/R4in84/Primus)  
**Author**: Chris Martin ([@R4in84](https://github.com/R4in84))  
**License**: [MIT](LICENSE)