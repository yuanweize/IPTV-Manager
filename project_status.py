#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
IPTV Manager Project Status Check
项目状态检查脚本

This script provides a comprehensive status check of the IPTV Manager project.
此脚本提供IPTV Manager项目的全面状态检查。
"""

import os
import sys
import json
from pathlib import Path

def check_project_files():
    """检查项目文件 / Check project files"""
    print("📁 Project Files Status")
    print("-" * 30)
    
    required_files = {
        'iptv_manager.py': 'Main application script',
        'languages.py': 'Multi-language support module',
        'config.json': 'Configuration file',
        'install.sh': 'Installation script',
        'requirements.txt': 'Python dependencies',
        'README.md': 'Chinese documentation',
        'README_EN.md': 'English documentation',
        'LICENSE': 'MIT license file',
        'CHANGELOG.md': 'Version history',
        'CONTRIBUTING.md': 'Contribution guidelines',
        '.gitignore': 'Git ignore rules',
        'Makefile': 'Project management tool',
        'test_installation.py': 'Installation test script',
        'test_update_function.py': 'Update function test script'
    }
    
    missing_files = []
    present_files = []
    
    for filename, description in required_files.items():
        if os.path.exists(filename):
            present_files.append(filename)
            print(f"✓ {filename} - {description}")
        else:
            missing_files.append(filename)
            print(f"✗ {filename} - {description} (MISSING)")
    
    print(f"\nSummary: {len(present_files)}/{len(required_files)} files present")
    
    if missing_files:
        print(f"Missing files: {', '.join(missing_files)}")
        return False
    return True

def check_configuration():
    """检查配置文件 / Check configuration"""
    print("\n⚙️ Configuration Status")
    print("-" * 30)
    
    if not os.path.exists('config.json'):
        print("✗ config.json not found")
        return False
    
    try:
        with open('config.json', 'r', encoding='utf-8') as f:
            config = json.load(f)
        
        required_keys = ['language', 'sources', 'directories', 'download', 'maintenance', 'logging']
        
        for key in required_keys:
            if key in config:
                print(f"✓ {key} section present")
            else:
                print(f"✗ {key} section missing")
                return False
        
        # 检查语言设置
        language = config.get('language', 'zh')
        print(f"✓ Language setting: {language}")
        
        # 检查源配置
        sources = config.get('sources', {})
        enabled_sources = sum(1 for s in sources.values() if s.get('enabled', True))
        print(f"✓ Sources configured: {len(sources)} total, {enabled_sources} enabled")
        
        return True
        
    except Exception as e:
        print(f"✗ Configuration error: {e}")
        return False

def check_language_support():
    """检查多语言支持 / Check language support"""
    print("\n🌐 Language Support Status")
    print("-" * 30)
    
    try:
        sys.path.insert(0, '.')
        from languages import LANGUAGES, get_text, set_language
        
        print(f"✓ Language module imported successfully")
        print(f"✓ Available languages: {list(LANGUAGES.keys())}")
        
        # 测试中文
        set_language('zh')
        zh_title = get_text('menu_title')
        print(f"✓ Chinese title: {zh_title}")
        
        # 测试英文
        set_language('en')
        en_title = get_text('menu_title')
        print(f"✓ English title: {en_title}")
        
        # 检查关键文本
        key_texts = ['menu_download', 'menu_status', 'menu_update', 'update_checking']
        for key in key_texts:
            zh_text = LANGUAGES['zh'].get(key, 'MISSING')
            en_text = LANGUAGES['en'].get(key, 'MISSING')
            if zh_text != 'MISSING' and en_text != 'MISSING':
                print(f"✓ {key}: Available in both languages")
            else:
                print(f"✗ {key}: Missing in some languages")
                return False
        
        return True
        
    except Exception as e:
        print(f"✗ Language support error: {e}")
        return False

def check_syntax():
    """检查语法 / Check syntax"""
    print("\n🔍 Syntax Check Status")
    print("-" * 30)
    
    python_files = ['iptv_manager.py', 'languages.py', 'test_installation.py', 'test_update_function.py']
    
    for filename in python_files:
        if os.path.exists(filename):
            try:
                import subprocess
                result = subprocess.run([sys.executable, '-m', 'py_compile', filename], 
                                      capture_output=True, text=True)
                if result.returncode == 0:
                    print(f"✓ {filename}: Syntax OK")
                else:
                    print(f"✗ {filename}: Syntax Error")
                    print(f"  Error: {result.stderr}")
                    return False
            except Exception as e:
                print(f"✗ {filename}: Check failed - {e}")
                return False
        else:
            print(f"⚠ {filename}: File not found")
    
    return True

def check_version_consistency():
    """检查版本一致性 / Check version consistency"""
    print("\n📋 Version Consistency Status")
    print("-" * 30)
    
    versions = {}
    
    # 检查主程序版本
    try:
        with open('iptv_manager.py', 'r', encoding='utf-8') as f:
            content = f.read()
            if "version='IPTV Manager 1.0.5'" in content:
                versions['iptv_manager.py'] = '1.0.5'
                print("✓ iptv_manager.py: Version 1.0.5")
            else:
                print("✗ iptv_manager.py: Version not found or incorrect")
                return False
    except Exception as e:
        print(f"✗ iptv_manager.py: Error reading file - {e}")
        return False
    
    # 检查CHANGELOG版本
    try:
        with open('CHANGELOG.md', 'r', encoding='utf-8') as f:
            content = f.read()
            if "## [1.0.5]" in content:
                versions['CHANGELOG.md'] = '1.0.5'
                print("✓ CHANGELOG.md: Version 1.0.5")
            else:
                print("✗ CHANGELOG.md: Version 1.0.5 not found")
                return False
    except Exception as e:
        print(f"✗ CHANGELOG.md: Error reading file - {e}")
        return False
    
    # 检查README版本
    try:
        with open('README.md', 'r', encoding='utf-8') as f:
            content = f.read()
            if "版本**: 1.0.5" in content:
                versions['README.md'] = '1.0.5'
                print("✓ README.md: Version 1.0.5")
            else:
                print("✗ README.md: Version 1.0.5 not found")
                return False
    except Exception as e:
        print(f"✗ README.md: Error reading file - {e}")
        return False
    
    return True

def check_features():
    """检查功能特性 / Check features"""
    print("\n✨ Features Status")
    print("-" * 30)
    
    features = {
        'Multi-language support': 'languages.py exists and contains LANG_ZH, LANG_EN',
        'Installation script': 'install.sh exists and is executable',
        'Update functionality': 'update_program function in iptv_manager.py',
        'Interactive menu': 'interactive_mode function in iptv_manager.py',
        'Configuration management': 'IPTVConfig class in iptv_manager.py',
        'Test scripts': 'test_installation.py and test_update_function.py exist',
        'Documentation': 'README.md, README_EN.md, and other docs exist',
        'Project management': 'Makefile exists'
    }
    
    feature_status = {}
    
    # 检查多语言支持
    if os.path.exists('languages.py'):
        try:
            with open('languages.py', 'r', encoding='utf-8') as f:
                content = f.read()
                if 'LANG_ZH' in content and 'LANG_EN' in content:
                    feature_status['Multi-language support'] = True
                    print("✓ Multi-language support: Available")
                else:
                    feature_status['Multi-language support'] = False
                    print("✗ Multi-language support: Incomplete")
        except:
            feature_status['Multi-language support'] = False
            print("✗ Multi-language support: Error reading file")
    else:
        feature_status['Multi-language support'] = False
        print("✗ Multi-language support: languages.py missing")
    
    # 检查安装脚本
    if os.path.exists('install.sh'):
        feature_status['Installation script'] = True
        print("✓ Installation script: Available")
    else:
        feature_status['Installation script'] = False
        print("✗ Installation script: Missing")
    
    # 检查更新功能
    if os.path.exists('iptv_manager.py'):
        try:
            with open('iptv_manager.py', 'r', encoding='utf-8') as f:
                content = f.read()
                if 'def update_program(' in content:
                    feature_status['Update functionality'] = True
                    print("✓ Update functionality: Available")
                else:
                    feature_status['Update functionality'] = False
                    print("✗ Update functionality: Missing")
        except:
            feature_status['Update functionality'] = False
            print("✗ Update functionality: Error reading file")
    else:
        feature_status['Update functionality'] = False
        print("✗ Update functionality: iptv_manager.py missing")
    
    # 检查其他功能
    other_features = [
        ('Interactive menu', 'iptv_manager.py', 'def interactive_mode('),
        ('Configuration management', 'iptv_manager.py', 'class IPTVConfig'),
        ('Test scripts', 'test_installation.py', 'def main('),
        ('Documentation', 'README.md', '# 🎬 IPTV Manager'),
        ('Project management', 'Makefile', '.PHONY:')
    ]
    
    for feature_name, filename, search_text in other_features:
        if os.path.exists(filename):
            try:
                with open(filename, 'r', encoding='utf-8') as f:
                    content = f.read()
                    if search_text in content:
                        feature_status[feature_name] = True
                        print(f"✓ {feature_name}: Available")
                    else:
                        feature_status[feature_name] = False
                        print(f"✗ {feature_name}: Incomplete")
            except:
                feature_status[feature_name] = False
                print(f"✗ {feature_name}: Error reading file")
        else:
            feature_status[feature_name] = False
            print(f"✗ {feature_name}: File missing")
    
    return all(feature_status.values())

def main():
    """主函数 / Main function"""
    print("🎬 IPTV Manager Project Status Check")
    print("=" * 50)
    print("Checking project completeness and functionality...")
    print("检查项目完整性和功能性...")
    print()
    
    checks = [
        ("Project Files", check_project_files),
        ("Configuration", check_configuration),
        ("Language Support", check_language_support),
        ("Syntax Check", check_syntax),
        ("Version Consistency", check_version_consistency),
        ("Features", check_features)
    ]
    
    passed = 0
    total = len(checks)
    
    for check_name, check_func in checks:
        try:
            if check_func():
                passed += 1
                print(f"\n✅ {check_name}: PASSED")
            else:
                print(f"\n❌ {check_name}: FAILED")
        except Exception as e:
            print(f"\n💥 {check_name}: ERROR - {e}")
    
    print("\n" + "=" * 50)
    print(f"Overall Status: {passed}/{total} checks passed")
    
    if passed == total:
        print("🎉 Project Status: EXCELLENT")
        print("✅ All systems are ready!")
        print("✅ The project is complete and functional!")
        return 0
    elif passed >= total * 0.8:
        print("⚠️ Project Status: GOOD")
        print("✅ Most systems are working!")
        print("⚠️ Some minor issues need attention.")
        return 0
    else:
        print("❌ Project Status: NEEDS WORK")
        print("❌ Several issues need to be resolved.")
        return 1

if __name__ == "__main__":
    sys.exit(main())