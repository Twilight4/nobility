#!/usr/bin/env zsh

############################################################# 
# nb-ad-enum
#############################################################
nb-ad-enum-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-enum
------------
The nb-ad-enum namespace contains commands for enumerating Active Directory DC, GC and LDAP servers.

Initial Enumeration (without domain account)
--------------------------------------------
nb-ad-enum-responder            starts responder with passive analysis mode enabled (passively listen to the network and not send any poisoned packets)
nb-ad-enum-fping                fping active checks to validates which hosts are active on a network subnet
nb-ad-enum-nmap                 scan the list of active hosts within the network
nb-ad-enum-ldapsearch-pass-pol  retrieve password policy using ldapsearch

Making a Target User List (without domain account)
--------------------------------------------------
nb-ad-enum-kerbrute-users       use kerbrute to enumerate valid usernames 
nb-ad-enum-cme-users            use crackmapexec to enumerate valid usernames
nb-ad-enum-cme-users-auth       use crackmapexec with authentication to enumerate valid usernames
nb-ad-enum-enum4-users          use enum4linux to enumerate valid usernames
nb-ad-enum-ldap-anon-users      use ldap anonymous search to enumerate valid usernames

Domain Enumeration
------------------
nb-ad-enum-cme-pass-pol         use crackmapexec to retrieve password policy
nb-ad-enum-install              install dependencies
nb-ad-enum-ldapdomaindump       enumerate with ldapdomaindump
nb-ad-enum-bloodhound           enumerate with bloodhound

DOC
}

nb-ad-enum-ldap-anon-users() {
    __check-project
    nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP
    
    print -z "ldapsearch -h $dc -x -b \"DC=${__DOMAIN},DC=LOCAL\" -s sub \"(&(objectclass=user))\"  | grep sAMAccountName: | cut -f2 -d\" \""
}

nb-ad-enum-cme-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "crackmapexec smb $dc --users"
}

nb-ad-enum-cme-users-auth() {
    __check-project
    nb-vars-set-user
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Do you want to add a domain? (y/n)"
        local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

        if [[ $add_domain == "y" ]]; then
            __ask "Enter the domain"
            nb-vars-set-domain
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb $dc -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --users"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb $dc -u ${__USER} -p '${__PASS}' --users"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb $dc -u ${__USER} -H ${__HASH} --local-auth --users"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-ldapsearch-pass-pol() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-rhost

    print -z "ldapsearch -h ${__RHOST} -x -b \"DC=${__DOMAIN},DC=LOCAL\" -s sub "*" | grep -m 1 -B 10 pwdHistoryLength"
}

nb-ad-enum-pass-pol() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Do you want to add a domain? (y/n)"
        local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

        if [[ $add_domain == "y" ]]; then
            __ask "Enter the domain"
            nb-vars-set-domain
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum4-users() {
    __check-project
    nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "enum4linux -U 172.16.5.5  | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__netadpath)/enum4linux-user-enum.txt"
}

nb-ad-enum-kerbrute-users() {
    __check-project
    nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Do you wanna manually specify wordlists? (y/n)"
    local sw && __askvar sw "SPECIFY_WORDLIST"

    if [[ $sw == "y" ]]; then
      __ask "Select a user list"
      __askpath ul FILE $HOME/desktop/projects/

      print -z "kerbrute userenum -d ${__DOMAIN} --dc $dc $ul -o $(__netadpath)/kerbrute-user-enum.txt"
    else
      nb-vars-set-wordlist
      print -z "kerbrute userenum -d ${__DOMAIN} --dc $dc ${__WORDLIST} -o $(__netadpath)/kerbrute-user-enum.txt"
    fi
}

nb-ad-enum-nmap() {
    __check-project
    __ask "Specify the file with the list of active hosts"
    local f && __askpath f FILE $HOME/desktop/projects/
    print -z "sudo grc nmap -v -A -iL $f -oA $(__netadpath)/hosts-enum"
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
