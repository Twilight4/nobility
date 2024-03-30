#!/usr/bin/env zsh

############################################################# 
# nb-shell-handlers
#############################################################
nb-shell-handlers-help() {
    cat << "DOC" | bat --plain --language=help

nb-shell-handlers
-----------------
The shell-handlers namespace provides commands for spawning reverse shell connections.

Commands
--------
nb-shell-handlers-install        installs dependencies
nb-shell-handlers-nc             netcat shell handlers
nb-shell-handlers-ncrl           ncrl shell handlers
nb-shell-handlers-nc-udp         netcat udp shell
nb-shell-handlers-socat          socat shell handlers

DOC
}

nb-shell-handlers-install() {
    __info "Running $0..."
    __pkgs netcat socat
}


############################################################# 
# netcat
#############################################################
nb-shell-handlers-nc() {
    nb-vars-set-lport

    echo
    nc -nlvp ${__LPORT}
}

nb-shell-handlers-ncrl() {
    nb-vars-set-lport
    echo
    rlwrap nc -nlvp ${__LPORT}
}

nb-shell-handlers-nc-udp() {
    nb-vars-set-lport

    echo
    nc -nlvu ${__LPORT}
}


############################################################# 
# socat
#############################################################
nb-shell-handlers-socat() {
    nb-vars-set-lport

    echo
    socat file:`tty`,raw,echo=0 tcp-listen:${__LPORT}
}
