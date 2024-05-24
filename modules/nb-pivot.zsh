#!/usr/bin/env zsh

############################################################# 
# nb-pivot
#############################################################
nb-pivot-help() {
    cat << "DOC" | bat --plain --language=help

nb-pivot
------------
The pivot namespace provides commands for using ssh to proxy and pivot.

Commands
--------
nb-pivot-install                      installs dependencies
nb-pivot-mount-remote-sshfs           mounts a remote directory to local /mnt path using sshfs
nb-pivot-ssh-dynamic-proxy            enable dynamic port forwarding with ssh
nb-pivot-ssh-remote-to-local          forwards remote port to local port
nb-pivot-ssh-remote-to-local-burp     forwards remote port 8080 to local port 8080
nb-pivot-chisel                       # TODO use chisel for pivoting

DOC
}

nb-pivot-install() {
    __info "Running $0..."
    __pkgs sshfs rsync
}

nb-pivot-mount-remote-sshfs() { 
    __check-user
    local lm && __askpath lm LMOUNT /mnt
    local rm && __askvar rm RMOUNT /
    nb-vars-set-rhost
    mkdir -p ${lm}
    print -z "sshfs ${__USER}@${__RHOST}:${rm} ${lm}" 
}

nb-pivot-ssh-dynamic-proxy() {
    __check-user
    nb-vars-set-rhost
    nb-vars-set-lport
    print -z "ssh -D ${__LPORT} -CqN ${__USER}@${__RHOST}" 

    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"
}

nb-pivot-ssh-remote-to-local() {
    __check-user
    nb-vars-set-rhost
    nb-vars-set-rport
    nb-vars-set-lport
    print -z "ssh -R ${__LPORT}:127.0.0.1:${__RPORT} ${__USER}@${__RHOST}" 
}

nb-pivot-ssh-remote-to-local-burp() {
    __check-user
    nb-vars-set-rhost
    print -z "ssh -R 8080:127.0.0.1:8080 ${__USER}@${__RHOST}"
}

