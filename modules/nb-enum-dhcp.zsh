#!/usr/bin/env zsh

############################################################# 
# nb-enum-dhcp
#############################################################
nb-enum-dhcp-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-dhcp
-------------
The nb-enum-dhcp namespace contains commands for scanning and enumerating DHCP servers.

Commands
--------
nb-enum-dhcp-install           installs dependencies
nb-enum-dhcp-nmap-sweep        scan a network for services
nb-enum-dhcp-tcpdump           capture traffic to and from a host
nb-enum-dhcp-discover-nmap     broadcast DHCP discover packets

DOC
}

nb-enum-dhcp-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap 
}

nb-enum-dhcp-sweep-nmap() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sU -p67 ${__NETWORK} -oA $(__netpath)/dhcp-sweep"
}

nb-enum-dhcp-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and udp port 67 and port 68 -w $(__hostpath)/dhcp.pcap"
}

nb-enum-dhcp-discover-nmap() {
    print -z "sudo grc nmap -v --script broadcast-dhcp-discover"
}
