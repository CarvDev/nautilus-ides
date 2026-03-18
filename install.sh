#!/bin/bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main"

load_common() {
    local script_dir common_path script_source

    script_source="${BASH_SOURCE[0]}"

    # When this script is piped into bash, BASH_SOURCE[0] is empty and
    # dirname would resolve to the current working directory. Only trust a
    # local common.sh when install.sh itself comes from a real file.
    if [ -n "$script_source" ] && [ -f "$script_source" ]; then
        script_dir="$(cd "$(dirname "$script_source")" && pwd 2>/dev/null)"
        common_path="${script_dir}/common.sh"

        if [ -f "$common_path" ]; then
            # shellcheck source=./common.sh
            source "$common_path"
            return
        fi
    fi

    if command -v curl > /dev/null 2>&1; then
        # Support execution via: wget/curl .../install.sh | bash
        source /dev/stdin <<< "$(curl -fsSL "${REPO_RAW_BASE}/common.sh")"
        return
    fi

    if command -v wget > /dev/null 2>&1; then
        source /dev/stdin <<< "$(wget -qO- "${REPO_RAW_BASE}/common.sh")"
        return
    fi

    echo "Failed to load common.sh. Install curl or wget, or run from a local checkout."
    exit 1
}

load_common

get_available_ide_selection "Select an IDE to install:"

print_success "Selected IDE: $IDE_LABEL"
echo ""

install_python_nautilus

SCRIPT_NAME="$(get_extension_script_name "$IDE")"
IDE_RECORD="$(get_ide_record "$IDE")" || fail "Failed to resolve IDE ${IDE}."

IFS='|' read -r IDE_ID IDE_LABEL IDE_COMMAND IDE_NEW_WINDOW <<< "$IDE_RECORD"
print_info "Installing generic Nautilus extension for ${IDE_LABEL}..."
TEMPLATE_CONTENT="$(render_extension_template "$IDE_ID" "$IDE_LABEL" "$IDE_COMMAND" "$IDE_NEW_WINDOW")"
write_extension_file "$SCRIPT_NAME" "$TEMPLATE_CONTENT"
register_installed_ide "$IDE_ID" "$IDE_LABEL" "$SCRIPT_NAME"
echo ""

restart_nautilus
print_success "Installation Complete for ${IDE_LABEL}"
