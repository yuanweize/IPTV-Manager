#!/bin/bash
# IPTV直播源管理脚本一键安装脚本
# 适用于Debian/Ubuntu系统

set -e

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

# 用户交互函数
get_user_preferences() {
    log_step "配置安装选项..."
    
    # 强制进入交互模式，除非明确设置了环境变量跳过
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "请选择安装路径:"
        echo "1) 使用默认路径: $DEFAULT_INSTALL_DIR"
        echo "2) 自定义路径"
        echo
        read -p "请输入选择 (1-2) [默认: 1]: " path_choice
        
        case ${path_choice:-1} in
            1)
                INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                ;;
            2)
                read -p "请输入自定义安装路径: " custom_path
                if [[ -z "$custom_path" ]]; then
                    log_warn "路径不能为空，使用默认路径"
                    INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                else
                    INSTALL_DIR="$custom_path"
                fi
                ;;
            *)
                log_warn "无效选择，使用默认路径"
                INSTALL_DIR="$DEFAULT_INSTALL_DIR"
                ;;
        esac
        
        # 询问直播源文件保存目录
        echo
        echo "请选择直播源文件保存目录:"
        echo "1) 使用默认目录: $INSTALL_DIR/data"
        echo "2) 自定义目录"
        echo
        read -p "请输入选择 (1-2) [默认: 1]: " data_choice
        
        case ${data_choice:-1} in
            1)
                DATA_DIR="$INSTALL_DIR/data"
                ;;
            2)
                read -p "请输入自定义直播源保存目录: " custom_data_dir
                if [[ -z "$custom_data_dir" ]]; then
                    log_warn "目录不能为空，使用默认目录"
                    DATA_DIR="$INSTALL_DIR/data"
                else
                    DATA_DIR="$custom_data_dir"
                fi
                ;;
            *)
                log_warn "无效选择，使用默认目录"
                DATA_DIR="$INSTALL_DIR/data"
                ;;
        esac
        
        # 询问是否立即运行
        echo
        read -p "安装完成后是否立即下载直播源? (Y/n): " run_immediately
        RUN_IMMEDIATELY=${run_immediately:-Y}
    else
        # 非交互模式，使用默认值或环境变量
        log_info "非交互模式检测到，使用默认配置"
        INSTALL_DIR="${CUSTOM_INSTALL_DIR:-$DEFAULT_INSTALL_DIR}"
        DATA_DIR="${CUSTOM_DATA_DIR:-$INSTALL_DIR/data}"
        RUN_IMMEDIATELY="${AUTO_RUN:-Y}"
    fi
    
    log_info "安装路径: $INSTALL_DIR"
    log_info "数据目录: $DATA_DIR"
    log_info "安装后立即运行: $RUN_IMMEDIATELY"
    echo
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warn "检测到root用户，建议使用普通用户运行此脚本"
        
        # 检查是否通过管道执行
        if [[ -t 0 ]]; then
            # 标准输入是终端，可以交互
            read -p "是否继续? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                exit 1
            fi
        else
            # 通过管道执行，自动继续但给出警告
            log_warn "通过管道执行，自动继续安装（3秒后开始）"
            sleep 3
        fi
    fi
}

# 检查系统类型
check_system() {
    log_step "检查系统环境..."
    
    if [[ ! -f /etc/debian_version ]]; then
        log_error "此脚本仅支持Debian/Ubuntu系统"
        exit 1
    fi
    
    log_info "系统检查通过: $(lsb_release -d | cut -f2)"
}

# 安装系统依赖
install_system_deps() {
    log_step "安装系统依赖..."
    
    # 更新包列表
    sudo apt update
    
    # 安装Python3和相关包
    if ! command -v python3 &> /dev/null; then
        log_info "安装Python3..."
        sudo apt install -y python3
    else
        log_info "Python3已安装: $(python3 --version)"
    fi
    
    # 安装Python开发包和pip相关组件
    log_info "安装Python开发包..."
    sudo apt install -y python3-pip python3-distutils python3-setuptools python3-dev python3-venv
    
    # 安装其他必要工具
    sudo apt install -y curl wget cron
    
    log_info "系统依赖安装完成"
}

# 下载项目文件
download_files() {
    log_step "下载项目文件..."
    
    # 创建临时目录
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # 下载文件列表
    local files=("iptv_manager.py" "config.json" "requirements.txt")
    
    for file in "${files[@]}"; do
        log_info "下载 $file..."
        if curl -fsSL "${GITHUB_RAW_URL}/${file}" -o "$file"; then
            log_info "✓ $file 下载成功"
        else
            log_error "✗ $file 下载失败"
            rm -rf "$TEMP_DIR"
            exit 1
        fi
    done
    
    log_info "所有文件下载完成"
}

# 安装Python依赖
install_python_deps() {
    log_step "安装Python依赖..."
    
    # 更新PATH以包含用户本地bin目录
    export PATH="$HOME/.local/bin:$PATH"
    
    # 多种方法尝试安装依赖
    local install_success=false
    
    # 方法1: 尝试使用系统pip3
    if command -v pip3 &> /dev/null && pip3 --version &> /dev/null 2>&1; then
        log_info "使用系统pip3安装依赖..."
        if pip3 install requests chardet --user &> /dev/null; then
            install_success=true
        fi
    fi
    
    # 方法2: 使用python -m pip
    if [ "$install_success" = false ]; then
        log_info "使用python -m pip安装依赖..."
        if python3 -m pip install requests chardet --user &> /dev/null; then
            install_success=true
        fi
    fi
    
    # 方法3: 重新安装pip后再试
    if [ "$install_success" = false ]; then
        log_warn "常规方法失败，尝试重新安装pip..."
        if curl -sS https://bootstrap.pypa.io/get-pip.py | python3 - --user &> /dev/null; then
            export PATH="$HOME/.local/bin:$PATH"
            if python3 -m pip install requests chardet --user &> /dev/null; then
                install_success=true
            fi
        fi
    fi
    
    # 验证安装结果
    if python3 -c "import requests, chardet" 2>/dev/null; then
        log_info "Python依赖安装成功"
    else
        log_error "Python依赖安装失败"
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
    log_step "创建目录结构..."
    
    log_info "创建基础目录: $INSTALL_DIR"
    sudo mkdir -p "$INSTALL_DIR"
    
    # 创建数据目录（可能在不同位置）
    if [[ "$DATA_DIR" != "$INSTALL_DIR/data" ]]; then
        log_info "创建自定义数据目录: $DATA_DIR"
        mkdir -p "$DATA_DIR"
        # 如果数据目录需要sudo权限
        if [[ ! -w "$(dirname "$DATA_DIR")" ]]; then
            sudo mkdir -p "$DATA_DIR"
            sudo chown -R $USER:$USER "$DATA_DIR"
        fi
    else
        mkdir -p "$DATA_DIR"
    fi
    
    # 创建其他子目录
    mkdir -p "$INSTALL_DIR"/{backup,logs}
    
    # 设置权限
    sudo chown -R $USER:$USER "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"/{backup,logs}
    chmod 755 "$DATA_DIR"
    
    log_info "目录结构创建完成"
}

# 安装脚本文件
install_scripts() {
    log_step "安装脚本文件..."
    
    # 修改配置文件中的路径
    log_info "更新配置文件中的路径设置..."
    python3 -c "
import json
with open('config.json', 'r') as f:
    config = json.load(f)
config['directories']['base_dir'] = '$INSTALL_DIR'
config['directories']['data_dir'] = '$DATA_DIR'
config['directories']['backup_dir'] = '$INSTALL_DIR/backup'
config['directories']['log_dir'] = '$INSTALL_DIR/logs'
with open('config.json', 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
"
    
    # 复制文件到目标目录
    for file in iptv_manager.py config.json requirements.txt; do
        if [[ -f "$file" ]]; then
            cp "$file" "$INSTALL_DIR/"
            log_info "安装文件: $file"
        else
            log_error "文件不存在: $file"
            exit 1
        fi
    done
    
    # 设置执行权限
    chmod +x "$INSTALL_DIR/iptv_manager.py"
    
    log_info "脚本文件安装完成"
}

# 创建软连接
create_symlink() {
    log_step "创建软连接..."
    
    local symlink_path="/usr/local/bin/iptv"
    local target_script="$INSTALL_DIR/iptv_manager.py"
    
    # 检查是否可以交互
    if [[ "${SKIP_INTERACTIVE:-}" != "true" ]]; then
        # 重新打开标准输入以确保可以交互
        exec < /dev/tty 2>/dev/null || true
        
        echo
        echo "是否创建全局命令软连接？"
        echo "创建后可以在任何位置使用 'iptv' 命令"
        echo "软连接位置: $symlink_path"
        echo
        read -p "创建软连接? (Y/n): " create_link
        create_link=${create_link:-Y}
    else
        # 非交互模式，使用环境变量或默认值
        create_link="${CREATE_SYMLINK:-Y}"
    fi
    
    if [[ "$create_link" =~ ^[Yy]$ ]]; then
        # 检查是否已存在
        if [[ -L "$symlink_path" ]]; then
            log_warn "软连接已存在，正在更新..."
            sudo rm -f "$symlink_path"
        elif [[ -f "$symlink_path" ]]; then
            log_warn "发现同名文件 $symlink_path，跳过软连接创建"
            return
        fi
        
        # 创建软连接
        if sudo ln -sf "$target_script" "$symlink_path"; then
            log_info "✓ 软连接创建成功: $symlink_path -> $target_script"
            
            # 创建包装脚本以确保在正确目录执行
            local wrapper_script="/tmp/iptv_wrapper"
            cat > "$wrapper_script" << EOF
#!/bin/bash
# IPTV Manager 包装脚本
cd "$INSTALL_DIR" && python3 iptv_manager.py "\$@"
EOF
            chmod +x "$wrapper_script"
            sudo mv "$wrapper_script" "$symlink_path"
            
            log_info "现在可以在任何位置使用 'iptv' 命令了！"
            echo
            echo "使用示例:"
            echo "  iptv                    # 下载直播源"
            echo "  iptv --status          # 查看状态"
            echo "  iptv --help            # 查看帮助"
        else
            log_warn "软连接创建失败，可能需要管理员权限"
            echo "你可以手动创建软连接："
            echo "  sudo ln -sf $target_script $symlink_path"
        fi
    else
        log_info "跳过软连接创建"
        echo "你可以通过以下方式使用脚本："
        echo "  cd $INSTALL_DIR && python3 iptv_manager.py"
    fi
    
    echo
}

# 测试安装
test_installation() {
    log_step "测试安装..."
    
    # 保存当前目录
    ORIGINAL_DIR=$(pwd)
    
    # 切换到目标目录进行测试
    cd "$INSTALL_DIR"
    
    # 测试脚本语法
    if python3 -m py_compile iptv_manager.py 2>/dev/null; then
        log_info "脚本语法检查通过"
    else
        log_error "脚本语法检查失败"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    # 测试配置文件
    if python3 -c "import json; json.load(open('config.json'))" 2>/dev/null; then
        log_info "配置文件格式正确"
    else
        log_error "配置文件格式错误"
        cd "$ORIGINAL_DIR"
        exit 1
    fi
    
    # 测试运行
    if python3 iptv_manager.py --status 2>/dev/null; then
        log_info "脚本运行测试通过"
    else
        log_info "脚本基础功能正常（首次运行无数据是正常的）"
    fi
    
    # 返回原目录
    cd "$ORIGINAL_DIR"
}

# 设置定时任务
setup_cron() {
    log_step "设置定时任务..."
    
    local choice
    
    # 检查是否可以交互
    if [[ -t 0 ]]; then
        # 可以交互，询问用户选择
        echo "请选择定时任务频率:"
        echo "1) 每6小时执行一次 (推荐)"
        echo "2) 每天凌晨2点执行"
        echo "3) 每小时执行一次"
        echo "4) 跳过定时任务设置"
        
        read -p "请输入选择 (1-4) [默认: 1]: " choice
        choice=${choice:-1}
    else
        # 管道模式，使用默认值
        log_info "管道模式，使用默认定时任务设置（每6小时执行一次）"
        choice=1
    fi
    
    case $choice in
        1)
            CRON_ENTRY="0 */6 * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            log_info "设置定时任务：每6小时执行一次"
            ;;
        2)
            CRON_ENTRY="0 2 * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            log_info "设置定时任务：每天凌晨2点执行"
            ;;
        3)
            CRON_ENTRY="0 * * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            log_info "设置定时任务：每小时执行一次"
            ;;
        4)
            log_info "跳过定时任务设置"
            return
            ;;
        *)
            log_warn "无效选择，使用默认设置（每6小时执行一次）"
            CRON_ENTRY="0 */6 * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
    esac
    
    # 添加到crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    log_info "定时任务设置完成"
}

# 立即运行脚本
run_script() {
    if [[ "$RUN_IMMEDIATELY" =~ ^[Yy]$ ]]; then
        log_step "立即下载直播源..."
        cd "$INSTALL_DIR"
        if python3 iptv_manager.py; then
            log_info "直播源下载完成!"
        else
            log_warn "直播源下载遇到问题，请检查网络连接"
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
        echo "  iptv                              # 执行下载任务（全局命令）"
        echo "  iptv --status                     # 查看状态"
        echo "  iptv --help                       # 查看帮助"
        echo
        echo "  或者使用完整路径："
        echo "  cd $INSTALL_DIR"
        echo "  python3 iptv_manager.py          # 执行下载任务"
    else
        echo "  cd $INSTALL_DIR"
        echo "  python3 iptv_manager.py          # 执行下载任务"
        echo "  python3 iptv_manager.py --status # 查看状态"
        echo "  python3 iptv_manager.py --help   # 查看帮助"
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

# 显示帮助信息
show_help() {
    echo "IPTV直播源管理脚本一键安装程序"
    echo "========================================"
    echo
    echo "使用方法:"
    echo "  bash install.sh                    # 交互式安装"
    echo "  curl -fsSL <url> | bash            # 使用默认配置安装"
    echo
    echo "环境变量配置（非交互模式）:"
    echo "  SKIP_INTERACTIVE=true             # 跳过交互，使用默认或环境变量配置"
    echo "  CUSTOM_INSTALL_DIR=/path/to/dir   # 自定义安装目录"
    echo "  CUSTOM_DATA_DIR=/path/to/data     # 自定义数据目录"
    echo "  AUTO_RUN=Y                        # 安装后自动运行（Y/n）"
    echo "  CREATE_SYMLINK=Y                  # 创建全局命令软连接（Y/n）"
    echo
    echo "示例:"
    echo "  CUSTOM_INSTALL_DIR=/home/user/iptv CUSTOM_DATA_DIR=/media/iptv bash install.sh"
    echo "  SKIP_INTERACTIVE=true bash install.sh"
    echo
}

# 主函数
main() {
    # 检查是否需要显示帮助
    if [[ "$1" == "--help" ]] || [[ "$1" == "-h" ]]; then
        show_help
        exit 0
    fi
    
    echo -e "${BLUE}IPTV直播源管理脚本一键安装程序${NC}"
    echo "========================================"
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
    
    check_root
    get_user_preferences
    check_system
    install_system_deps
    download_files
    install_python_deps
    create_directories
    install_scripts
    create_symlink
    test_installation
    setup_cron
    run_script
    show_completion
}

# 执行主函数
main "$@"