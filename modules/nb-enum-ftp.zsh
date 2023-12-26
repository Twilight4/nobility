#!/usr/bin/env zsh

############################################################# 
# nb-enum-ftp
#############################################################
nb-enum-ftp-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-ftp
-------------
The nb-enum-ftp namespace contains commands for scanning and enumerating FTP servers.

Commands
--------
nb-enum-ftp-install           installs dependencies
nb-enum-ftp-nmap-sweep        scan a network for services
nb-enum-ftp-tcpdump           capture traffic to and from a host
nb-enum-ftp-hydra             brute force passwords for a user account
nb-enum-ftp-lftp-grep         search (grep) the target system
nb-enum-ftp-wget-mirror       mirror the FTP server locally

DOC
}

nb-enum-ftp-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap hydra ftp lftp wget 
}

nb-enum-ftp-sweep-nmap() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p21 ${__NETWORK} -oA $(__netpath)/ftp-sweep"
}

nb-enum-ftp-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 21 -w $(__hostpath)/ftp.pcap"
}

nb-enum-ftp-hydra() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} FTP"
}

nb-enum-ftp-lftp-grep() {
    nb-vars-set-rhost
    local q && __askvar q QUERY
    print -z "lftp ${__RHOST}:/ > find | grep -i \"${QUERY}\" "
}

nb-enum-ftp-wget-mirror() {
    __warn "The destination site will be mirrored in the current directory"
    nb-vars-set-rhost
    local u && __prefill u USER "anonymous"
    local p && __prefill p PASSWORD "anonymous@example.com"
    print -z "wget --mirror ftp://${u}:${p}@${__RHOST}"
}
