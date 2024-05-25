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
nb-ad-enum-responder            starts responder with passive analysis mode enabled (passively listen to the network and not send any poisoned packets)
nb-ad-enum-fping                fping active checks to validates which hosts are active on a network subnet
nb-ad-enum-nmap                 scan the list of active hosts within the network
nb-ad-enum-install              install dependencies
nb-ad-enum-ldapdomaindump       enumerate with ldapdomaindump
nb-ad-enum-bloodhound           enumerate with bloodhound

DOC
}

nb-ad-enum-nmap() {
    __check-project
    __ask "Specify the file with the list of active hosts"
    local f && __askpath f FILE $HOME/desktop/projects/
    print -z "sudo nmap -v -A -iL hosts.txt -oA $(__netadpath)/hosts-enum"
}

nb-ad-enum-fping() {
    __check-project
    __ask "Specify also a CIDR subnet mask e.g. /23"
    nb-vars-set-rhost
    print -z "fping -asgq ${__RHOST} | tee $(__netadpath)/fping-check.txt"
}

nb-ad-enum-responder() {
    __check-project
    nb-vars-set-iface
    print -z "sudo responder -I ${__IFACE} -A | tee $(__netadpath)/responder-passive.txt"
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
    __check-project
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
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    pushd $(__domadpath) &> /dev/null
    print -z "sudo bloodhound-python -d ${__DOMAIN} -u ${__USER} -p ${__PASS} -ns ${__RHOST} -c all"
    __info "Output saved in 'bloodhound' directory"
    popd &> /dev/null
}
