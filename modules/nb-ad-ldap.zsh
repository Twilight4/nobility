#!/usr/bin/env zsh

############################################################# 
# nb-ad-ldap
#############################################################
nb-ad-ldap-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-ldap
------------
The nb-ad-ldap namespace contains commands for scanning and 
enumerating Active Directory DC, GC and LDAP servers.

Commands
--------
nb-ad-ldap-install        installs dependencies
nb-ad-ldap-nmap-sweep     scan a network for services
nb-ad-ldap-tcpdump        capture traffic to and from a host
nb-ad-ldap-ctx            query ldap naming contexts
nb-ad-ldapsearch-anon    connect with anonymous bind and query ldap
nb-ad-ldapsearch-auth    connect with authenticated bind and query ldap
nb-ad-ldap-whoami         send ldap whoami request
nb-ad-ldap-hydra          brute force passwords for a user account

DOC
}

nb-ad-ldap-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap ldap-utils hydra
}

nb-ad-ldap-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -sU -p389,636,3269 ${__NETWORK} -oA $(__netpath)/ldap-sweep"
}

nb-ad-ldap-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 389 and port 636 and port 3269 -w $(__hostpath)/ldap.pcap"
}

nb-ad-ldap-ctx() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    print -z "ldapsearch -x -H ldap://${__RHOST}:389 -s base namingcontexts"
}

nb-ad-ldapsearch-anon() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN
    print -z "ldapsearch -x -H ldap://${__RHOST}:389 -s sub -b \"${dn}\" "
}

nb-ad-ldapsearch-auth() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN
    __ask "Enter a user account with bind and read permissions to the directory"
    __check-user
    print -z "ldapsearch -x -H ldap://${__RHOST}:389 -D '${dn}' \"(objectClass=*)\" -w \"${__USER}\" "
}

nb-ad-ldap-whoami() {
    __ask "Enter the address of the target DC, GC or LDAP server"
    nb-vars-set-rhost
    print -z "ldapwhoami -h ${__RHOST} -w \"non-existing-user\" "
}

nb-ad-ldap-hydra() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/ldap-hydra-brute.txt ${__RHOST} LDAP -F"
}
