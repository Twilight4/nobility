#!/usr/bin/env zsh

############################################################# 
# nb-enum-pop3
#############################################################
nb-enum-pop3-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-pop3
------------
The nb-enum-pop3 namespace contains commands for scanning and enumerating POP3 email services.

Commands
--------
nb-enum-pop3-install     installs dependencies
nb-enum-pop3-nmap-sweep  scan a network for services
nb-enum-pop3-tcpdump     capture traffic to and from a host
nb-enum-pop3-hydra       brute force passwords for a user account

DOC
}

nb-enum-pop3-install() {
    __info "Running $0..."
    __pkgs nmap tcpdump hydra
}

nb-enum-pop3-nmap-sweep() {
    __check-project || return
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -p 110,995 ${__NETWORK} -oA $(__netpath)/pop3-sweep"
}

nb-enum-pop3-tcpdump() {
    __check-project || return
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 110 and port 995 -w $(__hostpath)/pop3.pcap"
}

nb-enum-pop3-hydra() {
    __check-project || return
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/pop3-hydra-brute.txt ${__RHOST} POP3"
}
