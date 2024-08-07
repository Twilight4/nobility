#!/usr/bin/env zsh

############################################################# 
# nb-ad-enum
#############################################################
nb-ad-enum-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-enum
------------
The nb-ad-enum namespace contains commands for enumerating and exploiting Active Directory server.

Initial Passive Enumeration
---------------------------
nb-ad-enum-responder                 starts responder with passive analysis mode enabled (passively listen to the network)
nb-ad-enum-fping                     fping active checks to validates which hosts are active on a network subnet

Enumerating Users
====================================
NULL Session
------------
nb-ad-enum-null-getadusers           use GetADUsers.py to enumerate valid usernames
nb-ad-enum-null-cme-users            use crackmapexec to enumerate valid usernames
nb-ad-enum-null-cme-rid              use crackmapexec to enumerate valid usernames by rid bruteforcing
nb-ad-enum-null-lookupsid            use lookupsid.py to brute force sids of valid accounts
nb-ad-enum-null-enum4-users          dump users list using enum4linux
nb-ad-enum-null-cme-pass-pol         use crackmapexec to retrieve password policy

AUTH Session
------------
nb-ad-enum-auth-getadusers           use GetADUsers.py to enumerate valid usernames
nb-ad-enum-auth-cme-users            use crackmapexec with authentication to enumerate valid usernames
nb-ad-enum-auth-cme-rid              use crackmapexec to enumerate valid usernames by rid bruteforcing
nb-ad-enum-auth-lookupsid            use lookupsid.py to brute force sids of valid accounts
nb-ad-enum-auth-enum4-users          dump users list using enum4linux
nb-ad-enum-auth-cme-pass-pol         use crackmapexec to retrieve password policy

Authenticated Domain Enumeration
--------------------------------
nb-ad-enum-auth-bloodhound           enumerate with bloodhound
nb-ad-enum-auth-ldapdomaindump       enumerate with ldapdomaindump
nb-ad-enum-auth-cme-groups           use crackmapexec with authentication to enumerate domain groups
nb-ad-enum-auth-cme-loggedon         use crackmapexec with authentication to enumerate logged-on users
nb-ad-enum-auth-cme-petipotam        use crackmapexec petipotam module

DOC
}

nb-ad-enum-null-enum4-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "enum4linux -U ${__DCHOST} | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__dcpath)/enum4linux-user-enum.txt"
}

nb-ad-enum-auth-enum4-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "enum4linux -u ${__USER} -p ${__PASS} -U ${__DCHOST} | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__dcpath)/enum4linux-user-enum.txt"
}

nb-ad-enum-null-cme-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "crackmapexec smb ${__DCHOST} -u '' -p '' --users | tee $(__dcpath)/cme-users-enum.txt"
}

nb-ad-enum-null-cme-rid() {
    __check-project
    nb-vars-set-rhost

    print -z "crackmapexec smb ${__RHOST} -u '' -p '' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
}

nb-ad-enum-auth-lookupsid() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass

    print -z "lookupsid.py ${__USER}:${__PASS}@${__RHOST}"
}

nb-ad-enum-null-lookupsid() {
    __check-project
    nb-vars-set-rhost

    print -z "lookupsid.py -no-pass ${__RHOST}"
}

nb-ad-enum-auth-cme-rid() {
    __check-project
    nb-vars-set-user
    nb-vars-set-rhost

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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-getadusers() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "GetADUsers.py -all ${__DOMAIN}/${__USER}:'${__PASS}' -dc-ip ${__DCHOST} -outputfile $(__dcpath)/adusers.txt"
}

nb-ad-enum-null-getadusers() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "GetADUsers.py -all -dc-ip ${__DCHOST} -debug -outputfile $(__dcpath)/adusers.txt"
}

nb-ad-enum-auth-cme-users() {
    __check-project
    nb-vars-set-user
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

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
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --users | tee $(__dcpath)/cme-users-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -p '${__PASS}' --users | tee $(__dcpath)/cme-users-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -H ${__HASH} --local-auth --users | tee $(__dcpath)/cme-users-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-groups() {
    __check-project
    nb-vars-set-user
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

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
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --groups | tee $(__dcpath)/cme-groups-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -p '${__PASS}' --groups | tee $(__dcpath)/cme-groups-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -H ${__HASH} --local-auth --groups | tee $(__dcpath)/cme-groups-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-loggedon() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-pass-pol() {
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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-null-cme-pass-pol() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user

    __ask "Do you want to add a domain? (y/n)"
    local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

    if [[ $add_domain == "y" ]]; then
        __ask "Enter the domain"
        nb-vars-set-domain
        print -z "crackmapexec smb ${__RHOST} -u '' -d ${__DOMAIN} -p '' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    else
        print -z "crackmapexec smb ${__RHOST} -u '' -p '' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    fi
}

nb-ad-enum-fping() {
    __check-project
    __ask "Specify also a CIDR subnet mask e.g. /23"
    nb-vars-set-network
    print -z "fping -asgq ${__NETWORK} | tee $(__netpath)/fping-check.txt"
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

nb-ad-enum-auth-ldapdomaindump() {
    __check-project
	  nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "ldapdomaindump ${__DCHOST} -u '${__DOMAIN}\\\\${__USER}' -p '${__PASS}' -o $(__dcpath)/ldapdomaindump"
}

nb-ad-enum-auth-bloodhound() {
    __check-project
	  nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass
    __info "Output will be saved in 'bloodhound' directory"
    __info "Now you can zip the .json files together to upload to bloodhound:"
    __ok "  zip -r bloodhound-data.zip *.json"

    #pushd $(__netpath) &> /dev/null
    print -z "sudo bloodhound-python -d ${__DOMAIN} -u ${__USER} -p '${__PASS}' -ns ${__DCHOST} -c all"
    #popd &> /dev/null
}

nb-ad-enum-auth-cme-petipotam() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M petipotam | tee $(__netpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M petipotam | tee $(__netpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M petipotam | tee $(__netpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}
