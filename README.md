# IPTV直播源管理脚本

一个专为Debian服务器环境设计的高性能IPTV直播源自动下载和管理脚本，支持多源并发下载、自动更新、配置化管理和完整的维护功能。

## 🚀 一键安装

只需要一条命令即可完成所有安装和配置：

```bash
curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash
```

或者如果你想先下载再运行：

```bash
wget https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh
chmod +x install.sh
./install.sh
```

就这么简单！安装脚本会：
- 自动下载所有必要文件到 `/opt/IPTV-Manager`
- 安装Python依赖
- 创建完整的目录结构
- 配置定时任务（可选）
- 支持自定义安装路径

### 📝 安装选项

安装过程中会询问：
- **安装路径**：默认 `/opt/IPTV-Manager`（推荐），可自定义任意路径
- **定时任务**：可选择执行频率或跳过设置
- **立即运行**：安装完成后是否立即下载直播源

> 💡 **路径说明**：`/opt` 目录是Linux系统中存放第三方软件的标准位置，使用此路径更符合系统规范。

## 功能特性

### 核心功能
- 🚀 **多源并发下载**: 支持同时下载多个IPTV直播源，提高效率
- ⚙️ **配置化管理**: 所有参数通过JSON配置文件管理，易于维护
- 🔄 **自动重试机制**: 网络失败时自动重试，确保下载成功率
- 📝 **完整日志记录**: 详细的运行日志，便于问题排查
- 🗂️ **文件版本控制**: 自动备份历史版本，支持回滚
- 🧹 **自动清理维护**: 定期清理过期文件，保持系统整洁

### 高级特性
- 🌐 **编码自动检测**: 智能检测M3U文件编码，确保兼容性
- 🔒 **权限管理**: 自动设置正确的文件和目录权限
- 📊 **状态报告**: 生成详细的执行状态报告
- ⏰ **定时任务兼容**: 完美支持crontab定时执行
- 🛡️ **异常处理**: 完善的错误处理机制，确保系统稳定性

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
wget https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh
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
    "data_dir": "data",
    "backup_dir": "backup", 
    "log_dir": "logs"
  }
}
```

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

安装完成后，进入安装目录：

```bash
# 进入安装目录（默认为 /opt/IPTV-Manager）
cd /opt/IPTV-Manager

# 下载直播源
python3 iptv_manager.py

# 查看状态
python3 iptv_manager.py --status

# 查看帮助
python3 iptv_manager.py --help
```

### 高级用法

```bash
# 使用自定义配置文件
python3 iptv_manager.py --config /path/to/config.json

# 查看版本信息
python3 iptv_manager.py --version
```

### 定时任务设置

使用crontab设置定时执行：

```bash
# 编辑crontab
crontab -e

# 添加定时任务（每6小时执行一次）
0 */6 * * * cd /opt/IPTV-Manager && python3 iptv_manager.py >> /opt/IPTV-Manager/logs/cron.log 2>&1

# 每天凌晨2点执行
0 2 * * * cd /opt/IPTV-Manager && python3 iptv_manager.py

# 每小时执行一次
0 * * * * cd /opt/IPTV-Manager && python3 iptv_manager.py
```

## 目录结构

执行后会创建以下目录结构：

```
/opt/IPTV-Manager/
├── iptv_manager.py          # 主脚本文件
├── config.json              # 配置文件
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

- **版本**: 1.0.0
- **作者**: IPTV管理脚本开发专家
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