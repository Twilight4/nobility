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
nb-enum-web-vhosts-gobuster        brute force for virtual hosts
nb-enum-web-eyewitness             scrape screenshots from target URL
nb-enum-web-wordpress              enumerate Wordpress information
nb-enum-web-headers                grab headers from a target url using curl
nb-enum-web-mirror                 mirrors the target website locally

DOC
}

nb-enum-web-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap whatweb wafw00f gobuster eyewitness wpscan wget curl seclists wordlists hakrawler gospider
}

nb-enum-web-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo nmap -n -Pn -sS -p80,443,8080 ${__NETWORK} -oA $(__netpath)/web-sweep"
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


############################################################# 
# vhosts
#############################################################
nb-enum-web-vhosts-gobuster() {
    __check-project
    nb-vars-set-url
    local w && __askpath w FILE /usr/share/seclists/Discovery/DNS/subdomains-top1mil-20000.txt
    __check-threads
    print -z "gobuster vhost -u ${__URL} -w ${w} -a \"${__UA}\" -t ${__THREADS} -o $(__urlpath)/vhosts.txt"
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
