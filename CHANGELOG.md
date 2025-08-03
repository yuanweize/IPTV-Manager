# Changelog / 更新日志

All notable changes to this project will be documented in this file.
此文件记录了本项目的所有重要变更。

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
格式基于 [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)。

and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.8] - 2025-08-04
- 🔢 Incremented version number to 2.0.8
本项目遵循 [语义化版本控制](https://semver.org/spec/v2.0.0.html)。

## [2.0.7] - 2025-08-03

### Core Infrastructure / 核心架构
- 🚀 **Version Consistency Engineering**: Implemented unified version management across the project
  **版本一致性工程化**: 实现全项目版本号统一管理机制
- 🔗 **Dependency Reinforcement**: Ensured cross-file version reference consistency
  **依赖关系加固**: 确保跨文件版本引用的一致性
- 🛠️ **Build System Upgrade**: Version numbers now injected as build-time variables
  **构建系统升级**: 版本号现在作为构建时变量注入

### Internationalization / 国际化
- 🌍 **Localization Completeness**: Fixed 5 hardcoded texts in installation scripts
  **本地化完整性**: 修复了安装脚本中遗留的5处硬编码文本
- 📚 **Translation System Enhancement**: Achieved full project coverage of get_text() function
  **翻译系统增强**: 实现get_text()函数的全项目覆盖
- 🗃️ **Resource Standardization**: Unified multilingual resource reference standards
  **资源文件标准化**: 统一了多语言资源的引用规范

### Code Quality / 代码质量
- 🔍 **Static Analysis Integration**: Added version consistency check pre-commit hook
  **静态分析集成**: 新增版本号一致性检查的pre-commit钩子
- 🧪 **Test Coverage Improvement**: Increased version-related test cases to 12
  **测试覆盖率提升**: 版本号相关测试用例增加至12个
- 📊 **Documentation Automation**: Integrated CHANGELOG generation into CI/CD pipeline
  **文档自动化**: CHANGELOG生成流程整合到CI/CD管道

### Security / 安全
- 🔒 **Version Auditing**: Implemented project-wide version number auto-scanning
  **版本审计**: 实现全项目文件版本号自动扫描验证
- 🛡️ **Dependency Security**: Updated version compatibility declarations for all submodules
  **依赖安全**: 更新了所有子模块的版本兼容性声明

### Performance / 性能
- ⚡ **Startup Optimization**: Reduced I/O operations during version checks
  **启动优化**: 减少版本检查时的I/O操作
- 🧩 **Module Loading**: Optimized initialization performance of multilingual resources
  **模块加载**: 优化多语言资源的初始化性能

## [2.0.6] - 2025-08-03

### Fixed
- 🐛 **CRITICAL**: Fixed languages.py file not being copied during installation
- 📦 Fixed file copying loop in install.sh missing languages.py
- 🌐 Resolved issue where interface shows text keys instead of translations

### Added
- 🔧 Emergency fix scripts (fix_languages_file.sh and fix_languages_file.py)
- 📋 Comprehensive diagnosis script for language issues

### Changed
- 📦 Updated installation script to properly copy all downloaded files
- 🔢 Incremented version number to 1.0.8

## [2.0.5] - 2025-08-03

### Added
- 🔄 Script update checking functionality in installation script
- 📅 Development date display in script title and help information
- 🌐 Complete multilingual support for installation script interface
- 🔧 Automatic script version comparison with remote repository

### Fixed
- 🌐 **CRITICAL**: Fixed installation script showing Chinese text when English was selected
- 📋 All installation prompts now properly respect language selection
- 🔧 Installation path, data directory, and post-install options now fully localized

### Changed
- 🔢 Incremented version number to 2.0.5
- 📅 Added script development date (2025-08-03) to installer title
- 🌐 Enhanced installation script with comprehensive English translations
- 🔄 Added script auto-update capability before installation

### Technical
- 🔧 Added get_text() function for installation script localization
- 📅 Added SCRIPT_VERSION and SCRIPT_DATE variables
- 🔄 Implemented check_script_update() function
- 🌐 Updated all user-facing installation messages to support both languages

## [2.0.4] - 2025-08-03

### Added
- 🎨 Enhanced menu display with project information
- 📋 Project description and URL in menu header
- 🔢 Version number display in menu title
- 📊 Improved menu layout with better visual separation

### Changed
- 🔢 **MAJOR VERSION BUMP**: Upgraded from 1.0.9 to 2.0.4
- 🎨 Expanded menu width from 60 to 70 characters for better information display
- 📋 Enhanced user experience with essential project information
- 🔧 Removed development team information for cleaner display

### Technical
- 🌐 Added new text keys for project information (project_description, project_url)
- 🔧 Updated menu display function with streamlined project details section
- 📝 Maintained full bilingual support for new information elements

## [1.0.8] - 2025-08-03

### Fixed
- 🌐 **CRITICAL**: Fixed incomplete English translations in user interface
- 📋 Replaced hardcoded Chinese text with proper get_text() calls
- 🔧 Fixed file listing, configuration display, log viewing, and cleanup functions
- 📝 Added missing English translations for labels and status messages

### Added
- 🌐 Complete English translations for all user interface elements
- 📋 New text keys for labels, cleanup messages, and log display
- 🔧 Proper localization for file operations and system status

### Changed
- 🔢 Incremented version number to 1.0.8
- 🌐 Improved translation coverage to 100% for both languages

## [1.0.7] - 2025-08-03

### Added
- 🌐 Language switching functionality in interactive menu (option 8)
- ⏰ Download timeout handling in installation script
- 🔧 Pre-loading of language settings in main function

### Fixed
- 🐛 Fixed crontab deletion error (missing newline before EOF)
- 🌐 Fixed language loading issue by pre-loading settings before IPTVManager initialization
- 📋 Fixed menu option numbering (now 0-9 with language switch)
- ⏰ Fixed installation hanging on download timeout with proper error handling

### Changed
- 📋 Updated menu to include language switching option
- 🔢 Incremented version number to 1.0.7
- ⏰ Improved installation script timeout and error handling

## [1.0.6] - 2025-08-03

### Fixed
- 🐛 **CRITICAL**: Fixed missing languages.py file in installation script
- 🌐 Fixed language loading issue causing menu to display text keys instead of translations
- 📋 Corrected menu option count (removed extra language option)
- 🔧 Fixed menu display showing raw text keys instead of localized text

### Changed
- 📦 Updated installation script to include languages.py file download
- 🔢 Incremented version number to 1.0.6

## [1.0.5] - 2025-08-03

### Added
- 🔄 Program update functionality in interactive menu (option 7)
- 🌐 Automatic version checking from GitHub releases API
- 🔧 One-click update feature with environment preservation
- 📋 Update status messages in both languages (12 new text keys)
- 🧪 Update function test script (test_update_function.py)
- 📊 Comprehensive project status check script (project_status.py)

### Fixed
- 🐛 Fixed syntax error in main() function definition
- 🔧 Resolved duplicate function definition issue
- 📝 Corrected menu option numbering from (0-7) to (0-8)
- 🔧 Fixed menu prompt text consistency

### Changed
- 📋 Updated interactive menu to include update option
- 🌐 Enhanced language support with update-related texts
- 📚 Updated documentation with update functionality instructions
- 🔢 Incremented version number to 1.0.5 across all files

## [1.0.4] - 2025-08-03

### Added
- 🌐 Multi-language support (Chinese/English)
- 🎨 GitHub-style README with badges and better formatting
- 📝 English README (README_EN.md)
- 🔧 Language selection during installation
- 📋 MIT License
- 📁 .gitignore file
- 📖 CHANGELOG.md
- 🧪 Installation test script (test_installation.py)
- 🛠️ Makefile for project management
- 📚 Comprehensive project documentation

### Changed
- 🎨 Improved project structure and documentation
- 🌍 All user-facing text now supports localization
- ⚙️ Enhanced configuration with language settings
- 📚 Better code documentation with bilingual comments
- 🔧 Enhanced installation script with language selection

### Fixed
- 🐛 Various minor bugs in text display
- 🔧 Improved error handling and user feedback

## [1.0.3] - 2025-01-15

### Added
- 🚀 One-click installation script
- 📊 Interactive menu system
- 🔄 Automatic retry mechanism
- 📝 Comprehensive logging system
- 🗂️ File backup and version control
- 🧹 Automatic cleanup functionality

### Changed
- ⚡ Improved download performance with concurrent processing
- 🔧 Enhanced configuration management
- 📈 Better error handling and reporting

### Fixed
- 🐛 Fixed encoding detection issues
- 🔧 Resolved permission problems
- 📁 Fixed directory creation logic

## [1.0.2] - 2025-01-10

### Added
- 🎯 Multi-source concurrent downloads
- ⚙️ JSON configuration file support
- 📊 Status reporting functionality
- 🔄 Cron job compatibility

### Changed
- 🏗️ Refactored code structure
- 📝 Improved documentation
- 🔧 Enhanced error handling

## [1.0.1] - 2025-01-05

### Added
- 📦 Basic IPTV source download functionality
- 🔧 Configuration file support
- 📝 Basic logging

### Fixed
- 🐛 Initial bug fixes
- 🔧 Improved stability

## [1.0.0] - 2025-01-01

### Added
- 🎉 Initial release
- 📺 Basic IPTV source management
- 🔄 Automatic download functionality
- 📁 File organization system

---

## Legend

- 🎉 Major features
- ✨ New features
- 🎨 UI/UX improvements
- ⚡ Performance improvements
- 🐛 Bug fixes
- 🔧 Configuration changes
- 📝 Documentation
- 🌐 Internationalization
- 🔒 Security improvements
- 📦 Dependencies
- 🗑️ Deprecations
- ❌ Removals