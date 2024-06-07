#!/usr/bin/env zsh
 
############################################################# 
# nb-enum-smtp
#############################################################
nb-enum-smtp-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-smtp
-------------
The nb-enum-smtp namespace contains commands for scanning and enumerating SMTP service.

Commands
--------
nb-enum-smtp-sweep          scan a network for mail services
nb-enum-smtp-open-relay     check for open relay misconfiguration

DOC
}

nb-enum-smtp-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sV -sC --script smtp-commands -p25,143,110,465,587,993,995 ${__NETWORK} -oA $(__netpath)/mail-sweep"
}

nb-enum-smtp-open-relay() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -p25 -Pn --script smtp-open-relay ${__NETWORK} -oA $(__netpath)/mail-sweep
}
