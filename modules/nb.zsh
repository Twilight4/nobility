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
 nb-update                      git pull the nobility changes from github repository
 nb-status                      check the current status of the locally cloned nobility repository
 nb-message-toggle              toggle the "Nobility loaded" shell startup message

 Namespaces
 ----------
 Nobility is organized in a tree of namespaces that are accessible via "nb-" with tab completion and search.
 Each namespace has its own install and help commands.

 Install and Engagement Preparation
 ----------------------------------
 nb-install-                    Installers for commonly used applications and global installer for all dependencies
 nb-project-                    Commands to define scope and manage project data
 nb-vars-global-                Persistent environment variables used in all commands, all sessions
 nb-vars-                       Per-session, per-engagement variables used in all commands

 Utilities
 ---------
 nb-crack-                      Commands for cracking password hashes
 nb-encoding-                   Commands for encoding / encrypting data
 nb-srv-                        Commands for spawning file hosting services
 nb-compile-                    Commands for compiling exploits
 nb-shell-tty-                  Commands for upgrading tty shells
 nb-shell-handlers-             Commands for spawning reverse shell handlers
 nb-shell-handlers-msf-         Commands for spawning reverse shells with Metasploit
 nb-pivot-                      Commands for pivoting with ssh
 nb-wep-                        Commands for weaponization/target profiling

 Reconneissance/OSINT Phase
 --------------------------
 nb-recon-org-                  Commands for organization files and data
 nb-recon-user-                 Commands for searching person's data
 nb-recon-github-               Commands for searching github repositories
 nb-recon-networks-             Commands for identiying an organization's networks nb-recon-domains-              Commands for horizontal domain enumeration nb-recon-subs-                 Commands for vertical sub-domain enumeration External Enumeration Phase
 --------------------------
 nb-enum-web-                   Enumerate web servers and services
 nb-enum-web-aws-               Enumerate AWS hosted services
 nb-enum-web-dirs-              Enumerate directories and files
 nb-enum-web-php-               Enumerate php web servers
 nb-enum-web-ssl-               Enumerate SSL certs and services
 nb-enum-web-vuln-              Enumerate common web vulnerabilities

 Internal Enumeration Phase
 --------------------------
 nb-enum-network-               Enumerate and scan target hosts/networks
 nb-enum-dhcp-                  Enumerate DHCP services
 nb-enum-dns-                   Enumerate DNS services
 nb-enum-ftp-                   Enumerate FTP services
 nb-enum-kerb-                  Enumerate Kerberos services
 nb-enum-ldap-                  Enumerate LDAP and Active Directory services
 nb-enum-mssql-                 Enumerate MSSQL database services
 nb-enum-mysql-                 Enumerate MYSQL database services
 nb-enum-smtp-                  Enumerate SMTP services
 nb-enum-nfs-                   Enumerate NFS shares and services
 nb-enum-oracle-                Enumerate Oracle database services
 nb-enum-pop3-                  Enumerate POP3 services
 nb-enum-rdp-                   Enumerate RDP services

 Host Post-Exploitation Enumeration Phase
 ----------------------------------------
 nb-local-dump-                 Commands for manually dumping windows local hashes
 nb-local-pillaging-            Commands for local pillaging
 nb-local-cred-                 Commands for local credential hunting
 nb-local-persist-              Commands for local persistence

 Active Directory Enumeration and Exploitation Phase
 ---------------------------------------------------
 nb-ad-kerb-                    Commands for attacking kerberos
 nb-ad-smb-                     Commands for SMB services enumeration
 nb-ad-smb-relay                Commands for SMB relay AD attack
 nb-ad-rce-                     Commands for RCE on target system
 nb-ad-cve-                     Commands for exploiting systems vulnerable to modern CVEs
 nb-ad-dump-                    Commands for dumping windows hashes in domain
 nb-ad-gpp-                     Commands for GPP AD attack
 nb-ad-ipv6-                    Commands for IPv6 AD attack
 nb-ad-enum-                    Commands for AD internal enumeration

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
    local next_line="echo \"\""
    
    if grep -qF "#$line" "$file"; then
        # Uncomment the __info line
        sed -i "s/#$line/$line/" "$file"
        # Uncomment the next line (echo "")
        sed -i "/$line/{n;s/#$next_line/$next_line/;}" "$file"
        __info "Nobility startup message visible"
    else
        # Comment the __info line
        sed -i "s/$line/#$line/" "$file"
        # Comment the next line (echo "")
        sed -i "/$line/{n;s/$next_line/#$next_line/;}" "$file"
        __info "Nobility startup message suppressed"
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
