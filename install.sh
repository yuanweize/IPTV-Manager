#!/bin/bash
# IPTV直播源管理脚本安装脚本
# 适用于Debian/Ubuntu系统

set -e

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
    
    # 从配置文件读取基础目录
    BASE_DIR="/data/media/iptv"
    if [[ -f config.json ]]; then
        BASE_DIR=$(python3 -c "import json; print(json.load(open('config.json'))['directories']['base_dir'])" 2>/dev/null || echo "/data/media/iptv")
    fi
    
    log_info "创建基础目录: $BASE_DIR"
    sudo mkdir -p "$BASE_DIR"
    
    # 创建子目录
    mkdir -p "$BASE_DIR"/{data,backup,logs}
    
    # 设置权限
    sudo chown -R $USER:$USER "$BASE_DIR"
    chmod 755 "$BASE_DIR"
    chmod 755 "$BASE_DIR"/{data,backup,logs}
    
    log_info "目录结构创建完成"
}

# 复制脚本文件
install_scripts() {
    log_step "安装脚本文件..."
    
    BASE_DIR="/data/media/iptv"
    if [[ -f config.json ]]; then
        BASE_DIR=$(python3 -c "import json; print(json.load(open('config.json'))['directories']['base_dir'])" 2>/dev/null || echo "/data/media/iptv")
    fi
    
    # 获取当前目录的绝对路径
    CURRENT_DIR=$(pwd)
    TARGET_DIR=$(realpath "$BASE_DIR")
    
    # 检查是否已经在目标目录中
    if [[ "$CURRENT_DIR" == "$TARGET_DIR" ]]; then
        log_info "已在目标目录中，跳过文件复制"
        # 确保文件存在
        if [[ ! -f "iptv_manager.py" ]] || [[ ! -f "config.json" ]] || [[ ! -f "requirements.txt" ]]; then
            log_error "当前目录缺少必要文件，请确保在正确的项目目录中运行安装脚本"
            exit 1
        fi
    else
        # 复制主要文件（只有当源文件和目标文件不同时）
        for file in iptv_manager.py config.json requirements.txt; do
            if [[ -f "$file" ]]; then
                if [[ ! -f "$BASE_DIR/$file" ]] || ! cmp -s "$file" "$BASE_DIR/$file"; then
                    cp "$file" "$BASE_DIR/"
                    log_info "复制文件: $file"
                else
                    log_info "文件已存在且相同: $file"
                fi
            else
                log_warn "源文件不存在: $file"
            fi
        done
    fi
    
    # 设置执行权限
    chmod +x "$BASE_DIR/iptv_manager.py"
    
    log_info "脚本文件安装完成"
}

# 测试安装
test_installation() {
    log_step "测试安装..."
    
    BASE_DIR="/data/media/iptv"
    if [[ -f config.json ]]; then
        BASE_DIR=$(python3 -c "import json; print(json.load(open('config.json'))['directories']['base_dir'])" 2>/dev/null || echo "/data/media/iptv")
    fi
    
    # 保存当前目录
    ORIGINAL_DIR=$(pwd)
    
    # 切换到目标目录进行测试
    cd "$BASE_DIR"
    
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
        log_error "脚本运行测试失败，但这可能是正常的（首次运行）"
        log_info "继续安装过程..."
    fi
    
    # 返回原目录
    cd "$ORIGINAL_DIR"
}

# 设置定时任务
setup_cron() {
    log_step "设置定时任务..."
    
    BASE_DIR="/data/media/iptv"
    if [[ -f config.json ]]; then
        BASE_DIR=$(python3 -c "import json; print(json.load(open('config.json'))['directories']['base_dir'])" 2>/dev/null || echo "/data/media/iptv")
    fi
    
    echo "请选择定时任务频率:"
    echo "1) 每6小时执行一次 (推荐)"
    echo "2) 每天凌晨2点执行"
    echo "3) 每小时执行一次"
    echo "4) 跳过定时任务设置"
    
    read -p "请输入选择 (1-4): " choice
    
    case $choice in
        1)
            CRON_ENTRY="0 */6 * * * cd $BASE_DIR && python3 iptv_manager.py >> $BASE_DIR/logs/cron.log 2>&1"
            ;;
        2)
            CRON_ENTRY="0 2 * * * cd $BASE_DIR && python3 iptv_manager.py >> $BASE_DIR/logs/cron.log 2>&1"
            ;;
        3)
            CRON_ENTRY="0 * * * * cd $BASE_DIR && python3 iptv_manager.py >> $BASE_DIR/logs/cron.log 2>&1"
            ;;
        4)
            log_info "跳过定时任务设置"
            return
            ;;
        *)
            log_warn "无效选择，跳过定时任务设置"
            return
            ;;
    esac
    
    # 添加到crontab
    (crontab -l 2>/dev/null; echo "$CRON_ENTRY") | crontab -
    log_info "定时任务设置完成"
}

# 显示安装完成信息
show_completion() {
    BASE_DIR="/data/media/iptv"
    if [[ -f config.json ]]; then
        BASE_DIR=$(python3 -c "import json; print(json.load(open('config.json'))['directories']['base_dir'])" 2>/dev/null || echo "/data/media/iptv")
    fi
    
    echo
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}    IPTV直播源管理脚本安装完成!${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo
    echo -e "${BLUE}安装目录:${NC} $BASE_DIR"
    echo -e "${BLUE}配置文件:${NC} $BASE_DIR/config.json"
    echo -e "${BLUE}主脚本:${NC} $BASE_DIR/iptv_manager.py"
    echo
    echo -e "${YELLOW}使用方法:${NC}"
    echo "  cd $BASE_DIR"
    echo "  python3 iptv_manager.py          # 执行下载任务"
    echo "  python3 iptv_manager.py --status # 查看状态"
    echo "  python3 iptv_manager.py --help   # 查看帮助"
    echo
    echo -e "${YELLOW}日志文件:${NC}"
    echo "  $BASE_DIR/logs/iptv_manager_$(date +%Y%m%d).log"
    echo
    echo -e "${YELLOW}配置修改:${NC}"
    echo "  编辑 $BASE_DIR/config.json 来修改配置"
    echo
    echo -e "${GREEN}安装完成! 享受使用吧!${NC}"
}

# 主函数
main() {
    echo -e "${BLUE}IPTV直播源管理脚本安装程序${NC}"
    echo "=================================="
    echo
    
    check_root
    check_system
    install_system_deps
    install_python_deps
    create_directories
    install_scripts
    test_installation
    setup_cron
    show_completion
}

# 执行主函数
main "$@"