#!/usr/bin/env zsh

############################################################# 
# nb-recon-subs
#############################################################
nb-recon-subs-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-subs
-------------
The recon namespace provides commands to recon vertical sub-domains of a root domain.
All subdomains for a domain will be stored in $__PROJECT/amass and $__PROJECT/domains/$DOMAIN/subs.txt.
You can sort unique this file in place with the "sfu" alias.

Commands
--------
nb-recon-subs-install          installs dependencies

Commands - enumeration
----------------------
nb-recon-subs-amass-enum       enumerate subdomains into amass db (api keys help)
nb-recon-subs-amass-diff       track changes between last 2 enumerations using amass db
nb-recon-subs-amass-names      list gathered subs in the amass db
nb-recon-subs-crt-sh           gather subdomains from crt.sh
nb-recon-subs-subfinder        gather subdomains from sources (api keys help)
nb-recon-subs-ffuf             gather subdomains with ffuf
nb-recon-subs-assetfinder      gather subdomains from sources (api keys help)
nb-recon-subs-wayback          gather subdomains from Wayback Machine

Commands - brute force
----------------------
nb-recon-subs-brute-massdns    try to resolve a list of subdomains generated for brute forcing
nb-recon-subs-gen-wordlist     generate a wordlist of possible sub domains 

Commands - processing
---------------------
nb-recon-subs-resolve-massdns  resolve a file of subdomains using massdns
nb-recon-subs-resolve-parse    parse resolved.txt into A, CNAME and IP's

DOC
}

nb-recon-subs-install() {
    __info "Running $0..."
    __pkgs gobuster amass curl wordlists seclists dnsrecon dnsutils
	__pkgs subfinder assetfinder waybackurls massdns
}

nb-recon-subs-amass-enum() {
    __check-project
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/amass
    print -z "amass enum -active -ip -d ${__DOMAIN} -dir ${__PROJECT}/amass"
}

nb-recon-subs-amass-diff() {
    __check-project
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/amass
    print -z "amass track -d ${__DOMAIN} -last 2 -dir ${__PROJECT}/amass"
}

nb-recon-subs-amass-names() {
    __check-project
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/amass
    print -z "amass db -names -d ${__DOMAIN} -dir ${__PROJECT}/amass | tee -a $(__dompath)/subs.txt"
}

nb-recon-subs-crt-sh() {
    __check-project
    nb-vars-set-domain
    print -z "curl -s 'https://crt.sh/?q=%.${__DOMAIN}' | grep -i \"${__DOMAIN}\" | cut -d '>' -f2 | cut -d '<' -f1 | grep -v \" \" | sort -u | tee -a  $(__dompath)/subs.txt "
}

nb-recon-subs-subfinder() {
    __check-project
    nb-vars-set-domain
    __check-threads
    print -z "subfinder -t ${__THREADS} -d ${__DOMAIN} -nW -silent | tee -a $(__dompath)/subs.txt"
}

nb-recon-subs-ffuf() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-wordlist


    __ask "Enter number of threads (default 40)"
    __check-threads
    print -z "ffuf -c -p 0.1 -t ${__THREADS} -H \"Host: FUZZ.${__DOMAIN}\" -fs 5602 -fc 404 -w ${__WORDLIST} -u ${__DOMAIN} -o $(__dompath)/ffuf-subs.csv -of csv"
}

nb-recon-subs-assetfinder() {
    __check-project
    nb-vars-set-domain
    print -z "echo ${__DOMAIN} | assetfinder --subs-only | tee -a $(__dompath)/subs.txt" 
}

nb-recon-subs-wayback() {
    __check-project
    nb-vars-set-domain 
    print -z "echo ${__DOMAIN} | waybackurls | cut -d "/" -f3 | sort -u | grep -v \":80\" | tee -a $(__dompath)/subs.txt"
}

nb-recon-subs-resolve-massdns() {
    __check-project
    __check-resolvers
    nb-vars-set-domain
    print -z "massdns -r ${__RESOLVERS} -s 100 -c 3 -t A -o S -w  $(__dompath)/resolved.txt $(__dompath)/subs.txt"
}

nb-recon-subs-brute-massdns() {
    __check-project
    __check-resolvers
    nb-vars-set-domain
    __ask "Select the file containing a custom wordlist for ${__DOMAIN} (nb-recon-subs-gen-wordlist)"
    local f && __askpath f FILE $(__dompath)
    print -z "massdns -r ${__RESOLVERS} -s 100 -c 3 -t A -o S -w  $(__dompath)/resolved-brute.txt $f"
}

nb-recon-subs-resolve-parse() {
    __check-project
    nb-vars-set-domain
    __info "Generating files resolved-*.txt"
    grep -ie "CNAME" $(__dompath)/resolved.txt | sort -u > $(__dompath)/resolved-CNAME.txt
    grep -v "CNAME" $(__dompath)/resolved.txt | sort -u > $(__dompath)/resolved-A.txt
    grep -v "CNAME" $(__dompath)/resolved.txt | sort -u | cut -d' ' -f3 | sort -u > $(__dompath)/resolved-IP.txt
}

nb-recon-subs-gen-wordlist() {
    __check-project
    nb-vars-set-domain
    local f && __askpath f FILE /usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
    print -z "for s in \$(cat ${f}); do echo \$s.${__DOMAIN} >> $(__dompath)/subs.wordlist.txt; done"
}
