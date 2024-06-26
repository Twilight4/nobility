#!/usr/bin/env zsh

############################################################# 
# nb-ad-enum
#############################################################
nb-ad-enum-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-enum
------------
The nb-ad-enum namespace contains commands for enumerating Active Directory DC, GC and LDAP servers.

Initial Enumeration - Without Authentication
--------------------------------------------
nb-ad-enum-responder                 starts responder with passive analysis mode enabled (passively listen to the network)
nb-ad-enum-fping                     fping active checks to validates which hosts are active on a network subnet

Enumerating Users - Without Authentication
------------------------------------------
nb-ad-enum-kerbrute-users            use kerbrute to enumerate valid usernames 
nb-ad-enum-cme-users                 use crackmapexec to enumerate valid usernames

Domain Enumeration - With Authentication
----------------------------------------
nb-ad-enum-auth-impacket-getadusers  use impacket-getadusers to enumerate valid usernames
nb-ad-enum-auth-cme-users            use crackmapexec with authentication to enumerate valid usernames
nb-ad-enum-auth-cme-groups           use crackmapexec with authentication to enumerate domain groups
nb-ad-enum-auth-cme-loggedon         use crackmapexec with authentication to enumerate logged-on users
nb-ad-enum-auth-cme-pass-pol         use crackmapexec to retrieve password policy

Other Commands - With Authentication
------------------------------------
nb-ad-enum-auth-ldapdomaindump       enumerate with ldapdomaindump
nb-ad-enum-auth-bloodhound           enumerate with bloodhound
nb-ad-enum-auth-cme-pass             pass the password/hash
nb-ad-enum-auth-cme-petipotam        use crackmapexec petipotam module
nb-ad-enum-auth-cme-command          the password/hash and execute command

DOC
}

nb-ad-enum-cme-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "crackmapexec smb $dc --users | tee $(__netadpath)/cme-users-enum.txt"
}

nb-ad-enum-impacket-getadusers-auth() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "impacket-GetADUsers -all ${__DOMAIN}/${__USER}:'${__PASS}' -dc-ip $dc -outputfile $(__domadpath)/adusers.txt"
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
            print -z "crackmapexec smb $dc -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --users | tee $(__netadpath)/cme-users-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb $dc -u ${__USER} -p '${__PASS}' --users | tee $(__netadpath)/cme-users-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb $dc -u ${__USER} -H ${__HASH} --local-auth --users | tee $(__netadpath)/cme-users-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-cme-groups-auth() {
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
            print -z "crackmapexec smb $dc -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --groups | tee $(__netadpath)/cme-groups-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb $dc -u ${__USER} -p '${__PASS}' --groups | tee $(__netadpath)/cme-groups-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb $dc -u ${__USER} -H ${__HASH} --local-auth --groups | tee $(__netadpath)/cme-groups-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-cme-loggedon-auth() {
    __check-project
    nb-vars-set-user
    nb-vars-set-network

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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --loggedon-users | tee $(__netadpath)/cme-loggedon-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --loggedon-users | tee $(__netadpath)/cme-loggedon-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --loggedon-users | tee $(__netadpath)/cme-loggedon-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-cme-pass-pol-auth() {
    __check-project
    nb-vars-set-rhost
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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth --pass-pol | tee $(__netadpath)/cme-pass-pol.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
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

      print -z "sudo kerbrute userenum -d ${__DOMAIN} --dc $dc $ul -o $(__netadpath)/kerbrute-user-enum.txt"
    else
      nb-vars-set-wordlist
      print -z "sudo kerbrute userenum -d ${__DOMAIN} --dc $dc ${__WORDLIST} -o $(__netadpath)/kerbrute-user-enum.txt"
    fi
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
    print -z "sudo responder -I ${__IFACE} -A"
}

nb-ad-enum-install() {
    __info "Running $0..."
    __pkgs bloodhound neo4j bloodhound.py
}

nb-ad-enum-ldapdomaindump() {
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "ldapdomaindump $dc -u "${__DOMAIN}\\${__USER}" -p "${__PASS}" -o $(__domadpath)/ldapdomaindump"}
    __info "Output saved in 'ldapdomaindump' directory"
}

nb-ad-enum-bloodhound() {
    __check-project
	  nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    #pushd $(__domadpath) &> /dev/null
    print -z "sudo bloodhound-python -d ${__DOMAIN} -u ${__USER} -p '${__PASS}' -ns $dc -c all"
    __info "Output saved in 'bloodhound' directory"
    __info "You can zip the .json files together to upload to bloodhound GUI using command:"
    __ok "zip -r bloodhound-data.zip *.json"
    #popd &> /dev/null
}

nb-ad-enum-cme-pass-auth() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' | tee $(__netadpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' | tee $(__netadpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth | tee $(__netadpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-cme-command-auth() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user

    __ask "Enter command to execute"
    local cm && __askvar cm "COMMAND"

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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -x $cm | tee $(__netadpath)/cme-command-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -x $cm | tee $(__netadpath)/cme-command-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -x $cm | tee $(__netadpath)/cme-command-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-cme-petipotam-auth() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M petipotam | tee $(__netadpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M petipotam | tee $(__netadpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M petipotam | tee $(__netadpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}
