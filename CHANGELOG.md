# 📝 Changelog

All notable changes to Primus will be documented in this file.

## [1.2.1] - 2026-05-14

### ✨ New Features

**Memory Analysis Update**
- ✅ Updated the memory usage module to group processes by application.
- ✅ Consolidates multi-process apps (e.g., Firefox, Discord) into single entries.
- ✅ Added an "Instances" count to show active child process totals.
- ✅ Standardized column alignment for better readability in the console.
- ✅ Implemented name truncation to keep the UI within window boundaries.

**Multi-Browser Cleanup**
- ✅ Re-coded the browser cleanup engine using dynamic loops.
- ✅ Automatically detects active profiles to prevent unnecessary commands.
- ✅ Supports 14 different Chromium, Firefox, and Opera variants.

### 🔧 Updates & Refinements

**Menu & Workflow Reorganization**
- 🔧 Reorganized maintenance tasks into more logical categories:
  - **General Cleanup**: Routine tasks (now includes Error Reports & Dumps).
  - **Deep System Cleanup**: Interactive tasks (now includes Disk Cleanup).
- 🔧 Re-ordered script subroutines to match the UI flow for easier maintenance.

**UI Layout & Logic**
- 🔧 Improved header rendering to handle special characters like ampersands (`^&`).
- 🔧 Recalibrated margins (%M0% / %M1%) for consistent vertical symmetry.
- 🔧 Simplified complex PowerShell modules into shorter, more efficient execution strings.
- 🔧 Added a detection tag for Windows Insider / Dev Builds.

---

## [1.2.0] - 2026-05-08

### ✨ New Features

**Security Tools** 🛡️ **(NEW)**
- ✅ Microsoft Safety Scanner (MSERT) integration.
  - Automated download with architecture detection (x86/x64).
  - 10-day expiration check with automatic re-download.
- ✅ Reset Windows Firewall to default settings.
  - Automatically saves current rules to timestamped `.wfw` files.
  - Safety check stops the reset if the backup fails.
- ✅ Windows Defender History Cleanup.
  - Automated Safe Mode transitions to bypass file protections.
  - Clears service history, scan logs, and threat signatures.
- ✅ Force Windows Defender signature updates.

**Privacy & Telemetry Tools** 🔒 **(NEW)**
- ✅ Toggle Windows System Telemetry (DiagTrack and dmwappushservice).
- ✅ Toggle Activity History, Timeline, and Cloud Sync.
- ✅ Toggle Error Reporting (WER) and crash report uploads.
- ✅ Toggle CEIP and Application Experience scheduled tasks.
- ✅ Toggle Cortana web results and Bing Search integration.
- ✅ Toggle App Advertising ID and cross-app tracking.

**Storage Options**
- ✅ CompactOS system compression (Enable/Disable).
- ✅ Manage Hibernation file size (Disable / Reduced / Full).
- ✅ Toggle Windows Reserved Storage (for supported builds).
- ✅ Set Shadow Copy storage limits (5GB to 20GB).

### 🔧 Updates & Refinements

**System Awareness**
- 🔧 Added build version checks to prevent running unsupported features.
- 🔧 Automated configuration snapshots for Firewall and Network settings.
- 🔧 Integrated all storage tasks with the session space tracker.

**Visuals & Logic**
- 🔧 Used box-drawing characters for critical warnings.
- 🔧 Displays current compression state before the CompactOS menu.
- 🔧 Improved service management to ensure dependencies are handled correctly.

---

## [1.1.0] - 2026-05-05

### ✨ New Features

**System Diagnostics & Repair**
- ✅ Query volume dirty bits to check for file system errors.
- ✅ Read-only integrity scans for non-destructive analysis.
- ✅ Schedule and cancel offline repairs.
- ✅ Structured WinSxS reset process with built-in safety locks.

**System Optimization**
- ✅ SSD TRIM and HDD defragmentation (with drive type detection).
- ✅ Memory analysis for top 10 processes.
- ✅ Clear system clipboard and flush standby RAM cache.

**Maintenance & Recovery**
- ✅ Registry hive backups (SYSTEM, SOFTWARE, SAM, etc.).
- ✅ Generates a straightforward emergency Registry restore script.
- ✅ Driver backups via DISM export.
- ✅ Rebuild Windows Font Cache and DirectX shader cache.
- ✅ Purge Windows.old with post-deletion verification.

---

## [1.0.1] - 2026-04-28

### ✨ New Features

**Update & Space Tracking**
- ✅ Automated update check via GitHub API on startup.
- ✅ Displays reclaimed space after cleanup tasks.
- ✅ Tracks total session space with a summary on exit.

**Extended Browser Support**
- ✅ Added support for Thorium, Helium, Floorp, and Zen browsers.

---

## [1.0.0] - 2026-04-15

### 🎉 Initial Release
A personal collection of scripts for Windows 10/11 maintenance with built-in safety checks and logging.

### ✨ What's Included

#### **💾 System Recovery**
- ✅ Create manual System Restore Points.
- ✅ Standard Shadow Copy cleanup (keeps the most recent).
- ✅ Automated disk space checks before operations.

#### **🧹 System Maintenance**
- ✅ Cleanup of temporary files, Prefetch, and Update caches.
- ✅ Thumbnail, icon, and font cache regeneration.
- ✅ Recycle Bin purge and native Disk Cleanup integration.
- ✅ Multi-browser cache cleanup for all supported browsers.
- ✅ WinSxS store cleanup and Store cache reset.
- ✅ Clear crash dumps and system event logs.

#### **🌐 Network Tools**
- ✅ DNS and ARP cache management.
- ✅ IP address release and renew.
- ✅ TCP/IP stack and Winsock resets.

#### **🔧 System Repair**
- ✅ System File Checker (SFC) and DISM health tools.

---

## Legend

| Icon | Meaning |
|------|---------|
| 🎉 | Major Release |
| ✨ | New Feature |
| 🐛 | Bug Fix |
| 🔧 | Update / Refinement |
| 🔒 | Privacy Update |
| 🛡️ | Safety Check |

---

**Project**: [Primus](https://github.com/R4in84/Primus)  
**Author**: Chris Martin ([@R4in84](https://github.com/R4in84))  
**License**: [MIT](LICENSE)
