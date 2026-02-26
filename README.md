# Nautilus IDE Extensions

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## 🚀 Description

This repository provides a universal Nautilus extension generator to add "Open with..." context menu support for **any** IDE or text editor, allowing you to open files and folders directly from your file explorer.

### Supported IDEs:
- **Out-of-the-box presets:** VS Code (`code`), Cursor (`cursor`), Windsurf (`windsurf`), and Antigravity (`antigravity`).
- **Universal Support:** A `[custom]` option allows you to generate extensions for *any* other tool (e.g., Neovim, Zed, Sublime Text) by defining your own binary command and window arguments interactively!

This repository is based on the excellent work from [code-nautilus](https://github.com/harry-cpp/code-nautilus) by harry-cpp.

## 🎯 Features

- Right-click to open files in your favorite IDE.
- Open entire folders directly from the context menu.
- **Dynamic Template Engine:** Automatically configures your extension based on your IDE's specific arguments (like `--new-window` support).
- **Atomic Installation:** Safe and robust installation process that prevents corrupted states.
- Clean and modern integration with Nautilus.

## 🛠️ Installation / Update

Clone this repository and run the interactive installation script:

```bash
git clone https://github.com/RodrigoSaka/nautilus-ides.git
cd nautilus-ides
./install.sh

```

## 🗑️ Uninstallation

To remove an extension, simply run the uninstaller from the cloned directory:

```bash
cd nautilus-ides
./uninstall.sh

```

## 📦 Requirements

* Python Nautilus (`python-nautilus` package)
* Your chosen IDE
* Nautilus file manager

## 📝 Usage

1. Right-click on any file to open it in the IDE
2. Right-click on a folder to open it in the IDE
3. Or right-click on empty space inside a folder to open that directory in your IDE

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## 👥 Author

Created and maintained by Rodrigo Sakaguchi.