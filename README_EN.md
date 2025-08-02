<div align="center">

# 🎬 IPTV Manager

*High-Performance IPTV Live Source Management Tool*

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.6+-green.svg)](https://python.org)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![GitHub stars](https://img.shields.io/github/stars/yuanweize/IPTV-Manager.svg?style=social)](https://github.com/yuanweize/IPTV-Manager/stargazers)

English | [简体中文](README.md)

</div>

---

## 📖 Project Overview

A high-performance IPTV live source automatic download and management script designed specifically for Debian/Ubuntu server environments. Features multi-source concurrent downloads, automatic updates, configuration management, and comprehensive maintenance functions.

## 🚀 Quick Installation

### Method 1: Interactive Installation (Recommended)

Download and run the installation script with customizable configuration options:

```bash
wget https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
```

### Method 2: One-Click Installation

Install with default configuration:

```bash
curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash
```

### Method 3: Custom Installation

Use environment variables for custom configuration:

```bash
# Custom installation and data directories
CUSTOM_INSTALL_DIR=/home/user/iptv CUSTOM_DATA_DIR=/media/iptv bash install.sh

# Fully non-interactive installation
SKIP_INTERACTIVE=true CUSTOM_INSTALL_DIR=/opt/iptv bash install.sh
```

## ✨ Features

### Core Features
- 🚀 **Multi-source Concurrent Downloads**: Download multiple IPTV sources simultaneously for improved efficiency
- ⚙️ **Configuration Management**: All parameters managed through JSON configuration files
- 🔄 **Automatic Retry Mechanism**: Automatic retry on network failures to ensure download success
- 📝 **Complete Logging**: Detailed operation logs for easy troubleshooting
- 🗂️ **File Version Control**: Automatic backup of historical versions with rollback support
- 🧹 **Automatic Cleanup**: Regular cleanup of expired files to keep system tidy

### Advanced Features
- 🌐 **Automatic Encoding Detection**: Smart detection of M3U file encoding for compatibility
- 🔒 **Permission Management**: Automatic setting of correct file and directory permissions
- 📊 **Status Reports**: Generate detailed execution status reports
- ⏰ **Cron Compatible**: Perfect support for crontab scheduled execution
- 🛡️ **Exception Handling**: Comprehensive error handling for system stability

## 📋 System Requirements

- **Operating System**: Debian/Ubuntu Linux
- **Python Version**: Python 3.6+
- **Dependencies**: requests, chardet

## 🛠️ Installation Options

### Interactive Installation Options

During installation, you'll be prompted for the following configurations:

1. **Root User Check**:
   ```
   [WARN] Root user detected, recommend using regular user
   Continue? (y/N):
   ```

2. **Installation Path Selection**:
   ```
   Please select installation path:
   1) Use default path: /opt/IPTV-Manager
   2) Custom path
   Enter option (default: 1) >
   ```

3. **Data Directory Selection**:
   ```
   Please select live source file storage directory:
   1) Use default directory: /opt/IPTV-Manager/data
   2) Custom directory (recommended for large storage)
   Enter option (default: 1) >
   ```

4. **Post-Installation Actions**:
   ```
   Run immediately after installation (Y/n):
   Y) Download live sources immediately (recommended)
   n) Complete installation only, run manually later
   Enter option (default: Y) >
   ```

### Environment Variables

Supported environment variables for non-interactive configuration:

| Environment Variable | Description | Default Value |
| -------------------- | ----------- | ------------- |
| `SKIP_INTERACTIVE` | Skip interactive mode | `false` |
| `CUSTOM_INSTALL_DIR` | Custom installation directory | `/opt/IPTV-Manager` |
| `CUSTOM_DATA_DIR` | Custom data directory | `{install_dir}/data` |
| `AUTO_RUN` | Auto-run after installation | `Y` |
| `CREATE_SYMLINK` | Create global command symlink | `Y` |

## 📁 Directory Structure

### Default Directory Structure

```
/opt/IPTV-Manager/           # Installation directory
├── iptv_manager.py          # Main script file
├── config.json              # Configuration file
├── requirements.txt         # Python dependencies
├── data/                    # Live source data directory
│   ├── domestic.m3u         # Domestic sources
│   └── international.m3u    # International sources
├── backup/                  # Backup directory
│   ├── domestic_20240102_143022.m3u
│   └── international_20240102_143022.m3u
└── logs/                    # Log directory
    ├── iptv_manager_20240102.log
    └── status_report_20240102_143022.txt
```

## 🎯 Usage

### Basic Usage

#### Method 1: Using Global Command (Recommended)

If symlink was created during installation:

```bash
# Enter interactive menu (recommended)
iptv

# Direct download (for scripts and cron jobs)
iptv --download

# View status
iptv --status

# View help
iptv --help
```

#### Method 2: Using Full Path

```bash
# Navigate to installation directory (default: /opt/IPTV-Manager)
cd /opt/IPTV-Manager

# Enter interactive menu
python3 iptv_manager.py

# Direct download
python3 iptv_manager.py --download
```

### Interactive Menu

Running `iptv` command enters the friendly interactive menu:

```
============================================================
    IPTV Live Source Management System
============================================================
Please select operation:

1. [Download] Download/update live sources
2. [Status] View system status
3. [List] View live source list
4. [Config] Configuration management
5. [Logs] View logs
6. [Cleanup] Cleanup maintenance
7. [Uninstall] Uninstall program
0. [Exit] Exit program

============================================================
Enter option (0-7):
```

### Scheduled Tasks

Set up scheduled execution using crontab:

```bash
# Edit crontab
crontab -e

# Using global command (recommended)
0 */6 * * * iptv --download >> /opt/IPTV-Manager/logs/cron.log 2>&1

# Or using full path
0 */6 * * * cd /opt/IPTV-Manager && python3 iptv_manager.py --download >> /opt/IPTV-Manager/logs/cron.log 2>&1
```

## ⚙️ Configuration

### Configuration File

The `config.json` file contains the following main sections:

#### Live Source Configuration (sources)
```json
{
  "sources": {
    "domestic": {
      "name": "Domestic Source",
      "url": "https://live.hacks.tools/tv/iptv4.m3u",
      "filename": "domestic.m3u",
      "enabled": true
    }
  }
}
```

#### Directory Configuration (directories)
```json
{
  "directories": {
    "base_dir": "/opt/IPTV-Manager",
    "data_dir": "/opt/IPTV-Manager/data",
    "backup_dir": "/opt/IPTV-Manager/backup",
    "log_dir": "/opt/IPTV-Manager/logs"
  }
}
```

#### Download Configuration (download)
```json
{
  "download": {
    "timeout": 30,
    "retry_count": 3,
    "retry_delay": 5,
    "max_workers": 4,
    "user_agent": "IPTV-Manager/1.0"
  }
}
```

## 🔧 Troubleshooting

### Common Issues

1. **pip Installation Failed**
   ```bash
   # Install missing packages
   sudo apt install -y python3-distutils python3-setuptools python3-dev
   
   # Use python -m pip to install dependencies
   python3 -m pip install requests chardet --user
   ```

2. **Permission Errors**
   ```bash
   sudo chown -R $USER:$USER /opt/IPTV-Manager
   chmod +x /opt/IPTV-Manager/iptv_manager.py
   ```

3. **Network Timeout**
   - Increase `download.timeout` value
   - Check network connection and firewall settings

4. **Encoding Issues**
   - Script automatically detects encoding; check source file format if issues persist

## 📊 Performance Optimization

### Concurrency Settings
Adjust concurrency based on server performance:
```json
{
  "download": {
    "max_workers": 4  // Adjust based on CPU cores
  }
}
```

### Cleanup Strategy
```json
{
  "maintenance": {
    "backup_retention_days": 7,   // Backup retention days
    "log_retention_days": 30,     // Log retention days
    "enable_cleanup": true        // Enable automatic cleanup
  }
}
```

## 🔒 Security Recommendations

1. **File Permissions**: Ensure script and configuration file permissions are set correctly
2. **Network Security**: Use HTTPS sources, avoid insecure HTTP connections
3. **Regular Updates**: Regularly update Python dependency libraries
4. **Log Monitoring**: Regularly check log files for anomalies

## 📝 Version Information

- **Version**: 1.0.3
- **Environment**: Debian/Ubuntu servers
- **Python Requirement**: 3.6+

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Thanks to all contributors who have helped improve this project
- Special thanks to the open-source community for their valuable feedback

---

**Note**: Please ensure compliance with relevant laws and regulations, and use only for legal IPTV content access.