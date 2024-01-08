#!/usr/bin/env zsh

############################################################# 
# nb-ad-smb-relay
#############################################################
nb-ad-smb-relay-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-smb-relay
------------
The nb-ad-smb-relay namespace contains commands for scanning and 
enumerating Active Directory DC, GC and LDAP servers.

Commands
--------
nb-ad-smb-relay-install        installs dependencies
nb-ad-smb-relay     scan a network for services
nb-ad-smb-relay        capture traffic to and from a host
nb-ad-smb-relay            query ldap naming contexts
nb-ad-smb-relay    connect with anonymous bind and query ldap
nb-ad-smb-relay    connect with authenticated bind and query ldap
nb-ad-smb-relay         send ldap whoami request
nb-ad-smb-relay          brute force passwords for a user account

DOC
}
