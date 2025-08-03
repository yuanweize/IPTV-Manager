# Contributing to IPTV Manager / 贡献指南

Thank you for your interest in contributing to IPTV Manager! We welcome contributions from everyone.
感谢您对 IPTV Manager 项目的贡献感兴趣！我们欢迎所有人的贡献。

## 🤝 How to Contribute / 如何贡献

### Reporting Bugs / 报告错误

Before creating bug reports, please check the existing issues to avoid duplicates.
在提交错误报告前，请检查现有问题以避免重复。 When you create a bug report, please include as many details as possible:
提交错误报告时，请尽可能包含以下详细信息：

- **Use a clear and descriptive title**
  **使用清晰且描述性的标题**
- **Describe the exact steps to reproduce the problem**
  **描述重现问题的具体步骤**
- **Provide specific examples to demonstrate the steps**
- **Describe the behavior you observed and what behavior you expected**
- **Include screenshots if applicable**
- **Provide your environment details** (OS, Python version, etc.)

### Suggesting Enhancements

Enhancement suggestions are tracked as GitHub issues. When creating an enhancement suggestion, please include:

- **Use a clear and descriptive title**
- **Provide a step-by-step description of the suggested enhancement**
- **Provide specific examples to demonstrate the enhancement**
- **Describe the current behavior and explain the behavior you expected**
- **Explain why this enhancement would be useful**

### Pull Requests

1. **Fork the repository** and create your branch from `main`
2. **Make your changes** following our coding standards
3. **Add tests** if applicable
4. **Update documentation** if needed
5. **Ensure your code follows the existing style**
6. **Create a pull request** with a clear title and description

## 🛠️ Development Setup

### Prerequisites

- Python 3.6 or higher
- Git
- A Debian/Ubuntu system for testing (or Docker)

### Setting up the development environment

```bash
# Clone your fork
git clone https://github.com/your-username/IPTV-Manager.git
cd IPTV-Manager

# Install dependencies
python3 -m pip install -r requirements.txt

# Run the script
python3 iptv_manager.py --help
```

### Testing

Before submitting a pull request, please test your changes:

```bash
# Test basic functionality
python3 iptv_manager.py --status

# Test installation script
bash install.sh

# Test different language settings
INSTALL_LANGUAGE=en bash install.sh
```

## 📝 Coding Standards

### Python Code Style

- Follow [PEP 8](https://www.python.org/dev/peps/pep-0008/) style guide
- Use meaningful variable and function names
- Add docstrings to all functions and classes
- Include type hints where appropriate
- Keep functions focused and small

### Shell Script Style

- Use `#!/bin/bash` shebang
- Quote variables to prevent word splitting
- Use `set -e` for error handling
- Add comments for complex logic
- Follow consistent indentation (4 spaces)

### Documentation

- Update README.md if you change functionality
- Add comments for complex code sections
- Update CHANGELOG.md for notable changes
- Ensure both Chinese and English documentation are updated

## 🌐 Internationalization

When adding new user-facing text:

1. **Add the text to `languages.py`** in both `LANG_ZH` and `LANG_EN` dictionaries
2. **Use `get_text()` function** instead of hardcoded strings
3. **Test both language modes** to ensure proper display
4. **Keep translations concise** and culturally appropriate

Example:
```python
# Instead of:
print("Download completed successfully!")

# Use:
print(get_text('download_success'))
```

## 🔄 Git Workflow

### Branch Naming

- `feature/description` - for new features
- `bugfix/description` - for bug fixes
- `docs/description` - for documentation updates
- `refactor/description` - for code refactoring

### Commit Messages

Use clear and meaningful commit messages:

```
feat: add multi-language support for installation script
fix: resolve encoding detection issue with M3U files
docs: update README with new installation options
refactor: improve error handling in download module
```

### Pull Request Process

1. **Update documentation** as needed
2. **Add tests** for new functionality
3. **Ensure all tests pass**
4. **Update CHANGELOG.md** with your changes
5. **Request review** from maintainers

## 🏷️ Issue Labels

We use the following labels to categorize issues:

- `bug` - Something isn't working
- `enhancement` - New feature or request
- `documentation` - Improvements or additions to documentation
- `good first issue` - Good for newcomers
- `help wanted` - Extra attention is needed
- `question` - Further information is requested
- `wontfix` - This will not be worked on

## 📋 Code of Conduct

### Our Pledge

We pledge to make participation in our project a harassment-free experience for everyone, regardless of age, body size, disability, ethnicity, gender identity and expression, level of experience, nationality, personal appearance, race, religion, or sexual identity and orientation.

### Our Standards

Examples of behavior that contributes to creating a positive environment include:

- Using welcoming and inclusive language
- Being respectful of differing viewpoints and experiences
- Gracefully accepting constructive criticism
- Focusing on what is best for the community
- Showing empathy towards other community members

### Enforcement

Instances of abusive, harassing, or otherwise unacceptable behavior may be reported by contacting the project team. All complaints will be reviewed and investigated promptly and fairly.

## 🙏 Recognition

Contributors will be recognized in the following ways:

- Listed in the project's contributors section
- Mentioned in release notes for significant contributions
- Given credit in documentation updates

## 📞 Getting Help

If you need help with contributing:

- Check the [README.md](README.md) for basic setup
- Look at existing issues and pull requests
- Create a new issue with the `question` label
- Join our community discussions

Thank you for contributing to IPTV Manager! 🎉