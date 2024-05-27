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


    git clone https://github.com/cube0x0/CVE-2021-1675.git
}
