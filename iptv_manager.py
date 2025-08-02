#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IPTV直播源管理脚本
=================

功能描述:
- 自动下载和更新IPTV直播源
- 支持多源并发下载
- 配置文件管理所有参数
- 完整的日志记录和错误处理
- 文件版本控制和自动清理
- 兼容crontab定时执行

作者: IPTV管理脚本开发专家
版本: 1.0.0
适用环境: Debian服务器
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

# 检查并导入必要的依赖
def check_dependencies():
    """检查必要的依赖是否已安装"""
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
        print(f"错误: 缺少必要的依赖包: {', '.join(missing_deps)}")
        print("请运行以下命令安装:")
        print(f"python3 -m pip install {' '.join(missing_deps)} --user")
        print("或者:")
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
                "base_dir": "/data/media/iptv",
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
        """从文件加载配置"""
        if os.path.exists(self.config_path):
            try:
                with open(self.config_path, 'r', encoding='utf-8') as f:
                    user_config = json.load(f)
                    self._merge_config(self.config, user_config)
                logging.info(f"配置文件加载成功: {self.config_path}")
            except Exception as e:
                logging.warning(f"配置文件加载失败，使用默认配置: {e}")
        else:
            self._save_config()
            logging.info("创建默认配置文件")
    
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
        """验证配置有效性"""
        required_keys = ['sources', 'directories', 'download']
        for key in required_keys:
            if key not in self.config:
                raise ValueError(f"配置文件缺少必需的键: {key}")
        
        # 验证目录配置
        base_dir = self.config['directories']['base_dir']
        if not os.path.isabs(base_dir):
            raise ValueError("base_dir必须是绝对路径")
    
    def _save_config(self):
        """保存配置到文件"""
        try:
            with open(self.config_path, 'w', encoding='utf-8') as f:
                json.dump(self.config, f, indent=2, ensure_ascii=False)
        except Exception as e:
            logging.error(f"保存配置文件失败: {e}")
    
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
        """获取启用的直播源配置"""
        return {k: v for k, v in self.config['sources'].items() if v.get('enabled', True)}


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
                    logging.info(f"删除过期日志文件: {log_file}")
        except Exception as e:
            logging.error(f"清理日志文件失败: {e}")


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
            logging.debug(f"创建目录: {directory}")    

    def _detect_encoding(self, content: bytes) -> str:
        """检测文件编码"""
        try:
            result = chardet.detect(content)
            encoding = result.get('encoding', 'utf-8')
            confidence = result.get('confidence', 0)
            
            if confidence < 0.7:
                logging.warning(f"编码检测置信度较低: {confidence}, 使用UTF-8")
                return 'utf-8'
            
            logging.debug(f"检测到编码: {encoding}, 置信度: {confidence}")
            return encoding
        except Exception as e:
            logging.warning(f"编码检测失败，使用UTF-8: {e}")
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
        name = source_config.get('name', source_id)
        
        logging.info(f"开始下载 {name}: {url}")
        
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
                    raise ValueError("下载内容为空")
                
                # 检测编码并解码
                encoding = self._detect_encoding(content)
                try:
                    text_content = content.decode(encoding)
                except UnicodeDecodeError:
                    text_content = content.decode('utf-8', errors='ignore')
                    logging.warning(f"使用UTF-8强制解码: {filename}")
                
                # 验证M3U格式
                if not self._validate_m3u_content(text_content):
                    raise ValueError("无效的M3U文件格式")
                
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
                
                logging.info(f"下载成功 {name}: {filename} ({file_size} bytes, {channel_count} 频道)")
                return True, ""
                
            except requests.exceptions.RequestException as e:
                error_msg = f"网络请求失败: {e}"
                logging.warning(f"下载 {name} 失败 (尝试 {attempt + 1}/{retry_count}): {error_msg}")
                
                if attempt < retry_count - 1:
                    time.sleep(retry_delay)
                else:
                    logging.error(f"下载 {name} 最终失败: {error_msg}")
                    return False, error_msg
                    
            except Exception as e:
                error_msg = f"未知错误: {e}"
                logging.error(f"下载 {name} 失败: {error_msg}")
                return False, error_msg
        
        return False, "重试次数耗尽"
    
    def _validate_m3u_content(self, content: str) -> bool:
        """验证M3U文件内容格式"""
        if not content.strip():
            return False
        
        lines = content.strip().split('\n')
        if not lines[0].strip().startswith('#EXTM3U'):
            logging.warning("M3U文件缺少#EXTM3U头部，但继续处理")
        
        # 检查是否包含频道信息
        has_extinf = any(line.strip().startswith('#EXTINF:') for line in lines)
        has_urls = any(line.strip().startswith('http') for line in lines)
        
        return has_extinf and has_urls
    
    def _backup_file(self, file_path: Path):
        """备份现有文件"""
        try:
            backup_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.backup_dir')
            timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
            backup_name = f"{file_path.stem}_{timestamp}{file_path.suffix}"
            backup_path = backup_dir / backup_name
            
            shutil.copy2(file_path, backup_path)
            logging.debug(f"备份文件: {file_path} -> {backup_path}")
            
        except Exception as e:
            logging.warning(f"备份文件失败: {e}")
    
    def download_all_sources(self) -> Dict[str, Tuple[bool, str]]:
        """
        并发下载所有启用的直播源
        
        Returns:
            下载结果字典 {source_id: (成功标志, 错误信息)}
        """
        sources = self.config.get_sources()
        if not sources:
            logging.warning("没有启用的直播源")
            return {}
        
        logging.info(f"开始下载 {len(sources)} 个直播源")
        
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
        
        logging.info(f"下载完成: {success_count}/{total_count} 成功")
        
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
                    logging.debug(f"删除过期备份: {backup_file}")
            
            if deleted_count > 0:
                logging.info(f"清理过期备份文件: {deleted_count} 个")
                
        except Exception as e:
            logging.error(f"清理备份文件失败: {e}")
    
    def generate_status_report(self, download_results: Dict[str, Tuple[bool, str]]) -> str:
        """
        生成状态报告
        
        Args:
            download_results: 下载结果
            
        Returns:
            状态报告内容
        """
        report_lines = [
            "IPTV直播源管理状态报告",
            "=" * 50,
            f"生成时间: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}",
            ""
        ]
        
        # 下载结果统计
        if download_results:
            success_count = sum(1 for success, _ in download_results.values() if success)
            total_count = len(download_results)
            
            report_lines.extend([
                "下载结果统计:",
                f"  总计: {total_count} 个源",
                f"  成功: {success_count} 个",
                f"  失败: {total_count - success_count} 个",
                ""
            ])
            
            # 详细结果
            report_lines.append("详细结果:")
            for source_id, (success, error_msg) in download_results.items():
                status = "✓ 成功" if success else f"✗ 失败: {error_msg}"
                source_name = self.config.get(f'sources.{source_id}.name', source_id)
                report_lines.append(f"  {source_name}: {status}")
            
            report_lines.append("")
        
        # 文件信息
        data_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.data_dir')
        if data_dir.exists():
            report_lines.append("文件信息:")
            for m3u_file in data_dir.glob("*.m3u"):
                try:
                    stat = m3u_file.stat()
                    size = stat.st_size
                    mtime = datetime.fromtimestamp(stat.st_mtime).strftime('%Y-%m-%d %H:%M:%S')
                    
                    # 统计频道数量
                    with open(m3u_file, 'r', encoding='utf-8') as f:
                        content = f.read()
                        channel_count = content.count('#EXTINF:')
                    
                    report_lines.append(f"  {m3u_file.name}: {size} bytes, {channel_count} 频道, 更新时间: {mtime}")
                except Exception as e:
                    report_lines.append(f"  {m3u_file.name}: 读取失败 - {e}")
        
        return "\n".join(report_lines)
    
    def save_status_report(self, download_results: Dict[str, Tuple[bool, str]]):
        """保存状态报告到文件"""
        try:
            report_content = self.generate_status_report(download_results)
            
            log_dir = Path(self.config.get('directories.base_dir')) / self.config.get('directories.log_dir')
            report_file = log_dir / f"status_report_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
            
            with open(report_file, 'w', encoding='utf-8') as f:
                f.write(report_content)
            
            logging.info(f"状态报告已保存: {report_file}")
            
        except Exception as e:
            logging.error(f"保存状态报告失败: {e}")


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
            
            logging.info("IPTV管理器初始化完成")
            
        except Exception as e:
            print(f"初始化失败: {e}")
            sys.exit(1)
    
    def run(self):
        """执行主要任务流程"""
        try:
            logging.info("开始执行IPTV直播源更新任务")
            
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
                logging.warning(f"部分源下载失败: {', '.join(failed_sources)}")
                return 1
            else:
                logging.info("所有任务执行完成")
                return 0
                
        except Exception as e:
            logging.error(f"执行任务时发生错误: {e}")
            return 1
    
    def show_status(self):
        """显示当前状态"""
        try:
            download_results = {}  # 空结果用于显示文件状态
            report = self.maintenance.generate_status_report(download_results)
            print(report)
            
        except Exception as e:
            logging.error(f"显示状态失败: {e}")


def main():
    """主函数"""
    import argparse
    
    parser = argparse.ArgumentParser(description='IPTV直播源管理脚本')
    parser.add_argument('--config', '-c', default='config.json', help='配置文件路径')
    parser.add_argument('--status', '-s', action='store_true', help='显示当前状态')
    parser.add_argument('--version', '-v', action='version', version='IPTV Manager 1.0.0')
    
    args = parser.parse_args()
    
    try:
        manager = IPTVManager(args.config)
        
        if args.status:
            manager.show_status()
            return 0
        else:
            return manager.run()
            
    except KeyboardInterrupt:
        print("\n用户中断执行")
        return 130
    except Exception as e:
        print(f"程序执行失败: {e}")
        return 1


if __name__ == "__main__":
    sys.exit(main())