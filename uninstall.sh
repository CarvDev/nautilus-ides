#!/bin/bash

source "$(dirname "$0")/common.sh"

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
