#!/bin/bash

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

get_ide_selection "Select an IDE to uninstall:"

echo -e "${GREEN}Selected IDE to uninstall: $IDE${NC}"
echo ""

# Remove the extension
echo -e "${BLUE}Removing $SCRIPT_NAME...${NC}"
if [ -f ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME ]; then
    rm -f ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME
    echo -e "${GREEN}Successfully removed $SCRIPT_NAME${NC}"
else
    echo -e "${YELLOW}$SCRIPT_NAME not found in ~/.local/share/nautilus-python/extensions/${NC}"
fi
echo ""

# Restart nautilus
echo -e "${BLUE}Restarting nautilus...${NC}"
nautilus -q > /dev/null 2>&1
echo ""

echo -e "${GREEN}Uninstallation Complete for $IDE${NC}"
