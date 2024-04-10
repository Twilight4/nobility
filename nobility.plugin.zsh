#!/usr/bin/env zsh

autoload colors; colors

# Check for essential packages
if command -v pacman &> /dev/null; then
    pacman -Qs rlwrap >/dev/null || sudo pacman -S --noconfirm rlwrap
    pacman -Qs git >/dev/null || sudo pacman -S --noconfirm git
elif command -v apt-get &> /dev/null; then
    dpkg -l | grep -qw rlwrap || sudo apt-get -y install rlwrap
    dpkg -l | grep -qw git || sudo apt-get -y install git
fi

# Check for directories
mkdir -p $HOME/.nobility/{vars,globals}


############################################################# 
# Constants
#############################################################
export __PLUGIN="${0:A:h}"
export __LOGFILE="${__PLUGIN}/log.txt"
export __STATUS=$(cd ${__PLUGIN} && git status | grep On | cut -d" " -f2,3)
export __VARS=$HOME/.nobility/vars
export __GLOBALS=$HOME/.nobility/globals
export __PAYLOADS="$__PLUGIN/payloads"
export __SCRIPTS="$__PLUGIN/scripts"
export __TOOLS="/opt/tools"


############################################################# 
# Diagnostic Log
#############################################################
echo "[*] loading... " >> ${__LOGFILE}

# Source all nb scripts
for f in ${0:A:h}/modules/nb* ; do
  echo "[+] sourcing $f ... "  >> ${__LOGFILE}
  source $f >> ${__LOGFILE} 2>&1
done

# Completion enhancement
# zstyle ':completion:*' matcher-list 'r:|[-]=**'
ZSTYLE_ORIG=`zstyle -L ':completion:\*' matcher-list`
ZSTYLE_NEW="${ZSTYLE_ORIG} 'r:|[-]=**'"
eval ${ZSTYLE_NEW}

echo "[*] nobility loaded." >> ${__LOGFILE}


############################################################# 
# Shell Log
#############################################################
__info "Nobility ZSH plugin loaded"
echo ""
