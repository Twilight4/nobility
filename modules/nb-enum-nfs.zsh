#!/usr/bin/env zsh

############################################################# 
# nb-enum-nfs
#############################################################
nb-enum-nfs-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-nfs
-----------
The nb-enum-nfs namespace contains commands for scanning and enumerating NFS services.

Commands
--------
nb-enum-nfs-install        installs dependencies
nb-enum-nfs-nmap-sweep     scan a network for services
nb-enum-nfs-tcpdump        capture traffic to and from a host
nb-enum-nfs-show           show remote NFS shares
nb-enum-nfs-mount          mount a remote NFS share locally

DOC
}

nb-enum-nfs-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap nfs-common
}

nb-enum-nfs-nmap-sweep() {
    __check-project
    nb-vars-set-network

    __ask "Do you want to scan a network subnet or a host? (n/h)"
    local scan && __askvar scan "SCAN_TYPE"

    if [[ $scan == "h" ]]; then
      nb-vars-set-rhost
      print -z "sudo grc nmap -v -n -Pn -sS -sU -p U:111,T:111,U:2049,T:2049 ${__RHOST} -oA $(__hostpath)/nfs-sweep"
    elif [[ $scan == "n" ]]; then
      nb-vars-set-network
      print -z "sudo grc nmap -v -n -Pn -sS -sU -p U:111,T:111,U:2049,T:2049 ${__NETWORK} -oA $(__netpath)/nfs-sweep"
    else
        echo
        __err "Invalid option. Please choose 'n' for network or 'h' for host."
    fi
}

nb-enum-nfs-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 111 and port 2049 -w $(__hostpath)/nfs.pcap"
}

nb-enum-nfs-show() {
    nb-vars-set-rhost
    print -z "showmount -e ${__RHOST}"
}

nb-enum-nfs-mount() {
    nb-vars-set-rhost
    local share && __askvar share SHARE
    mkdir -p /mnt/${share}
    print -z "mount -t nfs ${__RHOST}:/${share} /mnt/${share} -o nolock"
}
