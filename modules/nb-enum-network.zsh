#!/usr/bin/env zsh
 
############################################################# 
# nb-enum-network
#############################################################
nb-enum-network-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-network
-------------
The nb-enum-network namespace contains commands for scanning and enumerating target hosts/networks.

Ping Sweep/Host Discovery
-------------------------
nb-enum-network-nmap-ping-sweep           sweep a network subnet with ping requests
nb-enum-network-ping-sweep-msf            sweep a network subnet with ping requests
nb-enum-network-ping-sweep-linux          sweep a network subnet with ping requests on linux
nb-enum-network-ping-sweep-windows-cmd    sweep a network subnet with ping requests on windows
nb-enum-network-ping-sweep-windows-pwsh   sweep a network subnet with ping requests on windows powershell

Open Ports Discovery
--------------------
nb-enum-network-rustscan-all              scan with TCP syn requests, all ports
nb-enum-network-nmap-top                  scan with TCP syn requests, top 1000 ports
nb-enum-network-nmap-all                  scan with TCP syn requests, all ports
nb-enum-network-masscan-all               scan with TCP syn requests, all ports
nb-enum-network-masscan-top               scan with TCP requests, uses $__TCP_PORTS global var
nb-enum-network-masscan-windows           scan for common Windows ports
nb-enum-network-masscan-linux             scan for common Linux ports
nb-enum-network-masscan-web               scan for common web server ports

Service Enumeration
-------------------
nb-enum-network-rustscan-discovery-all    scan with initial TCP syn requests, all ports
nb-enum-network-nmap-discovery-top        scan with TCP syn requests and scripts, top 1000 ports
nb-enum-network-nmap-discovery-all        scan all ports with versioning and scripts, all ports

Super Fast and Aggressive Scan
------------------------------
nb-enum-network-rustscan-aggressive-all   TCP syn rustscan scan all ports super fast and furious, all ports
nb-enum-network-nmap-aggressive-all       TCP syn nmap scan all ports super fast and furious, all ports

Commands
--------
nb-enum-network-install              installs dependencies
nb-enum-network-tcpdump              capture traffic to and from a network
nb-enum-network-tcpdump-bcasts       capture ethernet broadcasts and multi-cast traffic
nb-enum-network-nmap-lse-grep        search nmap lse scripts

DOC
}

nb-enum-network-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap masscan
}

nb-enum-network-nmap-lse-grep() {
    local q && __askvar q QUERY
    print -z "ls /usr/share/nmap/scripts/* | grep -ie \"${q}\" "
}

nb-enum-network-rustscan-aggressive-all() {
    __check-project
    nb-vars-set-rhost
    print -z "rustscan -a ${__RHOST} -r 1-65535 --ulimit 5000 -- -A -T4 -Pn -v -n --stats-every=20s --min-parallelism=100 --min-rate=1000 -oA $(__netpath)/rustscan-aggressive-all"
}

nb-enum-network-nmap-aggressive-all() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo grc nmap -A -Pn -T4 -p- -v -n --stats-every=10s --min-parallelism=100 --min-rate=1000 -oA $(__netpath)/nmap-aggressive-all.nmap ${__RHOST}"
}

nb-enum-network-rustscan-all() {
    __check-project 
    __ask "Enter alive hosts which you scanned with ping sweep"
    nb-vars-set-rhost
    print -z "rustscan -a ${__RHOST} -r 1-65535 --ulimit 5000 -- --open -oA $(__netpath)/rustscan-all"
}

nb-enum-network-rustscan-discovery-all() {
    __check-project 
    __ask "Enter alive hosts which you scanned with ping sweep"
    nb-vars-set-rhost
    print -z "rustscan -a ${__RHOST} -r 1-65535 --ulimit 5000 -- --open -A -Pn -oA $(__netpath)/rustscan-discovery-all"
}

nb-enum-network-tcpdump() {
    __check-project 
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} net ${__RHOST} -w $(__netpath)/network.pcap"
}

nb-enum-network-tcpdump-bcasts() {
    __check-project 
    nb-vars-set-iface
    print -z "sudo tcpdump -i ${__IFACE} ether broadcast and ether multicast -w $__PROJECT/networks/bcasts.pcap"
}

nb-enum-network-nmap-ping() {
    __check-project 
    nb-vars-set-rhost
    print -z "grc nmap -vvv -sn --open ${__RHOST} -oA $(__netpath)/nmap-ping-sweep"
}

nb-enum-network-nmap-top() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -n -Pn -sS --open --top-ports 1000 ${__RHOST} -oA $(__netpath)/nmap-top"
}

nb-enum-network-nmap-all() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -n -Pn -T4 --open -sS -p- ${__RHOST} -oA $(__netpath)/nmap-all"
}

nb-enum-network-nmap-discovery-all() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo grc nmap -vvv -n -Pn -T4 --open -sS -p- -sC -sV --stats-every=20s  ${__RHOST} -oA $(__netpath)/nmap-discovery-all"
}

nb-enum-network-nmap-discovery-top() {
    __check-project 
    nb-vars-set-rhost
    print -z "grc nmap -vvv -n -Pn -sV -sS -sC --top-ports 1000 ${__RHOST} -oA $(__netpath)/nmap-discovery-top"
}

nb-enum-network-masscan-top() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo masscan ${__RHOST} -p${__TCP_PORTS} -oL $(__netpath)/masscan-top.txt"
}

nb-enum-network-masscan-windows() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo masscan ${__RHOST} -p135-139,445,3389,389,636,88 -oL $(__netpath)/masscan-windows.txt"
}

nb-enum-network-masscan-linux() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo masscan ${__RHOST} -p22,111,2222 -oL $(__netpath)/masscan-linux.txt"
}

nb-enum-network-masscan-web() {
    __check-project 
    nb-vars-set-rhost
    print -z "sudo masscan ${__RHOST} -p80,800,8000,8080,8888,443,4433,4443 -oL $(__netpath)/masscan-web.txt"
}

nb-enum-network-masscan-all() {
    __check-iface
    __check-project
    nb-vars-set-rhost
    print -z "masscan -p1-65535 --open-only ${__RHOST} --rate=1000 -e ${__IFACE} -oL $(__netpath)/masscan-all.txt"
}

nb-enum-network-ping-sweep-msf() {
    __ask "Network with subnet ex. 10.10.10.10/23"
    local sb && __askvar sb NETWORK_SUBNET

    __ask "Do you have meterpreter shell runnning? (y/n)"
    local sh && __askvar sh "ANSWER"

    if [[ $sh == "n" ]]; then
      __err "Start a meterpreter shell first using on ${__LHOST}:${__LPORT} before proceeding."
      __info "Use nb-shell-handlers-msf-listener"
      exit 1
    fi

    __msf << VAR
use post/multi/gather/ping_sweep;
set RHOSTS $sb;
set SESSION 1;
run;
exit
VAR
}

nb-enum-network-ping-sweep-linux() {
    __ask "Enter the network without the /23"
    local sb && __askvar sb NETWORK_SUBNET

    __info "Use the following command in linux:"
    __ok "for i in $(seq 254); do ping $sb$i -c1 -W1 & done | grep from"
}

nb-enum-network-ping-sweep-windows-cmd() {
    local sb && __askvar sb NETWORK_SUBNET

    __info "Use the following command in windows cmd:"
    __ok "for /L %i in (1 1 254) do ping $sb.%i -n 1 -w 100"
}

nb-enum-network-ping-sweep-windows-pwsh() {
    local sb && __askvar sb NETWORK_SUBNET

    __info "Use the following command in windows powershell:"
    __ok "1..254 | % {\"172.16.5.\$(\$_): \$(Test-Connection -count 1 -comp \"$sb\".\$(\$_) -quiet)\"}"
}
