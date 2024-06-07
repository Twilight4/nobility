#!/usr/bin/env zsh

############################################################# 
# nb-enum-host
#############################################################
nb-enum-host-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-host
-------------
The nb-enum-host namespace contains commands for scanning and enumerating an individual host.

Host Discovery
--------------
nb-enum-host-nmap-top                syn scan of the top 1000 ports
nb-enum-host-nmap-top-discovery      syn scan of the top 1000 ports with versioning and scripts
nb-enum-host-nmap-all                syn scan all ports 
nb-enum-host-nmap-all-discovery      syn scan all ports with versioning and scripts
nb-enum-host-nmap-udp                udp scan top 100 ports
nb-enum-host-masscan-all-tcp         scan all tcp ports
nb-enum-host-masscan-all-udp         scan all udp ports

Service Enumeration
-------------------
nb-enum-host-nmap-aggressive-all         TCP syn scan all ports very aggresively and fast
nb-enum-host-rustscan-aggressive-all     TCP syn scan all ports using better nmap alternative with classic scan

Commands
---------
nb-enum-host-install                 installs dependencies
nb-enum-host-tcpdump                 capture traffic to and from a host
nb-enum-host-nmap-lse-grep           search nmap lse scripts


DOC
}

nb-enum-host-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap masscan curl
}

nb-enum-host-tcpdump() {
    __check-project
    __check-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} -w $(__hostpath)/tcpdump.pcap"
}

nb-enum-host-nmap-aggressive-all() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo grc nmap -A -sV -sC -Pn -T4 -p- -v -n --stats-every=20s --min-parallelism=100 --min-rate=300 -oN $(__hostpath)/nmap-aggressive-all.nmap ${__RHOST}"
}

nb-enum-host-rustscan-aggressive-all() {
    __check-project
    nb-vars-set-rhost
    print -z "rustscan -a ${__RHOST} -r 1-65535 --ulimit 5000 -- -sV -sC -T4 -Pn --min-rate=10000 -oA $(__hostpath)/rustscan-aggressive-all"
}

nb-enum-host-nmap-top(){
    __check-project
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -Pn -sS --top-ports 1000 --open ${__RHOST} -oA $(__hostpath)/nmap-top"
}

nb-enum-host-nmap-top-discovery(){
    __check-project
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -Pn -sS --top-ports 1000 --open -sC -sV ${__RHOST} -oA $(__hostpath)/nmap-top-discovery"
}

nb-enum-host-nmap-all() {
    __check-project
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -Pn -sS -p- -T4 --open ${__RHOST} -oA $(__hostpath)/nmap-all"
}

nb-enum-host-nmap-all-discovery() {
    __check-project
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -Pn -sS -p- -sC -sV --open ${__RHOST} -oA $(__hostpath)/nmap-all-discovery"
}

nb-enum-host-nmap-udp() {
    __check-project
    nb-vars-set-rhost
    print -z "sudo grc nmap -v -Pn -sU --top-ports 100 -sV -sC --open ${__RHOST} -oA $(__hostpath)/nmap-udp"
}

nb-enum-host-masscan-all-tcp() {
    __check-iface
    __check-project
    nb-vars-set-rhost
    print -z "masscan -p1-65535 --open-only ${__RHOST} --rate=1000 -e ${__IFACE} -oL $(__hostpath)/masscan-all-tcp.txt"
}

nb-enum-host-masscan-all-udp() {
    __check-iface
    __check-project
    nb-vars-set-rhost
    print -z "masscan -pU:1-65535 --open-only ${__RHOST} --rate=1000 -e ${__IFACE} -oL $(__hostpath)/masscan-all-udp.txt"
}

nb-enum-host-nmap-lse-grep() {
    local q && __askvar q QUERY
    print -z "ls /usr/share/nmap/scripts/* | grep -ie \"${q}\" "
}

nb-enum-host-ip() {
    __check-project
    nb-vars-set-rhost
    print -z "curl -s \"https://iplist.cc/api/${__RHOST}\" | tee $(__hostpath/ip.json) "
}
