#!/usr/bin/env zsh

############################################################# 
# nb-ad-cve
#############################################################
nb-ad-cve-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-cve
----------
The nb-ad-cve namespace provides commands for popular active direcory CVEs vulnerabilities and exploits.

Commands
--------
nb-ad-cve-printnightmare                  command to check for CVE-2021-34527 and CVE-2021-1675 vulnerability

DOC
}


nb-ad-cve-printnightmare() {
    __check-project

    __ask "This will clone the cube0x0 CVE github repo to downloads, continue? (y/n)"
    local cb && __askvar cb ANSWER

    if [[ $db == "y" ]]; then
      git clone https://github.com/cube0x0/CVE-2021-1675.git ~/downloads/CVE-2021-1675
    else
      __err "Operation cancelled by user"
      exit 1
    fi

    __ask "This will uninstall current version of impacket and installcube0x0's version of Impacket, continue? (y/n)"
    local im && __askvar im ANSWER

    if [[ $im == "y" ]]; then
      pip3 uninstall impacket
      git clone https://github.com/cube0x0/impacket ~/downloads/impacket
      cd ~/downloads/impacket
      python3 ./setup.py install
      cd ~/downloads/
    else
      __err "Operation cancelled by user"
      exit 1
    fi
}
