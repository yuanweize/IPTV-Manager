# Project Structure / 项目结构

This document describes the structure and organization of the IPTV Manager project.

本文档描述了IPTV Manager项目的结构和组织。

## 📁 File Structure / 文件结构

```
IPTV-Manager/
├── 📄 README.md                    # 中文说明文档
├── 📄 README_EN.md                 # English documentation
├── 📄 LICENSE                      # MIT license
├── 📄 CHANGELOG.md                 # Version history
├── 📄 CONTRIBUTING.md              # Contribution guidelines
├── 📄 PROJECT_STRUCTURE.md         # This file
├── 📄 .gitignore                   # Git ignore rules
│
├── 🐍 iptv_manager.py              # Main application script
├── 🐍 languages.py                 # Multi-language support
├── 🐍 test_installation.py         # Installation test script
│
├── ⚙️ config.json                  # Configuration file
├── 📋 requirements.txt             # Python dependencies
│
└── 🔧 install.sh                   # Installation script
```

## 📋 Core Components / 核心组件

### 🐍 Python Scripts / Python脚本

#### `iptv_manager.py`
- **Purpose**: Main application logic / 主应用程序逻辑
- **Features**: 
  - Multi-source concurrent downloads / 多源并发下载
  - Configuration management / 配置管理
  - Interactive menu system / 交互式菜单系统
  - Logging and error handling / 日志记录和错误处理
  - File backup and cleanup / 文件备份和清理

#### `languages.py`
- **Purpose**: Multi-language support / 多语言支持
- **Features**:
  - Chinese and English language packs / 中英文语言包
  - Dynamic language switching / 动态语言切换
  - Centralized text management / 集中化文本管理

#### `test_installation.py`
- **Purpose**: Installation verification / 安装验证
- **Features**:
  - Dependency checking / 依赖检查
  - Configuration validation / 配置验证
  - Functionality testing / 功能测试

### ⚙️ Configuration / 配置文件

#### `config.json`
- **Purpose**: Application configuration / 应用程序配置
- **Sections**:
  - `language`: Interface language / 界面语言
  - `sources`: IPTV source definitions / IPTV源定义
  - `directories`: Path configurations / 路径配置
  - `download`: Download settings / 下载设置
  - `maintenance`: Cleanup settings / 清理设置
  - `logging`: Log configuration / 日志配置

#### `requirements.txt`
- **Purpose**: Python dependencies / Python依赖
- **Dependencies**:
  - `requests`: HTTP client library / HTTP客户端库
  - `chardet`: Character encoding detection / 字符编码检测

### 🔧 Installation / 安装脚本

#### `install.sh`
- **Purpose**: Automated installation / 自动化安装
- **Features**:
  - Interactive configuration / 交互式配置
  - Language selection / 语言选择
  - Dependency installation / 依赖安装
  - Directory setup / 目录设置
  - Symlink creation / 软链接创建
  - Cron job setup / 定时任务设置

## 🏗️ Architecture / 架构设计

### Class Structure / 类结构

```
IPTVManager (Main Controller)
├── IPTVConfig (Configuration Management)
├── IPTVLogger (Logging System)
├── IPTVDownloader (Download Engine)
└── IPTVMaintenance (Cleanup & Reports)
```

#### `IPTVConfig`
- Configuration file loading and validation / 配置文件加载和验证
- Multi-language source name resolution / 多语言源名称解析
- Settings management / 设置管理

#### `IPTVLogger`
- Log file management / 日志文件管理
- Automatic log rotation / 自动日志轮转
- Old log cleanup / 旧日志清理

#### `IPTVDownloader`
- Concurrent download processing / 并发下载处理
- Encoding detection and conversion / 编码检测和转换
- File validation and backup / 文件验证和备份
- Retry mechanism / 重试机制

#### `IPTVMaintenance`
- Backup file cleanup / 备份文件清理
- Status report generation / 状态报告生成
- System maintenance tasks / 系统维护任务

### Data Flow / 数据流

```
1. Configuration Loading / 配置加载
   config.json → IPTVConfig → Language Setup

2. Download Process / 下载流程
   Source URLs → IPTVDownloader → Concurrent Processing → File Validation → Backup → Save

3. Maintenance / 维护
   Old Files → IPTVMaintenance → Cleanup → Status Report

4. User Interface / 用户界面
   User Input → Interactive Menu → Function Execution → Result Display
```

## 🌐 Multi-language Support / 多语言支持

### Language Files / 语言文件

The `languages.py` file contains language packs for:
- **Chinese (zh)**: Default language / 默认语言
- **English (en)**: Alternative language / 备选语言

### Text Keys / 文本键

Text keys are organized by category:
- `menu_*`: Menu items / 菜单项
- `download_*`: Download related / 下载相关
- `config_*`: Configuration related / 配置相关
- `error_*`: Error messages / 错误消息
- `status_*`: Status information / 状态信息

### Usage / 使用方法

```python
from languages import get_text, set_language

# Set language / 设置语言
set_language('en')  # or 'zh'

# Get translated text / 获取翻译文本
title = get_text('menu_title')
```

## 📦 Installation Process / 安装流程

### Installation Steps / 安装步骤

1. **System Check** / 系统检查
   - OS compatibility / 操作系统兼容性
   - User permissions / 用户权限

2. **Language Selection** / 语言选择
   - Interactive prompt / 交互式提示
   - Environment variable support / 环境变量支持

3. **Configuration** / 配置
   - Installation path / 安装路径
   - Data directory / 数据目录
   - Post-installation actions / 安装后操作

4. **Dependencies** / 依赖安装
   - System packages / 系统包
   - Python packages / Python包

5. **File Installation** / 文件安装
   - Script copying / 脚本复制
   - Configuration setup / 配置设置
   - Permission setting / 权限设置

6. **System Integration** / 系统集成
   - Symlink creation / 软链接创建
   - Cron job setup / 定时任务设置

7. **Testing** / 测试
   - Installation verification / 安装验证
   - Initial download / 初始下载

## 🔄 Runtime Directories / 运行时目录

### Default Structure / 默认结构

```
/opt/IPTV-Manager/              # Installation directory / 安装目录
├── iptv_manager.py             # Main script / 主脚本
├── languages.py                # Language support / 语言支持
├── config.json                 # Configuration / 配置文件
├── requirements.txt            # Dependencies / 依赖文件
├── test_installation.py        # Test script / 测试脚本
├── data/                       # Live source files / 直播源文件
│   ├── domestic.m3u
│   └── international.m3u
├── backup/                     # Backup files / 备份文件
│   ├── domestic_20240203_120000.m3u
│   └── international_20240203_120000.m3u
└── logs/                       # Log files / 日志文件
    ├── iptv_manager_20240203.log
    └── status_report_20240203_120000.txt
```

### Custom Data Directory / 自定义数据目录

When using a custom data directory (e.g., `/media/iptv`):

```
/opt/IPTV-Manager/              # Installation directory / 安装目录
├── [program files]             # Program files / 程序文件
├── backup/                     # Backup files / 备份文件
└── logs/                       # Log files / 日志文件

/media/iptv/                    # Custom data directory / 自定义数据目录
├── domestic.m3u                # Live source files / 直播源文件
└── international.m3u
```

## 🔧 Configuration Management / 配置管理

### Configuration Hierarchy / 配置层次

1. **Default Configuration** / 默认配置
   - Built into the application / 内置于应用程序
   - Provides fallback values / 提供回退值

2. **User Configuration** / 用户配置
   - Loaded from `config.json` / 从config.json加载
   - Overrides default values / 覆盖默认值

3. **Runtime Configuration** / 运行时配置
   - Command line arguments / 命令行参数
   - Environment variables / 环境变量

### Configuration Validation / 配置验证

The system validates:
- Required keys presence / 必需键的存在
- Path validity / 路径有效性
- Value ranges / 值范围
- File permissions / 文件权限

## 📊 Monitoring and Logging / 监控和日志

### Log Types / 日志类型

1. **Application Logs** / 应用程序日志
   - Daily rotation / 每日轮转
   - Configurable levels / 可配置级别
   - UTF-8 encoding / UTF-8编码

2. **Status Reports** / 状态报告
   - Download statistics / 下载统计
   - File information / 文件信息
   - Error summaries / 错误摘要

3. **Cron Logs** / 定时任务日志
   - Scheduled execution logs / 计划执行日志
   - Error capture / 错误捕获

### Cleanup Strategy / 清理策略

- **Log Retention** / 日志保留: 30 days default / 默认30天
- **Backup Retention** / 备份保留: 7 days default / 默认7天
- **Automatic Cleanup** / 自动清理: Configurable / 可配置

---

This structure provides a scalable and maintainable foundation for the IPTV Manager project, supporting both current functionality and future enhancements.

这种结构为IPTV Manager项目提供了可扩展和可维护的基础，支持当前功能和未来的增强。