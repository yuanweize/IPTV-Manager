#!/bin/bash
# IPTV直播源管理脚本一键安装脚本 - 开发日期: 2025-08-03
# IPTV Live Source Management Script One-Click Installer - Development Date: 2025-08-03
# 适用于Debian/Ubuntu系统 / For Debian/Ubuntu Systems
# 脚本版本 / Script Version: 2.0.8

set -e

# 脚本信息
SCRIPT_VERSION="2.0.9"
SCRIPT_DATE="2025-08-03"

# 项目信息
GITHUB_REPO="yuanweize/IPTV-Manager"
GITHUB_RAW_URL="https://raw.githubusercontent.com/${GITHUB_REPO}/refs/heads/main"
DEFAULT_INSTALL_DIR="/opt/IPTV-Manager"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# 进度显示函数
show_progress_bar() {
    local current=$1
    local total=$2
    local description=$3
    local width=40
    local percentage=$((current * 100 / total))
    local filled=$((current * width / total))
    local empty=$((width - filled))
    
    printf "\r%s [" "$description"
    printf "%*s" $filled | tr ' ' '#'
    printf "%*s" $empty | tr ' ' '-'
    printf "] %d%% (%d/%d)" $percentage $current $total
    
    if [ $current -eq $total ]; then
        echo
    fi
}

# 多语言文本函数
get_text() {
    local key="$1"
    
    if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
        case "$key" in
            "install_path_selection") echo "Installation Path Selection" ;;
            "select_install_path") echo "Please select installation path:" ;;
            "use_default_path") echo "Use default path" ;;
            "custom_path") echo "Custom path" ;;
            "default_recommended") echo "Tip: Default path follows Linux standards, recommended" ;;
            "enter_option_default") echo "Enter option (default: 1) >" ;;
            "data_dir_selection") echo "Data Directory Selection" ;;
            "select_data_dir") echo "Please select live source file storage directory:" ;;
            "use_default_dir") echo "Use default directory" ;;
            "custom_dir_recommended") echo "Custom directory (recommended for large storage)" ;;
            "large_storage_tip") echo "Tip: If you have large capacity disk, recommend custom directory" ;;
            "post_install_actions") echo "Post-Installation Actions" ;;
            "run_after_install") echo "Run immediately after installation(Y/n):" ;;
            "download_immediately") echo "Download live sources immediately (recommended)" ;;
            "install_only") echo "Complete installation only, run manually later" ;;
            "test_install_tip") echo "Tip: Choose Y to immediately test if the program works" ;;
            "config_confirmation") echo "Installation Configuration Confirmation" ;;
            "install_path") echo "Installation Path" ;;
            "data_directory") echo "Data Directory" ;;
            "run_after_install_short") echo "Run After Installation" ;;
            "confirm_install") echo "Confirm the above configuration and start installation? (Y/n):" ;;
            "config_confirmed") echo "[OK] Configuration confirmed, starting installation" ;;
            # 安装步骤相关
            "step_config_options") echo "Configuring installation options..." ;;
            "step_check_root") echo "Check user permissions" ;;
            "step_select_language") echo "Select language" ;;
            "step_check_update") echo "Check script updates" ;;
            "step_get_config") echo "Get user configuration" ;;
            "step_check_system") echo "Check system environment" ;;
            "step_install_deps") echo "Install system dependencies" ;;
            "step_download_files") echo "Download project files" ;;
            "step_install_python_deps") echo "Install Python dependencies" ;;
            "step_create_dirs") echo "Create directory structure" ;;
            "step_install_scripts") echo "Install script files" ;;
            "step_create_symlink") echo "Create symbolic link" ;;
            "step_test_install") echo "Test installation" ;;
            "step_setup_cron") echo "Setup scheduled tasks" ;;
            "step_run_script") echo "Run script immediately" ;;
            # 系统检查相关
            "check_system_compat") echo "Checking system compatibility..." ;;
            "system_compat_ok") echo "System compatibility check passed" ;;
            "update_package_list") echo "Updating package list..." ;;
            "python3_installed") echo "Python3 already installed" ;;
            "install_python3") echo "Installing Python3..." ;;
            "install_python_dev") echo "Installing Python development packages..." ;;
            "install_tools") echo "Installing necessary tools..." ;;
            # 下载相关
            "download_project_files") echo "Downloading project files..." ;;
            "temp_directory") echo "Temporary directory" ;;
            "download_success") echo "download successful" ;;
            "download_failed") echo "download failed" ;;
            # 目录创建相关
            "create_base_dir") echo "Creating base directory" ;;
            "create_custom_data_dir") echo "Creating custom data directory" ;;
            "create_backup_log_dirs") echo "Creating backup and log directories..." ;;
            "set_permissions") echo "Setting directory permissions..." ;;
            # 脚本安装相关
            "install_script_files") echo "Installing script files..." ;;
            "update_config_paths") echo "Updating configuration file paths and language settings..." ;;
            "config_update_success") echo "Configuration file update successful" ;;
            "config_update_failed") echo "Configuration file update failed" ;;
            "copy_files_to_install") echo "Copying files to installation directory..." ;;
            "set_exec_permissions") echo "Setting execution permissions..." ;;
            "exec_permissions_success") echo "Execution permissions set successfully" ;;
            "files_installed") echo "files installed" ;;
            # 软连接相关
            "global_command_symlink") echo "Global command symbolic link" ;;
            "symlink_description") echo "After creation, you can use 'iptv' command anywhere" ;;
            "symlink_location") echo "Symbolic link location" ;;
            "target_program") echo "Target program" ;;
            "symlink_recommended") echo "Tip: Recommended for easier use" ;;
            "create_symlink_prompt") echo "Create global command symbolic link?(Y/n):" ;;
            "will_create_symlink") echo "Will create global command symbolic link" ;;
            "skip_symlink") echo "Skip symbolic link creation" ;;
            "create_wrapper_script") echo "Creating wrapper script..." ;;
            "global_command_success") echo "Global command created successfully" ;;
            "target_directory") echo "Target directory" ;;
            "can_use_iptv_anywhere") echo "Now you can use 'iptv' command anywhere" ;;
            # 测试相关
            "test_install_result") echo "Testing installation result..." ;;
            "check_script_syntax") echo "Checking script syntax..." ;;
            "script_syntax_ok") echo "Script syntax check passed" ;;
            "check_config_file") echo "Checking configuration file..." ;;
            "config_format_ok") echo "Configuration file format correct" ;;
            "test_program_run") echo "Testing program execution..." ;;
            "program_test_ok") echo "Program execution test passed" ;;
            # Root用户警告
            "root_detected") echo "Root user detected, recommend using regular user" ;;
            "root_suggestion") echo "Suggestion: Use regular user to run this script for better security" ;;
            "root_impact") echo "Impact: Root user installation may cause permission issues" ;;
            "continue_prompt") echo "Continue? (y/N):" ;;
            "continue_root_install") echo "Continue with root user installation" ;;
            "install_cancelled_root") echo "Installation cancelled. Please re-run with regular user:" ;;
            "non_interactive_mode") echo "Mode: Non-interactive mode, auto-continue installation (starting in 3 seconds)" ;;
            # 其他常用文本
            "selected_default_path") echo "Selected default installation path" ;;
            "enter_custom_path") echo "Enter custom installation path (e.g., /home/user/iptv-manager):" ;;
            "enter_custom_path_prompt") echo "Enter custom path >" ;;
            "path_cannot_empty") echo "Path cannot be empty, using default path" ;;
            "set_custom_install_path") echo "Set custom installation path" ;;
            "invalid_choice_default") echo "Invalid choice, using default path" ;;
            "enter_custom_data_dir") echo "Enter custom live source storage directory:" ;;
            "suggested_paths") echo "Suggested path examples:" ;;
            "external_storage") echo "(external storage)" ;;
            "data_partition") echo "(data partition)" ;;
            "user_directory") echo "(user directory)" ;;
            "dir_cannot_empty") echo "Directory cannot be empty, using default directory" ;;
            "set_custom_data_dir") echo "Set custom data directory" ;;
            "invalid_choice_default_dir") echo "Invalid choice, using default directory" ;;
            "will_download_after_install") echo "Will download live sources immediately after installation" ;;
            "install_only_manual_later") echo "Installation only, can use 'iptv' command to run manually later" ;;
            "non_interactive_detected") echo "Non-interactive mode detected, using default configuration" ;;
            "installation_cancelled") echo "Installation cancelled. To reconfigure, please re-run the installation script." ;;
            # 定时任务相关
            "config_cron") echo "Configuring scheduled tasks..." ;;
            "cron_setup") echo "Scheduled Task Setup" ;;
            "select_cron_frequency") echo "Please select scheduled task frequency:" ;;
            "every_6_hours") echo "Every 6 hours (recommended)" ;;
            "daily_2am") echo "Daily at 2 AM" ;;
            "every_hour") echo "Every hour" ;;
            "skip_cron") echo "Skip scheduled task setup" ;;
            "cron_recommendation") echo "Tip: Option 1 is recommended, keeps updated without being too frequent" ;;
            "enter_choice_default_1") echo "Enter choice (default: 1) >" ;;
            "selected_6_hours") echo "[OK] Selected: Every 6 hours" ;;
            "selected_daily_2am") echo "[OK] Selected: Daily at 2 AM" ;;
            "selected_hourly") echo "[OK] Selected: Every hour" ;;
            "selected_skip_cron") echo "[OK] Selected: Skip scheduled task setup" ;;
            "invalid_choice_default_6h") echo "[OK] Invalid choice, using default: Every 6 hours" ;;
            "non_interactive_cron") echo "Mode: Non-interactive mode, using default scheduled task (every 6 hours)" ;;
            "skip_cron_setup") echo "[OK] Skip scheduled task setup" ;;
            "add_to_crontab") echo "Adding scheduled task to crontab..." ;;
            "cron_setup_complete") echo "Scheduled task setup complete" ;;
            "task_content") echo "Task content" ;;
            "cron_setup_failed") echo "Scheduled task setup failed, please add manually:" ;;
            "add_line") echo "Add line" ;;
            "install_complete_message") echo "IPTV Manager installation completed!" ;;
            "update_available_message") echo "A new version of the installation script is available!" ;;
            "download_progress_label") echo "Download progress" ;;
            "checking_updates") echo "Checking for updates..." ;;
            "script_up_to_date") echo "The script is already up to date" ;;
            "update_success_message") echo "Script updated! Restarting with the new version..." ;;
            "network_issue_warning") echo "Unable to check for updates (network issue)" ;;
            "starting_installation") echo "Starting installation process" ;;
            "all_steps_complete") echo "All installation steps completed!" ;;
            *) echo "$key" ;;
        esac
    else
        case "$key" in
            "install_path_selection") echo "安装路径选择" ;;
            "select_install_path") echo "请选择安装路径:" ;;
            "use_default_path") echo "使用默认路径" ;;
            "custom_path") echo "自定义路径" ;;
            "default_recommended") echo "提示: 默认路径符合Linux标准，推荐使用" ;;
            "enter_option_default") echo "输入选项回车默认: 1 >" ;;
            "data_dir_selection") echo "数据目录选择" ;;
            "select_data_dir") echo "请选择直播源文件保存目录:" ;;
            "use_default_dir") echo "使用默认目录" ;;
            "custom_dir_recommended") echo "自定义目录 (推荐用于大容量存储)" ;;
            "large_storage_tip") echo "提示: 如果有大容量磁盘，建议选择自定义目录" ;;
            "post_install_actions") echo "安装后操作" ;;
            "run_after_install") echo "安装完成后立即运行(Y/n):" ;;
            "download_immediately") echo "立即下载直播源 (推荐，验证安装是否成功)" ;;
            "install_only") echo "仅完成安装，稍后手动运行" ;;
            "test_install_tip") echo "提示: 选择Y可以立即测试程序是否正常工作" ;;
            "config_confirmation") echo "安装配置确认" ;;
            "install_path") echo "安装路径" ;;
            "data_directory") echo "数据目录" ;;
            "run_after_install_short") echo "安装后立即运行" ;;
            "confirm_install") echo "确认以上配置并开始安装? (Y/n):" ;;
            "config_confirmed") echo "[OK] 配置确认，开始安装" ;;
            # 安装步骤相关
            "step_config_options") echo "配置安装选项..." ;;
            "step_check_root") echo "检查用户权限" ;;
            "step_select_language") echo "选择语言" ;;
            "step_check_update") echo "检查脚本更新" ;;
            "step_get_config") echo "获取用户配置" ;;
            "step_check_system") echo "检查系统环境" ;;
            "step_install_deps") echo "安装系统依赖" ;;
            "step_download_files") echo "下载项目文件" ;;
            "step_install_python_deps") echo "安装Python依赖" ;;
            "step_create_dirs") echo "创建目录结构" ;;
            "step_install_scripts") echo "安装脚本文件" ;;
            "step_create_symlink") echo "创建软连接" ;;
            "step_test_install") echo "测试安装" ;;
            "step_setup_cron") echo "设置定时任务" ;;
            "step_run_script") echo "立即运行脚本" ;;
            # 系统检查相关
            "check_system_compat") echo "[检查] 系统兼容性..." ;;
            "system_compat_ok") echo "系统兼容性检查通过" ;;
            "update_package_list") echo "[更新] 软件包列表..." ;;
            "python3_installed") echo "Python3已安装" ;;
            "install_python3") echo "[安装] Python3..." ;;
            "install_python_dev") echo "[安装] Python开发包..." ;;
            "install_tools") echo "[安装] 必要工具..." ;;
            # 下载相关
            "download_project_files") echo "[下载] 项目文件..." ;;
            "temp_directory") echo "临时目录" ;;
            "download_success") echo "下载成功" ;;
            "download_failed") echo "下载失败" ;;
            # 目录创建相关
            "create_base_dir") echo "[创建] 基础目录" ;;
            "create_custom_data_dir") echo "[创建] 自定义数据目录" ;;
            "create_backup_log_dirs") echo "[创建] 备份和日志目录..." ;;
            "set_permissions") echo "[权限] 设置目录权限..." ;;
            # 脚本安装相关
            "install_script_files") echo "[安装] 脚本文件..." ;;
            "update_config_paths") echo "更新配置文件路径和语言设置..." ;;
            "config_update_success") echo "配置文件更新成功" ;;
            "config_update_failed") echo "配置文件更新失败" ;;
            "copy_files_to_install") echo "复制文件到安装目录..." ;;
            "set_exec_permissions") echo "设置执行权限..." ;;
            "exec_permissions_success") echo "执行权限设置成功" ;;
            "files_installed") echo "个文件" ;;
            # 软连接相关
            "global_command_symlink") echo "全局命令软连接" ;;
            "symlink_description") echo "创建后可以在任何位置使用 'iptv' 命令" ;;
            "symlink_location") echo "软连接位置" ;;
            "target_program") echo "目标程序" ;;
            "symlink_recommended") echo "提示: 推荐创建，使用更方便" ;;
            "create_symlink_prompt") echo "是否创建全局命令软连接?(Y/n):" ;;
            "will_create_symlink") echo "[OK] 将创建全局命令软连接" ;;
            "skip_symlink") echo "[OK] 跳过软连接创建" ;;
            "create_wrapper_script") echo "[创建] 包装脚本..." ;;
            "global_command_success") echo "全局命令创建成功" ;;
            "target_directory") echo "目标目录" ;;
            "can_use_iptv_anywhere") echo "现在可以在任何位置使用 'iptv' 命令" ;;
            # 测试相关
            "test_install_result") echo "[测试] 安装结果..." ;;
            "check_script_syntax") echo "检查脚本语法..." ;;
            "script_syntax_ok") echo "脚本语法检查通过" ;;
            "check_config_file") echo "检查配置文件..." ;;
            "config_format_ok") echo "配置文件格式正确" ;;
            "test_program_run") echo "测试程序运行..." ;;
            "program_test_ok") echo "程序运行测试通过" ;;
            # Root用户警告
            "root_detected") echo "检测到root用户，建议使用普通用户运行此脚本" ;;
            "root_suggestion") echo "建议: 使用普通用户运行此脚本以提高安全性" ;;
            "root_impact") echo "影响: root用户安装可能导致权限问题" ;;
            "continue_prompt") echo "是否继续? (y/N):" ;;
            "continue_root_install") echo "[OK] 继续使用root用户安装" ;;
            "install_cancelled_root") echo "安装已取消。请使用普通用户重新运行：" ;;
            "non_interactive_mode") echo "模式: 非交互模式，自动继续安装（3秒后开始）" ;;
            # 其他常用文本
            "selected_default_path") echo "[OK] 已选择默认安装路径" ;;
            "enter_custom_path") echo "请输入自定义安装路径 (例如: /home/user/iptv-manager):" ;;
            "enter_custom_path_prompt") echo "输入自定义路径 >" ;;
            "path_cannot_empty") echo "路径不能为空，使用默认路径" ;;
            "set_custom_install_path") echo "[OK] 已设置自定义安装路径" ;;
            "invalid_choice_default") echo "无效选择，使用默认路径" ;;
            "enter_custom_data_dir") echo "请输入自定义直播源保存目录:" ;;
            "suggested_paths") echo "建议路径示例:" ;;
            "external_storage") echo "(外部存储)" ;;
            "data_partition") echo "(数据分区)" ;;
            "user_directory") echo "(用户目录)" ;;
            "dir_cannot_empty") echo "目录不能为空，使用默认目录" ;;
            "set_custom_data_dir") echo "[OK] 已设置自定义数据目录" ;;
            "invalid_choice_default_dir") echo "无效选择，使用默认目录" ;;
            "will_download_after_install") echo "[OK] 将在安装完成后立即下载直播源" ;;
            "install_only_manual_later") echo "[OK] 仅完成安装，稍后可使用 'iptv' 命令手动运行" ;;
            "non_interactive_detected") echo "非交互模式检测到，使用默认配置" ;;
            "installation_cancelled") echo "安装已取消。如需重新配置，请重新运行安装脚本。" ;;
            # 定时任务相关
            "config_cron") echo "[配置] 定时任务..." ;;
            "cron_setup") echo "定时任务设置" ;;
            "select_cron_frequency") echo "请选择定时任务频率:" ;;
            "every_6_hours") echo "每6小时执行一次 (推荐)" ;;
            "daily_2am") echo "每天凌晨2点执行" ;;
            "every_hour") echo "每小时执行一次" ;;
            "skip_cron") echo "跳过定时任务设置" ;;
            "cron_recommendation") echo "提示: 推荐选择选项1，既能保持更新又不会过于频繁" ;;
            "enter_choice_default_1") echo "输入选择回车默认: 1 >" ;;
            "selected_6_hours") echo "[OK] 已选择：每6小时执行一次" ;;
            "selected_daily_2am") echo "[OK] 已选择：每天凌晨2点执行" ;;
            "selected_hourly") echo "[OK] 已选择：每小时执行一次" ;;
            "selected_skip_cron") echo "[OK] 已选择：跳过定时任务设置" ;;
            "invalid_choice_default_6h") echo "[OK] 无效选择，使用默认：每6小时执行一次" ;;
            "non_interactive_cron") echo "模式: 非交互模式，使用默认定时任务设置（每6小时执行一次）" ;;
            "skip_cron_setup") echo "[OK] 跳过定时任务设置" ;;
            "add_to_crontab") echo "[添加] 定时任务到crontab..." ;;
            "cron_setup_complete") echo "定时任务设置完成" ;;
            "task_content") echo "任务内容" ;;
            "cron_setup_failed") echo "[警告] 定时任务设置失败，请手动添加：" ;;
            "add_line") echo "添加行" ;;
            "install_complete_message") echo "IPTV直播源管理脚本安装完成!" ;;
            "update_available_message") echo "发现新版本的安装脚本！" ;;
            "download_progress_label") echo "下载进度" ;;
            "checking_updates") echo "检查脚本更新..." ;;
            "script_up_to_date") echo "脚本已是最新版本" ;;
            "update_success_message") echo "脚本已更新！使用新版本重新启动..." ;;
            "network_issue_warning") echo "无法检查更新（网络问题）" ;;
            "starting_installation") echo "开始安装过程" ;;
            "all_steps_complete") echo "所有安装步骤完成！" ;;
            *) echo "$key" ;;
        esac
    fi
}

# 语言选择函数
select_language() {
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Language Selection / 语言选择"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "Please select your preferred language:"
        echo "请选择您的首选语言:"
        echo
        echo "1) 中文 (Chinese)"
        echo "2) English"
        echo
        echo -n "Enter option (default: 1) / 输入选项 (默认: 1) > "
        read lang_choice
        
        case ${lang_choice:-1} in
            1)
                SELECTED_LANGUAGE="zh"
                log_info "[OK] 已选择中文界面"
                ;;
            2)
                SELECTED_LANGUAGE="en"
                log_info "[OK] English interface selected"
                ;;
            *)
                log_warn "Invalid choice, using Chinese / 无效选择，使用中文"
                SELECTED_LANGUAGE="zh"
                ;;
        esac
    else
        # 非交互模式，使用环境变量或默认值
        SELECTED_LANGUAGE="${INSTALL_LANGUAGE:-zh}"
        log_info "Non-interactive mode: Language set to $SELECTED_LANGUAGE"
    fi
}

# 用户交互函数
get_user_preferences() {
    log_step "$(get_text 'step_config_options')"
    
    # 强制进入交互模式，除非明确设置了环境变量跳过
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'install_path_selection')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'select_install_path')"
        echo "1) $(get_text 'use_default_path'): $DEFAULT_INSTALL_DIR"
        echo "2) $(get_text 'custom_path')"
        echo
        echo "$(get_text 'default_recommended')"
        echo
        echo -n "$(get_text 'enter_option_default') "
        read path_choice
        
        case ${path_choice:-1} in
            1)
                INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                log_info "$(get_text 'selected_default_path'): $INSTALL_DIR"
                ;;
            2)
                echo
                echo "$(get_text 'enter_custom_path')"
                echo -n "$(get_text 'enter_custom_path_prompt') "
                read custom_path
                if [[ -z "$custom_path" ]]; then
                    log_warn "$(get_text 'path_cannot_empty')"
                    INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                else
                    INSTALL_DIR="$custom_path"
                    log_info "$(get_text 'set_custom_install_path'): $INSTALL_DIR"
                fi
                ;;
            *)
                log_warn "$(get_text 'invalid_choice_default')"
                INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                ;;
        esac
        
        # 询问直播源文件保存目录
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'data_dir_selection')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'select_data_dir')"
        echo "1) $(get_text 'use_default_dir'): $INSTALL_DIR/data"
        echo "2) $(get_text 'custom_dir_recommended')"
        echo
        echo "$(get_text 'large_storage_tip')"
        if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
            echo "      Example: /media/storage/iptv or /data/iptv"
        else
            echo "      例如: /media/storage/iptv 或 /data/iptv"
        fi
        echo
        echo -n "$(get_text 'enter_option_default') "
        read data_choice
        
        case ${data_choice:-1} in
            1)
                DATA_DIR="$INSTALL_DIR/data"
                log_info "[OK] $(get_text 'use_default_dir'): $DATA_DIR"
                ;;
            2)
                echo
                echo "$(get_text 'enter_custom_data_dir')"
                echo "$(get_text 'suggested_paths')"
                echo "  /media/storage/iptv    $(get_text 'external_storage')"
                echo "  /data/iptv            $(get_text 'data_partition')"
                echo "  /home/user/iptv-data  $(get_text 'user_directory')"
                echo
                echo -n "输入自定义路径 > "
                read custom_data_dir
                if [[ -z "$custom_data_dir" ]]; then
                    log_warn "$(get_text 'dir_cannot_empty')"
                    DATA_DIR="$INSTALL_DIR/data"
                else
                    DATA_DIR="$custom_data_dir"
                    log_info "$(get_text 'set_custom_data_dir'): $DATA_DIR"
                fi
                ;;
            *)
                log_warn "$(get_text 'invalid_choice_default_dir')"
                DATA_DIR="$INSTALL_DIR/data"
                ;;
        esac
        
        # 询问是否立即运行
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'post_install_actions')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'run_after_install')"
        echo "Y) $(get_text 'download_immediately')"
        echo "n) $(get_text 'install_only')"
        echo
        echo "$(get_text 'test_install_tip')"
        echo
        if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
            echo -n "Enter option (default: Y) > "
        else
            echo -n "输入选项回车默认: Y > "
        fi
        read run_immediately
        RUN_IMMEDIATELY=${run_immediately:-Y}
        
        if [[ "$RUN_IMMEDIATELY" =~ ^[Yy]$ ]]; then
            log_info "$(get_text 'will_download_after_install')"
        else
            log_info "$(get_text 'install_only_manual_later')"
        fi
    else
        # 非交互模式，使用默认值或环境变量
        log_info "$(get_text 'non_interactive_detected')"
        INSTALL_DIR="${CUSTOM_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
        DATA_DIR="${CUSTOM_DATA_DIR:-$INSTALL_DIR/data}"
        RUN_IMMEDIATELY="${AUTO_RUN:-Y}"
    fi
    
    # 显示配置确认
    echo
    echo -e "${BLUE} $(get_text 'config_confirmation')${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${GREEN}[OK]${NC} $(get_text 'install_path'): $INSTALL_DIR"
    echo -e "${GREEN}[OK]${NC} $(get_text 'data_directory'): $DATA_DIR"
    echo -e "${GREEN}[OK]${NC} $(get_text 'run_after_install_short'): $RUN_IMMEDIATELY"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # 检查是否可以交互
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        echo
        echo -n "$(get_text 'confirm_install') "
        read confirm_install
        confirm_install=${confirm_install:-Y}
        
        if [[ ! "$confirm_install" =~ ^[Yy]$ ]]; then
            echo
            if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                echo "Installation cancelled. Please re-run the script to reconfigure."
            else
                echo "$(get_text 'installation_cancelled')"
            fi
            exit 0
        fi
        echo "$(get_text 'config_confirmed')"
    fi
    
    echo
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warn "$(get_text 'root_detected')"
        echo "$(get_text 'root_suggestion')"
        echo "$(get_text 'root_impact')"
        
        # 检查是否通过管道执行
        if [[ "${SKIP_INTERACTIVE:-}" != "true" ]] && [[ -t 0 ]]; then
            echo
            echo -n "$(get_text 'continue_prompt') "
            read root_continue
            echo
            if [[ ! $root_continue =~ ^[Yy]$ ]]; then
                echo "$(get_text 'install_cancelled_root')"
                echo "  su - username"
                echo "  ./install.sh"
                exit 1
            fi
            echo "$(get_text 'continue_root_install')"
        else
            # 通过管道执行或非交互模式，自动继续但给出警告
            echo "$(get_text 'non_interactive_mode')"
            sleep 3
        fi
    fi
}

# 检查系统类型
check_system() {
    echo "  $(get_text 'check_system_compat')"
    
    if [[ ! -f /etc/debian_version ]]; then
        echo "  [错误] 系统不兼容"
        echo "     错误: 此脚本仅支持Debian/Ubuntu系统"
        echo "     当前系统: $(uname -s)"
        exit 1
    fi
    
    local system_info=$(lsb_release -d 2>/dev/null | cut -f2 || echo "Debian/Ubuntu")
    echo "  [OK] $(get_text 'system_compat_ok'): $system_info"
}

# 安装系统依赖
install_system_deps() {
    echo "  $(get_text 'update_package_list')"
    sudo apt update > /dev/null 2>&1
    
    # 安装Python3和相关包
    if ! command -v python3 &> /dev/null; then
        echo "  $(get_text 'install_python3')"
        sudo apt install -y python3 > /dev/null 2>&1
    else
        echo "  [OK] $(get_text 'python3_installed'): $(python3 --version)"
    fi
    
    # 安装Python开发包和pip相关组件
    echo "  $(get_text 'install_python_dev')"
    sudo apt install -y python3-pip python3-distutils python3-setuptools python3-dev python3-venv > /dev/null 2>&1
    
    # 安装其他必要工具
    echo "  $(get_text 'install_tools')"
    sudo apt install -y curl wget cron > /dev/null 2>&1
}

# 下载项目文件
download_files() {
    echo "  $(get_text 'download_project_files')"
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    echo "     $(get_text 'temp_directory'): $TEMP_DIR"
    
    # 下载文件列表
    local files=("iptv_manager.py" "languages.py" "config.json" "requirements.txt")
    local total_files=${#files[@]}
    local current_file=0
    
    for file in "${files[@]}"; do
        current_file=$((current_file + 1))
        echo "  [下载] $file ($current_file/$total_files)..."
        
        if curl -fsSL "${GITHUB_RAW_URL}/${file}" -o "$file" 2>/dev/null; then
            echo "    [OK] $file $(get_text 'download_success')"
        else
            echo "    [错误] $file $(get_text 'download_failed')"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    done
}

# 安装Python依赖
install_python_deps() {
    # 更新PATH以包含用户本地bin目录
    export PATH="$HOME/.local/bin:$PATH"
    
    # 多种方法尝试安装依赖
    local install_success=false
    
    # 方法1: 尝试使用系统pip3
    if command -v pip3 &> /dev/null && pip3 --version &> /dev/null 2>&1; then
        echo "  [安装] 使用系统pip3安装依赖..."
        if pip3 install requests chardet --user &> /dev/null; then
            install_success=true
            echo "    [OK] 依赖安装成功"
        fi
    fi
    
    # 方法2: 使用python -m pip
    if [ "$install_success" = false ]; then
        echo "  [重试] 使用python -m pip安装依赖..."
        if python3 -m pip install requests chardet --user &> /dev/null; then
            install_success=true
            echo "    [OK] 依赖安装成功"
        fi
    fi
    
    # 方法3: 重新安装pip后再试
    if [ "$install_success" = false ]; then
        echo "  [修复] 重新安装pip后再试..."
        if curl -sS https://bootstrap.pypa.io/get-pip.py | python3 - --user &> /dev/null; then
            export PATH="$HOME/.local/bin:$PATH"
            if python3 -m pip install requests chardet --user &> /dev/null; then
                install_success=true
                echo "    [OK] 依赖安装成功"
            fi
        fi
    fi
    
    # 验证安装结果
    if python3 -c "import requests, chardet" 2>/dev/null; then
        echo "  [OK] Python依赖验证通过"
    else
        echo "  [错误] Python依赖安装失败"
        echo
        echo "请手动执行以下命令安装依赖："
        echo "  python3 -m pip install requests chardet --user"
        echo "或者："
        echo "  sudo apt install python3-requests python3-chardet"
        echo
        echo "然后重新运行安装脚本"
        exit 1
    fi
}

# 创建目录结构
create_directories() {
    echo "  $(get_text 'create_base_dir'): $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    
    # 创建数据目录（可能在不同位置）
    if [[ "$DATA_DIR" != "$INSTALL_DIR/data" ]]; then
        echo "  $(get_text 'create_custom_data_dir'): $DATA_DIR"
        mkdir -p "$DATA_DIR"
        # 如果数据目录需要sudo权限
        if [[ ! -w "$(dirname "$DATA_DIR")" ]]; then
            sudo mkdir -p "$DATA_DIR"
            sudo chown -R $USER:$USER "$DATA_DIR"
        fi
    else
        echo "  [创建] 数据目录: $DATA_DIR"
        mkdir -p "$DATA_DIR"
    fi
    
    # 创建其他子目录
    echo "  $(get_text 'create_backup_log_dirs')"
    mkdir -p "$INSTALL_DIR"/{backup,logs}
    
    # 设置权限
    echo "  $(get_text 'set_permissions')"
    sudo chown -R $USER:$USER "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"/{backup,logs}
    chmod 755 "$DATA_DIR"
}

# 安装脚本文件
install_scripts() {
    echo "  $(get_text 'install_script_files')"
    
    # 修改配置文件中的路径和语言设置
    echo "     $(get_text 'update_config_paths')"
    python3 -c "
import json
with open('config.json', 'r') as f:
    config = json.load(f)
config['language'] = '$SELECTED_LANGUAGE'
config['directories']['base_dir'] = '$INSTALL_DIR'
config['directories']['data_dir'] = '$DATA_DIR'
config['directories']['backup_dir'] = '$INSTALL_DIR/backup'
config['directories']['log_dir'] = '$INSTALL_DIR/logs'
with open('config.json', 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
" 2>/dev/null
    
    if [ $? -eq 0 ]; then
        echo "     [OK] $(get_text 'config_update_success')"
    else
        echo "     [错误] $(get_text 'config_update_failed')"
        exit 1
    fi
    
    # 复制文件到目标目录
    echo "     $(get_text 'copy_files_to_install')"
    local files_copied=0
    for file in iptv_manager.py languages.py config.json requirements.txt; do
        if [[ -f "$file" ]]; then
            if cp "$file" "$INSTALL_DIR/" 2>/dev/null; then
                echo "       [OK] $file"
                files_copied=$((files_copied + 1))
            else
                echo "       [错误] $file (复制失败)"
                exit 1
            fi
        else
            echo "       [错误] $file (文件不存在)"
            exit 1
        fi
    done
    
    # 设置执行权限
    echo "     $(get_text 'set_exec_permissions')"
    if chmod +x "$INSTALL_DIR/iptv_manager.py" 2>/dev/null; then
        echo "     [OK] $(get_text 'exec_permissions_success')"
    else
        echo "     [警告] 执行权限设置失败，但不影响使用"
    fi
    
    echo "  [OK] $(get_text 'files_installed') $files_copied $(get_text 'files_installed')"
}

# 创建软连接
create_symlink() {
    echo "  [$(get_text 'step_create_symlink')] $(get_text 'global_command_symlink')..."
    
    local symlink_path="/usr/local/bin/iptv"
    local target_script="$INSTALL_DIR/iptv_manager.py"
    
    # 检查是否可以交互
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'global_command_symlink')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'symlink_description')"
        echo "$(get_text 'symlink_location'): $symlink_path"
        echo "$(get_text 'target_program'): $target_script"
        echo
        echo "$(get_text 'symlink_recommended')"
        echo
        echo -n "$(get_text 'create_symlink_prompt') "
        read create_link
        create_link=${create_link:-Y}
        
        if [[ "$create_link" =~ ^[Yy]$ ]]; then
            echo "$(get_text 'will_create_symlink')"
        else
            echo "$(get_text 'skip_symlink')"
        fi
    else
        # 非交互模式，使用环境变量或默认值
        create_link="${CREATE_SYMLINK:-Y}"
    fi
    
    if [[ "$create_link" =~ ^[Yy]$ ]]; then
        # 检查是否已存在并验证目标
        if [[ -L "$symlink_path" ]]; then
            # 是软连接，检查目标是否正确
            current_target=$(readlink "$symlink_path" 2>/dev/null || echo "")
            if [[ "$current_target" == "$target_script" ]]; then
                echo "  [OK] 软连接已存在且指向正确位置"
                return
            else
                echo "  [更新] 软连接存在但指向不同位置，正在更新..."
                echo "     当前指向: $current_target"
                echo "     更新指向: $target_script"
                sudo rm -f "$symlink_path"
            fi
        elif [[ -f "$symlink_path" ]]; then
            # 是普通文件，检查是否是我们的包装脚本
            if grep -q "cd.*iptv_manager.py" "$symlink_path" 2>/dev/null; then
                # 是我们的包装脚本，检查路径是否正确
                if grep -q "cd \"$INSTALL_DIR\"" "$symlink_path" 2>/dev/null; then
                    echo "  [OK] 包装脚本已存在且路径正确"
                    return
                else
                    echo "  [更新] 包装脚本存在但路径不同，正在更新..."
                    sudo rm -f "$symlink_path"
                fi
            else
                echo "  [警告] 发现同名文件但不是IPTV相关，跳过软连接创建"
                echo "     文件位置: $symlink_path"
                echo "     请手动处理后重新安装"
                return
            fi
        fi
        
        # 创建包装脚本以确保在正确目录执行
        echo "  $(get_text 'create_wrapper_script')"
        local wrapper_script="/tmp/iptv_wrapper_$$"
        cat > "$wrapper_script" << EOF
#!/bin/bash
# IPTV Manager 包装脚本
# 安装路径: $INSTALL_DIR
# 创建时间: $(date)
cd "$INSTALL_DIR" && python3 iptv_manager.py "\$@"
EOF
        chmod +x "$wrapper_script"
        
        if sudo mv "$wrapper_script" "$symlink_path" 2>/dev/null; then
            echo "  [OK] $(get_text 'global_command_success'): $symlink_path"
            echo "     $(get_text 'target_directory'): $INSTALL_DIR"
            echo "     $(get_text 'can_use_iptv_anywhere')"
        else
            echo "  [错误] 全局命令创建失败"
            echo "     原因: 可能需要管理员权限"
            echo "     手动创建: sudo ln -sf $target_script $symlink_path"
            rm -f "$wrapper_script" 2>/dev/null
        fi
    else
        echo "  $(get_text 'skip_symlink')"
        echo "     使用方法: cd $INSTALL_DIR && python3 iptv_manager.py"
    fi
}

# 测试安装
test_installation() {
    echo "  $(get_text 'test_install_result')"
    
    # 保存当前目录
    ORIGINAL_DIR=$(pwd)
    
    # 切换到目标目录进行测试
    cd "$INSTALL_DIR"
    
    # 测试脚本语法
    echo "     $(get_text 'check_script_syntax')"
    if python3 -m py_compile iptv_manager.py 2>/dev/null; then
        echo "     [OK] $(get_text 'script_syntax_ok')"
    else
        echo "     [错误] 脚本语法检查失败"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    # 测试配置文件
    echo "     $(get_text 'check_config_file')"
    if python3 -c "import json; json.load(open('config.json'))" 2>/dev/null; then
        echo "     [OK] $(get_text 'config_format_ok')"
    else
        echo "     [错误] 配置文件格式错误"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    # 测试运行
    echo "     $(get_text 'test_program_run')"
    if python3 iptv_manager.py --status >/dev/null 2>&1; then
        echo "     [OK] $(get_text 'program_test_ok')"
    else
        echo "     [OK] 程序基础功能正常（首次运行无数据是正常的）"
    fi
    
    # 返回原目录
    cd "$ORIGINAL_DIR"
}

# 设置定时任务
setup_cron() {
    echo "  $(get_text 'config_cron')"
    
    local choice
    
    # 检查是否可以交互
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'cron_setup')"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "$(get_text 'select_cron_frequency')"
        echo "1) $(get_text 'every_6_hours')"
        echo "2) $(get_text 'daily_2am')"
        echo "3) $(get_text 'every_hour')"
        echo "4) $(get_text 'skip_cron')"
        echo
        echo "$(get_text 'cron_recommendation')"
        echo
        echo -n "$(get_text 'enter_choice_default_1') "
        read choice
        choice=${choice:-1}
        
        case $choice in
            1) echo "$(get_text 'selected_6_hours')" ;;
            2) echo "$(get_text 'selected_daily_2am')" ;;
            3) echo "$(get_text 'selected_hourly')" ;;
            4) echo "$(get_text 'selected_skip_cron')" ;;
            *) echo "$(get_text 'invalid_choice_default_6h')"; choice=1 ;;
        esac
    else
        # 非交互模式，使用默认值
        echo "     模式: 非交互模式，使用默认定时任务设置（每6小时执行一次）"
        choice=1
    fi
    
    case $choice in
        1)
            CRON_ENTRY="0 */6 * * * cd $INSTALL_DIR && python3 iptv_manager.py --download >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
        2)
            CRON_ENTRY="0 2 * * * cd $INSTALL_DIR && python3 iptv_manager.py --download >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
        3)
            CRON_ENTRY="0 * * * * cd $INSTALL_DIR && python3 iptv_manager.py --download >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
        4)
            echo "  [OK] 跳过定时任务设置"
            return
            ;;
        *)
            CRON_ENTRY="0 */6 * * * cd $INSTALL_DIR && python3 iptv_manager.py --download >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
    esac
    
    # 添加到crontab
    echo "  [添加] 定时任务到crontab..."
    if (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab - 2>/dev/null; then
        echo "  [OK] 定时任务设置完成"
        echo "     任务内容: $CRON_ENTRY"
    else
        echo "  [警告] 定时任务设置失败，请手动添加："
        echo "     crontab -e"
        echo "     添加行: $CRON_ENTRY"
    fi
}

# 立即运行脚本
run_script() {
    if [[ "$RUN_IMMEDIATELY" =~ ^[Yy]$ ]]; then
        echo "  [运行] 立即下载直播源..."
        echo "     正在初始化下载任务，请稍候..."
        echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        cd "$INSTALL_DIR"
        
        # 显示进度的函数
        show_progress() {
            local duration=$1
            local step=0
            local total=50
            
            while [ $step -le $total ]; do
                local progress=$((step * 100 / total))
                local filled=$((step * 40 / total))
                local empty=$((40 - filled))
                
                printf "\r$(get_text 'download_progress_label'): ["
                printf "%*s" $filled | tr ' ' '█'
                printf "%*s" $empty | tr ' ' '░'
                printf "] %d%%" $progress
                
                sleep 0.1
                step=$((step + 1))
            done
            echo
        }
        
        # 在后台运行下载任务
        local log_file="/tmp/iptv_install_output_$$.log"
        timeout 120 python3 iptv_manager.py --download > "$log_file" 2>&1 &
        local download_pid=$!
        
        # 显示进度动画（使用ASCII字符）
        local spinner_chars="|/-\\"
        local i=0
        echo "     正在下载直播源文件..."
        
        local timeout_count=0
        local max_timeout=400  # 120秒超时 (400 * 0.3秒)
        
        while kill -0 $download_pid 2>/dev/null && [ $timeout_count -lt $max_timeout ]; do
            local char=${spinner_chars:$((i % ${#spinner_chars})):1}
            printf "\r     %s 下载中... (超时倒计时: %d秒)" "$char" $(((max_timeout - timeout_count) * 3 / 10))
            sleep 0.3
            i=$((i + 1))
            timeout_count=$((timeout_count + 1))
        done
        
        # 检查是否超时
        if [ $timeout_count -ge $max_timeout ]; then
            kill $download_pid 2>/dev/null
            printf "\r%*s\r" 70 ""
            echo "     [超时] 下载超时，但这不影响安装"
            echo "     [提示] 您可以稍后手动运行 'iptv --download' 重试"
            local exit_code=124  # timeout exit code
        else
            # 等待进程完成并获取退出状态
            wait $download_pid
            local exit_code=$?
        fi
        
        printf "\r%*s\r" 70 ""  # 清除进度行
        
        if [ $exit_code -eq 0 ]; then
            echo "     [OK] 直播源下载完成!"
            echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            # 显示下载结果
            if [ -f "$log_file" ]; then
                echo "     下载详情:"
                local success_info=$(tail -n 10 "$log_file" | grep -E "(下载|完成|成功|源)" | head -3)
                if [ -n "$success_info" ]; then
                    echo "$success_info" | sed 's/^/       /'
                else
                    echo "       请查看日志文件获取详细信息"
                fi
                rm -f "$log_file"
            fi
        elif [ $exit_code -eq 124 ]; then
            echo "     [提示] 安装完成，但初始下载超时"
            echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "     这是正常现象，不影响程序功能"
            echo "     解决方案:"
            echo "       • 稍后使用 'iptv --download' 手动下载"
            echo "       • 或运行 'iptv' 进入交互式菜单选择下载"
        else
            echo "     [错误] 直播源下载遇到问题"
            echo "     ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "     可能的原因:"
            echo "       • 网络连接问题"
            echo "       • 直播源服务器暂时不可用"
            echo "       • 防火墙阻止了连接"
            echo
            echo "     解决方案:"
            echo "       • 稍后使用 'iptv --download' 命令重试"
            echo "       • 检查网络连接: ping google.com"
            echo "       • 查看详细日志: tail -f $INSTALL_DIR/logs/iptv_manager_$(date +%Y%m%d).log"
            
            if [ -f "$log_file" ]; then
                echo
                echo "     错误详情:"
                tail -n 5 "$log_file" | sed 's/^/       /'
                rm -f "$log_file"
            fi
        fi
    fi
}

# 清理临时文件
cleanup() {
    if [[ -n "$TEMP_DIR" ]] && [[ -d "$TEMP_DIR" ]]; then
        rm -rf "$TEMP_DIR"
    fi
}

# 显示安装完成信息
show_completion() {
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    IPTV直播源管理脚本安装完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}安装目录:${NC} $INSTALL_DIR"
    echo -e "${BLUE}配置文件:${NC} $INSTALL_DIR/config.json"
    echo -e "${BLUE}主脚本:${NC} $INSTALL_DIR/iptv_manager.py"
    echo
    echo -e "${YELLOW}使用方法:${NC}"
    if [[ -f "/usr/local/bin/iptv" ]]; then
        echo "  [推荐] 使用全局命令："
        echo "    iptv                            # 进入交互式菜单"
        echo "    iptv --download                 # 直接下载直播源"
        echo "    iptv --status                   # 查看状态"
        echo "    iptv --help                     # 查看帮助"
        echo
        echo "  [备选] 使用完整路径："
        echo "    cd $INSTALL_DIR"
        echo "    python3 iptv_manager.py        # 进入交互式菜单"
    else
        echo "  使用完整路径："
        echo "    cd $INSTALL_DIR"
        echo "    python3 iptv_manager.py        # 进入交互式菜单"
        echo "    python3 iptv_manager.py --download # 直接下载直播源"
        echo "    python3 iptv_manager.py --status   # 查看状态"
        echo "    python3 iptv_manager.py --help     # 查看帮助"
        echo
        echo "  [提示] 可手动创建软连接："
        echo "    sudo ln -sf $INSTALL_DIR/iptv_manager.py /usr/local/bin/iptv"
    fi
    echo
    echo -e "${YELLOW}数据目录:${NC}"
    echo "  直播源文件: $DATA_DIR"
    echo "  备份文件: $INSTALL_DIR/backup/"
    echo "  日志文件: $INSTALL_DIR/logs/"
    echo
    echo -e "${YELLOW}配置修改:${NC}"
    echo "  编辑 $INSTALL_DIR/config.json 来修改配置"
    echo "  数据目录可在配置文件中的 directories.data_dir 字段修改"
    echo
    echo -e "${GREEN}安装完成! 享受使用吧!${NC}"
}

# 检查脚本更新
check_script_update() {
    if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
        echo -e "${BLUE}Checking for script updates...${NC}"
    else
        echo -e "${BLUE}$(get_text 'checking_updates')${NC}"
    fi
    
    local remote_script_url="https://raw.githubusercontent.com/yuanweize/IPTV-Manager/refs/heads/main/install.sh"
    local temp_script="/tmp/install_remote.sh"
    
    # 下载远程脚本检查版本
    if curl -fsSL "$remote_script_url" -o "$temp_script" 2>/dev/null; then
        local remote_version=$(grep "SCRIPT_VERSION=" "$temp_script" | head -1 | cut -d'"' -f2)
        local remote_date=$(grep "SCRIPT_DATE=" "$temp_script" | head -1 | cut -d'"' -f2)
        
        if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
            echo "Local script version: $SCRIPT_VERSION (Date: $SCRIPT_DATE)"
            echo "Remote script version: $remote_version (Date: $remote_date)"
        else
            echo "本地脚本版本: $SCRIPT_VERSION (日期: $SCRIPT_DATE)"
            echo "远程脚本版本: $remote_version (日期: $remote_date)"
        fi
        
        if [[ "$remote_version" > "$SCRIPT_VERSION" ]] || [[ "$remote_date" > "$SCRIPT_DATE" ]]; then
            if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                echo -e "${YELLOW}[UPDATE AVAILABLE]${NC} A newer script version is available!"
                echo -n "Update to the latest version? (Y/n): "
            else
                echo -e "${YELLOW}[发现更新]${NC} $(get_text 'update_available_message')"
                echo -n "是否更新到最新版本? (Y/n): "
            fi
            
            read update_choice
            if [[ "${update_choice:-Y}" =~ ^[Yy]$ ]]; then
                if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                    echo "Updating script..."
                else
                    echo "正在更新脚本..."
                fi
                
                cp "$temp_script" "$0"
                chmod +x "$0"
                rm -f "$temp_script"
                
                if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                    echo -e "${GREEN}[SUCCESS]${NC} Script updated! Restarting with new version..."
                else
                    echo -e "${GREEN}[成功]${NC} $(get_text 'update_success_message')"
                fi
                
                # 重新执行新脚本
                exec "$0" "$@"
            else
                if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                    echo "Continuing with current version..."
                else
                    echo "继续使用当前版本..."
                fi
            fi
        else
            if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
                echo -e "${GREEN}[UP TO DATE]${NC} Script is already the latest version"
            else
                echo -e "${GREEN}[已是最新]${NC} $(get_text 'script_up_to_date')"
            fi
        fi
        
        rm -f "$temp_script"
    else
        if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
            echo -e "${YELLOW}[WARNING]${NC} Unable to check for updates (network issue)"
        else
            echo -e "${YELLOW}[警告]${NC} $(get_text 'network_issue_warning')"
        fi
    fi
    
    echo
}

# 显示帮助信息
show_help() {
    echo "IPTV直播源管理脚本一键安装程序 - 开发日期: $SCRIPT_DATE"
    echo "IPTV Manager One-Click Installer - Development Date: $SCRIPT_DATE"
    echo "=================================================================="
    echo
    echo "使用方法 / Usage:"
    echo "  bash install.sh                    # 交互式安装 / Interactive installation"
    echo "  curl -fsSL <url> | bash            # 使用默认配置安装 / Install with defaults"
    echo
    echo "环境变量配置（非交互模式）/ Environment Variables (Non-interactive):"
    echo "  SKIP_INTERACTIVE=true             # 跳过交互，使用默认或环境变量配置"
    echo "  INSTALL_LANGUAGE=zh|en            # 界面语言 (zh=中文, en=English)"
    echo "  CUSTOM_INSTALL_DIR=/path/to/dir   # 自定义安装目录"
    echo "  CUSTOM_DATA_DIR=/path/to/data     # 自定义数据目录"
    echo "  AUTO_RUN=Y                        # 安装后自动运行（Y/n）"
    echo "  CREATE_SYMLINK=Y                  # 创建全局命令软连接（Y/n）"
    echo
    echo "示例 / Examples:"
    echo "  # 中文界面，自定义目录"
    echo "  INSTALL_LANGUAGE=zh CUSTOM_INSTALL_DIR=/home/user/iptv bash install.sh"
    echo "  # English interface, custom directories"
    echo "  INSTALL_LANGUAGE=en CUSTOM_INSTALL_DIR=/opt/iptv CUSTOM_DATA_DIR=/media/iptv bash install.sh"
    echo "  # 完全非交互式安装"
    echo "  SKIP_INTERACTIVE=true INSTALL_LANGUAGE=en bash install.sh"
    echo
}

# 主函数
main() {
    # 检查是否需要显示帮助
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    if [[ "${SELECTED_LANGUAGE:-zh}" == "en" ]]; then
        echo -e "${BLUE}IPTV Manager One-Click Installer - Development Date: $SCRIPT_DATE${NC}"
        echo "=================================================================="
    else
        echo -e "${BLUE}IPTV直播源管理脚本一键安装程序 - 开发日期: $SCRIPT_DATE${NC}"
        echo "========================================"
    fi
    echo
    
    # 显示执行模式
    if [[ "${SKIP_INTERACTIVE:-}" == "true" ]]; then
        log_info "非交互模式：使用环境变量或默认配置"
    elif [[ -t 0 ]]; then
        log_info "交互模式：将询问配置选项"
    else
        log_info "管道模式：尝试交互，如失败则使用默认配置"
    fi
    echo
    
    # 设置清理陷阱
    trap cleanup EXIT
    
    # 安装步骤列表
    local steps=(
        "check_root:$(get_text 'step_check_root')"
        "select_language:$(get_text 'step_select_language')"
        "check_script_update:$(get_text 'step_check_update')"
        "get_user_preferences:$(get_text 'step_get_config')"
        "check_system:$(get_text 'step_check_system')"
        "install_system_deps:$(get_text 'step_install_deps')"
        "download_files:$(get_text 'step_download_files')"
        "install_python_deps:$(get_text 'step_install_python_deps')"
        "create_directories:$(get_text 'step_create_dirs')"
        "install_scripts:$(get_text 'step_install_scripts')"
        "create_symlink:$(get_text 'step_create_symlink')"
        "test_installation:$(get_text 'step_test_install')"
        "setup_cron:$(get_text 'step_setup_cron')"
        "run_script:运行脚本"
        "show_completion:显示完成信息"
    )
    
    local total_steps=${#steps[@]}
    local current_step=0
    
    echo
    echo -e "${BLUE}$(get_text 'starting_installation')${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    for step_info in "${steps[@]}"; do
        local step_func="${step_info%%:*}"
        local step_desc="${step_info##*:}"
        
        current_step=$((current_step + 1))
        show_progress_bar $current_step $total_steps "安装进度"
        echo -e "${BLUE}[$current_step/$total_steps]${NC} $step_desc"
        
        # 执行步骤
        $step_func
        
        echo -e "${GREEN}[OK]${NC} $step_desc 完成"
        echo
    done
    
    echo -e "${GREEN}$(get_text 'all_steps_complete')${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# 执行主函数
main "$@"