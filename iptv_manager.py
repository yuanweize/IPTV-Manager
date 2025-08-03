#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IPTV直播源管理脚本 / IPTV Live Source Management Script
=======================================================

功能描述 / Features:
- 自动下载和更新IPTV直播源 / Automatic download and update of IPTV live sources
- 支持多源并发下载 / Multi-source concurrent downloads
- 配置文件管理所有参数 / Configuration file manages all parameters
- 完整的日志记录和错误处理 / Complete logging and error handling
- 文件版本控制和自动清理 / File version control and automatic cleanup
- 兼容crontab定时执行 / Compatible with crontab scheduled execution
- 多语言支持 / Multi-language support

作者 / Author: IPTV管理脚本开发专家 / IPTV Management Script Expert
版本 / Version: 1.0.7
适用环境 / Environment: Debian/Ubuntu服务器 / Debian/Ubuntu servers
"""

import os
import sys
import json
import logging
import threading
import time
import shutil
from datetime import datetime, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple
from concurrent.futures import ThreadPoolExecutor, as_completed
from urllib.parse import urlparse

# 导入多语言支持
try:
    from languages import get_text, set_language, lang_manager
except ImportError:
    # 如果语言文件不存在，创建简单的替代函数
    def get_text(key, *args, **kwargs):
        return key
    def set_language(lang):
        pass
    class DummyLangManager:
        def get(self, key, *args, **kwargs):
            return key
    lang_manager = DummyLangManager()

# 检查并导入必要的依赖
def check_dependencies():
    """检查必要的依赖是否已安装 / Check if required dependencies are installed"""
    missing_deps = []
    
    try:
        import requests
    except ImportError:
        missing_deps.append('requests')
    
    try:
        import chardet
    except ImportError:
        missing_deps.append('chardet')
    
    if missing_deps:
        print(f"{get_text('error')}: {get_text('missing_dependencies')}: {', '.join(missing_deps)}")
        print(f"{get_text('install_dependencies')}:")
        print(f"python3 -m pip install {' '.join(missing_deps)} --user")
        print(f"{get_text('or')}:")
        print("./install.sh")
        sys.exit(1)

# 执行依赖检查
check_dependencies()

# 导入依赖
import requests
import chardet


class IPTVConfig:
    """IPTV配置管理类"""
    
    def __init__(self, config_path: str = "config.json"):
        """
        初始化配置管理器
        
        Args:
            config_path: 配置文件路径
        """
        self.config_path = config_path
        self.config = self._load_default_config()
        self._load_config()
        self._validate_config()
    
    def _load_default_config(self) -> Dict:
        """加载默认配置"""
        return {
            "sources": {
                "domestic": {
                    "name": "国内源",
                    "url": "https://live.hacks.tools/tv/iptv4.m3u",
                    "filename": "domestic.m3u",
                    "enabled": True
                },
                "international": {
                    "name": "国际源", 
                    "url": "https://live.hacks.tools/iptv/index.m3u",
                    "filename": "international.m3u",
                    "enabled": True
                }
            },
            "directories": {
                "base_dir": "/opt/IPTV-Manager",
                "data_dir": "data",
                "backup_dir": "backup",
                "log_dir": "logs"
            },
            "download": {
                "timeout": 30,
                "retry_count": 3,
                "retry_delay": 5,
                "max_workers": 4,
                "user_agent": "IPTV-Manager/1.0"
            },
            "maintenance": {
                "backup_retention_days": 7,
                "log_retention_days": 30,
                "enable_backup": True,
                "enable_cleanup": True
            },
            "logging": {
                "level": "INFO",
                "format": "%(asctime)s - %(name)s - %(levelname)s - %(message)s",
                "max_size_mb": 10,
                "backup_count": 5
            }
        }
    
    def _load_config(self):
        """从文件加载配置 / Load configuration from file"""
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                    self._merge_config(self.config, user_config)
                
                # 设置语言
                language = self.config.get('language', 'zh')
                set_language(language)
                
                logging.info(f"Configuration loaded successfully / 配置文件加载成功: {self.config_path}")
            except Exception as e:
                logging.warning(f"Configuration load failed, using default / 配置文件加载失败，使用默认配置: {e}")
        else:
            self._save_config()
            logging.info("Default configuration file created / 创建默认配置文件")
    
    def _merge_config(self, default: Dict, user: Dict):
        """递归合并配置"""
        for key, value in user.items():
            if key in default:
                if isinstance(default[key], dict) and isinstance(value, dict):
                    self._merge_config(default[key], value)
                else:
                    default[key] = value
            else:
                default[key] = value
    
    def _validate_config(self):
        """验证配置有效性 / Validate configuration"""
        required_keys = ['sources', 'directories', 'download']
        for key in required_keys:
            if key not in self.config:
                raise ValueError(f"{get_text('missing_config_key')}: {key}")
        
        # 验证目录配置
        base_dir = self.config['directories']['base_dir']
        if not os.path.isabs(base_dir):
            raise ValueError(get_text('invalid_base_dir'))
    
    def _save_config(self):
        """保存配置到文件 / Save configuration to file"""
        try:
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logging.error(f"{get_text('config_save_failed')}: {e}")
    
    def get(self, key: str, default=None):
        """获取配置值"""
        keys = key.split('.')
        value = self.config
        for k in keys:
            if isinstance(value, dict) and k in value:
                value = value[k]
            else:
                return default
        return value
    
    def get_sources(self) -> Dict:
        """获取启用的直播源配置 / Get enabled live source configurations"""
        return {k: v for k, v in self.config['sources'].items() if v.get('enabled', True)}
    
    def get_source_name(self, source_id: str, source_config: Dict) -> str:
        """根据当前语言获取源名称 / Get source name based on current language"""
        language = self.config.get('language', 'zh')
        if language == 'en' and 'name_en' in source_config:
            return source_config['name_en']
        return source_config.get('name', source_id)


class IPTVLogger:
    """IPTV日志管理类"""
    
    def __init__(self, config: IPTVConfig):
        """
        初始化日志管理器
        
        Args:
            config: 配置管理器实例
        """
        self.config = config
        self._setup_logging()
    
    def _setup_logging(self):
        """设置日志配置"""
        log_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.log_dir')
        log_dir.mkdir(parents=True, exist_ok=True)
        
        log_file = log_dir / f"iptv_manager_{datetime.now().strftime('%Y%m%d')}.log"
        
        # 配置日志格式
        formatter = logging.Formatter(self.config.get('logging.format'))
        
        # 文件处理器
        file_handler = logging.FileHandler(log_file, encoding='utf-8')
        file_handler.setFormatter(formatter)
        
        # 控制台处理器
        console_handler = logging.StreamHandler()
        console_handler.setFormatter(formatter)
        
        # 配置根日志器
        logger = logging.getLogger()
        logger.setLevel(getattr(logging, self.config.get('logging.level', 'INFO')))
        logger.addHandler(file_handler)
        logger.addHandler(console_handler)
    
    def cleanup_old_logs(self):
        """清理过期日志文件"""
        if not self.config.get('maintenance.enable_cleanup', True):
            return
        
        log_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.log_dir')
        retention_days = self.config.get('maintenance.log_retention_days', 30)
        cutoff_date = datetime.now() - timedelta(days=retention_days)
        
        try:
            for log_file in log_dir.glob("iptv_manager_*.log"):
                if log_file.stat().st_mtime < cutoff_date.timestamp():
                    log_file.unlink()
                    logging.info(f"{get_text('deleted_log')}: {log_file}")
        except Exception as e:
            logging.error(f"{get_text('cleanup_failed')}: {e}")


class IPTVDownloader:
    """IPTV下载器类"""
    
    def __init__(self, config: IPTVConfig):
        """
        初始化下载器
        
        Args:
            config: 配置管理器实例
        """
        self.config = config
        self.session = self._create_session()
        self._setup_directories()
    
    def _create_session(self) -> requests.Session:
        """创建HTTP会话"""
        session = requests.Session()
        session.headers.update({
            'User-Agent': self.config.get('download.user_agent'),
            'Accept': '*/*',
            'Accept-Encoding': 'gzip, deflate',
            'Connection': 'keep-alive'
        })
        return session
    
    def _setup_directories(self):
        """创建必要的目录结构"""
        base_dir = Path(self.config.get('directories.base_dir'))
        
        directories = [
            base_dir,
            base_dir / self.config.get('directories.data_dir'),
            base_dir / self.config.get('directories.backup_dir'),
            base_dir / self.config.get('directories.log_dir')
        ]
        
        for directory in directories:
            directory.mkdir(parents=True, exist_ok=True)
            # 设置目录权限 (755)
            os.chmod(directory, 0o755)
            logging.debug(f"{get_text('create_directory')}: {directory}")    

    def _detect_encoding(self, content: bytes) -> str:
        """检测文件编码 / Detect file encoding"""
        try:
            result = chardet.detect(content)
            encoding = result.get('encoding', 'utf-8')
            confidence = result.get('confidence', 0)
            
            if confidence < 0.7:
                logging.warning(f"{get_text('encoding_detection_low')}: {confidence}, {get_text('encoding_detection_failed')}")
                return 'utf-8'
            
            logging.debug(f"{get_text('detected_encoding')}: {encoding}, {get_text('confidence')}: {confidence}")
            return encoding
        except Exception as e:
            logging.warning(f"{get_text('encoding_detection_failed')}: {e}")
            return 'utf-8'
    
    def _download_source(self, source_id: str, source_config: Dict) -> Tuple[bool, str]:
        """
        下载单个直播源
        
        Args:
            source_id: 源标识符
            source_config: 源配置信息
            
        Returns:
            (成功标志, 错误信息)
        """
        url = source_config['url']
        filename = source_config['filename']
        name = self.config.get_source_name(source_id, source_config)
        
        logging.info(f"{get_text('download_source')} {name}: {url}")
        
        retry_count = self.config.get('download.retry_count', 3)
        retry_delay = self.config.get('download.retry_delay', 5)
        timeout = self.config.get('download.timeout', 30)
        
        for attempt in range(retry_count):
            try:
                response = self.session.get(url, timeout=timeout, stream=True)
                response.raise_for_status()
                
                # 获取内容
                content = response.content
                if not content:
                    raise ValueError(get_text('empty_content'))
                
                # 检测编码并解码
                encoding = self._detect_encoding(content)
                try:
                    text_content = content.decode(encoding)
                except UnicodeDecodeError:
                    text_content = content.decode('utf-8', errors='ignore')
                    logging.warning(f"{get_text('force_utf8')}: {filename}")
                
                # 验证M3U格式
                if not self._validate_m3u_content(text_content):
                    raise ValueError(get_text('invalid_m3u'))
                
                # 保存文件
                data_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.data_dir')
                file_path = data_dir / filename
                
                # 备份现有文件
                if file_path.exists() and self.config.get('maintenance.enable_backup', True):
                    self._backup_file(file_path)
                
                # 写入新文件
                with open(file_path, 'w', encoding='utf-8') as f:
                    f.write(text_content)
                
                # 设置文件权限 (644)
                os.chmod(file_path, 0o644)
                
                file_size = len(text_content)
                channel_count = text_content.count('#EXTINF:')
                
                logging.info(f"{get_text('download_success')} {name}: {filename} ({file_size} bytes, {channel_count} {get_text('channels')})")
                return True, ""
                
            except requests.exceptions.RequestException as e:
                error_msg = f"{get_text('network_error')}: {e}"
                logging.warning(f"{get_text('download_failed')} {name} ({get_text('download_retry')} {attempt + 1}/{retry_count}): {error_msg}")
                
                if attempt < retry_count - 1:
                    time.sleep(retry_delay)
                else:
                    logging.error(f"{get_text('download_final_failed')} {name}: {error_msg}")
                    return False, error_msg
                    
            except Exception as e:
                error_msg = f"{get_text('unknown_error')}: {e}"
                logging.error(f"{get_text('download_failed')} {name}: {error_msg}")
                return False, error_msg
        
        return False, get_text('retry_exhausted')
    
    def _validate_m3u_content(self, content: str) -> bool:
        """验证M3U文件内容格式 / Validate M3U file content format"""
        if not content.strip():
            return False
        
        lines = content.strip().split('\n')
        if not lines[0].strip().startswith('#EXTM3U'):
            logging.warning("M3U file missing #EXTM3U header, but continuing processing")
        
        # 检查是否包含频道信息
        has_extinf = any(line.strip().startswith('#EXTINF:') for line in lines)
        has_urls = any(line.strip().startswith('http') for line in lines)
        
        return has_extinf and has_urls
    
    def _backup_file(self, file_path: Path):
        """备份现有文件 / Backup existing file"""
        try:
            backup_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.backup_dir')
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_name = f"{file_path.stem}_{timestamp}{file_path.suffix}"
            backup_path = backup_dir / backup_name
            
            shutil.copy2(file_path, backup_path)
            logging.debug(f"{get_text('backup_file')}: {file_path} -> {backup_path}")
            
        except Exception as e:
            logging.warning(f"{get_text('backup_failed')}: {e}")
    
    def download_all_sources(self) -> Dict[str, Tuple[bool, str]]:
        """
        并发下载所有启用的直播源
        
        Returns:
            下载结果字典 {source_id: (成功标志, 错误信息)}
        """
        sources = self.config.get_sources()
        if not sources:
            logging.warning("No enabled live sources" if get_text('language') == 'en' else "没有启用的直播源")
            return {}
        
        logging.info(f"Starting download of {len(sources)} live sources" if get_text('language') == 'en' else f"开始下载 {len(sources)} 个直播源")
        
        results = {}
        max_workers = min(len(sources), self.config.get('download.max_workers', 4))
        
        with ThreadPoolExecutor(max_workers=max_workers) as executor:
            # 提交所有下载任务
            future_to_source = {
                executor.submit(self._download_source, source_id, source_config): source_id
                for source_id, source_config in sources.items()
            }
            
            # 收集结果
            for future in as_completed(future_to_source):
                source_id = future_to_source[future]
                try:
                    success, error_msg = future.result()
                    results[source_id] = (success, error_msg)
                except Exception as e:
                    error_msg = f"任务执行异常: {e}"
                    logging.error(f"源 {source_id} 下载任务异常: {error_msg}")
                    results[source_id] = (False, error_msg)
        
        # 统计结果
        success_count = sum(1 for success, _ in results.values() if success)
        total_count = len(results)
        
        logging.info(f"{get_text('download_complete_stats')}: {success_count}/{total_count} {get_text('success_sources')}")
        
        return results


class IPTVMaintenance:
    """IPTV维护管理类"""
    
    def __init__(self, config: IPTVConfig):
        """
        初始化维护管理器
        
        Args:
            config: 配置管理器实例
        """
        self.config = config
    
    def cleanup_old_backups(self):
        """清理过期备份文件"""
        if not self.config.get('maintenance.enable_cleanup', True):
            return
        
        backup_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.backup_dir')
        retention_days = self.config.get('maintenance.backup_retention_days', 7)
        cutoff_date = datetime.now() - timedelta(days=retention_days)
        
        try:
            deleted_count = 0
            for backup_file in backup_dir.glob("*"):
                if backup_file.is_file() and backup_file.stat().st_mtime < cutoff_date.timestamp():
                    backup_file.unlink()
                    deleted_count += 1
                    logging.debug(f"{get_text('deleted_backup')}: {backup_file}")
            
            if deleted_count > 0:
                logging.info(f"{get_text('cleanup_old_backups')}: {deleted_count} 个")
                
        except Exception as e:
            logging.error(f"{get_text('cleanup_failed')}: {e}")
    
    def generate_status_report(self, download_results: Dict[str, Tuple[bool, str]]) -> str:
        """
        生成状态报告
        
        Args:
            download_results: 下载结果
            
        Returns:
            状态报告内容
        """
        report_lines = [
            get_text('status_report_title'),
            "=" * 50,
            f"{get_text('generate_time')}: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            ""
        ]
        
        # 下载结果统计
        if download_results:
            success_count = sum(1 for success, _ in download_results.values() if success)
            total_count = len(download_results)
            
            report_lines.extend([
                f"{get_text('download_stats')}:",
                f"  {get_text('total_sources')}: {total_count} {get_text('sources') if get_text('sources') != 'sources' else '个源'}",
                f"  {get_text('success_sources')}: {success_count} {get_text('sources') if get_text('sources') != 'sources' else '个'}",
                f"  {get_text('failed_sources')}: {total_count - success_count} {get_text('sources') if get_text('sources') != 'sources' else '个'}",
                ""
            ])
            
            # 详细结果
            report_lines.append(f"{get_text('detailed_results')}:")
            for source_id, (success, error_msg) in download_results.items():
                status = f"✓ {get_text('success_sources')}" if success else f"✗ {get_text('failed_sources')}: {error_msg}"
                source_name = self.config.get_source_name(source_id, self.config.config['sources'][source_id])
                report_lines.append(f"  {source_name}: {status}")
            
            report_lines.append("")
        
        # 文件信息
        data_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.data_dir')
        if data_dir.exists():
            report_lines.append(f"{get_text('file_info')}:")
            for m3u_file in data_dir.glob("*.m3u"):
                try:
                    stat = m3u_file.stat()
                    size = stat.st_size
                    mtime = datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
                    
                    # 统计频道数量
                    with open(m3u_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                        channel_count = content.count('#EXTINF:')
                    
                    report_lines.append(f"  {m3u_file.name}: {size} bytes, {channel_count} {get_text('channels')}, {get_text('update_time')}: {mtime}")
                except Exception as e:
                    report_lines.append(f"  {m3u_file.name}: {get_text('read_failed')} - {e}")
        
        return "\n".join(report_lines)
    
    def save_status_report(self, download_results: Dict[str, Tuple[bool, str]]):
        """保存状态报告到文件"""
        try:
            report_content = self.generate_status_report(download_results)
            
            log_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.log_dir')
            report_file = log_dir / f"status_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            
            with open(report_file, 'w', encoding='utf-8') as f:
                f.write(report_content)
            
            logging.info(f"{get_text('status_report_saved')}: {report_file}")
            
        except Exception as e:
            logging.error(f"{get_text('save_report_failed')}: {e}")


class IPTVManager:
    """IPTV管理器主类"""
    
    def __init__(self, config_path: str = "config.json"):
        """
        初始化IPTV管理器
        
        Args:
            config_path: 配置文件路径
        """
        try:
            self.config = IPTVConfig(config_path)
            self.logger = IPTVLogger(self.config)
            self.downloader = IPTVDownloader(self.config)
            self.maintenance = IPTVMaintenance(self.config)
            
            logging.info(get_text('init_complete'))
            
        except Exception as e:
            print(f"{get_text('init_failed')}: {e}")
            sys.exit(1)
    
    def run(self):
        """执行主要任务流程"""
        try:
            logging.info(get_text('task_start'))
            
            # 清理过期文件
            self.logger.cleanup_old_logs()
            self.maintenance.cleanup_old_backups()
            
            # 下载直播源
            download_results = self.downloader.download_all_sources()
            
            # 生成状态报告
            self.maintenance.save_status_report(download_results)
            
            # 检查是否有失败的下载
            failed_sources = [source_id for source_id, (success, _) in download_results.items() if not success]
            
            if failed_sources:
                logging.warning(f"{get_text('partial_failed')}: {', '.join(failed_sources)}")
                return 1
            else:
                logging.info(get_text('task_complete'))
                return 0
                
        except Exception as e:
            logging.error(f"{get_text('task_error')}: {e}")
            return 1
    
    def show_status(self):
        """显示当前状态 / Display current status"""
        try:
            download_results = {}  # 空结果用于显示文件状态
            report = self.maintenance.generate_status_report(download_results)
            print(report)
            
        except Exception as e:
            logging.error(f"{get_text('show_status_failed')}: {e}")


def show_menu():
    """显示交互式菜单 / Display interactive menu"""
    print("\n" + "="*60)
    print(f"    {get_text('menu_title')}")
    print("="*60)
    print(f"{get_text('menu_prompt').replace('请输入选项 (0-8):', '请选择要执行的操作:').replace('Enter option (0-8):', 'Please select operation:')}")
    print()
    print(f"1. {get_text('menu_download')}")
    print(f"2. {get_text('menu_status')}")
    print(f"3. {get_text('menu_list')}")
    print(f"4. {get_text('menu_config')}")
    print(f"5. {get_text('menu_logs')}")
    print(f"6. {get_text('menu_cleanup')}")
    print(f"7. {get_text('menu_update')}")
    print(f"8. {get_text('menu_language')}")
    print(f"9. {get_text('menu_uninstall')}")
    print(f"0. {get_text('menu_exit')}")
    print()
    print("="*60)


def interactive_mode(manager):
    """交互式模式 / Interactive mode"""
    while True:
        try:
            show_menu()
            choice = input(f"{get_text('menu_prompt')} ").strip()
            
            if choice == '0':
                print(f"\n{get_text('menu_exit').replace('[退出] ', '[').replace('[Exit] ', '[')} {get_text('exit_message')}")
                return 0
                
            elif choice == '1':
                print(f"\n{get_text('menu_download').replace('[下载] ', '[').replace('[Download] ', '[')} {get_text('download_start')}")
                print("-" * 50)
                result = manager.run()
                if result == 0:
                    print(f"\n[{get_text('download_complete').split('！')[0].split('!')[0]}] {get_text('download_complete')}")
                else:
                    print(f"\n[{get_text('error')}] {get_text('download_error')}")
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '2':
                print(f"\n{get_text('menu_status').replace('[状态] ', '[').replace('[Status] ', '[')} {get_text('status_info')}")
                print("-" * 50)
                manager.show_status()
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '3':
                print(f"\n{get_text('menu_list').replace('[列表] ', '[').replace('[List] ', '[')} {get_text('file_list')}")
                print("-" * 50)
                show_source_files(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '4':
                print(f"\n{get_text('menu_config').replace('[配置] ', '[').replace('[Config] ', '[')} {get_text('config_info')}")
                print("-" * 50)
                show_config_info(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '5':
                print(f"\n{get_text('menu_logs').replace('[日志] ', '[').replace('[Logs] ', '[')} {get_text('logs_recent')}")
                print("-" * 50)
                show_recent_logs(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '6':
                print(f"\n{get_text('menu_cleanup').replace('[清理] ', '[').replace('[Cleanup] ', '[')} {get_text('cleanup_maintenance')}")
                print("-" * 50)
                cleanup_files(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '7':
                print(f"\n{get_text('menu_update').replace('[更新] ', '[').replace('[Update] ', '[')} {get_text('update_program')}")
                print("-" * 50)
                update_program(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '8':
                print(f"\n{get_text('menu_language').replace('[语言] ', '[').replace('[Language] ', '[')} {get_text('language_switch')}")
                print("-" * 50)
                switch_language(manager)
                input(f"\n{get_text('continue_prompt')}")
                
            elif choice == '9':
                print(f"\n{get_text('menu_uninstall').replace('[卸载] ', '[').replace('[Uninstall] ', '[')} {get_text('uninstall_program')}")
                print("-" * 50)
                if uninstall_program(manager):
                    print(f"\n[Complete] Program uninstalled successfully")
                    return 0
                else:
                    print(f"\n[Cancelled] Uninstall operation cancelled")
                input(f"\n{get_text('continue_prompt')}")
                
            else:
                print(f"\n[{get_text('error')}] {get_text('invalid_option')}")
                input(f"{get_text('continue_prompt')}")
                
        except KeyboardInterrupt:
            print(f"\n\n[{get_text('user_interrupt').split('，')[0].split(',')[0]}] {get_text('user_interrupt')}")
            return 130
        except Exception as e:
            print(f"\n[{get_text('error')}] {get_text('operation_failed')}: {e}")
            input(f"{get_text('continue_prompt')}")


def show_source_files(manager):
    """显示直播源文件信息"""
    try:
        # 获取数据目录路径
        if hasattr(manager.config, 'get'):
            # 如果config是字典
            data_dir_path = manager.config.get('directories', {}).get('data_dir')
        else:
            # 如果config是对象，尝试访问属性
            data_dir_path = getattr(manager.config, 'data_dir', None)
            if not data_dir_path:
                # 尝试从directories属性获取
                directories = getattr(manager.config, 'directories', {})
                if hasattr(directories, 'get'):
                    data_dir_path = directories.get('data_dir')
                else:
                    data_dir_path = getattr(directories, 'data_dir', None)
        
        if not data_dir_path:
            print("[错误] 无法获取数据目录配置")
            return
            
        data_dir = Path(data_dir_path)
        if not data_dir.exists():
            print(f"[信息] 数据目录不存在: {data_dir}")
            print("       请先执行下载操作")
            return
            
        m3u_files = list(data_dir.glob("*.m3u"))
        if not m3u_files:
            print(f"[信息] 数据目录: {data_dir}")
            print("       未找到直播源文件，请先下载直播源")
            return
            
        print(f"[目录] {data_dir}")
        print(f"[统计] 共找到 {len(m3u_files)} 个直播源文件:")
        print()
        
        for i, file_path in enumerate(m3u_files, 1):
            stat = file_path.stat()
            size = stat.st_size
            mtime = datetime.fromtimestamp(stat.st_mtime)
            
            # 格式化文件大小
            if size < 1024:
                size_str = f"{size} B"
            elif size < 1024 * 1024:
                size_str = f"{size / 1024:.1f} KB"
            else:
                size_str = f"{size / (1024 * 1024):.1f} MB"
                
            print(f"{i:2d}. [文件] {file_path.name}")
            print(f"    [大小] {size_str}")
            print(f"    [时间] {mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            print()
            
    except Exception as e:
        print(f"[错误] 获取文件信息失败: {e}")
        print(f"[调试] 错误类型: {type(e).__name__}")
        print(f"[调试] 配置对象类型: {type(manager.config)}")
        if hasattr(manager.config, '__dict__'):
            print(f"[调试] 配置对象属性: {list(manager.config.__dict__.keys())}")


def show_config_info(manager):
    """显示配置信息"""
    try:
        config = manager.config
        print(f"[{get_text('config_current').split(' ')[0]}] {get_text('config_current')}:")
        print()
        
        # 语言设置
        current_language = config.config.get('language', 'zh')
        language_name = "中文" if current_language == 'zh' else "English"
        print(f"[{get_text('language') if get_text('language') != 'language' else '语言'}] {get_text('language') if get_text('language') != 'language' else '界面语言'}:")
        print(f"   {get_text('current') if get_text('current') != 'current' else '当前'}: {language_name} ({current_language})")
        print()
        
        # 目录配置
        print("[目录] 目录配置:")
        if hasattr(config, 'get'):
            dirs = config.get('directories', {})
        else:
            dirs = getattr(config, 'directories', {})
            
        if hasattr(dirs, 'items'):
            for key, value in dirs.items():
                print(f"   {key}: {value}")
        elif hasattr(dirs, '__dict__'):
            for key, value in dirs.__dict__.items():
                print(f"   {key}: {value}")
        print()
        
        # 直播源配置
        print("[源站] 直播源配置:")
        if hasattr(config, 'get'):
            sources = config.get('sources', {})
        else:
            sources = getattr(config, 'sources', {})
            
        if hasattr(sources, 'items'):
            enabled_count = sum(1 for s in sources.values() if (hasattr(s, 'get') and s.get('enabled', True)) or (hasattr(s, 'enabled') and getattr(s, 'enabled', True)))
            print(f"   总数: {len(sources)} 个")
            print(f"   启用: {enabled_count} 个")
            print()
            
            for name, source in sources.items():
                if hasattr(source, 'get'):
                    enabled = source.get('enabled', True)
                    source_name = source.get('name', name)
                    url = source.get('url', 'N/A')
                    filename = source.get('filename', 'N/A')
                else:
                    enabled = getattr(source, 'enabled', True)
                    source_name = getattr(source, 'name', name)
                    url = getattr(source, 'url', 'N/A')
                    filename = getattr(source, 'filename', 'N/A')
                    
                status = "[启用]" if enabled else "[禁用]"
                print(f"   • {source_name} {status}")
                print(f"     URL: {url}")
                print(f"     文件: {filename}")
                print()
        print()
        
        # 下载配置
        print("[下载] 下载配置:")
        if hasattr(config, 'get'):
            download = config.get('download', {})
        else:
            download = getattr(config, 'download', {})
            
        if hasattr(download, 'get'):
            timeout = download.get('timeout', 30)
            retry_count = download.get('retry_count', 3)
            max_workers = download.get('max_workers', 4)
        else:
            timeout = getattr(download, 'timeout', 30)
            retry_count = getattr(download, 'retry_count', 3)
            max_workers = getattr(download, 'max_workers', 4)
            
        print(f"   超时时间: {timeout} 秒")
        print(f"   重试次数: {retry_count} 次")
        print(f"   并发数: {max_workers} 个")
        print()
        
    except Exception as e:
        print(f"[错误] 获取配置信息失败: {e}")
        print(f"[调试] 错误类型: {type(e).__name__}")
        print(f"[调试] 配置对象类型: {type(manager.config)}")


def show_recent_logs(manager):
    """显示最近的日志"""
    try:
        # 获取日志目录
        if hasattr(manager.config, 'get'):
            log_dir_path = manager.config.get('directories', {}).get('log_dir')
        else:
            directories = getattr(manager.config, 'directories', {})
            if hasattr(directories, 'get'):
                log_dir_path = directories.get('log_dir')
            else:
                log_dir_path = getattr(directories, 'log_dir', None)
        
        if not log_dir_path:
            print("[错误] 无法获取日志目录配置")
            return
            
        log_dir = Path(log_dir_path)
        if not log_dir.exists():
            print("[信息] 日志目录不存在")
            return
            
        # 查找最新的日志文件
        log_files = list(log_dir.glob("iptv_manager_*.log"))
        if not log_files:
            print("[信息] 未找到日志文件")
            return
            
        latest_log = max(log_files, key=lambda x: x.stat().st_mtime)
        print(f"[文件] 最新日志文件: {latest_log.name}")
        print("[内容] 最近 20 行日志:")
        print("-" * 50)
        
        with open(latest_log, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for line in lines[-20:]:
                print(line.rstrip())
                
    except Exception as e:
        print(f"[错误] 读取日志失败: {e}")


def cleanup_files(manager):
    """清理文件"""
    try:
        print("[清理] 开始清理过期文件...")
        
        # 获取配置
        if hasattr(manager.config, 'get'):
            backup_dir_path = manager.config.get('directories', {}).get('backup_dir')
            log_dir_path = manager.config.get('directories', {}).get('log_dir')
            maintenance = manager.config.get('maintenance', {})
        else:
            directories = getattr(manager.config, 'directories', {})
            if hasattr(directories, 'get'):
                backup_dir_path = directories.get('backup_dir')
                log_dir_path = directories.get('log_dir')
            else:
                backup_dir_path = getattr(directories, 'backup_dir', None)
                log_dir_path = getattr(directories, 'log_dir', None)
            maintenance = getattr(manager.config, 'maintenance', {})
        
        # 清理备份文件
        if backup_dir_path:
            backup_dir = Path(backup_dir_path)
            if backup_dir.exists():
                if hasattr(maintenance, 'get'):
                    retention_days = maintenance.get('backup_retention_days', 7)
                else:
                    retention_days = getattr(maintenance, 'backup_retention_days', 7)
                    
                cutoff_date = datetime.now() - timedelta(days=retention_days)
                
                backup_files = list(backup_dir.glob("*.m3u"))
                cleaned_count = 0
                
                for file_path in backup_files:
                    if datetime.fromtimestamp(file_path.stat().st_mtime) < cutoff_date:
                        file_path.unlink()
                        cleaned_count += 1
                        
                print(f"[清理] 清理了 {cleaned_count} 个过期备份文件")
        
        # 清理日志文件
        if log_dir_path:
            log_dir = Path(log_dir_path)
            if log_dir.exists():
                if hasattr(maintenance, 'get'):
                    log_retention_days = maintenance.get('log_retention_days', 30)
                else:
                    log_retention_days = getattr(maintenance, 'log_retention_days', 30)
                    
                cutoff_date = datetime.now() - timedelta(days=log_retention_days)
                
                log_files = list(log_dir.glob("*.log"))
                cleaned_count = 0
                
                for file_path in log_files:
                    if datetime.fromtimestamp(file_path.stat().st_mtime) < cutoff_date:
                        file_path.unlink()
                        cleaned_count += 1
                        
                print(f"[清理] 清理了 {cleaned_count} 个过期日志文件")
                
        print("[完成] 清理完成！")
        
    except Exception as e:
        print(f"[错误] 清理失败: {e}")


def get_current_version():
    """获取当前版本号 / Get current version"""
    return "1.0.7"

def get_remote_version():
    """获取远程版本号 / Get remote version"""
    import urllib.request
    import re
    
    try:
        # 从GitHub获取最新的iptv_manager.py文件
        url = "https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/iptv_manager.py"
        with urllib.request.urlopen(url, timeout=10) as response:
            content = response.read().decode('utf-8')
            
        # 使用正则表达式提取版本号
        version_pattern = r'版本 / Version: (\d+\.\d+\.\d+)'
        match = re.search(version_pattern, content)
        
        if match:
            return match.group(1)
        else:
            # 备用方案：查找其他版本标识
            version_pattern2 = r'version=\'IPTV Manager (\d+\.\d+\.\d+)\''
            match2 = re.search(version_pattern2, content)
            if match2:
                return match2.group(1)
                
        return None
    except Exception as e:
        print(f"Error getting remote version: {e}")
        return None

def compare_versions(version1, version2):
    """比较版本号 / Compare versions"""
    def version_tuple(v):
        return tuple(map(int, (v.split("."))))
    
    return version_tuple(version1) < version_tuple(version2)

def update_program(manager):
    """更新程序 / Update program"""
    try:
        import subprocess
        import tempfile
        
        print(f"{get_text('update_checking')}")
        
        # 获取当前版本和远程版本
        current_version = get_current_version()
        remote_version = get_remote_version()
        
        if remote_version is None:
            print(f"[{get_text('error')}] {get_text('update_failed')}: Unable to check remote version")
            print(f"[{get_text('info')}] You can manually update by running:")
            print("curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash")
            return
        
        print(f"{get_text('update_current')}: {current_version}")
        print(f"{get_text('update_latest')}: {remote_version}")
        
        # 比较版本号
        if not compare_versions(current_version, remote_version):
            print(f"[{get_text('info')}] {get_text('update_no_new')}")
            return
        
        print(f"\n[{get_text('info')}] {get_text('update_available')}")
        confirm = input(f"{get_text('update_confirm')} (Y/n): ").strip().lower()
        
        if confirm not in ['y', 'yes', '']:
            print(f"[{get_text('info')}] {get_text('update_cancelled')}")
            return
        
        # 下载最新的安装脚本
        print(f"{get_text('update_downloading')}")
        
        try:
            import urllib.request
            install_script_url = "https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh"
            
            with tempfile.NamedTemporaryFile(mode='w+b', suffix='.sh', delete=False) as temp_file:
                with urllib.request.urlopen(install_script_url, timeout=30) as script_response:
                    temp_file.write(script_response.read())
                temp_script_path = temp_file.name
            
            # 设置执行权限
            os.chmod(temp_script_path, 0o755)
            
            print(f"{get_text('update_installing')}")
            
            # 获取当前配置
            current_config = manager.config.config
            install_dir = current_config['directories']['base_dir']
            data_dir = current_config['directories']['data_dir']
            language = current_config.get('language', 'zh')
            
            # 设置环境变量进行更新安装
            env = os.environ.copy()
            env.update({
                'SKIP_INTERACTIVE': 'true',
                'INSTALL_LANGUAGE': language,
                'CUSTOM_INSTALL_DIR': install_dir,
                'CUSTOM_DATA_DIR': data_dir,
                'AUTO_RUN': 'n',
                'CREATE_SYMLINK': 'Y'
            })
            
            # 执行更新安装
            result = subprocess.run(['bash', temp_script_path], env=env, capture_output=True, text=True)
            
            # 清理临时文件
            os.unlink(temp_script_path)
            
            if result.returncode == 0:
                print(f"\n[{get_text('info')}] {get_text('update_success')}")
            else:
                print(f"\n[{get_text('error')}] {get_text('update_failed')}")
                if result.stderr:
                    print(f"Error details: {result.stderr}")
                    
        except Exception as e:
            print(f"[{get_text('error')}] {get_text('update_failed')}: {e}")
            print(f"[{get_text('info')}] You can manually update by running:")
            print("curl -fsSL https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh | bash")
            
    except Exception as e:
        print(f"[{get_text('error')}] {get_text('update_failed')}: {e}")


def switch_language(manager):
    """切换语言 / Switch language"""
    try:
        current_lang = manager.config.config.get('language', 'zh')
        
        print(f"{get_text('language_select')}:")
        print("1. 中文 (Chinese)")
        print("2. English")
        print(f"{get_text('current')}: {'中文' if current_lang == 'zh' else 'English'}")
        print()
        
        choice = input("Enter choice (1-2) / 输入选择 (1-2): ").strip()
        
        if choice == '1':
            new_lang = 'zh'
            lang_name = '中文'
        elif choice == '2':
            new_lang = 'en'
            lang_name = 'English'
        else:
            print(f"[{get_text('error')}] Invalid choice / 无效选择")
            return
        
        if new_lang == current_lang:
            print(f"[{get_text('info')}] Language unchanged / 语言未改变")
            return
        
        # 更新配置文件
        manager.config.config['language'] = new_lang
        manager.config._save_config()
        
        # 设置新语言
        set_language(new_lang)
        
        print(f"[{get_text('info')}] Language switched to {lang_name} / 语言已切换到{lang_name}")
        print(f"[{get_text('info')}] {get_text('update_success').replace('请重新启动程序', '').replace('Please restart the program', '')}")
        
    except Exception as e:
        print(f"[{get_text('error')}] Language switch failed / 语言切换失败: {e}")


def uninstall_program(manager):
    """卸载程序"""
    try:
        print("[警告] 此操作将完全删除 IPTV 管理系统及其所有数据！")
        print("[警告] 包括：程序文件、配置文件、直播源文件、备份文件、日志文件")
        print()
        
        confirm1 = input("确认要卸载吗？输入 'yes' 继续，其他任意键取消: ").strip()
        if confirm1.lower() != 'yes':
            return False
            
        print()
        confirm2 = input("最后确认：输入 'DELETE' 开始卸载: ").strip()
        if confirm2 != 'DELETE':
            return False
            
        print()
        print("[卸载] 开始卸载程序...")
        
        # 获取实际的目录配置
        print("[信息] 正在读取当前安装配置...")
        
        # 首先尝试从当前工作目录获取配置
        current_dir = Path.cwd()
        config_file = current_dir / 'config.json'
        
        base_dir = None
        data_dir = None
        
        if config_file.exists():
            try:
                import json
                with open(config_file, 'r', encoding='utf-8') as f:
                    file_config = json.load(f)
                base_dir = file_config.get('directories', {}).get('base_dir', str(current_dir))
                data_dir = file_config.get('directories', {}).get('data_dir', f'{base_dir}/data')
                print(f"[配置] 从配置文件读取: {config_file}")
            except Exception as e:
                print(f"[警告] 读取配置文件失败: {e}")
        
        # 如果配置文件读取失败，尝试从manager对象获取
        if not base_dir:
            try:
                if hasattr(manager.config, 'get'):
                    directories = manager.config.get('directories', {})
                    base_dir = directories.get('base_dir', str(current_dir))
                    data_dir = directories.get('data_dir', f'{base_dir}/data')
                else:
                    directories = getattr(manager.config, 'directories', {})
                    if hasattr(directories, 'get'):
                        base_dir = directories.get('base_dir', str(current_dir))
                        data_dir = directories.get('data_dir', f'{base_dir}/data')
                    else:
                        base_dir = getattr(directories, 'base_dir', str(current_dir))
                        data_dir = getattr(directories, 'data_dir', f'{base_dir}/data')
                print(f"[配置] 从管理器对象读取")
            except Exception as e:
                print(f"[警告] 从管理器读取配置失败: {e}")
                base_dir = str(current_dir)
                data_dir = f'{base_dir}/data'
        
        print(f"[路径] 程序目录: {base_dir}")
        print(f"[路径] 数据目录: {data_dir}")
        print()
        
        # 删除cron任务
        print("[卸载] 删除定时任务...")
        import subprocess
        try:
            # 获取当前crontab
            result = subprocess.run(['crontab', '-l'], capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.strip().split('\n')
                # 过滤掉包含iptv_manager.py的行
                filtered_lines = [line for line in lines if 'iptv_manager.py' not in line and 'iptv' not in line]
                
                if len(filtered_lines) != len(lines):
                    # 有变化，更新crontab
                    if filtered_lines and filtered_lines != ['']:
                        # 确保最后有换行符
                        cron_content = '\n'.join(filtered_lines) + '\n'
                        subprocess.run(['crontab', '-'], input=cron_content, text=True)
                    else:
                        subprocess.run(['crontab', '-r'], capture_output=True)
                    print("[卸载] 定时任务已删除")
                else:
                    print("[卸载] 未找到相关定时任务")
        except Exception as e:
            print(f"[警告] 删除定时任务失败: {e}")
        
        # 删除软连接
        print("[卸载] 删除软连接...")
        symlink_path = "/usr/local/bin/iptv"
        if Path(symlink_path).exists():
            try:
                subprocess.run(['sudo', 'rm', '-f', symlink_path], check=True)
                print("[卸载] 软连接已删除")
            except Exception as e:
                print(f"[警告] 删除软连接失败: {e}")
        
        # 删除程序目录
        print(f"[卸载] 删除程序目录: {base_dir}")
        base_path = Path(base_dir)
        if base_path.exists():
            try:
                if str(base_path).startswith('/opt/'):
                    subprocess.run(['sudo', 'rm', '-rf', str(base_path)], check=True)
                else:
                    import shutil
                    shutil.rmtree(base_path)
                print("[卸载] 程序目录已删除")
            except Exception as e:
                print(f"[错误] 删除程序目录失败: {e}")
                return False
        
        # 删除数据目录（如果与程序目录不同）
        if data_dir != f'{base_dir}/data':
            print(f"[卸载] 删除数据目录: {data_dir}")
            data_path = Path(data_dir)
            if data_path.exists():
                try:
                    if str(data_path).startswith('/opt/') or str(data_path).startswith('/media/'):
                        subprocess.run(['sudo', 'rm', '-rf', str(data_path)], check=True)
                    else:
                        import shutil
                        shutil.rmtree(data_path)
                    print("[卸载] 数据目录已删除")
                except Exception as e:
                    print(f"[错误] 删除数据目录失败: {e}")
        
        print()
        print("[完成] IPTV 管理系统已完全卸载")
        print("[信息] 感谢您的使用！")
        return True
        
    except Exception as e:
        print(f"[错误] 卸载失败: {e}")
        return False


def main():
    """主函数 / Main function"""
    import argparse
    
    parser = argparse.ArgumentParser(
        description='IPTV Live Source Management System / IPTV直播源管理系统',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument(
        '--download', 
        action='store_true',
        help='Download/update live sources directly / 直接下载/更新直播源'
    )
    
    parser.add_argument(
        '--status', 
        action='store_true',
        help='Show system status / 显示系统状态'
    )
    
    parser.add_argument(
        '--config', 
        type=str, 
        default='config.json',
        help='Configuration file path / 配置文件路径'
    )
    
    parser.add_argument(
        '--version', 
        action='version', 
        version='IPTV Manager 1.0.7'
    )
    
    args = parser.parse_args()
    
    try:
        # 预先加载语言设置
        if os.path.exists(args.config):
            try:
                import json
                with open(args.config, 'r', encoding='utf-8') as f:
                    config_data = json.load(f)
                language = config_data.get('language', 'zh')
                set_language(language)
            except Exception:
                set_language('zh')  # 默认中文
        else:
            set_language('zh')  # 默认中文
        
        manager = IPTVManager(args.config)
        
        if args.download:
            # 直接下载模式
            return manager.run()
        elif args.status:
            # 显示状态
            manager.show_status()
            return 0
        else:
            # 交互式模式
            return interactive_mode(manager)
            
    except KeyboardInterrupt:
        print(f"\n{get_text('user_interrupt')}")
        return 130
    except Exception as e:
        print(f"{get_text('error')}: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())