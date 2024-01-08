#!/usr/bin/env zsh

############################################################# 
# nb-ad-smb-relay
#############################################################
nb-ad-smb-relay-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-smb-relay
------------
The nb-ad-smb-relay namespace contains commands for scanning and 
enumerating Active Directory DC, GC and LDAP servers.

Commands
--------
nb-ad-smb-relay-install              installs dependencies
nb-ad-smb-relay-enum                 identify hosts without smb signing
nb-ad-smb-relay-responder            capture and replay the SMB requests
nb-ad-smb-relay-ntlmrelay-shell      get interactive shell
nb-ad-smb-relay-ntlmrelay-command    execute a shell command on a target host using ntlmrelayx.py
nb-ad-smb-relay-multirelay-command   execute a shell command on a target host using multirelay.py

DOC
}

nb-ad-smb-relay-install() {
    __info "Running $0..."
    __pkgs crackmapexec
}

nb-ad-smb-relay-enum() {

}

nb-ad-smb-relay-responder() {

}

nb-ad-smb-relay-ntlmrelay-shell() {

}

nb-ad-smb-relay-ntlmrelay-command() {

}

nb-ad-smb-relay-multirelay-command() {

}
