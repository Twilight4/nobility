#!/usr/bin/env zsh

############################################################# 
# nb-ad-smb
#############################################################
nb-ad-smb-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-smb
------------
The nb-ad-smb namespace contains commands for scanning and enumerating smb services/shares.

Automated Enumeration tools
=====================================
NULL Session
------------
nb-ad-smb-null-enum4                 enumerate with enum4linux
nb-ad-smb-null-enum4-aggressive      aggressively enumerate with enum4linux
nb-ad-smb-null-rpcclient             use rcpclient for queries

AUTH Session
------------
nb-ad-smb-auth-enum4                 enumerate with enum4linux
nb-ad-smb-auth-enum4-aggressive      aggressively enumerate with enum4linux
nb-ad-smb-auth-rpcclient             use rcpclient for queries

Shares Enumeration
=====================================
NULL Session
------------
nb-ad-smb-null-cme-list              list shares with cme
nb-ad-smb-null-cme-spider            spider available shares on the remote host or subnet
nb-ad-smb-null-samrdump              info using impacket
nb-ad-smb-null-smbmap-list           query with smbmap
nb-ad-smb-null-smbmap-list-rec       list shares recursively
nb-ad-smb-null-smbclient-list        list shares
nb-ad-smb-null-smbclient-list-rec    list shares recursively

AUTH Session
------------
nb-ad-smb-auth-cme-list              list shares with cme authenticated session
nb-ad-smb-auth-cme-spider            spider available shares on the remote host or subnet
nb-ad-smb-auth-samrdump              info using impacket
nb-ad-smb-auth-smbmap-list           query with smbmap authenticated session
nb-ad-smb-auth-smbmap-list-rec       list shares recursively with authentication
nb-ad-smb-auth-smbclient-list        list shares
nb-ad-smb-auth-smbclient-list-rec    list shares recursively

Connecting to Service
-------------------------------------
nb-ad-smb-null-smbclient-connect     connect with a null session
nb-ad-smb-auth-smbclient-connect     connect with an authenticated session

Download / Upload
====================================
NULL Session
------------
nb-ad-smb-null-smbclient-download-rec  recursively download files from SMB share
nb-ad-smb-null-smbmap-download       download a file from a share
nb-ad-smb-null-smbmap-download-pat   download files from a share matching a pattern
nb-ad-smb-null-smbget-download-rec   recursively download the SMB share
nb-ad-smb-null-smbmap-upload         upload a file to a share

AUTH Session
------------
nb-ad-smb-null-smbclient-download-rec  recursively download files from SMB share
nb-ad-smb-auth-smbmap-download       download a file from a share
nb-ad-smb-null-smbmap-download-pat   download files from a share matching a pattern
nb-ad-smb-auth-smbget-download-rec   recursively download the SMB share
nb-ad-smb-auth-smbmap-upload         upload a file to a share

Misc Commands
-------------------------------------
nb-ad-smb-nmap-sweep                 scan a network for services
nb-ad-smb-install                    installs dependencies
nb-ad-smb-tcpdump                    capture traffic to and from a host
nb-ad-smb-auth-mount                 mount an SMB share
nb-ad-smb-responder                  spoof and get responses using responder
nb-ad-smb-net-use-null               print a net use statement for windows
nb-ad-smb-nbtscan                    scan a local network 

DOC
}

nb-ad-smb-install() {
  __info "Running $0..."
  __pkgs nmap tcpdump smbmap enum4linux smbclient impacket responder nbtscan rpcclient
}

nb-ad-smb-nmap-sweep() {
  __check-project

  __ask "Do you want to scan a network subnet or a host? (n/h)"
  local scan && __askvar scan "SCAN_TYPE"

  if [[ $scan == "h" ]]; then
    nb-vars-set-rhost
    print -z "sudo grc nmap -v -sV -sC --script=smb-enum-shares.nse,smb-enum-users.nse -n -Pn -sS -p445,137-139 ${__RHOST} -oA $(__netpath)/smb-sweep"
  elif [[ $scan == "n" ]]; then
    nb-vars-set-network
    print -z "sudo grc nmap -v -sV -sC --script=smb-enum-shares.nse,smb-enum-users.nse -n -Pn -sS -p445,137-139 ${__NETWORK} -oA $(__netpath)/smb-sweep"
  else
      echo
      __err "Invalid option. Please choose 'n' for network or 'h' for host."
  fi
}

nb-ad-smb-tcpdump() {
  __check-project
  nb-vars-set-iface
  nb-vars-set-rhost
  print -z "tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 445 -w $(__hostpath)/smb.pcap"
}

nb-ad-smb-null-smbmap-list() {
  __check-project
  nb-vars-set-rhost
  print -z "smbmap -H ${__RHOST} --no-banner"
}

nb-ad-smb-null-smbmap-list-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __info "You can add --dir-only flag"
  print -z "smbmap -H ${__RHOST} -r ${__SHARE} --no-banner"
}

nb-ad-smb-null-smbmap-download() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __ask "Enter file to download"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --download \"${__SHARE}\\\\$file\" --no-banner"
}

nb-ad-smb-auth-smbmap-download() {
  __check-project
  __check-share
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __ask "Enter file to download"
  local file && __askvar file FILE
  print -z "smbmap -u '${__USER}' -p '${__PASS}' -d ${__DOMAIN} -H ${__RHOST} --download \"${__SHARE}\\\\$file\" --no-banner"
}

nb-ad-smb-auth-smbmap-download-pat() {
  __check-project
  __check-share
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __ask "Enter the pattern (ex. xml)"
  local pat && __askvar file pat
  print -z "smbmap -u '${__USER}' -p '${__PASS}' -d ${__DOMAIN} -H ${__RHOST} -r ${__SHARE} -A $pat --no-banner"
}

nb-ad-smb-null-smbmap-download-pat() {
  __check-project
  __check-share
  nb-vars-set-rhost
  __ask "Enter the pattern (ex. xml)"
  local pat && __askvar file pat
  print -z "smbmap -H ${__RHOST} -r ${__SHARE} -A $pat --no-banner"
}

nb-ad-smb-null-smbmap-upload() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __ask "File to upload"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --upload $file \"${__SHARE}\\\\$file\" --no-banner"
}

nb-ad-smb-auth-smbmap-upload() {
  __check-project
  __check-share
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __ask "File to upload"
  local file && __askvar file FILE
  print -z "smbmap -u '${__USER}' -p '${__PASS}' -d ${__DOMAIN} -H ${__RHOST} --upload $file \"${__SHARE}\\\\$file\" --no-banner"
}

nb-ad-smb-null-smbget-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -z "smbget -R smb://${__RHOST}/${__SHARE}"
}

nb-ad-smb-auth-smbget-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  print -z "smbget -U ${__DOMAIN}/${__USER}%${__PASS} -R smb://${__RHOST}/${__SHARE}"
}

nb-ad-smb-auth-smbmap-list() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  print -z "smbmap -u '${__USER}' -p '${__PASS}' -d ${__DOMAIN} -H ${__RHOST} --no-banner"
}

nb-ad-smb-auth-smbmap-list-rec() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __check-share
  __info "You can add --dir-only flag"
  print -z "smbmap -u '${__USER}' -p '${__PASS}' -d ${__DOMAIN} -H ${__RHOST} -r '${__SHARE}' --no-banner"
}

nb-ad-smb-null-enum4() {
  __check-project
  nb-vars-set-rhost
  print -z "enum4linux -a ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-ad-smb-auth-enum4-aggressive() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "enum4linux -u ${__USER} -p ${__PASS} -A ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-ad-smb-auth-enum4() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "enum4linux -u ${__USER} -p ${__PASS} -a ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-ad-smb-null-enum4-aggressive() {
  __check-project
  nb-vars-set-rhost
  print -z "enum4linux -A ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-ad-smb-null-cme-list() {
  __check-project
  nb-vars-set-rhost
  print -z "crackmapexec smb ${__RHOST} --shares -u '' -p ''"
}

nb-ad-smb-null-cme-spider() {
    __check-project
    nb-vars-set-network
    __ask "Enter name of the share to spider"
    __check-share

    print -z "crackmapexec smb ${__NETWORK} -u '' -p '' -M spider_plus --share '${__SHARE}' | tee $(__netpath)/cme-null-shares-spider-sweep.txt"
    __ok "Results have been written to /tmp/cme_spider_plus/${__NETWORK}.json"
}

nb-ad-smb-auth-cme-spider() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user
    __ask "Enter name of the share to spider"
    __check-share

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Do you want to add a domain? (y/n)"
        local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

        if [[ $add_domain == "y" ]]; then
            __ask "Enter the domain"
            nb-vars-set-domain
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M spider_plus --share '${__SHARE}' | tee $(__netpath)/cme-shares-spider-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M spider_plus --share '${__SHARE}' | tee $(__netpath)/cme-shares-spider-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M spider_plus --share '${__SHARE}' | tee $(__netpath)/cme-shares-spider-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
    __ok "Results have been written to /tmp/cme_spider_plus/${__NETWORK}.json"
}

nb-ad-smb-auth-cme-list() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Do you want to add a domain? (y/n)"
        local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

        if [[ $add_domain == "y" ]]; then
            __ask "Enter the domain"
            nb-vars-set-domain
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --shares | tee $(__netpath)/cme-shares-enum-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --shares | tee $(__netpath)/cme-shares-enum-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --shares | tee $(__netpath)/cme-shares-enum-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-smb-null-smbclient-list() {
  __check-project
  nb-vars-set-rhost
  print -r -z "smbclient -L //${__RHOST} -N "
}

nb-ad-smb-auth-smbclient-list() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  __check-share
  print -r -z "smbclient -L //${__RHOST}/${__SHARE} -U ${__USER}%${__PASS}"
}

nb-ad-smb-null-smbclient-list-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -N -c 'recurse;ls'"
}

nb-ad-smb-auth-smbclient-list-rec() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER}%${__PASS} -c 'recurse;ls'"
}

nb-ad-smb-null-smbclient-connect() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -N "
}

nb-ad-smb-auth-smbclient-connect() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER}%${__PASS} "
}

nb-ad-smb-auth-mount() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  __check-share
  print -z "mount -t cifs -o ro,username=${__USER},password=${__PASS} '//${__RHOST}/${__SHARE}' /mnt/${__SHARE}/"
}

nb-ad-smb-null-samrdump() {
  __check-project
  nb-vars-set-rhost
  print -z "impacket-samrdump ${__RHOST}"
}

nb-ad-smb-auth-samrdump() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "impacket-samrdump ${__USER}:${__PASS}@${__RHOST}"
}

nb-ad-smb-responder() {
  __check-project
  nb-vars-set-iface
  print -z "sudo responder -I ${__IFACE} -dwP | tee $(__netpath)/smb-responder.txt"
}

nb-ad-smb-net-use-null() {
  __check-project
  nb-vars-set-rhost
  __info "net use //${__RHOST}/IPC$ \"\" /u:\"\" "
}

nb-ad-smb-nbtscan() {
  __check-project
  nb-vars-set-network
  print -z "nbtscan ${__NETWORK}"
}

nb-ad-smb-null-rpcclient() {
  __check-project
  nb-vars-set-rhost
  print -z "rpcclient -U \"\" -N ${__RHOST}"
}

nb-ad-smb-auth-rpcclient() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "rpcclient -U \"${__USER}\" --password ${__PASS} ${__RHOST}"
}

nb-ad-smb-null-smbclient-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share

  print -r -z "smbclient //${__RHOST}/${__SHARE} -N -c 'recurse on; prompt off; mget *'"
}

nb-ad-smb-auth-smbclient-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  nb-vars-set-user
  nb-vars-set-pass

  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER}%${__PASS} -c 'recurse on; prompt off; mget *'"
}
