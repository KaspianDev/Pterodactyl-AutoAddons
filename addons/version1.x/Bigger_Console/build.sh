#!/bin/bash
#shellcheck source=/dev/null

set -e

########################################################
# 
#         Pterodactyl-AutoAddons Installation
#
#         Created and maintained by Ferks-FK
#
#            Protected by GPL 3.0 License
#
########################################################

#### Fixed Variables ####

SCRIPT_VERSION="v3.0"
SUPPORT_LINK="https://discord.gg/buDBbSGJmQ"

update_variables() {
BIGGER_CONSOLE="$PTERO/resources/scripts/components/server/ServerConsole.tsx"
MORE_BUTTONS="$PTERO/resources/scripts/components/server/MoreButtons.tsx"
MC_PASTE="$PTERO/app/Repositories/Eloquent/MCPasteVariableRepository.php"
CONFIG_FILE="$PTERO/config/app.php"
PANEL_VERSION=$(cat "$CONFIG_FILE" | grep -n ^ | grep ^12: | cut -d: -f2 | cut -c18-23 | sed "s/'//g")
}


print_brake() {
  for ((n = 0; n < $1; n++)); do
    echo -n "#"
  done
  echo ""
}

print_warning() {
  COLOR_YELLOW='\033[1;33m'
  COLOR_NC='\033[0m'
  echo -e "* ${COLOR_YELLOW}WARNING${COLOR_NC}: $1"
  echo ""
}


hyperlink() {
  echo -e "\e]8;;${1}\a${1}\e]8;;\a"
}


#### Colors ####

GREEN="\e[0;92m"
YELLOW="\033[1;33m"
red='\033[0;31m'
reset="\e[0m"


#### OS check ####

check_distro() {
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$(echo "$ID" | awk '{print tolower($0)}')
    OS_VER=$VERSION_ID
  elif type lsb_release >/dev/null 2>&1; then
    OS=$(lsb_release -si | awk '{print tolower($0)}')
    OS_VER=$(lsb_release -sr)
  elif [ -f /etc/lsb-release ]; then
    . /etc/lsb-release
    OS=$(echo "$DISTRIB_ID" | awk '{print tolower($0)}')
    OS_VER=$DISTRIB_RELEASE
  elif [ -f /etc/debian_version ]; then
    OS="debian"
    OS_VER=$(cat /etc/debian_version)
  elif [ -f /etc/SuSe-release ]; then
    OS="SuSE"
    OS_VER="?"
  elif [ -f /etc/redhat-release ]; then
    OS="Red Hat/CentOS"
    OS_VER="?"
  else
    OS=$(uname -s)
    OS_VER=$(uname -r)
  fi

  OS=$(echo "$OS" | awk '{print tolower($0)}')
  OS_VER_MAJOR=$(echo "$OS_VER" | cut -d. -f1)
}

#### Find where pterodactyl is installed ####

find_pterodactyl() {
echo
print_brake 47
echo -e "* ${GREEN}Looking for your pterodactyl installation...${reset}"
print_brake 47
echo
sleep 2
if [ -d "/var/www/pterodactyl" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/pterodactyl"
  elif [ -d "/var/www/panel" ]; then
    PTERO_INSTALL=true
    PTERO="/var/www/panel"
  elif [ -d "/mnt/d/Pobrane/pterofork/panel" ]; then
    PTERO_INSTALL=true
    PTERO="/mnt/d/Pobrane/pterofork/panel"
  else
    PTERO_INSTALL=false
fi
# Update the variables after detection of the pterodactyl installation #
update_variables
}

#### Verify Compatibility ####

compatibility() {
echo
print_brake 57
echo -e "* ${GREEN}Checking if the addon is compatible with your panel...${reset}"
print_brake 57
echo
sleep 2
if [ -f "$CONFIG_FILE" ]; then
  if [ "$PANEL_VERSION" == "1.6.6" ]; then
      echo
      print_brake 23
      echo -e "* ${GREEN}Compatible Version!${reset}"
      print_brake 23
      echo
    elif [ "$PANEL_VERSION" == "1.7.0" ]; then
      echo
      print_brake 23
      echo -e "* ${GREEN}Compatible Version!${reset}"
      print_brake 23
      echo
    else
      echo
      print_brake 24
      echo -e "* ${red}Incompatible Version!${reset}"
      print_brake 24
      echo
      exit 1
  fi
fi
}


#### Install Dependencies ####

dependencies() {
echo
print_brake 30
echo -e "* ${GREEN}Installing dependencies...${reset}"
print_brake 30
echo
case "$OS" in
debian | ubuntu)
curl -sL https://deb.nodesource.com/setup_16.x | sudo -E bash - && apt-get install -y nodejs
;;
centos)
[ "$OS_VER_MAJOR" == "7" ] && curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash - && sudo yum install -y nodejs yarn
[ "$OS_VER_MAJOR" == "8" ] && curl -sL https://rpm.nodesource.com/setup_16.x | sudo -E bash - && sudo dnf install -y nodejs
;;
esac
}


#### Panel Backup ####

backup() {
echo
print_brake 32
echo -e "* ${GREEN}Performing security backup...${reset}"
print_brake 32
  if [ -d "$PTERO/PanelBackup[Auto-Addons]" ]; then
    echo
    print_brake 45
    echo -e "* ${GREEN}There is already a backup, skipping step...${reset}"
    print_brake 45
    echo
  else
    cd "$PTERO"
    if [ -d "$PTERO/node_modules" ]; then
        tar -czvf "PanelBackup[Auto-Addons].tar.gz" --exclude "node_modules" -- * .env
        mkdir -p "PanelBackup[Auto-Addons]"
        mv "PanelBackup[Auto-Addons].tar.gz" "PanelBackup[Auto-Addons]"
      else
        tar -czvf "PanelBackup[Auto-Addons].tar.gz" -- * .env
        mkdir -p "PanelBackup[Auto-Addons]"
        mv "PanelBackup[Auto-Addons].tar.gz" "PanelBackup[Auto-Addons]"
    fi
fi
}


#### Download Files ####

download_files() {
echo
print_brake 25
echo -e "* ${GREEN}Downloading files...${reset}"
print_brake 25
echo
cd "$PTERO"
mkdir -p temp
cd temp
curl -sSLo Bigger_Console.tar.gz https://raw.githubusercontent.com/Ferks-FK/Pterodactyl-AutoAddons/${SCRIPT_VERSION}/addons/version1.x/Bigger_Console/Bigger_Console.tar.gz
tar -xzvf Bigger_Console.tar.gz
cd Bigger_Console
cp -rf -- * "$PTERO"
cd "$PTERO"
rm -r temp
}


#### Check if it is already installed ####

verify_installation() {
if grep '<div css={tw`rounded bg-yellow-500 p-3`}>' "$BIGGER_CONSOLE" &>/dev/null; then
    print_brake 61
    echo -e "* ${red}This addon is already installed in your panel, aborting...${reset}"
    print_brake 61
    exit 1
  else
    dependencies
    backup
    download_files
    production
    bye
fi
}

#### Check if another conflicting addon is installed ####

check_conflict() {
echo
print_brake 66
echo -e "* ${GREEN}Checking if a similar/conflicting addon is already installed...${reset}"
print_brake 66
echo
sleep 2
if [ -f "$MORE_BUTTONS" ]; then
    echo
    print_brake 70
    echo -e "* ${red}The addon ${YELLOW}More Buttons ${red}is already installed, aborting...${reset}"
    print_brake 70
    echo
    exit 1
  elif [ -f "$MC_PASTE" ]; then
    echo
    print_brake 55
    echo -e "* ${red}The addon ${YELLOW}MC Paste ${red}is already installed, aborting...${reset}"
    print_brake 55
    echo
    exit 1
fi
}

#### Panel Production ####

production() {
echo
print_brake 25
echo -e "* ${GREEN}Producing panel...${reset}"
print_brake 25
echo
if [ -d "$PTERO/node_modules" ]; then
    cd "$PTERO"
    yarn build:production
  else
    npm i -g yarn
    cd "$PTERO"
    yarn install
    yarn build:production
fi
}


bye() {
print_brake 50
echo
echo -e "${GREEN}* The addon ${YELLOW}Bigger Console${GREEN} was successfully installed."
echo -e "* A security backup of your panel has been created."
echo -e "* Thank you for using this script."
echo -e "* Support group: ${YELLOW}$(hyperlink "$SUPPORT_LINK")${reset}"
echo
print_brake 50
}


#### Exec Script ####
check_distro
find_pterodactyl
if [ "$PTERO_INSTALL" == true ]; then
    echo
    print_brake 66
    echo -e "* ${GREEN}Installation of the panel found, continuing the installation...${reset}"
    print_brake 66
    echo
    compatibility
    check_conflict
    verify_installation
  elif [ "$PTERO_INSTALL" == false ]; then
    echo
    print_brake 66
    echo -e "* ${red}The installation of your panel could not be located, aborting...${reset}"
    print_brake 66
    echo
    exit 1
fi
