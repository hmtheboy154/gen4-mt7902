#!/bin/bash

#Made by github.com/RichyKunBv with love

# Por si acaso xd.
set -e

VERDE='\033[0;32m'
AMA='\033[0;33m'
ROJO='\033[0;31m'
MAGENTA='\033[0;35m'
DEFAULT='\033[0m'



detectar_distribucion() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO="$ID"
        
        # Detectar familia de distribución
        if [[ "$ID" == "debian" || "$ID_LIKE" == *"debian"* ]]; then
            DISTRO_FAMILIA="debian"
        elif [[ "$ID" == "fedora" || "$ID_LIKE" == *"fedora"* || "$ID" == "rhel" || "$ID" == "centos" ]]; then
            DISTRO_FAMILIA="fedora"
        elif [[ "$ID" == "arch" || "$ID_LIKE" == *"arch"* || "$ID" == "manjaro" ]]; then
            DISTRO_FAMILIA="arch"
        else
            DISTRO_FAMILIA="desconocida"
        fi
    elif [ -f /etc/redhat-release ]; then
        DISTRO="redhat"
        DISTRO_FAMILIA="fedora"
    elif [ -f /etc/arch-release ]; then
        DISTRO="arch"
        DISTRO_FAMILIA="arch"
    else
        DISTRO="desconocida"
        DISTRO_FAMILIA="desconocida"
    fi
    
    echo -e "${VERDE}Distribution detected: $DISTRO (Family: $DISTRO_FAMILIA)${DEFAULT}"
}

# --- SUDO obligatorio ---
if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo -e "${ROJO}Error: Please run this script with sudo.${DEFAULT}"
    exit 1
fi

# Detectar distribución al inicio
detectar_distribucion

# --- Comandos ---

function instalar_dependencias() {
    echo -e "\n${AMA}› Checking dependencies to install...${DEFAULT}"
    
    case "$DISTRO_FAMILIA" in
        debian)
            sudo apt update
            sudo apt install -y git make dkms build-essential linux-headers-$(uname -r)
            echo -e "${VERDE}  Dependencies installed.${DEFAULT}"
            ;;
        fedora)
            if command -v dnf &> /dev/null; then
            sudo dnf install -y git make dkms kernel-devel kernel-headers
            sudo dnf group install -y development-tools
            fi
            echo -e "${VERDE}  Dependencies installed.${DEFAULT}"
            ;;
        arch)
            sudo pacman -S --noconfirm --needed git make dkms base-devel linux-headers
            echo -e "${VERDE}  Dependencies installed.${DEFAULT}"
            ;;
        *)
            echo -e "${ROJO}  Unsupported distribution.${DEFAULT}"
            ;;
    esac
}

# Que haces en mi codigo miamor? U//w//U

function instalar_driver() {
        echo "› Checking..."
        rm -rf gen4-mt7902

        echo -e "${ROJO}  Cloning driver repository...${DEFAULT}"
        git clone https://github.com/hmtheboy154/gen4-mt7902.git

        echo -e "${ROJO}  Entering driver directory...${DEFAULT}"
        cd gen4-mt7902

        echo -e "${ROJO}  Compiling the driver...${DEFAULT}"
        make

        echo -e "${ROJO}  Installing the driver...${DEFAULT}"
        sudo make install
}


function verificador() {
        echo "› Verifying installation..."

if lsmod | grep -q "mt7902_pci"; then
        echo "✅ Congratulations! The driver is loaded."
else
        echo "⚠️  The driver is installed. Please reboot to activate it."
fi
}


while true; do
    echo -e "\n${VERDE}--- Driver Installation Wizard ---${DEFAULT}"
    echo -e "${VERDE}--- Distribution: $DISTRO (Family: $DISTRO_FAMILIA) ---${DEFAULT}"
    echo "  1. Install mt7902 Driver"
    echo -e "  ${ROJO}X. Exit${DEFAULT}"
    read -p "  Select an option: " opcion

    case $opcion in
        1)
            clear
            detectar_distribucion
            instalar_dependencias
            instalar_driver
            verificador
            read -p "Press [Enter] to continue..."
            clear
            ;;
        
        [xX])
            break 
            ;;

        *)
            echo -e "\n${ROJO}  Invalid option. Please try again.${DEFAULT}"
            sleep 1
            clear
            ;;

    esac
done
