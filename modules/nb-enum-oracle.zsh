#!/usr/bin/env zsh

############################################################# 
# nb-enum-oracle
#############################################################
nb-enum-oracle-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-oracle
--------------s
The nb-enum-oracle namespace contains commands for scanning and enumerating Oracle services and databases.

Commands
--------
nb-enum-oracle-install           installs dependencies
nb-enum-oracle-nmap-sweep        scan a network for services
nb-enum-oracle-tcpdump           capture traffic to and from a host
nb-enum-oracle-sqlplus           sqlplus client
nb-enum-oracle-odat              odat anonymous enumeration
nb-enum-oracle-odat-creds        odat authenticated enumeration
nb-enum-oracle-odat-passwords    odat password brute
nb-enum-oracle-version           tnscmd version query
nb-enum-oracle-status            tnscmd status query
nb-enum-oracle-sidguess          tnscmd password brute force
nb-enum-oracle-oscanner          oscanner enumeration
nb-enum-oracle-hydra-listener    brute force passwords 
nb-enum-oracle-hydra-sid         brute force passwords

DOC
}

nb-enum-oracle-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap odat tnscmd10g sidguess oscanner hydra
    __pkgs oracle-instantclient-sqlplus 
    sudo sh -c "echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf"; sudo ldconfig
}

nb-enum-oracle-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p 1521 ${__NETWORK} -oA $(__netpath)/oracle-sweep"
}

nb-enum-oracle-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 1521 -w $(__hostpath)/oracle.pcap"
}

nb-enum-oracle-sqlplus() {
    nb-vars-set-rhost
    local sid && __askvar sid "SID(DATABASE)"
    local u && __askvar u "USER"
    local p && __askvar [u] "PASSWORD"
    print -z "sqlplus ${u}/${p}@${__RHOST}:1521/${sid} as sysdba"
}

nb-enum-oracle-odat() {
    nb-vars-set-rhost
    print -z "odat all -s ${__RHOST}"
}

nb-enum-oracle-odat-creds() {
    nb-vars-set-rhost
    local sid && __askvar sid "SID(DATABASE)"
    local u && __askvar u "USER"
    local p && __askvar [u] "PASSWORD"
    print -z "odat all -s ${__RHOST} -p 1521 -d ${sid} -U ${u} -P ${p}"
}

nb-enum-oracle-odat-passwords() {
    nb-vars-set-rhost
    local sid && __askvar sid "SID(DATABASE)"
    __info "cat /usr/share/metasploit-framework/data/wordlists/oracle_default_userpass.txt | sed -e "s/[[:space:]]/\\\/g""
    print -z "odat passwordguesser -s ${__RHOST} -d ${sid} --accounts-file accounts.txt"
}

nb-enum-oracle-version(){
    nb-vars-set-rhost
    print -z "tnscmd10g version -h ${__RHOST}"
}

nb-enum-oracle-status(){
    nb-vars-set-rhost
    print -z "tnscmd10g status -h ${__RHOST}"
}

nb-enum-oracle-sidguess(){
    nb-vars-set-rhost
    print -z "sidguess host=${__RHOST} port=1521 sidfile=sid.txt"
}

nb-enum-oracle-oscanner() {
    nb-vars-set-rhost
    print -z "oscanner -s ${__RHOST}"
}

nb-enum-oracle-hydra-listener() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/oracle-listener-hydra-brute.txt ${__RHOST} Oracle Listener"
}

nb-enum-oracle-hydra-sid() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/oracle-sid-hydra-brute.txt ${__RHOST} Oracle Sid"
}
