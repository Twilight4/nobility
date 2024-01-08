#!/usr/bin/env zsh

############################################################# 
# nb-ad-pth
#############################################################
nb-ad-pth-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pth
------------
The

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
