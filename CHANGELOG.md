# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.6] - 2025-08-03

### Fixed
- � P**CRITICAL**: Fixed missing languages.py file in installation script
- 🌐 Fixed language loading issue causing menu to display text keys instead of translations
- � Correlcted menu option count (removed extra language option)
- �  Fixed menu display showing raw text keys instead of localized text

### Changed
- 📦 Updated installation script to include languages.py file download
- 🔢 Incremented version number to 1.0.6

## [1.0.5] - 2025-08-03

### Added
- 🔄 Program update functionality in interactive menu (option 7)
- 🌐 Automatic version checking from GitHub releases API
- �  One-click update feature with environment preservation
- 📋 Update status messages in both languages (12 new text keys)
- 🧪 Update function test script (test_update_function.py)
- � Comrprehensive project status check script (project_status.py)

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