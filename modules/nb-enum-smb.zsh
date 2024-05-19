#!/usr/bin/env zsh

############################################################# 
# nb-enum-smb
#############################################################
nb-enum-smb-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-smb
------------
The nb-enum-smb namespace contains commands for scanning and enumerating smb services.

Protocol Attacks
----------------
nb-enum-smb-hydra                    brute force password/login for a user account

Automated Enumeration tools
-------------------------------------
nb-enum-smb-nmap-sweep               scan a network for services
nb-enum-smb-null-enum4               enumerate with enum4linux
nb-enum-smb-null-enum4-aggressive    aggressively enumerate with enum4linux
nb-enum-smb-null-rpcclient           use rcpclient for queries

Shares Enumeration
-------------------------------------
NULL Session
------------
nb-enum-smb-null-cme-list            list shares with cme
nb-enum-smb-null-samrdump            info using impacket
nb-enum-smb-null-smbmap-list         query with smbmap
nb-enum-smb-null-smbmap-list-rec     list shares recursively
nb-enum-smb-null-smbclient-list      list shares
nb-enum-smb-null-smbclient-list-rec  list shares recursively

AUTH Session
------------
nb-enum-smb-user-smbmap              query with smbmap authenticated session
nb-enum-smb-user-cme-list            list shares with cme authenticated session

Connecting to Service
-------------------------------------
nb-enum-smb-null-smbclient-connect   connect with a null session
nb-enum-smb-user-smbclient-connect   connect with an authenticated session

Other Commands
-------------------------------------
nb-enum-smb-null-smbmap-download     download a file from a share
nb-enum-smb-null-smbget-download-rec recursively download the SMB share
nb-enum-smb-null-smbmap-upload       upload a file to a share
nb-enum-smb-install                  installs dependencies
nb-enum-smb-tcpdump                  capture traffic to and from a host
nb-enum-user-smb-mount               mount an SMB share
nb-enum-smb-responder                spoof and get responses using responder
nb-enum-smb-net-use-null             print a net use statement for windows
nb-enum-smb-nbtscan                  scan a local network 

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

nb-enum-smb-null-smbmap-list() {
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

nb-enum-smb-null-smbmap-upload() {
  nb-vars-set-rhost
  __ask "File to download"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --upload $file \"${__SHARE\\$file\"}"
}

nb-enum-smb-null-smbget-download-rec() {
  nb-vars-set-rhost
  __check-share
  print -z "smbget -R smb://${__RHOST}/${__SHARE}"
}

nb-enum-smb-hydra() {
    __check-project
    nb-vars-set-rhost

    __ask "You wanna brute force login/password/both? (l/p/b)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Is the service running on default port? (y/n)"
    local df && __askvar df "DEFAULT_PORT"

    if [[ $df == "n" ]]; then
      __ask "Enter port number"
      local pn && __askvar pn "PORT_NUMBER"
    else
      __err "SOMETHING WENT WRONG. Aborting"
      exit 1
    fi

    if [[ $login == "p" ]]; then
      nb-vars-set-user
      if [[ $df == "n" ]]; then
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -s $pn -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
      else
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
      fi
    elif [[ $login == "l" ]]; then
      nb-vars-set-wordlist
      nb-vars-set-pass
      if [[ $df == "n" ]]; then
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -s $pn -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
      else
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
      fi
    elif [[ $login == "b" ]]; then
      __ask "Do you wanna manually specify wordlists? (y/n)"
      local sw && __askvar sw "SPECIFY_WORDLIST"
      if [[ $sw == "y" ]]; then
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/

        if [[ $df == "n" ]]; then
          print -z "hydra -L $ul -P $pl -s $pn -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
        fi
      else
        nb-vars-set-wordlist
        if [[ $df == "n" ]]; then
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -s $pn -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/smb-hydra-brute.txt ${__RHOST} smb -t 64 -F"
        fi
      fi
    else
      echo
      __err "Invalid option. Please choose 'p' for password or 'l' for login."
    fi
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

nb-enum-smb-null-enum4-aggresssive() {
  nb-vars-set-rhost
  print -z "enum4linux -A ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
}

nb-enum-smb-null-cme-list() {
  nb-vars-set-rhost
  print -z "crackmapexec smb ${__RHOST} --shares -u '' -p ''"
}

nb-enum-smb-user-cme-list() {
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "crackmapexec smb ${__RHOST} --shares -u '${__USER}' -p '${__PASS}'"
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

nb-enum-smb-null-samrdump() {
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

nb-enum-smb-null-rpcclient() {
  nb-vars-set-rhost
  print -z "rpcclient -U \" \" ${__RHOST}"
}
