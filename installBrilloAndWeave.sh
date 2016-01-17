#!/bin/bash
# This script will install Brillo and Weave

clear
echo "    ____       _ ____         ___      _       __" 
echo "   / __ )_____(_) / /___     ( _ )    | |     / /__  ____ __   _____"
echo '  / __  / ___/ / / / __ \   / __ \/|  | | /| / / _ \/ __ `/ | / / _ \'
echo " / /_/ / /  / / / / /_/ /  / /_/  <   | |/ |/ /  __/ /_/ /| |/ /  __/"
echo "/_____/_/  /_/_/_/\____/   \____/\/   |__/|__/\___/\__,_/ |___/\___/"
echo "                                                                      "
echo "Install Brillo and Weave by @bobvanluijt"
echo "   "

##
# Check Ubuntu version
##
HOST=$(lsb_release -r 2>/dev/null | sed 's/[^0-9]*//g')
if [[ "$HOST" != "1404" ]]; then
    echo "Ubuntu 14.04 is recommended (https://developers.google.com/brillo/eap/reference/downloads)"
    echo "Are you sure you want to continue Y/n, followed by [ENTER]"
    read NONUBUNTU
    if [[ "$NONUBUNTU" == "n" ]]; then
        echo "Terminated"
        exit 1
    fi
fi

##
# SELECT BOARD TYPE
##
echo "Enter the boardtype you would like to install (dragonboard or edison), followed by [ENTER]:"
echo "You can rerun the script to add other boards"
echo "Board overview: https://developers.google.com/brillo/eap/guides/get-started/get-hardware"
read BOARDTYPE

if [[ "$BOARDTYPE" != "dragonboard" && "$BOARDTYPE" != "edison" ]]; then
    echo "This boars is unknown, script terminated"
    exit 1
fi

##
# SET GIT EMAIL
##
echo "Enter Git email adres, followed by [ENTER]"
echo "Example: test@test.com"
read GITEMAIL

if [[ "$GITEMAIL" == "" ]]; then
    echo "No email is setup"
    exit 1
fi

##
# SET GIT NAME
##
echo "Enter Git name, followed by [ENTER], followed by enter"
echo "Example: John Doe"
read GITUSER

if [[ "$GITUSER" == "" ]]; then
    echo "No user name is setup"
    exit 1
fi

##
# INSTALL WEAVE
##
echo "Install Weave? y/n"
echo "Select 'n' when only installing an additional board"
read WEAVE

if [[ "$WEAVE" != "y" && "$WEAVE" != "n" ]]; then
    echo "Select 'n' or 'y' for installing Weave"
    exit 1
fi

echo "START INSTALLATION"

apt-get update && \
apt-get upgrade -y && \
apt-get install software-properties-common python-software-properties wget -qq -y && \
apt-get install git-core gnupg flex bison gperf build-essential zip curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev x11proto-core-dev libx11-dev lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc unzip openjdk-7-jdk python-networkx -qq -y && \
wget https://dl.google.com/dl/brillo/bdk/latest/bdk-latest.tar.gz && \
tar -xzf bdk-latest.tar.gz && \
rm bdk-latest.tar.gz && \
export BDK_PATH=~/bdk && \
yes | ${BDK_PATH}/tools/bdk/brunch/brunch bsp download "$BOARDTYPE"

if [[ "$WEAVE" == "y" ]]; then
    echo "INSTALL WEAVE"
    git config --global user.email "$GITEMAIL" && \
    git config --global user.name "$GITUSER" && \
    git clone https://android.googlesource.com/platform/system/weaved/ && \
    repo init -u https://weave.googlesource.com/weave/manifest -b weave-release-1.1
fi
