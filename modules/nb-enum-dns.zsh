#!/usr/bin/env zsh
 
############################################################# 
# nb-enum-dns
#############################################################
nb-enum-dns-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-dns
-------------
The nb-enum-dns namespace contains commands for scanning and enumerating DNS records and servers.
Commands are executed against specific name servers (__RHOST) rather than public resolvers.

Commands
--------
nb-enum-dns-install              installs dependencies
nb-enum-dns-nmap-sweep           scan a network for services
nb-enum-dns-tcpdump              capture traffic to and from a host
nb-enum-dns-host-txfr            attempt a zone transfer
nb-enum-dns-host-all             list all types
nb-enum-dns-host-txt             list txt records
nb-enum-dns-host-mx              list mx records
nb-enum-dns-host-ns              list ns records
nb-enum-dns-host-srv             list srv records
nb-enum-dns-nmap-ad              discover Active Directory related records
nb-enum-dns-dnsrecon             discover dns records, servers and attempt zone txfrs
nb-enum-dns-dnsrecon-reverse     do reverse lookups on an IP network

DOC
}

nb-enum-dns-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap dnsutils dnsrecon 
}

nb-enum-dns-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -sU -p53 ${__NETWORK} -oA $(__netpath)/dns-sweep"
}

nb-enum-dns-tcpdump() {
    __check-project  
    __check-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 53 -w $(__hostpath)/dns.pcap"
}

nb-enum-dns-host-txfr() {
    nb-vars-set-rhost
    nb-vars-set-domain
    print -z "host -l ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-host-all() {
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "host -a ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-host-txt() {
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "host -t txt ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-host-mx() {
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "host -t mx ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-host-ns() {
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "host -t ns ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-host-srv() {
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "host -t srv ${__DOMAIN} ${__RHOST}"
}

nb-enum-dns-nmap-ad() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "grc nmap --script dns-srv-enum --script-args dns-srv-enum.domain=${__DOMAIN} ${__RHOST} -o $(__dompath)/nmap-AD.txt"
}

nb-enum-dns-dnsrecon() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-rhost
    print -z "dnsrecon -d ${__DOMAIN} -n ${__RHOST} -a -s -w -z --threads 10 -c $(__dompath)/dns.csv"
}

nb-enum-dns-dnsrecon-reverse() {
    __check-project
    nb-vars-set-rhost
    mkdir -p ${__PROJECT}/domains
    print -z "dnsrecon -r ${__NETWORK} -n ${__RHOST} -c ${__PROJECT}/domains/revdns.csv"
}
