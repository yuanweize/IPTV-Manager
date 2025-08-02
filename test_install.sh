#!/bin/bash
# 简单的安装测试脚本

echo "测试IPTV管理器安装..."

# 检查Python依赖
echo "1. 检查Python依赖..."
if python3 -c "import requests, chardet" 2>/dev/null; then
    echo "✓ Python依赖已安装"
else
    echo "✗ Python依赖缺失"
    exit 1
fi

# 检查脚本文件
echo "2. 检查脚本文件..."
if [[ -f "iptv_manager.py" ]] && [[ -x "iptv_manager.py" ]]; then
    echo "✓ 主脚本文件存在且可执行"
else
    echo "✗ 主脚本文件问题"
    exit 1
fi

# 检查配置文件
echo "3. 检查配置文件..."
if python3 -c "import json; json.load(open('config.json'))" 2>/dev/null; then
    echo "✓ 配置文件格式正确"
else
    echo "✗ 配置文件格式错误"
    exit 1
fi

# 检查目录结构
echo "4. 检查目录结构..."
for dir in data backup logs; do
    if [[ -d "$dir" ]]; then
        echo "✓ 目录存在: $dir"
    else
        echo "✗ 目录缺失: $dir"
        exit 1
    fi
done

# 测试脚本运行
echo "5. 测试脚本运行..."
if python3 iptv_manager.py --help >/dev/null 2>&1; then
    echo "✓ 脚本可以正常运行"
else
    echo "✗ 脚本运行失败"
    exit 1
fi

echo
echo "🎉 所有测试通过！IPTV管理器安装成功！"
echo
echo "使用方法:"
echo "  python3 iptv_manager.py          # 下载直播源"
echo "  python3 iptv_manager.py --status # 查看状态"
echo "  python3 iptv_manager.py --help   # 查看帮助"