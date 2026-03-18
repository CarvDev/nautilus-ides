#!/bin/bash
set -euo pipefail

REPO_RAW_BASE="https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main"

load_common() {
    local script_dir common_path script_source

    script_source="${BASH_SOURCE[0]}"

    # When this script is piped into bash, BASH_SOURCE[0] is empty and
    # dirname would resolve to the current working directory. Only trust a
    # local common.sh when uninstall.sh itself comes from a real file.
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

get_installed_ide_selection "Select an IDE to uninstall:"

print_success "Selected IDE to uninstall: $IDE_LABEL"
echo ""

SCRIPT_NAME="$(get_installed_script_name "$IDE")"
if [ -z "$SCRIPT_NAME" ]; then
    SCRIPT_NAME="$(get_extension_script_name "$IDE")"
fi

print_info "Removing ${SCRIPT_NAME}..."
if [ -f "${EXTENSIONS_DIR}/${SCRIPT_NAME}" ]; then
    rm -f "${EXTENSIONS_DIR}/${SCRIPT_NAME}"
    unregister_installed_ide "$IDE"
    print_success "Successfully removed ${IDE_LABEL}"
else
    print_warning "${SCRIPT_NAME} not found in ${EXTENSIONS_DIR}"
fi
echo ""

restart_nautilus
print_success "Uninstallation Complete for $IDE_LABEL"
