#!/bin/bash

source "$(dirname "$0")/common.sh"

check_root

check_python_nautilus

get_ide_selection "Select an IDE to install:"

get_ide_name $IDE

get_ide_setup

echo -e "${GREEN}Selected IDE: $IDE${NC}"
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

# Setting up IDE arguments
if [ -n "$NEW_WINDOW_ARG" ]; then
    sed -i "s/__NEW_WINDOW_SUPPORT__/True/g" /tmp/$SCRIPT_NAME
    sed -i "s/__NEW_WINDOW_ARG__/$NEW_WINDOW_ARG/g" /tmp/$SCRIPT_NAME
else 
    sed -i "s/__NEW_WINDOW_SUPPORT__/False/g" /tmp/$SCRIPT_NAME
    sed -i "s/__NEW_WINDOW_ARG__/''/g" /tmp/$SCRIPT_NAME
fi

# Setting up new-window always
if [ "$ALWAYS_OPEN_NEW_WINDOW" -eq "1" ]; then
    sed -i "s/__NEW_WINDOW_ALWAYS__/True/g" /tmp/$SCRIPT_NAME
else 
    sed -i "s/__NEW_WINDOW_ALWAYS__/False/g" /tmp/$SCRIPT_NAME
fi

# Move recent built script to nautilus extensions directory
mv /tmp/$SCRIPT_NAME ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME

# Restart nautilus
echo -e "${BLUE}Restarting nautilus...${NC}"
nautilus -q > /dev/null 2>&1
echo ""

echo -e "${GREEN}Installation Complete for $IDE${NC}"
