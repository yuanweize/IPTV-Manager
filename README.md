<div align="center">

# IPTV Manager

*高性能IPTV直播源管理工具*

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.6+-green.svg)](https://python.org)
[![Platform](https://img.shields.io/badge/platform-Linux-lightgrey.svg)](https://www.linux.org/)
[![GitHub stars](https://img.shields.io/github/stars/yuanweize/IPTV-Manager.svg?style=social)](https://github.com/yuanweize/IPTV-Manager/stargazers)

[English](README_EN.md) | 简体中文

</div>

---

## 项目简介

一个专为Debian/Ubuntu服务器环境设计的高性能IPTV直播源自动下载和管理脚本，支持多源并发下载、自动更新、配置化管理和完整的维护功能。

📚 **相关文档**：
- [更新日志](CHANGELOG.md) - 查看项目的版本历史和变更记录。
- [贡献指南](CONTRIBUTING.md) - 了解如何为项目贡献代码或报告问题。
- [项目结构](PROJECT_STRUCTURE.md) - 了解项目的目录结构和设计理念。

## 一键安装

### 方法1: 交互式安装（推荐）

下载安装脚本后运行，可以自定义所有配置选项：

```bash
wget -O install.sh https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
```

### 方法2: 快速安装

使用默认配置一键安装：

```bash
curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash
```

### 方法3: 自定义安装

使用环境变量指定自定义配置：

```bash
# 自定义安装目录和数据目录
CUSTOM_INSTALL_DIR=/home/user/iptv CUSTOM_DATA_DIR=/media/iptv bash install.sh

# 完全非交互式安装
SKIP_INTERACTIVE=true CUSTOM_INSTALL_DIR=/opt/iptv bash install.sh
```

### 安装选项详解

#### 交互式安装选项

安装过程中会依次询问以下配置，每个选项都有清晰的提示：

1. **Root用户检查**：
   ```
   [WARN] 检测到root用户，建议使用普通用户运行此脚本
   是否继续? (y/N):
   ```

2. **安装路径选择**：
   ```
   请选择安装路径:
   1) 使用默认路径: /opt/IPTV-Manager
   2) 自定义路径
   输入选项回车默认: 1 >
   ```

3. **数据目录选择**：
   ```
   请选择直播源文件保存目录:
   1) 使用默认目录: /opt/IPTV-Manager/data
   2) 自定义目录 (推荐用于大容量存储)
   输入选项回车默认: 1 >
   ```

4. **安装后操作**：
   ```
   安装完成后立即运行(Y/n):
   Y) 立即下载直播源 (推荐，验证安装是否成功)
   n) 仅完成安装，稍后手动运行
   输入选项回车默认: Y >
   ```

5. **全局命令软连接**：
   ```
   是否创建全局命令软连接?(Y/n):
   ```

6. **定时任务设置**：
   ```
   请选择定时任务频率:
   1) 每6小时执行一次 (推荐)
   2) 每天凌晨2点执行
   3) 每小时执行一次
   4) 跳过定时任务设置
   输入选择回车默认: 1 >
   ```

7. **配置确认**：
   ```
   确认以上配置并开始安装? (Y/n):
   ```

#### 环境变量配置

支持以下环境变量进行非交互式配置：

| 环境变量             | 说明               | 默认值              |
| -------------------- | ------------------ | ------------------- |
| `SKIP_INTERACTIVE`   | 跳过交互模式       | `false`             |
| `INSTALL_LANGUAGE`   | 界面语言           | `zh` (中文)         |
| `CUSTOM_INSTALL_DIR` | 自定义安装目录     | `/opt/IPTV-Manager` |
| `CUSTOM_DATA_DIR`    | 自定义数据目录     | `{安装目录}/data`   |
| `AUTO_RUN`           | 安装后自动运行     | `Y`                 |
| `CREATE_SYMLINK`     | 创建全局命令软连接 | `Y`                 |

#### 使用示例

```bash
# 查看安装帮助
bash install.sh --help

# 安装到用户目录，数据保存到外部磁盘
CUSTOM_INSTALL_DIR=$HOME/iptv-manager \
CUSTOM_DATA_DIR=/mnt/storage/iptv \
bash install.sh

# 服务器自动化部署
SKIP_INTERACTIVE=true \
CUSTOM_INSTALL_DIR=/opt/iptv \
AUTO_RUN=n \
CREATE_SYMLINK=n \
bash install.sh

# 创建软连接但不自动运行
CUSTOM_INSTALL_DIR=/home/user/iptv \
AUTO_RUN=n \
bash install.sh
```

### 安装后的目录结构

```
{安装目录}/
├── iptv_manager.py          # 主脚本文件
├── config.json              # 配置文件
├── backup/                  # 备份目录
├── logs/                    # 日志目录
└── requirements.txt         # Python依赖

{数据目录}/                   # 直播源文件目录（可独立配置）
├── domestic.m3u             # 国内源文件
└── international.m3u        # 国际源文件
```

> 💡 **目录说明**：
> - 安装目录包含程序文件、配置和日志
> - 数据目录可以独立配置，便于使用大容量存储
> - `/opt` 目录是Linux系统存放第三方软件的标准位置

## 功能特性

### 核心功能
- **多源并发下载**: 支持同时下载多个IPTV直播源，提高效率
- **配置化管理**: 所有参数通过JSON配置文件管理，易于维护
- **自动重试机制**: 网络失败时自动重试，确保下载成功率
- **完整日志记录**: 详细的运行日志，便于问题排查
- **文件版本控制**: 自动备份历史版本，支持回滚
- **自动清理维护**: 定期清理过期文件，保持系统整洁

### 高级特性
- **编码自动检测**: 智能检测M3U文件编码，确保兼容性
- **权限管理**: 自动设置正确的文件和目录权限
- **状态报告**: 生成详细的执行状态报告
- **定时任务兼容**: 完美支持crontab定时执行
- **异常处理**: 完善的错误处理机制，确保系统稳定性

## 系统要求

- **操作系统**: Debian/Ubuntu Linux
- **Python版本**: Python 3.6+
- **依赖库**: requests, chardet

## 快速安装

### 方法1: 自动安装（推荐）

```bash
# 克隆或下载项目文件后，运行安装脚本
chmod +x install.sh
./install.sh
```

### 方法2: 手动安装

```bash
# 1. 下载安装脚本
wget -O install.sh https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh
chmod +x install.sh

# 2. 运行安装脚本（支持交互式配置）
./install.sh

# 3. 或者直接克隆整个项目
git clone https://github.com/yuanweize/IPTV-Manager.git
cd IPTV-Manager
./install.sh
```

### 3. 配置文件说明

配置文件 `config.json` 包含以下主要部分：

#### 直播源配置 (sources)
```json
{
  "sources": {
    "domestic": {
      "name": "国内源",
      "url": "https://live.hacks.tools/tv/iptv4.m3u",
      "filename": "domestic.m3u",
      "enabled": true
    }
  }
}
```

- `name`: 源的显示名称
- `url`: M3U文件的下载地址
- `filename`: 保存的文件名
- `enabled`: 是否启用此源

#### 目录配置 (directories)
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

- `base_dir`: 程序安装的基础目录
- `data_dir`: 直播源文件保存目录（可以是独立路径）
- `backup_dir`: 备份文件保存目录
- `log_dir`: 日志文件保存目录

#### 下载配置 (download)
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

## 使用方法

### 基本使用

#### 方法1: 使用全局命令（推荐）

如果安装时创建了软连接，可以在任何位置直接使用：

```bash
# 进入交互式菜单（推荐）
iptv

# 直接下载直播源（用于脚本和定时任务）
iptv --download

# 查看状态
iptv --status

# 查看帮助
iptv --help
```

#### 方法2: 使用完整路径

```bash
# 进入安装目录（默认为 /opt/IPTV-Manager）
cd /opt/IPTV-Manager

# 进入交互式菜单
python3 iptv_manager.py

# 直接下载直播源
python3 iptv_manager.py --download

# 查看状态
python3 iptv_manager.py --status

# 查看帮助
python3 iptv_manager.py --help
```

### 交互式菜单

直接运行 `iptv` 命令会进入友好的交互式菜单：

```
============================================================
    IPTV直播源管理系统
============================================================
请选择要执行的操作:

1. [下载] 下载/更新直播源
2. [状态] 查看系统状态
3. [列表] 查看直播源列表
4. [配置] 配置管理
5. [日志] 查看日志
6. [清理] 清理维护
7. [更新] 更新程序
8. [语言] 切换语言
9. [定时] 定时任务管理
10. [卸载] 卸载程序
0. [退出] 退出程序

============================================================
请输入选项 (0-8):
```

菜单功能说明：
- **下载/更新直播源**: 执行主要的下载任务
- **查看系统状态**: 显示详细的系统状态信息
- **查看直播源列表**: 列出所有已下载的直播源文件
- **配置管理**: 查看当前配置信息
- **查看日志**: 显示最近的运行日志
- **清理维护**: 清理过期的备份和日志文件
- **更新程序**: 检查并更新到最新版本
- **切换语言**: 切换界面语言（中文/英文）
- **定时任务管理**: 查看、设置或删除定时任务
- **卸载程序**: 完全卸载IPTV管理系统

### 高级用法

```bash
# 使用自定义配置文件
iptv --config /path/to/config.json
# 或
python3 iptv_manager.py --config /path/to/config.json

# 查看版本信息
iptv --version
# 或
python3 iptv_manager.py --version

# 直接下载模式（跳过菜单，用于脚本）
iptv --download
# 或
python3 iptv_manager.py --download
```

### 定时任务设置

使用crontab设置定时执行：

```bash
# 编辑crontab
crontab -e

# 使用全局命令（推荐）
0 */6 * * * iptv --download >> /opt/IPTV-Manager/logs/cron.log 2>&1

# 或使用完整路径
0 */6 * * * cd /opt/IPTV-Manager && python3 iptv_manager.py --download >> /opt/IPTV-Manager/logs/cron.log 2>&1

# 其他时间设置示例
0 2 * * * iptv --download         # 每天凌晨2点执行
0 * * * * iptv --download         # 每小时执行一次
```

## 目录结构

### 默认目录结构

```
/opt/IPTV-Manager/           # 安装目录
├── iptv_manager.py          # 主脚本文件
├── config.json              # 配置文件
├── requirements.txt         # Python依赖文件
├── data/                    # 直播源数据目录
│   ├── domestic.m3u         # 国内源文件
│   └── international.m3u    # 国际源文件
├── backup/                  # 备份目录
│   ├── domestic_20240102_143022.m3u
│   └── international_20240102_143022.m3u
└── logs/                    # 日志目录
    ├── iptv_manager_20240102.log
    └── status_report_20240102_143022.txt
```

### 自定义数据目录结构

如果你在安装时选择了自定义数据目录（如 `/media/iptv`），结构如下：

```
/opt/IPTV-Manager/           # 安装目录
├── iptv_manager.py          # 主脚本文件
├── config.json              # 配置文件
├── requirements.txt         # Python依赖文件
├── backup/                  # 备份目录
└── logs/                    # 日志目录

/media/iptv/                 # 自定义数据目录
├── domestic.m3u             # 国内源文件
└── international.m3u        # 国际源文件
```

> 💡 **目录优势**：
> - 程序文件与数据文件分离，便于管理
> - 数据目录可选择大容量存储设备
> - 备份和日志仍保存在程序目录，便于维护

## 软连接管理

### 创建软连接

如果安装时没有创建软连接，可以手动创建：

```bash
# 创建软连接（需要管理员权限）
sudo ln -sf /opt/IPTV-Manager/iptv_manager.py /usr/local/bin/iptv

# 或创建包装脚本（推荐）
sudo tee /usr/local/bin/iptv > /dev/null << 'EOF'
#!/bin/bash
cd /opt/IPTV-Manager && python3 iptv_manager.py "$@"
EOF
sudo chmod +x /usr/local/bin/iptv
```

### 删除软连接

```bash
# 删除软连接
sudo rm -f /usr/local/bin/iptv
```

### 验证软连接

```bash
# 检查软连接是否存在
ls -la /usr/local/bin/iptv

# 测试命令是否可用
which iptv
iptv --help
```

## 添加新的直播源

在 `config.json` 的 `sources` 部分添加新源：

```json
{
  "sources": {
    "existing_source": { ... },
    "new_source": {
      "name": "新直播源",
      "url": "https://example.com/playlist.m3u",
      "filename": "new_source.m3u",
      "enabled": true
    }
  }
}
```

## 日志和监控

### 日志文件
- **运行日志**: `logs/iptv_manager_YYYYMMDD.log`
- **状态报告**: `logs/status_report_YYYYMMDD_HHMMSS.txt`
- **Cron日志**: `logs/cron.log` (如果配置了重定向)

### 日志级别
可在配置文件中设置日志级别：
- `DEBUG`: 详细调试信息
- `INFO`: 一般信息 (默认)
- `WARNING`: 警告信息
- `ERROR`: 错误信息

## 安装测试

安装完成后，可以运行测试脚本验证安装是否成功：

```bash
# 进入安装目录
cd /opt/IPTV-Manager

# 运行测试脚本
python3 test_installation.py
```

测试脚本会检查：
- Python依赖包是否正确安装
- 配置文件是否有效
- 脚本是否可以正常执行
- 目录结构是否正确
- 多语言支持是否工作

### 程序更新

IPTV Manager支持在线更新功能：

#### 通过交互式菜单更新
```bash
# 启动程序
iptv

# 选择菜单选项 7 进行更新
# 程序会自动检查GitHub上的最新版本
# 如有新版本会提示是否更新
```

#### 手动更新
```bash
# 重新运行安装脚本即可更新
curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash
```

更新功能特点：
- 自动检查最新版本
- 保持现有配置和数据
- 支持双语更新提示
- 一键更新安装

### 使用Makefile（可选）

项目包含Makefile来简化常用操作：

```bash
# 查看所有可用命令
make help

# 运行安装
make install

# 运行测试
make test

# 直接下载源
make download

# 查看状态
make status

# 清理临时文件
make clean
```

## 故障排除

### 常见问题

1. **pip安装失败 (ModuleNotFoundError: No module named 'distutils.util')**
   ```bash
   # 安装缺失的包
   sudo apt install -y python3-distutils python3-setuptools python3-dev
   
   # 使用python -m pip安装依赖
   python3 -m pip install requests chardet --user
   ```

2. **权限错误**
   ```bash
   sudo chown -R $USER:$USER /opt/IPTV-Manager
   chmod +x /opt/IPTV-Manager/iptv_manager.py
   ```

3. **网络超时**
   - 增加 `download.timeout` 值
   - 检查网络连接和防火墙设置

4. **编码问题**
   - 脚本会自动检测编码，如有问题检查源文件格式

5. **磁盘空间不足**
   - 启用自动清理: `"enable_cleanup": true`
   - 减少备份保留天数

6. **Python版本问题**
   ```bash
   # 确保使用Python 3.6+
   python3 --version
   
   # 如果版本过低，升级Python
   sudo apt install python3.9 python3.9-pip
   ```

### 调试模式

```bash
# 启用详细日志
# 在config.json中设置: "level": "DEBUG"

# 查看实时日志
tail -f /opt/IPTV-Manager/logs/iptv_manager_$(date +%Y%m%d).log
```

## 性能优化

### 并发设置
根据服务器性能调整并发数：
```json
{
  "download": {
    "max_workers": 4  // 根据CPU核心数调整
  }
}
```

### 清理策略
```json
{
  "maintenance": {
    "backup_retention_days": 7,   // 备份保留天数
    "log_retention_days": 30,     // 日志保留天数
    "enable_cleanup": true        // 启用自动清理
  }
}
```

## 安全建议

1. **文件权限**: 确保脚本和配置文件权限正确设置
2. **网络安全**: 使用HTTPS源，避免不安全的HTTP连接
3. **定期更新**: 定期更新Python依赖库
4. **日志监控**: 定期检查日志文件，及时发现异常

## 版本信息

- **版本**: 2.0.9
- **适用环境**: Debian/Ubuntu服务器
- **Python要求**: 3.6+

## 技术支持

如遇到问题，请检查：
1. 日志文件中的错误信息
2. 网络连接状态
3. 配置文件格式正确性
4. 文件和目录权限设置

---

**注意**: 请确保遵守相关法律法规，仅用于合法的IPTV内容访问。
