#!/usr/bin/env zsh

autoload colors; colors

# Check for essential packages
pacman -Qs rlwrap >/dev/null || sudo pacman -S --noconfirm rlwrap
pacman -Qs git >/dev/null || sudo pacman -S --noconfirm git

# Check for directories
mkdir -p $HOME/.nobility/{vars,globals}


############################################################# 
# Constants
#############################################################
export __PLUGIN="${0:A:h}"
export __VER=$(cat ${__PLUGIN}/VERSION)
export __LOGFILE="${__PLUGIN}/log.txt"
export __REMOTE_CHK="${__PLUGIN}/remote_checked.txt"
export __REMOTE_VER="${__PLUGIN}/remote_ver.txt"
export __STATUS=$(cd ${__PLUGIN} && git status | grep On | cut -d" " -f2,3)
export __VARS=$HOME/.nobility/vars
export __GLOBALS=$HOME/.nobility/globals
export __PAYLOADS="$__PLUGIN/payloads"
export __SCRIPTS="$__PLUGIN/scripts"
export __TOOLS="$HOME/tools"


############################################################# 
# Self Update
#############################################################
__version-check() {

  local seconds=$((60*60*24*1))

  if test -f "$__REMOTE_CHK" ; then
      if test "$(($(date "+%s")-$(date -f "$__REMOTE_CHK" "+%s")))" -lt "$seconds" ; then
            echo "[*] Version already checked today: $__REMOTE_CHK" >> ${__LOGFILE}
          exit 1
      fi
  fi

  date -R > $__REMOTE_CHK

  echo "$(curl -s https://raw.githubusercontent.com/Twilight4/nobility/main/VERSION)" > $__REMOTE_VER
  
  echo "[*] Version checked and stored in:  $__REMOTE_VER" >> ${__LOGFILE}

}

(__version-check &)


############################################################# 
# Diagnostic Log
#############################################################
echo "Nobility ${__VER} in ${__PLUGIN}" > ${__LOGFILE}
echo " " >> ${__LOGFILE}
echo "[*] loading... " >> ${__LOGFILE}

#Source all nb scripts

for f in ${0:A:h}/modules/nb* ; do
  echo "[+] sourcing $f ... "  >> ${__LOGFILE}
  source $f >> ${__LOGFILE} 2>&1
done

source ${__ALIASES}

# Completion enhancement
# zstyle ':completion:*' matcher-list 'r:|[-]=**'
ZSTYLE_ORIG=`zstyle -L ':completion:\*' matcher-list`
ZSTYLE_NEW="${ZSTYLE_ORIG} 'r:|[-]=**'"
eval ${ZSTYLE_NEW}

echo "[*] nobility loaded." >> ${__LOGFILE}


############################################################# 
# Shell Log
#############################################################
echo " "

if [[ -f "$__REMOTE_VER" ]]; then
  
  echo "[*] Remote version file exists: $__REMOTE_VER " >> ${__LOGFILE}

  rv=$(cat ${__REMOTE_VER})

  if [[ ! -z $rv ]]; then

    echo "[*] Remote version is |${rv}|" >> ${__LOGFILE}

    [[ "$rv" == "$__VER" ]] && __info "Nobility is up to date" || __warn "Nobility update available: $rv, use nb-update to install"

  fi

fi

__info "Nobility ${__VER} ZSH plugin loaded "

