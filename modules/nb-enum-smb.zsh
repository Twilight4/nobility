#!/usr/bin/env zsh

############################################################# 
# nb-enum-smb
#############################################################
nb-enum-smb-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-smb
------------
The nb-enum-smb namespace contains commands for scanning and enumerating smb services.

Enumeration Commands
--------------------
nb-enum-smb-install                  installs dependencies
nb-enum-smb-nmap-sweep               scan a network for services
nb-enum-smb-tcpdump                  capture traffic to and from a host
nb-enum-smb-null-enum4               enumerate with enum4linux

Interacting/Connecting Commands
-------------------------------
nb-enum-smb-null-smbmap              query with smbmap null session
nb-enum-smb-null-smbmap-list-rec     list shares recursively with a null session
nb-enum-smb-null-smbmap-download     download a file from a share
nb-enum-smb-user-smbmap              query with smbmap authenticated session
nb-enum-smb-null-smbclient-list      list shares with a null session
nb-enum-smb-null-smbclient-list-rec  list shares recursively with a null session
nb-enum-smb-null-smbclient-connect   connect with a null session
nb-enum-smb-user-smbclient-connect   connect with an authenticated session
nb-enum-user-smb-mount               mount an SMB share
nb-enum-smb-samrdump                 dump info using impacket
nb-enum-smb-responder                spoof and get responses using responder
nb-enum-smb-net-use-null             print a net use statement for windows
nb-enum-smb-nbtscan                  scan a local network 
nb-enum-smb-rpcclient                use rcpclient for queries

DOC
}

nb-enum-smb-install() {
  __info "Running $0..."
  __pkgs nmap tcpdump smbmap enum4linux smbclient impacket responder nbtscan rpcclient
}

nb-enum-smb-nmap-sweep() {
  __check-project
  nb-vars-set-network
  print -z "sudo grc nmap -sV -sC --script=smb-enum-shares.nse,smb-enum-users.nse -n -Pn -sS -p445,137-139 ${__NETWORK} -oA $(__netpath)/smb-sweep"
}

nb-enum-smb-tcpdump() {
  __check-project
  nb-vars-set-iface
  nb-vars-set-rhost
  print -z "tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 445 -w $(__hostpath)/smb.pcap"
}

nb-enum-smb-null-smbmap() {
  nb-vars-set-rhost
  print -z "smbmap -H ${__RHOST}"
}

nb-enum-smb-null-smbmap-list-rec() {
  nb-vars-set-rhost
  __check-share
  print -z "smbmap -H ${__RHOST} -r ${__SHARE}"
}

nb-enum-smb-null-smbmap-download() {
  nb-vars-set-rhost
  __ask "File to download"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --download \"${__SHARE\\$file\"}"
}

nb-enum-smb-user-smbmap() {
  nb-vars-set-rhost
  __check-user
  __info "Usage with creds: -u <user> -p <pass> -d <domain>"
  print -z "smbmap -u ${__USER} -H ${__RHOST}"
}

nb-enum-smb-null-enum4() {
  nb-vars-set-rhost
  print -z "enum4linux -a ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-enum-smb-null-smbclient-list() {
  nb-vars-set-rhost
  print -r -z "smbclient -L //${__RHOST} -N "
}

nb-enum-smb-null-smbclient-list-rec() {
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -c 'recurse;ls'"
}

nb-enum-smb-null-smbclient-connect() {
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -N "
}

nb-enum-smb-user-smbclient-connect() {
  nb-vars-set-rhost
  __check-user
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER} "
}

nb-enum-user-smb-mount() {
  nb-vars-set-rhost
  __check-user
  local p && __askvar p PASSWORD
  __check-share
  print -z "mount //${__RHOST}/${__SHARE} /mnt/${__SHARE} -o username=${__USER},password=${p}"
}

nb-enum-smb-samrdump() {
  nb-vars-set-rhost
  print -z "samrdump.py ${__RHOST}"
}

nb-enum-smb-responder() {
  nb-vars-set-iface
  print -z "responder -I ${__IFACE} -A"
}

nb-enum-smb-net-use-null() {
    nb-vars-set-rhost
  __info "net use //${__RHOST}/IPC$ \"\" /u:\"\" "
}

nb-enum-smb-nbtscan() {
  nb-vars-set-network
  print -z "nbtscan ${__NETWORK}"
}

nb-enum-smb-rpcclient() {
  nb-vars-set-rhost
  print -z "rpcclient -U \" \" ${__RHOST}"
}
