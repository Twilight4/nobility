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
    __pkgs bloodhound neo4j bloodhound.py

    # Install ldapdomaindump from source
    sudo apt remove python3-ldapdomaindump
    sudo git clone https://github.com/dirkjanm/ldapdomaindump.git /opt/ldapdomaindump
    sudo chmod +x /opt/ldapdomaindump/bin/*
    sudo ln -sf /opt/ldapdomaindump/bin/* /bin/
}

nb-ad-enum-ldapdomaindump() {
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "ldapdomaindump ${__RHOST} -u "${__DOMAIN}\\${__USER}" -p "${__PASS}" -o $(__domadpath)/ldapdomaindump"}
    __info "Output saved in 'ldapdomaindump' directory"
}

nb-ad-enum-bloodhound() {
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "sudo bloodhound-python -d ${__DOMAIN} -u ${__USER} -p ${__PASS} -ns ${__RHOST} -c all"
    __info "Output saved in 'bloodhound' directory"
}
