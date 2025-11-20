#!/bin/bash

source "$(dirname "$0")/common.sh"

get_ide_selection "Select an IDE to install:"

echo -e "${GREEN}Selected IDE: $IDE${NC}"
echo ""

# Install python-nautilus
echo -e "${BLUE}Installing python-nautilus...${NC}"
if type "pacman" > /dev/null 2>&1
then
    # check if already install, else install
    pacman -Qi python-nautilus &> /dev/null
    if [ `echo $?` -eq 1 ]
    then
        sudo pacman -S --noconfirm python-nautilus
    else
        echo -e "${GREEN}python-nautilus is already installed${NC}"
    fi
elif type "apt-get" > /dev/null 2>&1
then
    # Find Ubuntu python-nautilus package
    package_name="python-nautilus"
    found_package=$(apt-cache search --names-only $package_name)
    if [ -z "$found_package" ]
    then
        package_name="python3-nautilus"
    fi

    # Check if the package needs to be installed and install it
    installed=$(apt list --installed $package_name -qq 2> /dev/null)
    if [ -z "$installed" ]
    then
        sudo apt-get install -y $package_name
    else
        echo -e "${GREEN}$package_name is already installed.${NC}"
    fi
elif type "dnf" > /dev/null 2>&1
then
    installed=`dnf list --installed nautilus-python 2> /dev/null`
    if [ -z "$installed" ]
    then
        sudo dnf install -y nautilus-python
    else
        echo -e "${GREEN}nautilus-python is already installed.${NC}"
    fi
else
    echo -e "${RED}Failed to find python-nautilus, please install it manually.${NC}"
fi
echo ""

# Remove previous version and setup folder
echo -e "${BLUE}Removing previous version (if found)...${NC}"
mkdir -p ~/.local/share/nautilus-python/extensions
rm -f ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME
echo ""

# Download and install the extension
echo -e "${BLUE}Downloading newest version for $IDE...${NC}"
wget -q -O ~/.local/share/nautilus-python/extensions/$SCRIPT_NAME https://raw.githubusercontent.com/RodrigoSaka/nautilus-ides/main/scripts/$SCRIPT_NAME
echo ""

# Restart nautilus
echo -e "${BLUE}Restarting nautilus...${NC}"
nautilus -q > /dev/null 2>&1
echo ""

echo -e "${GREEN}Installation Complete for $IDE${NC}"
