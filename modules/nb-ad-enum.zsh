#!/usr/bin/env zsh

############################################################# 
# nb-ad-enum
#############################################################
nb-ad-enum-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-enum
------------
The nb-ad-enum namespace contains commands for enumerating Active Directory DC, GC and LDAP servers.

Commands
--------
nb-ad-enum-install              Install dependencies
nb-ad-enum-ldapdomaindump       Enumerate with LdapDomainDump
nb-ad-enum-bloodhound           Enumerate with Bloodhound

DOC
}

nb-ad-enum-install() {
    __info "Running $0..."
    __pkgs python3-ldapdomaindump bloodhound neo4j
}

nb-ad-enum-ldapdomaindump() {
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    __check-user
    __ask "Enter a password for authentication"
    __check-pass

    print -z "python3 ldapdomaindump.py ${__RHOST} -u '${__DOMAIN}\\${__USER}' -p "${__PASS}" -o lootme"}
    __info "Output saved in 'lootme' directory"
}

nb-ad-enum-bloodhound() {

}
