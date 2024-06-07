#!/usr/bin/env zsh

############################################################# 
# nb-enum-web
#############################################################
nb-enum-web-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web
-----------
The nb-enum-web namespace contains commands for scanning and enumerating http services.

Commands
--------
nb-enum-web-install                installs dependencies
nb-enum-web-tcpdump                capture traffic to and from a host
nb-enum-web-nmap-sweep             nmap sweep scan to discover web servers on a network
nb-enum-web-whatweb                enumerate web server and platform information
nb-enum-web-waf                    enumerate WAF information
nb-enum-web-snmp                   create host list and scan IP with WORDLIST
nb-enum-web-ffuf-crawl             crawl/spider a website for hidden folders and files
nb-enum-web-vhosts-gobuster        brute force for virtual hosts with gobuster
nb-enum-web-vhosts-ffuf            brute force for virtual hosts with ffuf
nb-enum-web-eyewitness             scrape screenshots from target URL
nb-enum-web-wordpress              enumerate Wordpress information
nb-enum-web-wordpress-bruteforce   bruteforce Wordpress password, knowing the username
nb-enum-web-headers                grab headers from a target url using curl
nb-enum-web-mirror                 mirrors the target website locally

Brute Force
-----------
nb-enum-web-brute-get               brute force auth with get
nb-enum-web-brute-password-post     brute force auth password with post request
nb-enum-web-brute-login-post        brute force auth login with post request

DOC
}

nb-enum-web-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap whatweb wafw00f gobuster eyewitness wpscan wget curl seclists wordlists hakrawler gospider
}

nb-enum-web-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -n -Pn -sS -p80,443,8080 ${__NETWORK} -oA $(__netpath)/web-sweep"
}

nb-enum-web-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 80 -w $(__hostpath)/web.pcap"
}

nb-enum-web-whatweb() {
    __check-project
    nb-vars-set-url
    print -z "whatweb ${__URL} -a 3 | tee $(__urlpath)/whatweb.txt"
}

nb-enum-web-waf() {
    __check-project
    nb-vars-set-url
    print -z "wafw00f ${__URL} -o $(__urlpath)/waf.txt"
}

nb-enum-web-snmp() {
    __check-project
    STRINGS="/usr/share/seclists/Discovery/SNMP/snmp-onesixtyone.txt"
    WORDLIST=${2:-STRINGS}
    NETWORK=${3:-"10.11.1.0"}
    HOSTS=$(mktemp --suffix "-$0-hosts-$(date +%Y%m%d)")
    nb-arch-get-hosts "none" "$NETWORK" > "$HOSTS"
    onesixtyone -i "$HOSTS" -c "$STRINGS"
}

nb-enum-web-crawl() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist
    local w && __askpath w WORDLIST /usr/share/seclists/Discovery/Web-Content/raft-small-directories-lowercase.txt
    __check-threads
    local d && __askvar d "RECURSION DEPTH"
    print -z "ffuf -c -p 0.1 -t ${__THREADS} -recursion -recursion-depth ${d} -H \"User-Agent: Mozilla\" -fc 404 -w ${w} -u ${__URL}/FUZZ -o $(__urlpath)/ffuf-crawl.csv -of csv"
}


############################################################# 
# vhosts
#############################################################
nb-enum-web-vhosts-gobuster() {
    __check-project
    nb-vars-set-url
    local w && __askpath w WORDLIST /usr/share/seclists/Discovery/DNS/namelist.txt
    __check-threads
    print -z "gobuster vhost -u http://${__URL} -w ${w} -a \"${__UA}\" -t ${__THREADS} -o $(__urlpath)/vhosts-gobuster.txt"
}

nb-enum-web-vhosts-ffuf() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-url
    local w && __askpath w WORDLIST /usr/share/seclists/Discovery/DNS/namelist.txt
    __check-threads
    local s && __askvar s SUBDOMAIN

    # Run the curl command and extract the Content-Length number
    cl=$(curl -s -I http://${__URL} -H "HOST: $s" | grep "Content-Length:")

    # Remove any trailing newline character
    length=${cl//$'\n'/}

    # Print the content length
    __info "Content Length: $length"

    # Information
    __info "Add the gathered vhosts/subdomains to /etc/hosts"
    __ok "nb-project-host"

    print -z "ffuf -c -p 0.1 -fc 404 -fs $length -u http://${__URL} -w ${w}:FUZZ -t ${__THREADS} -H \"HOST: FUZZ.${__DOMAIN}\" -o $(__urlpath)/vhosts-ffuf.csv -of csv"
}


############################################################# 
# screenshots
#############################################################
nb-enum-web-eyewitness() {
    __check-project
    nb-vars-set-url
    mkdir -p $(__urlpath)/screens
    print -z "eyewitness --web --no-dns --no-prompt --single ${__URL} -d $(__urlpath)/screens --user-agent \"${__UA}\" "
}


############################################################# 
# apps
#############################################################
nb-enum-web-wordpress() {
    __check-project
    nb-vars-set-url
    print -z "wpscan --ua \"${__UA}\" --url ${__URL} --enumerate tt,vt,u,vp -o $(__urlpath)/wpscan.txt"
}

nb-enum-web-wordpress-bruteforce() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist

    __ask "Enter a user account"
	  __check-user
    print -z "wpscan --ua \"${__UA}\" --url ${__URL} --usernames ${__USER} --passwords ${__WORDLIST} --max-threads 20 -o $(__urlpath)/wpscan.txt"
}

nb-enum-web-headers() {
    __check-project
    nb-vars-set-url
    print -z "curl -s -X GET -I -L -A \"${__UA}\" \"${__URL}\" | tee $(__urlpath)/headers.txt"
}

nb-enum-web-mirror() {
    __warn "The destination site will be mirrored in the current directory"
    nb-vars-set-url
    print -z "wget -mkEpnp ${__URL} "
}

nb-enum-web-gospider() {
    __check-project
    nb-vars-set-url
    print -z "gospider -s "${__URL}" -o $(__urlpath)/spider.txt"
}

nb-enum-web-hakrawler() {
    __check-project
    nb-vars-set-url
    local d && __askvar d DEPTH
    print -z "hakrawler -url  "${__URL}" -depth ${d} -linkfinder -usewayback | tee $(__urlpath)/hakrawler.txt"
}

nb-enum-web-brute-get() {
    nb-vars-set-rhost
    __check-user
    __ask "Enter the URI for the get request, ex: /path"
    local uri && __askvar uri URI
    print -z "hydra -l ${__USER} -P ${__PASSLIST} ${__RHOST} http-get ${uri} -F"
}

nb-enum-web-brute-password-post() {
    nb-vars-set-rhost
    nb-vars-set-passlist
    __ask "Enter the URI for the post request, ex: /path"
    local uri && __askvar uri URI
    local uf && __askvar uf USER_FIELD
    local pf && __askvar pf PASSWORD_FIELD
    __ask "Enter the username which you wanna bruteforce"
    local un && __askvar un USER_NAME
    __ask "Enter the response value to check for failure"
    local fm && __askvar fm FAILURE
    print -z "hydra ${__RHOST} http-form-post \"${uri}:${uf}=^USER^&${pf}=^PASS^:${fm}\" -l ${un} -P ${__PASSLIST} -t 10 -w 30 -F"
}

nb-enum-web-brute-login-post() {
    nb-vars-set-rhost
    nb-vars-set-wordlist
    __ask "Enter the URI for the post request, ex: /path"
    local uri && __askvar uri URI
    local uf && __askvar uf USER_FIELD
    local pf && __askvar pf PASSWORD_FIELD
    __ask "Enter the response value to check for failure"
    local fm && __askvar fm FAILURE
    print -z "hydra ${__RHOST} http-form-post \"${uri}:${uf}=^USER^&${pf}=^PASS^:${fm}\" -l ${__WORDLIST} -p test -t 10 -w 30 -F"
}
