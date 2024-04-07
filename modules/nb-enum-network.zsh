#!/usr/bin/env zsh
 
############################################################# 
# nb-enum-network
#############################################################
nb-enum-network-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-network
-------------
The nb-enum-network namespace contains commands for scanning and enumerating a network.

Commands
--------
nb-enum-network-install              installs dependencies
nb-enum-network-tcpdump              capture traffic to and from a network
nb-enum-network-tcpdump-bcasts       capture ethernet broadcasts and multi-cast traffic
nb-enum-network-nmap-ping-sweep      sweep a network with ping requests
nb-enum-network-nmap-syn-sweep       sweep a network with TCP syn requests, top 1000 ports
nb-enum-network-nmap-udp-sweep       sweep a network with UDP requests, top 100 ports
nb-enum-network-nmap-all-sweep       sweep a network with TCP syn requests, all ports
nb-enum-network-nmap-discovery       sweep a network with TCP syn requests and scripts, top 100 ports
nb-enum-network-nmap-aggressive      sweep a network with TCP syn request very aggresively and fast
nb-enum-network-masscan-top          sweep a network with TCP requests, uses $__TCP_PORTS global var
nb-enum-network-masscan-windows      sweep a network for common Windows ports
nb-enum-network-masscan-linux        sweep a network for common Linux ports
nb-enum-network-masscan-web          sweep a network for common web server ports

DOC
}

nb-enum-network-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap masscan
}


nb-enum-network-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-network
    print -z "sudo tcpdump -i ${__IFACE} net ${__NETWORK} -w $(__netpath)/network.pcap"
}

nb-enum-network-tcpdump-bcasts() {
    __check-project
    nb-vars-set-iface
    print -z "sudo tcpdump -i ${__IFACE} ether broadcast and ether multicast -w $__PROJECT/networks/bcasts.pcap"
}

nb-enum-network-nmap-ping-sweep() {
    __check-project
    nb-vars-set-network
    print -z "nmap -vvv -sn --open ${__NETWORK} -oA $(__netpath)/nmap-ping-sweep"
}

nb-enum-network-nmap-syn-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -vvv -n -Pn -sS --open --top-ports 100 ${__NETWORK} -oA $(__netpath)/nmap-syn-sweep"
}

nb-enum-network-nmap-udp-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -vvv -n -Pn -sU --open --top-ports 100 ${__NETWORK} -oA $(__netpath)/nmap-udp-sweep"
}

nb-enum-network-nmap-all-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -vvv -n -Pn -T4 --open -sS -p- ${__NETWORK} -oA $(__netpath)/nmap-all-sweep"
}

nb-enum-network-nmap-discovery() {
    __check-project
    nb-vars-set-network
    print -z "nmap -vvv -n -Pn -sV -sC --top-ports 100 ${__NETWORK} -oA $(__netpath)/nmap-discovery"
}

nb-enum-network-nmap-aggressive() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -A -sV -sC -Pn -T4 -p- -v -n --stats-every=20s --min-parallelism=100 --min-rate=300 -oN $(__netpath)/nmap-aggressive.nmap ${__NETWORK}"
}

nb-enum-network-masscan-top() {
    __check-project
    nb-vars-set-network
    print -z "sudo masscan ${__NETWORK} -p${__TCP_PORTS} -oL $(__netpath)/masscan-top.txt"
}

nb-enum-network-masscan-windows() {
    __check-project
    nb-vars-set-network
    print -z "sudo masscan ${__NETWORK} -p135-139,445,3389,389,636,88 -oL $(__netpath)/masscan-windows.txt"
}

nb-enum-network-masscan-linux() {
    __check-project
    nb-vars-set-network
    print -z "sudo masscan ${__NETWORK} -p22,111,2222 -oL $(__netpath)/masscan-linux.txt"
}

nb-enum-network-masscan-web() {
    __check-project
    nb-vars-set-network
    print -z "sudo masscan ${__NETWORK} -p80,800,8000,8080,8888,443,4433,4443 -oL $(__netpath)/masscan-web.txt"
}
