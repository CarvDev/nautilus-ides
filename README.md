# Nautilus IDE Extensions

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

## Description

This project provides Nautilus context menu integrations for IDEs using a single Python extension template.

Instead of keeping one Python script per IDE, the installer reads a repository-controlled catalog, renders the generic template with the selected IDE data, and installs the final extension into Nautilus.

The target machine does not keep an editable IDE catalog. Supported IDEs are controlled only by this repository.

This repository is based on the excellent work from [code-nautilus](https://github.com/harry-cpp/code-nautilus) by harry-cpp.

## Features

- One generic extension template
- Repository-controlled IDE catalog
- Cleaner install and uninstall flow
- Easy to extend with new IDE commands
- Open files or folders from Nautilus

## Supported IDEs

Current defaults:

- **Antigravity** (`antigravity`)
- **VS Code** (`code`)
- **Cursor** (`cursor`)
- **Windsurf** (`windsurf`)

## How It Works

1. `install.sh` loads the IDE catalog from `config/ides.conf`
2. The user selects one IDE from the allowed list
3. The installer renders `scripts/nautilus-ide-template.py`
4. A final extension file like `cursor-nautilus.py` is written to Nautilus extensions
5. The installation is registered so `uninstall.sh` knows what it can remove

## IDE Catalog

The repository file `config/ides.conf` uses this format:

```text
id|label|command|new_window
```

Example:

```text
zed|Zed|zed|false
code-insiders|Code Insiders|code-insiders|false
```

Notes:
- `id`: unique identifier
- `label`: text shown in Nautilus
- `command`: executable or full command used to launch the IDE
- `new_window`: `true` or `false`

Example:

- `cursor|Cursor|cursor|false`
- `code-insiders|Code Insiders|code-insiders|false`

## Installation

Run the following command:

```bash
wget -qO- https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main/install.sh | bash
```

This installs the selected IDE using the generic extension template.

## Uninstallation

To remove one IDE installed by this project, run:

```bash
wget -qO- https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main/uninstall.sh | bash
```

The uninstall flow only lists IDEs that were installed by this project.

## Requirements

- Python Nautilus
- Your chosen IDE installed in the system
- Nautilus file manager

## Usage

1. Right-click on any file to open it in the IDE
2. Right-click on a folder to open it in the IDE
3. Right-click on empty space in a folder to open that folder in the IDE

## Adding a New IDE

1. Add a new line to `config/ides.conf`
2. Use a unique `id`
3. Set the label that should appear in Nautilus
4. Set the launch command available on the user system
5. Choose whether `--new-window` should be forced by default

Example:

```text
zed|Zed|zed|false
```

No extra Python file is needed. The installer will reuse the same template automatically.

## Project Structure

- `install.sh`: installs one selected IDE
- `uninstall.sh`: removes one installed IDE
- `common.sh`: shared shell helpers
- `config/ides.conf`: repository-controlled IDE catalog
- `scripts/nautilus-ide-template.py`: generic Nautilus extension template

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Author

Created and maintained by Rodrigo Sakaguchi
