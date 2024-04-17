#!/usr/bin/env zsh

############################################################# 
# nb-enum-mssql
#############################################################
nb-enum-mssql-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-mssql
-------------
The nb-enum-mssql namespace contains commands for scanning and enumerating MS SQL Server services and databases.

Commands
--------
nb-enum-mssql-install             installs dependencies
nb-enum-mssql-nmap-sweep          scan a network for services
nb-enum-mssql-tcpdump             capture traffic to and from a host
nb-enum-mssql-sqsh                make an interactive database connection
nb-enum-mssql-impacket-client     connect using impacket as a sql client
nb-enum-mssql-hydra               brute force passwords for a user account

DOC
}

nb-enum-mssql-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap sqsh impacket hydra
}

nb-enum-mssql-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -sU -p T:1433,U:1434 ${__NETWORK} -oA $(__netpath)/mssql-sweep"
}

nb-enum-mssql-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 1433 -w $(__hostpath)/mssql.pcap"
}

nb-enum-mssql-sqsh() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "sqsh -S ${__RHOST} -U ${__USER}"
}

nb-enum-mssql-impacket-client() {
    nb-vars-set-rhost
    __check-user
    local db && __askvar db DATABASE
    print -z "mssqlclient.py ${__USER}@${__RHOST} -db ${db} -windows-auth "
}

nb-enum-mssql-hydra() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/mssql-hydra-brute.txt ${__RHOST} MS-SQL"
}
