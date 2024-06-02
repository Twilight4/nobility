#!/usr/bin/env zsh

############################################################# 
# nb
#############################################################
nb-help() {
    cat << "DOC" | bat --plain --language=help

nb
--
The nb namespace is the root of all other namespaces that can be access with tab-completion.
To get started, explore the nb-<namespace>-help commands. Install dependencies per namespace,
using the nb-<namespace>-install commands or install all dependencies using nb-install-all.

 Commands
 --------
 nb-update            git pull the latest (MAIN branch) version of nobility
 nb-status            check the current status of the locally cloned nobility repository
 nb-message-toggle    toggle the "Nobility loaded" shell startup message

 Namespaces
 ----------
 nobility is organized in a tree of namespaces that are accessible via "nb-" with tab completion and search.
 Each namespace has its own install and help commands.

 Install and Configuration
 -------------------------
 nb-install-                    Installers for commonly used applications and global installer for all dependencies
 nb-vars-global-                Persistent environment variables used in all commands, all sessions

 Utility
 ---------
 nb-crack-                      Used for crackign password hashes
 nb-encoding-                   Used for encoding / decoding data
 nb-os-                         Variety of commands for managing your OS
 nb-srv-                        Commands for spawning file hosting services
 nb-compile-                    Commands for compiling exploits
 nb-shell-tty-                  Commands for upgrading tty shells
 nb-shell-handlers-             Commands for spawning reverse shell handlers
 nb-shell-handlers-msf-         Commands for spawning reverse shells with Metasploit

 Engagement / Project
 -----------------------------
 nb-vars-                       Per-session, per-engagement variables used in all commands
 nb-project-                    Commands to define scope and manage project data

 Reconneissance Phase
 --------------------
 nb-recon-org-                  Recon commands for organization files and data
 nb-recon-user-                 Recon commands for searching person's data
 nb-recon-github-               Recon commands for searching github repositories
 nb-recon-networks-             Recon commands for identiying an organization's networks
 nb-recon-domains-              Recon commands for horizontal domain enumeration
 nb-recon-subs-                 Recon commands for vertical sub-domain enumeration 

 Active Enumeration Phase
 ------------------------
 nb-enum-network-               Enumerate and scan networks
 nb-enum-host-                  Enumerate and scan an individual host
 nb-enum-dhcp-                  Enumerate DHCP services
 nb-enum-dns-                   Enumerate DNS services
 nb-enum-ftp-                   Enumerate FTP services
 nb-enum-kerb-                  Enumerate Kerberos services
 nb-enum-ldap-                  Enumerate LDAP and Active Directory services
 nb-enum-mssql-                 Enumerate MSSQL database services
 nb-enum-mysql-                 Enumerate MYSQL database services
 nb-enum-nfs-                   Enumerate NFS shares and services
 nb-enum-oracle-                Enumerate Oracle database services
 nb-enum-pop3-                  Enumerate POP3 services
 nb-enum-rdp-                   Enumerate RDP services
 nb-enum-web-                   Enumerate web servers and services
 nb-enum-web-aws-               Enumerate AWS hosted services
 nb-enum-web-dirs-              Enumerate directories and files
 nb-enum-web-php-               Enumerate php web servers
 nb-enum-web-ssl-               Enumerate SSL certs and services
 nb-enum-web-vuln-              Check for common web vulnerabilities

 Active-Directory Phase
 -----------------------
 nb-ad-kerb-                    Commands for attacking kerberos
 nb-ad-ldap-                    Commands for LDAP enumeration
 nb-ad-smb-                     Commands for SMB services enumeration
 nb-ad-rce-                     Commands for RCE on target system
 nb-ad-dump-                    Commands for Dumping Hashes in AD
 nb-ad-gpp-                     Commands for GPP AD attack
 nb-ad-ipv6-                    Commands for IPv6 AD attack
 nb-ad-enum-                    Commands for AD internal enumeration

 Post-Exploitation Phase
 -----------------------
 nb-pivot-                      Commands for pivoting with ssh

DOC
}

nb-update() {
	  cd ${__PLUGIN}
    git pull
    \cd - > /dev/null
    source $HOME/.config/zsh/.zshrc
}

nb-status() {
	  cd ${__PLUGIN}
    git status
    \cd - > /dev/null
}

nb-message-toggle() {
    local file="$HOME/.config/zsh/plugins/nobility/nobility.plugin.zsh"
    local line="__info \"Nobility ZSH plugin loaded\""
    if grep -qF "#$line" "$file"; then
        sed -i "s/#$line/$line/" "$file"
        __info "Nobility startup message suppressed"
    else
        sed -i "s/$line/#$line/" "$file"
        __info "Nobility startup message visible"
    fi
}


############################################################# 
# Output Helpers
#############################################################
__cyan() echo "$fg[cyan]$@ $reset_color"
__green() echo "$fg[green]$@ $reset_color"
__blue() echo "$fg[blue]$@ $reset_color"
__yellow() echo "$fg[yellow]$@ $reset_color"
__red() echo "$fg[red]$@ $reset_color"

__info() __blue "[*] $@"
__ok() __green "[+] $@"
__warn() __yellow "[!] $@"
__err() __red "[X] $@"


############################################################# 
# Input Helpers
#############################################################
__ask() __yellow "$@"
__prompt() __cyan "[?] $@"

__askvar() { 
    local retval=$1
    local question=$2
    local tmpval
    read "tmpval?$fg[cyan]${question}:$reset_color "
    eval $retval="'$tmpval'"
}

__askpath() { 
    local retval=$1
    local question=$2
    local prefill=$3
    local tmpinput=$(rlwrap -S "$fg[cyan]${question}: $reset_color" -P "${prefill}" -e '' -c -o cat)
    local tmpval=$(echo "${tmpinput}" | sed 's/\/$//' )
    eval $retval="'$tmpval'"
}

__prefill() { 
    local retval=$1
    local question=$2
    local prefill=$3
    local tmpval=$(rlwrap -S "$fg[cyan]${question}: $reset_color" -P "${prefill}" -e '' -o cat)
    eval $retval="'$tmpval'"
}

__check-proceed() {
    PS3="$fg[cyan]Select: $reset_color"
    COLUMNS=10
    select yn in "Yes" "Cancel"; do
    case $yn in
        Yes) 
            return 0
            break;;
        *)
            return 1
            break;;
    esac
    done
}

__menu() {
    PS3="$fg[cyan]Select: $reset_color"
    COLUMNS=10
    select o in $@; do break; done
    echo ${o}
}


############################################################# 
# String Helpers
#############################################################
__trim-slash() { echo $1 | sed 's/\/$//' }
__trim-quotes() { echo $1 | tr -d \" }
__trim-newline() { echo $1 | tr -d "\n"}

__rand() {
    if [ "$#" -eq  "1" ]
    then
        head /dev/urandom | tr -dc A-Za-z0-9 | head -c $1 ; echo ''
    else
        head /dev/urandom | tr -dc A-Za-z0-9 | head -c 16 ; echo ''
    fi  
}


############################################################# 
# Tool Helpers
#############################################################
__msf() {
    local msfcmd=$(cat $@)
    print -z "msfconsole -n -q -x \"${msfcmd}\" "
}
