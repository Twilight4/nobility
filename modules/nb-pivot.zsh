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
nb-pivot-ssh-socks-proxy-msf          configure msf's local proxy
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
    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"

    print -z "ssh -D ${__LPORT} -CqN ${__USER}@${__RHOST}" 
}

nb-pivot-ssh-socks-proxy() {
    nb-vars-set-lport
    local sb && __askvar sb SUBNET
    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"

    print -z "msfconsole -q -n -x 'use auxiliary/server/socket_proxy; set SRVPORT ${__LPORT}; set SRVHOST 0.0.0.0; set version 4a; run'"

    __info "Use post/multi/manage/autoroute to tell our socks_proxy module to route all the traffic via the meterpreter session"
    __ok "use post/multi/manage/autoroute; set SESSION 1; set SUBNET $sb; run"
    __info "You can also add routes with autoroute in metepreter session: 'run autoroute -s <subnet>/23'"
    __info "Use 'run autoroute -p' to list the active routes"
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

