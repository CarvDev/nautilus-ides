#!/bin/bash

source "$(dirname "$0")/common.sh"

check_root

get_ide_selection "Select an IDE to install:"

get_ide_name $IDE

echo -e "${GREEN}Selected IDE: $IDE${NC}"
echo ""

# Verify python-nautilus instalation
if python3 -c "import gi; from gi.repository import Nautilus" 2> /dev/null ; then
    echo -e "${GREEN}python-nautilus is installed${NC}"
else
    echo -e "${RED}Error: python-nautilus is not installed${NC}"
    exit 1
fi
echo ""

# Create nautilus extension folder if it doesn't exists
mkdir -p ~/.local/share/nautilus-python/extensions

# Download and install the extension
echo -e "${BLUE}Downloading newest version for $IDE...${NC}"
# Verify if the installation was successful
if wget -q -O /tmp/$SCRIPT_NAME https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main/scripts/ide-nautilus-template.py ; then
    echo -e "${GREEN}Download completed successfully.${NC}"
else
    echo -e "${RED}Download failed.${NC}"
    exit 1
fi
echo ""

# Replacing IDE name and command on the script 
sed -i "s/__IDE_COMMAND__/$IDE/g" /tmp/$SCRIPT_NAME
sed -i "s/__IDE_NAME__/$IDE_NAME/g" /tmp/$SCRIPT_NAME

# Move recent built script to nautilus extensions directory
mv /tmp/$SCRIPT_NAME ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME

# Restart nautilus
echo -e "${BLUE}Restarting nautilus...${NC}"
nautilus -q > /dev/null 2>&1
echo ""

echo -e "${GREEN}Installation Complete for $IDE${NC}"
