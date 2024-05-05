#!/usr/bin/env zsh

############################################################# 
# nb-ad-gpp
#############################################################
nb-ad-gpp-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-gpp
------------
The nb-ad-gpp namespace contains commands for 

Commands
--------
nb-ad-gpp-install         installs dependencies

DOC
}

nb-ad-gpp-install() {
    __info "Running $0..."
    __pkgs impacket
}
