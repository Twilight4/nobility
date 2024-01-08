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
nb-ad-smb-relay-install        installs dependencies
nb-ad-smb-relay-enum           identify hosts without smb signing
nb-ad-smb-relay-responder      capture and replay the SMB requests
nb-ad-smb-relay-multirelay     query ldap naming contexts
nb-ad-smb-relay-ntlmrelay      connect with anonymous bind and query ldap

DOC
}
