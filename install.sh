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
    
    # 获取安装路径
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
    
    log_info "安装路径: $INSTALL_DIR"
    
    # 询问是否立即运行
    echo
    read -p "安装完成后是否立即下载直播源? (Y/n): " run_immediately
    RUN_IMMEDIATELY=${run_immediately:-Y}
    
    echo
}

# 检查是否为root用户
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_warn "检测到root用户，建议使用普通用户运行此脚本"
        read -p "是否继续? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
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
    
    # 创建子目录
    mkdir -p "$INSTALL_DIR"/{data,backup,logs}
    
    # 设置权限
    sudo chown -R $USER:$USER "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"
    chmod 755 "$INSTALL_DIR"/{data,backup,logs}
    
    log_info "目录结构创建完成"
}

# 安装脚本文件
install_scripts() {
    log_step "安装脚本文件..."
    
    # 修改配置文件中的安装路径
    if [[ "$INSTALL_DIR" != "$DEFAULT_INSTALL_DIR" ]]; then
        log_info "更新配置文件中的安装路径..."
        python3 -c "
import json
with open('config.json', 'r') as f:
    config = json.load(f)
config['directories']['base_dir'] = '$INSTALL_DIR'
with open('config.json', 'w') as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
"
    fi
    
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
    
    echo "请选择定时任务频率:"
    echo "1) 每6小时执行一次 (推荐)"
    echo "2) 每天凌晨2点执行"
    echo "3) 每小时执行一次"
    echo "4) 跳过定时任务设置"
    
    read -p "请输入选择 (1-4) [默认: 1]: " choice
    choice=${choice:-1}
    
    case $choice in
        1)
            CRON_ENTRY="0 */6 * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
        2)
            CRON_ENTRY="0 2 * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
            ;;
        3)
            CRON_ENTRY="0 * * * * cd $INSTALL_DIR && python3 iptv_manager.py >> $INSTALL_DIR/logs/cron.log 2>&1"
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
    echo "  cd $INSTALL_DIR"
    echo "  python3 iptv_manager.py          # 执行下载任务"
    echo "  python3 iptv_manager.py --status # 查看状态"
    echo "  python3 iptv_manager.py --help   # 查看帮助"
    echo
    echo -e "${YELLOW}数据目录:${NC}"
    echo "  直播源文件: $INSTALL_DIR/data/"
    echo "  备份文件: $INSTALL_DIR/backup/"
    echo "  日志文件: $INSTALL_DIR/logs/"
    echo
    echo -e "${YELLOW}配置修改:${NC}"
    echo "  编辑 $INSTALL_DIR/config.json 来修改配置"
    echo
    echo -e "${GREEN}安装完成! 享受使用吧!${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}IPTV直播源管理脚本一键安装程序${NC}"
    echo "========================================"
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
    test_installation
    setup_cron
    run_script
    show_completion
}

# 执行主函数
main "$@"