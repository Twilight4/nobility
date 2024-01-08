#!/usr/bin/env zsh

############################################################# 
# nb-ad-pth
#############################################################
nb-ad-pth-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pth
------------
The nb-ad-pth namespace contains commands for pass-the-hash
attack on Active Directory DC server.

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

}

nb-ad-pth-exploit() {
    __check-project
    nb-vars-set-network

}

nb-ad-pth-sam() {
    __check-project
    nb-vars-set-network

}

nb-ad-pth-enum() {
    __check-project
    nb-vars-set-network

}

nb-ad-pth-lsa() {
    __check-project
    nb-vars-set-network

}

nb-ad-pth-lsassy() {
    __check-project
    nb-vars-set-network

}
