#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
多语言支持模块
Language Support Module
"""

# 中文语言包
LANG_ZH = {
    # 菜单相关
    "menu_title": "IPTV直播源管理系统",
    "project_description": "高性能IPTV直播源自动下载和管理工具",
    "project_url": "项目地址",
    "menu_download": "[下载] 下载/更新直播源",
    "menu_status": "[状态] 查看系统状态",
    "menu_list": "[列表] 查看直播源列表",
    "menu_config": "[配置] 配置管理",
    "menu_logs": "[日志] 查看日志",
    "menu_cleanup": "[清理] 清理维护",
    "menu_update": "[更新] 更新程序",
    "menu_cron": "[定时] 定时任务管理",
    "menu_uninstall": "[卸载] 卸载程序",
    "menu_exit": "[退出] 退出程序",
    "menu_prompt": "请输入选项 (0-10):",
    
    # 操作消息
    "download_start": "开始下载/更新直播源...",
    "download_complete": "直播源更新完成！",
    "download_error": "直播源更新遇到问题，请查看日志",
    "status_info": "系统状态信息",
    "file_list": "直播源文件列表",
    "config_info": "配置管理",
    "logs_recent": "查看最新日志",
    "cleanup_maintenance": "清理维护",
    "update_program": "更新程序",
    "uninstall_program": "卸载程序",
    "exit_message": "感谢使用 IPTV 管理系统，再见！",
    "continue_prompt": "按回车键继续...",
    "invalid_option": "无效选项，请输入 0-9 之间的数字",
    "operation_failed": "操作失败",
    "user_interrupt": "用户中断，退出程序",
    
    # 状态相关
    "status_report_title": "IPTV直播源管理状态报告",
    "generate_time": "生成时间",
    "download_stats": "下载结果统计",
    "total_sources": "总计",
    "success_sources": "成功",
    "failed_sources": "失败",
    "detailed_results": "详细结果",
    "file_info": "文件信息",
    "channels": "频道",
    "update_time": "更新时间",
    "read_failed": "读取失败",
    
    # 文件操作
    "directory": "目录",
    "file_count": "共找到",
    "files": "个直播源文件",
    "no_files": "未找到直播源文件，请先下载直播源",
    "file_size": "大小",
    "file_time": "时间",
    "get_file_info_failed": "获取文件信息失败",
    
    # 配置相关
    "config_current": "当前配置信息",
    "config_directories": "目录配置",
    "config_sources": "直播源配置",
    "config_download": "下载配置",
    "config_enabled": "启用",
    "config_disabled": "禁用",
    "timeout": "超时时间",
    "retry_count": "重试次数",
    "concurrency": "并发数",
    "seconds": "秒",
    "times": "次",
    "workers": "个",
    
    # 日志相关
    "log_directory": "日志目录",
    "log_not_exist": "日志目录不存在",
    "log_no_files": "未找到日志文件",
    "log_recent": "最新日志内容",
    "log_file": "日志文件",
    
    # 下载相关
    "download_source": "开始下载",
    "download_success": "下载成功",
    "download_failed": "下载失败",
    "download_retry": "重试",
    "download_final_failed": "最终失败",
    "download_complete_stats": "下载完成",
    "network_error": "网络请求失败",
    "unknown_error": "未知错误",
    "retry_exhausted": "重试次数耗尽",
    "invalid_m3u": "无效的M3U文件格式",
    "empty_content": "下载内容为空",
    "encoding_detection_failed": "编码检测失败，使用UTF-8",
    "encoding_detection_low": "编码检测置信度较低",
    "detected_encoding": "检测到编码",
    "confidence": "置信度",
    "force_utf8": "使用UTF-8强制解码",
    "backup_file": "备份文件",
    "backup_failed": "备份文件失败",
    
    # 维护相关
    "cleanup_old_backups": "清理过期备份文件",
    "cleanup_old_logs": "删除过期日志文件",
    "deleted_backup": "删除过期备份",
    "deleted_log": "删除过期日志文件",
    "cleanup_failed": "清理文件失败",
    "status_report_saved": "状态报告已保存",
    "save_report_failed": "保存状态报告失败",
    
    # 初始化相关
    "init_complete": "IPTV管理器初始化完成",
    "init_failed": "初始化失败",
    "config_loaded": "配置文件加载成功",
    "config_load_failed": "配置文件加载失败，使用默认配置",
    "config_created": "创建默认配置文件",
    "config_save_failed": "保存配置文件失败",
    "missing_config_key": "配置文件缺少必需的键",
    "invalid_base_dir": "base_dir必须是绝对路径",
    "create_directory": "创建目录",
    "task_start": "开始执行IPTV直播源更新任务",
    "task_complete": "所有任务执行完成",
    "task_error": "执行任务时发生错误",
    "partial_failed": "部分源下载失败",
    "show_status_failed": "显示状态失败",
    
    # 新增文本
    "sources": "个源",
    "status_report_title": "IPTV直播源管理状态报告",
    "generate_time": "生成时间",
    
    # 日志相关
    "log_directory": "日志目录",
    "log_not_exist": "日志目录不存在",
    "log_no_files": "未找到日志文件",
    "log_recent": "最新日志内容",
    "log_file": "日志文件",
    "log_latest_file": "最新日志文件",
    "log_content": "内容",
    "log_recent_lines": "最近行数",
    
    # 清理相关
    "cleanup_start": "开始清理过期文件...",
    "cleanup_backups": "清理了过期备份文件",
    "cleanup_logs": "清理了过期日志文件", 
    "cleanup_complete": "清理完成！",
    "cleanup_files": "个",
    
    # 通用标签
    "label_directory": "目录",
    "label_statistics": "统计",
    "label_file": "文件",
    "label_size": "大小",
    "label_time": "时间",
    "label_content": "内容",
    "label_language": "语言",
    "label_directories": "目录配置",
    "label_sources": "直播源配置",
    "label_download": "下载配置",
    "label_cleanup": "清理",
    "label_complete": "完成",
    
    # 错误相关
    "error": "错误",
    "warning": "警告",
    "info": "信息",
    "debug": "调试",
    "missing_dependencies": "缺少必要的依赖包",
    "install_dependencies": "请运行以下命令安装",
    "or": "或者",
    
    # 更新相关
    "update_checking": "检查更新中...",
    "update_available": "发现新版本",
    "update_current": "当前版本",
    "update_latest": "最新版本",
    "update_confirm": "是否立即更新?",
    "update_downloading": "下载更新中...",
    "update_installing": "安装更新中...",
    "update_success": "更新完成！请重新启动程序",
    "update_failed": "更新失败",
    "update_no_new": "已是最新版本",
    "update_cancelled": "更新已取消",
    
    # 卸载相关
    "uninstall_warning": "此操作将完全删除 IPTV 管理系统及其所有数据！",
    "uninstall_warning_details": "包括：程序文件、配置文件、直播源文件、备份文件、日志文件",
    "uninstall_confirm1": "确认要卸载吗？输入 'yes' 继续，其他任意键取消",
    "uninstall_confirm2": "最后确认：输入 'DELETE' 开始卸载",
    
    # 语言切换相关
    "language": "语言",
    "current": "当前",
    "menu_language": "[语言] 切换语言",
    "language_switch": "语言切换",
    "language_select": "请选择语言",
    "language_chinese": "中文",
    "language_english": "English",
    "language_switched": "语言已切换",
    "language_restart": "请重新启动程序以完全应用语言设置",
    
    # 定时任务管理相关
    "cron_management": "定时任务管理",
    "cron_current_status": "当前定时任务状态",
    "cron_not_configured": "未配置定时任务",
    "cron_configured": "已配置，执行频率",
    "cron_every_6_hours": "每6小时一次",
    "cron_daily_2am": "每天凌晨2点",
    "cron_every_hour": "每小时一次",
    "cron_custom": "自定义配置",
    "cron_options_title": "定时任务选项",
    "cron_option_view": "查看当前配置",
    "cron_option_set": "设置/修改定时任务",
    "cron_option_remove": "删除定时任务",
    "cron_option_back": "返回主菜单",
    "cron_select_frequency": "请选择执行频率",
    "cron_set_success": "定时任务设置成功",
    "cron_set_failed": "定时任务设置失败",
    "cron_remove_confirm": "确认删除所有 IPTV Manager 定时任务?",
    "cron_remove_success": "定时任务已删除",
    "cron_remove_failed": "删除定时任务失败",
    "cron_no_permission": "无权限操作 crontab",
    "task_content": "任务内容",
    "enter_choice_default_1": "输入选择 (默认: 1) >",
}

# 英文语言包
LANG_EN = {
    "uninstall_warning": "This will completely remove the IPTV Manager and all its data!",
    "uninstall_warning_details": "Including: program files, config files, channel lists, backups and logs",
    "uninstall_confirm1": "Confirm uninstall? Enter 'yes' to continue, any other key to cancel",
    "uninstall_confirm2": "Final confirmation: Enter 'DELETE' to start uninstall",
    # 菜单相关
    "menu_title": "IPTV Live Source Management System",
    "project_description": "High-Performance IPTV Live Source Management Tool",
    "project_url": "Project URL",
    "menu_download": "[Download] Download/update live sources",
    "menu_status": "[Status] View system status",
    "menu_list": "[List] View live source list",
    "menu_config": "[Config] Configuration management",
    "menu_logs": "[Logs] View logs",
    "menu_cleanup": "[Cleanup] Cleanup maintenance",
    "menu_update": "[Update] Update program",
    "menu_cron": "[Cron] Scheduled Task Management",
    "menu_uninstall": "[Uninstall] Uninstall program",
    "menu_exit": "[Exit] Exit program",
    "menu_prompt": "Enter option (0-10):",
    
    # 操作消息
    "download_start": "Starting download/update of live sources...",
    "download_complete": "Live source update completed!",
    "download_error": "Live source update encountered issues, please check logs",
    "status_info": "System Status Information",
    "file_list": "Live Source File List",
    "config_info": "Configuration Management",
    "logs_recent": "View Recent Logs",
    "cleanup_maintenance": "Cleanup Maintenance",
    "update_program": "Update Program",
    "uninstall_program": "Uninstall Program",
    "exit_message": "Thank you for using IPTV Manager, goodbye!",
    "continue_prompt": "Press Enter to continue...",
    "invalid_option": "Invalid option, please enter a number between 0-9",
    "operation_failed": "Operation failed",
    "user_interrupt": "User interrupt, exiting program",
    
    # 状态相关
    "status_report_title": "IPTV Live Source Management Status Report",
    "generate_time": "Generated at",
    "download_stats": "Download Statistics",
    "total_sources": "Total",
    "success_sources": "Success",
    "failed_sources": "Failed",
    "detailed_results": "Detailed Results",
    "file_info": "File Information",
    "channels": "channels",
    "update_time": "Updated",
    "read_failed": "Read failed",
    
    # 文件操作
    "directory": "Directory",
    "file_count": "Found",
    "files": "live source files",
    "no_files": "No live source files found, please download first",
    "file_size": "Size",
    "file_time": "Time",
    "get_file_info_failed": "Failed to get file information",
    
    # 配置相关
    "config_current": "Current Configuration",
    "config_directories": "Directory Configuration",
    "config_sources": "Live Source Configuration",
    "config_download": "Download Configuration",
    "config_enabled": "Enabled",
    "config_disabled": "Disabled",
    "timeout": "Timeout",
    "retry_count": "Retry Count",
    "concurrency": "Concurrency",
    "seconds": "seconds",
    "times": "times",
    "workers": "workers",
    
    # 日志相关
    "log_directory": "Log Directory",
    "log_not_exist": "Log directory does not exist",
    "log_no_files": "No log files found",
    "log_recent": "Recent Log Content",
    "log_file": "Log File",
    
    # 下载相关
    "download_source": "Starting download",
    "download_success": "Download successful",
    "download_failed": "Download failed",
    "download_retry": "Retry",
    "download_final_failed": "Final failure",
    "download_complete_stats": "Download completed",
    "network_error": "Network request failed",
    "unknown_error": "Unknown error",
    "retry_exhausted": "Retry attempts exhausted",
    "invalid_m3u": "Invalid M3U file format",
    "empty_content": "Downloaded content is empty",
    "encoding_detection_failed": "Encoding detection failed, using UTF-8",
    "encoding_detection_low": "Low confidence in encoding detection",
    "detected_encoding": "Detected encoding",
    "confidence": "confidence",
    "force_utf8": "Force UTF-8 decoding",
    "backup_file": "Backup file",
    "backup_failed": "Backup file failed",
    
    # 维护相关
    "cleanup_old_backups": "Cleanup old backup files",
    "cleanup_old_logs": "Delete old log files",
    "deleted_backup": "Deleted old backup",
    "deleted_log": "Deleted old log file",
    "cleanup_failed": "Cleanup files failed",
    "status_report_saved": "Status report saved",
    "save_report_failed": "Save status report failed",
    
    # 初始化相关
    "init_complete": "IPTV Manager initialization completed",
    "init_failed": "Initialization failed",
    "config_loaded": "Configuration file loaded successfully",
    "config_load_failed": "Configuration file load failed, using default config",
    "config_created": "Created default configuration file",
    "config_save_failed": "Save configuration file failed",
    "missing_config_key": "Configuration file missing required key",
    "invalid_base_dir": "base_dir must be an absolute path",
    "create_directory": "Create directory",
    "task_start": "Starting IPTV live source update task",
    "task_complete": "All tasks completed",
    "task_error": "Error occurred while executing tasks",
    "partial_failed": "Some sources failed to download",
    "show_status_failed": "Show status failed",
    
    # 新增文本
    "sources": "sources",
    "status_report_title": "IPTV Live Source Management Status Report",
    "generate_time": "Generated at",
    
    # 日志相关
    "log_directory": "Log Directory",
    "log_not_exist": "Log directory does not exist",
    "log_no_files": "No log files found",
    "log_recent": "Recent Log Content",
    "log_file": "Log File",
    "log_latest_file": "Latest log file",
    "log_content": "Content",
    "log_recent_lines": "Recent lines",
    
    # 清理相关
    "cleanup_start": "Starting cleanup of expired files...",
    "cleanup_backups": "Cleaned up expired backup files",
    "cleanup_logs": "Cleaned up expired log files",
    "cleanup_complete": "Cleanup completed!",
    "cleanup_files": "files",
    
    # 通用标签
    "label_directory": "Directory",
    "label_statistics": "Statistics",
    "label_file": "File",
    "label_size": "Size", 
    "label_time": "Time",
    "label_content": "Content",
    "label_language": "Language",
    "label_directories": "Directory Configuration",
    "label_sources": "Live Source Configuration",
    "label_download": "Download Configuration",
    "label_cleanup": "Cleanup",
    "label_complete": "Complete",
    
    # 错误相关
    "error": "Error",
    "warning": "Warning",
    "info": "Info",
    "debug": "Debug",
    "missing_dependencies": "Missing required dependencies",
    "install_dependencies": "Please run the following command to install",
    "or": "or",
    
    # 更新相关
    "update_checking": "Checking for updates...",
    "update_available": "New version available",
    "update_current": "Current version",
    "update_latest": "Latest version",
    "update_confirm": "Update now?",
    "update_downloading": "Downloading update...",
    "update_installing": "Installing update...",
    "update_success": "Update completed! Please restart the program",
    "update_failed": "Update failed",
    "update_no_new": "Already up to date",
    "update_cancelled": "Update cancelled",
    
    # 语言切换相关
    "language": "Language",
    "current": "Current",
    "menu_language": "[Language] Switch Language",
    "language_switch": "Language Switch",
    "language_select": "Please select language",
    "language_chinese": "中文",
    "language_english": "English",
    "language_switched": "Language switched",
    "language_restart": "Please restart the program to fully apply language settings",
    
    # Cron management related
    "cron_management": "Scheduled Task Management",
    "cron_current_status": "Current Status",
    "cron_not_configured": "Not configured",
    "cron_configured": "Configured, frequency",
    "cron_every_6_hours": "Every 6 hours",
    "cron_daily_2am": "Daily at 2 AM",
    "cron_every_hour": "Every hour",
    "cron_custom": "Custom",
    "cron_options_title": "Scheduled Task Options",
    "cron_option_view": "View current configuration",
    "cron_option_set": "Set/modify scheduled task",
    "cron_option_remove": "Remove scheduled task",
    "cron_option_back": "Back to main menu",
    "cron_select_frequency": "Please select frequency",
    "cron_set_success": "Scheduled task set successfully",
    "cron_set_failed": "Failed to set scheduled task",
    "cron_remove_confirm": "Confirm removal of all IPTV Manager scheduled tasks?",
    "cron_remove_success": "Scheduled task removed",
    "cron_remove_failed": "Failed to remove scheduled task",
    "cron_no_permission": "No permission to operate crontab",
    "task_content": "Task content",
    "enter_choice_default_1": "Enter choice (default: 1) >",
}

# 语言映射
LANGUAGES = {
    'zh': LANG_ZH,
    'en': LANG_EN
}

class LanguageManager:
    """语言管理器"""
    
    def __init__(self, language='zh'):
        """
        初始化语言管理器
        
        Args:
            language: 语言代码 ('zh' 或 'en')
        """
        self.language = language
        self.texts = LANGUAGES.get(language, LANG_ZH)
    
    def get(self, key, *args, **kwargs):
        """
        获取翻译文本
        
        Args:
            key: 文本键
            *args: 格式化参数
            **kwargs: 格式化参数
            
        Returns:
            翻译后的文本
        """
        text = self.texts.get(key, key)
        if args or kwargs:
            try:
                return text.format(*args, **kwargs)
            except:
                return text
        return text
    
    def set_language(self, language):
        """
        设置语言
        
        Args:
            language: 语言代码
        """
        if language in LANGUAGES:
            self.language = language
            self.texts = LANGUAGES[language]
    
    def get_available_languages(self):
        """获取可用语言列表"""
        return list(LANGUAGES.keys())

# 全局语言管理器实例
lang_manager = LanguageManager()

def get_text(key, *args, **kwargs):
    """
    Newly added text keys for logging:
    - 'config_load_success': 'Configuration loaded successfully'
    - 'config_load_fail': 'Configuration load failed, using default'
    - 'config_create_default': 'Default configuration file created'
    - 'm3u_missing_header': 'M3U file missing #EXTM3U header, but continuing processing'
    - 'source_download_error': 'Source {0} download task exception'
    - 'no_enabled_sources': 'No enabled live sources'
    """
    """
    获取翻译文本的便捷函数
    
    Args:
        key: 文本键
        *args: 格式化参数
        **kwargs: 格式化参数
        
    Returns:
        翻译后的文本
    """
    return lang_manager.get(key, *args, **kwargs)

def set_language(language):
    """
    设置全局语言
    
    Args:
        language: 语言代码
    """
    lang_manager.set_language(language)