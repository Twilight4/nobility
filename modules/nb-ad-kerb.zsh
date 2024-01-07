#!/usr/bin/env zsh

############################################################# 
# nb-enum-kerb
#############################################################
nb-ad-kerb-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-kerb
------------
The nb-enum-kerb namespace contains commands for scanning and 
enumerating kerberos records and servers.

Commands
--------
nb-ad-kerb-install        installs dependencies
nb-ad-kerb-nmap-sweep     scan a network for services
nb-ad-kerb-tcpdump        capture traffic to and from a host
nb-ad-kerb-users          enumerate domain users
nb-ad-kerb-kerberoast     get SPN for a service account

DOC
}

nb-enum-kerb-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap impacket-scripts   
}

nb-enum-kerb-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p88 ${__NETWORK} -oA $(__netpath)/kerb-sweep"
}

nb-enum-kerb-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 88 -w $(__hostpath)/kerb.pcap"
}

nb-enum-kerb-users() {
    nb-vars-set-rhost
    local realm && __askvar realm REALM
    print -z "nmap -v -p 88 --script krb5-enum-users --script-args krb5-enum-users.realm=${realm},userdb=/usr/share/seclists/Usernames/Names/names.txt ${__RHOST}"
}

nb-enum-kerb-kerberoast() {
    __ask "Enter target AD domain (must also be set in your hosts file)"
    nb-vars-set-domain
    __ask "Enter service user account"
    __check-user
    __ask "Enter the IP address of the target domain controller"
    nb-vars-set-rhost
    print -z "getuserspns.py -request ${__DOMAIN}s/${__USER} -dc-ip ${__RHOST} "
}
