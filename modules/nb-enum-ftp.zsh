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
nb-enum-ftp-hydra             brute force passwords/login for a user account
nb-enum-ftp-bounce            perform FTP bounce attack
nb-enum-ftp-wget-mirror       mirror/download all available files on the FTP server
nb-enum-ftp-tcpdump           capture traffic to and from a host
nb-enum-ftp-lftp-grep         search (grep) the target system

DOC
}

nb-enum-ftp-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap hydra ftp lftp wget 
}

nb-enum-ftp-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sV -sC -p 21 ${__NETWORK} -oA $(__netpath)/ftp-sweep"
}

nb-enum-ftp-hydra() {
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
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -s $pn -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
      else
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
      fi
    elif [[ $login == "l" ]]; then
      nb-vars-set-wordlist
      nb-vars-set-pass
      if [[ $df == "n" ]]; then
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -s $pn -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
      else
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
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
          print -z "hydra -L $ul -P $pl -s $pn -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
        fi
      else
        nb-vars-set-wordlist
        if [[ $df == "n" ]]; then
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -s $pn -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/ftp-hydra-brute.txt ${__RHOST} ftp -t 64 -F"
        fi
      fi
    else
      echo
      __err "Invalid option. Please choose 'p' for password or 'l' for login."
    fi
}

nb-enum-ftp-bounce() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass

    # Ask for the IP to be scanned
    __ask "Enter internal target ip to scan with nmap"
    local t && __askvar t TARGET_IP
    print -z "grc nmap -Pn -v -n -p80 -b ${__USER}:${__PASS}@${__RHOST} $t"
}

nb-enum-ftp-wget-mirror() {
    __warn "The destination site will be mirrored in the current directory"
    nb-vars-set-rhost
    local u && __prefill u USER "anonymous"
    local p && __prefill p PASSWORD "anonymous@example.com"
    print -z "wget --mirror ftp://${u}:${p}@${__RHOST}"
}

nb-enum-ftp-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 21 -w $(__hostpath)/ftp.pcap"
}

nb-enum-ftp-lftp-grep() {
    nb-vars-set-rhost
    local q && __askvar q QUERY
    print -z "lftp ${__RHOST}:/ > find | grep -i \"${QUERY}\" "
}

