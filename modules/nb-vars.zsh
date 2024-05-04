#!/usr/bin/env zsh

############################################################# 
# nb-vars
#############################################################
nb-vars-help() {
  cat << "DOC" | bat --plain --language=help

nb-vars
-------
The vars namespace manages environment variables used in other functions. These
variables are set per session, but can be saved with nb-vars-save and reloaded
with nb-vars-load. The values are stored as files in .nobility/vars.

The menu options for some of the variables can be set using nb-vars-global, such
as the list of favorite user-agents or wordlists (nb-vars-global-help).

Note: 
If you use in scripts: __check-VAR instead of nb-vars-set-VAR, 
it will not ask for tha variable nor prefill it, that means:
use __check-VAR for obvious choices,
use nb-vars-set-VAR for more verbosity

Variables
---------
__PROJECT     the root directory used for all output, ex: /projects/example
__IFACE       the interface to use for commands, ex: eth0
__DOMAIN      the domain to use for commands, ex: example.org
__NETWORK     the subnet to use for commands, ex: 10.1.2.0/24
__RHOST       the remote host or target, ex: 10.1.2.3, example: target.example.org
__RPORT       the remote port; ex: 80
__LHOST       the accessible local IP address, ex: 10.1.2.3
__LPORT       the accessible local PORT, ex: 4444
__URL         a target URL, example: https://target.example.org
__UA          the user agent to use for commands, ex: googlebot
__WORDLIST    used to select from a list of favorite wordlists (global var) brute forcing
__PASSLIST    used to select only from passwords wordlists for password brute forcing

Commands
--------
nb-vars           list all current variable values
nb-vars-save      save all current variable values ($HOME/.nobility)
nb-vars-load      restores all current variable values ($HOME/.nobility)
nb-vars-clear     clears all current variable values
nb-vars-set-*     used to set each individual variable

DOC
}

nb-vars() {
  echo "$(__cyan __PROJECT: ) ${__PROJECT}"
  echo "$(__cyan __IFACE: ) ${__IFACE}"
  echo "$(__cyan __DOMAIN: ) ${__DOMAIN}"
  echo "$(__cyan __NETWORK: ) ${__NETWORK}"
  echo "$(__cyan __RHOST: ) ${__RHOST}"
  echo "$(__cyan __RPORT: ) ${__RPORT}"
  echo "$(__cyan __LHOST: ) ${__LHOST}"
  echo "$(__cyan __LPORT: ) ${__LPORT}"
  echo "$(__cyan __URL: ) ${__URL}"
  echo "$(__cyan __UA: ) ${__UA}"
  echo "$(__cyan __WORDLIST: ) ${__WORDLIST}"
  echo "$(__cyan __PASSLIST: ) ${__PASSLIST}"
}

nb-vars-clear() {
  __PROJECT=""
  __IFACE=""
  __DOMAIN=""
  __NETWORK=""
  __RHOST=""
  __RPORT=""
  __LHOST=""
  __LPORT=""
  __URL=""
  __UA="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.169 Safari/537.36"
  __WORDLIST=""
  __PASSLIST="/usr/share/wordlists/seclists/Passwords/Leaked-Databases/rockyou.txt"

  # Save the changes
  nb-vars-save
}

nb-vars-save() {
  echo "${__PROJECT}" > $__VARS/PROJECT
  echo "${__IFACE}" > $__VARS/IFACE
  echo "${__DOMAIN}" > $__VARS/DOMAIN
  echo "${__NETWORK}" > $__VARS/NETWORK
  echo "${__RHOST}" > $__VARS/RHOST
  echo "${__RPORT}" > $__VARS/RPORT
  echo "${__LHOST}" > $__VARS/LHOST
  echo "${__LPORT}" > $__VARS/LPORT
  echo "${__URL}" > $__VARS/URL
  echo "${__UA}" > $__VARS/UA
  echo "${__WORDLIST}" > $__VARS/WORDLIST
  echo "${__PASSLIST}" > $__VARS/PASSLIST

  # Show the changes
  nb-vars
}

nb-vars-load() {
    __PROJECT=$(cat $__VARS/PROJECT) 
    __IFACE=$(cat $__VARS/IFACE)
    __DOMAIN=$(cat $__VARS/DOMAIN)
    __NETWORK=$(cat $__VARS/NETWORK)
    __RHOST=$(cat $__VARS/RHOST)
    __RPORT=$(cat $__VARS/RPORT)
    __LHOST=$(cat $__VARS/LHOST)
    __LPORT=$(cat $__VARS/LPORT)
    __URL=$(cat $__VARS/URL)
    __UA=$(cat $__VARS/UA)
    __WORDLIST=$(cat $__VARS/WORDLIST)
    __PASSLIST=$(cat $__VARS/PASSLIST)

    # Show the changes
    nb-vars
}


############################################################# 
# __PROJECT
#############################################################
export __PROJECT="$HOME/desktop/projects/"

nb-vars-set-project() {
  __ask "Select the project directory you created with nb-project-start."
  
  local pd=$(__menu $(find $__PROJECT -mindepth 1 -maxdepth 1 -type d))
  __ok "Selected: ${pd}"

  __PROJECT=$pd/tool-output
  mkdir -p ${__PROJECT}
}

# Check if output dir exists, if not, set it
__check-project() {
  if [ -z "$(find "$HOME/desktop/projects/" -mindepth 1 -maxdepth 1 -type d)" ]; then
    __err "There are no directories in the $HOME/desktop/projects/"
    exit
  fi

  [[ -z "${__PROJECT}" ]] && nb-vars-set-project
}


############################################################# 
# __IFACE
#############################################################
export __IFACE=""

nb-vars-set-iface() {
  if [[ -z "${__IFACE}" ]]
  then
    __ask "Choose an interface: "
    __IFACE=$(__menu $(ip addr list | awk -F': ' '/^[0-9]/ {print $2}')) 
  else
    __prefill __IFACE IFACE ${__IFACE}
  fi

}

__check-iface() { [[ -z "${__IFACE}" ]] && nb-vars-set-iface }


############################################################# 
# __DOMAIN
#############################################################
export __DOMAIN=""

nb-vars-set-domain() { __prefill __DOMAIN DOMAIN ${__DOMAIN} }

__check-domain() { [[ -z "${__DOMAIN}" ]] && nb-vars-set-domain }


############################################################# 
# __NETWORK
#############################################################
export __NETWORK=""

nb-vars-set-network() { __prefill __NETWORK NETWORK ${__NETWORK} }

__check-network() { [[ -z "${__NETWORK}" ]] && nb-vars-set-network }


############################################################# 
# __RHOST
#############################################################
export __RHOST=""

nb-vars-set-rhost() { __prefill __RHOST RHOST ${__RHOST} }


############################################################# 
# __RPORT
#############################################################
export __RPORT=""

nb-vars-set-rport() { __prefill __RPORT RPORT ${__RPORT} }


############################################################# 
# __LHOST
#############################################################
export __LHOST=""

nb-vars-set-lhost() {
  if [[ -z $__LHOST ]]
  then
    __ask "Choose a local IP address: " 
    __LHOST=$(__menu $(\ip addr list | grep -e "inet " | cut -d' ' -f6 | cut -d'/' -f1))
  else
    __prefill __LHOST LHOST ${__LHOST}
  fi
}


############################################################# 
# __LPORT
#############################################################
export __LPORT=""

nb-vars-set-lport() { __prefill __LPORT LPORT ${__LPORT} }


############################################################# 
# __URL
#############################################################
export __URL=""

nb-vars-set-url() { 
  local u && __prefill u URL ${__URL}
  __URL=$(echo ${u} | sed 's/\/$//')
}


############################################################# 
# __UA
#############################################################
export __UA="Mozilla/5.0"

nb-vars-set-ua() {
  IFS=$'\n'
  __ask "Choose a user agent: " 
  __UA=$(__menu $(cat  ${__MNU_UA}))
}

__check-ua() { [[ -z "${__UA}" ]] && nb-vars-set-ua }


############################################################# 
# __WORDLIST
#############################################################
export __WORDLIST=""

nb-vars-set-wordlist() {
  if [[ -z $__WORDLIST ]]
  then
    __ask "Choose a wordlist: "
    __WORDLIST=$(__menu $(cat ${__MNU_WORDLISTS}))
  else
    __WORDLIST= __prefill __WORDLIST WORDLIST ${__WORDLIST}
  fi
}

nb-vars-set-wordlist-usernames() {
  __ask "Choose a wordlist: "
  __WORDLIST=$(__menu $(find /usr/share/seclists/Usernames | sort))
}

nb-vars-set-wordlist-web() {
  __ask "Choose a wordlist: "
  __WORDLIST=$(__menu $(find /usr/share/seclists/Discovery/Web-Content | sort))
}

nb-vars-set-wordlist-dns() {
  __ask "Choose a wordlist: "
  __WORDLIST=$(__menu $(find /usr/share/seclists/Discovery/DNS | sort))
}


############################################################# 
# __PASSLIST
#############################################################
export __PASSLIST="/usr/share/wordlists/seclists/Passwords/Leaked-Databases/rockyou.txt"

nb-vars-set-passlist() {
  __ask "Choose a passlist: "
  __PASSLIST=$(__menu $(find /usr/share/seclists/Passwords | sort))
}

# Helpers
export __THREADS
__check-threads() { __askvar __THREADS THREADS }

export __USER
__check-user() { __askvar __USER USER }

export __PASS
__check-pass() { __askvar __PASS PASS }

export __HASH
__check-hash() { __askvar __HASH HASH }

export __SHARE
__check-share() { __askvar __SHARE SHARE }

export __ORG
__check-org() { __askvar __ORG ORG }

export __ASN
__check-asn() { __askvar __ASN ASN }

# Output dirs
__netpath() { 
    __check-project
    local net=$(echo ${__NETWORK} | cut -d'/' -f1)
    local result=${__PROJECT}/networks/${net}
    mkdir -p "${result}"
    echo "${result}"
}

__netadpath() { 
    __check-project
    local net=$(echo ${__NETWORK} | cut -d'/' -f1)
    local result=${__PROJECT}/networks/active-directory/${net}
    mkdir -p "${result}"
    echo "${result}"
}

__hostpath() { 
    __check-project
    local result=${__PROJECT}/hosts/${__RHOST}
    mkdir -p "${result}"
    echo "${result}"
}

__urlpath() { 
    __check-project
    local host=$(echo ${__URL} | cut -d'/' -f3)
    local result=${__PROJECT}/hosts/${host}
    mkdir -p "${result}"
    echo "${result}"
}

__dompath() { 
    __check-project
    local result=${__PROJECT}/domains/${__DOMAIN}
    mkdir -p "${result}"
    echo "${result}"
}

__domadpath() { 
    __check-project
    local result=${__PROJECT}/domains/active-directory/${__DOMAIN}
    mkdir -p "${result}"
    echo "${result}"
}
