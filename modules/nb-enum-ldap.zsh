#!/usr/bin/env zsh

############################################################# 
# nb-enum-ldap
#############################################################
nb-enum-ldap-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-ldap
------------
The nb-enum-ldap namespace contains commands for scanning and 
enumerating Active Directory DC, GC and LDAP servers.

Commands
--------
nb-enum-ldap-install        installs dependencies
nb-enum-ldap-nmap-sweep     scan a network for services
nb-enum-ldap-tcpdump        capture traffic to and from a host
nb-enum-ldap-ctx            query ldap naming contexts
nb-enum-ldap-search-anon    connect with anonymous bind and query ldap
nb-enum-ldap-search-auth    connect with authenticated bind and query ldap
nb-enum-ldap-whoami         send ldap whoami request
nb-enum-ldap-hydra          brute force passwords for a user account

DOC
}

nb-enum-ldap-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap ldap-utils hydra
}

nb-enum-ldap-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -sU -p389,636,3269 ${__NETWORK} -oA $(__netpath)/ldap-sweep"
}

nb-enum-ldap-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 389 and port 636 and port 3269 -w $(__hostpath)/ldap.pcap"
}

nb-enum-ldap-ctx() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    print -z "ldapsearch -x -h ${__RHOST} -s base namingcontexts"
}

nb-enum-ldap-search-anon() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    __ask "Enter a distinguished name (DN), such as: DC=example,DC=com"
    local dn && __askvar dn DN
    print -z "ldapsearch -x -h ${__RHOST} -s sub -b \"${dn}\" "
}

nb-enum-ldap-search-auth() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    __ask "Enter a distinguished name (DN), such as: DC=example,DC=com"
    local dn && __askvar dn DN
    __ask "Enter a user account with bind and read permissions to the directory"
    __check-user
    print -z "ldapsearch -x -h ${__RHOST} -D '${dn}' \"(objectClass=*)\" -w \"${__USER}\" "
}

nb-enum-ldap-whoami() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    print -z "ldapwhoami -h ${__RHOST} -w \"non-existing-user\" "
}

nb-enum-ldap-hydra() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/ldap-hydra-brute.txt ${__RHOST} LDAP"
}