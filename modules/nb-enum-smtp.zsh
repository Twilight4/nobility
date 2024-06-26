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
nb-enum-smtp-connect        connect to the smtp/pop3 services

DOC
}

nb-enum-smtp-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -v -sV -sC --script smtp-commands -p25,143,110,465,587,993,995 ${__NETWORK} -oA $(__netpath)/smtp-sweep"
}

nb-enum-smtp-open-relay() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -p25 -v -Pn --script smtp-open-relay ${__NETWORK} -oA $(__netpath)/smtp-open-relay-check"
}

nb-enum-smtp-connect() {
    __check-project
    nb-vars-set-rhost

    # connect
    print -z "telnet ${__RHOST} 25"

    # informational
    echo
    __info "Try connecting to other MAIL services ports if they're open:"
    __ok "telnet ${__RHOST} 110"
    __ok "telnet ${__RHOST} 465"
    __ok "telnet ${__RHOST} 995"
}
