# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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