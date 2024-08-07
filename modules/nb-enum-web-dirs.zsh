#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-dirs
#############################################################
nb-enum-web-dirs-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-dirs
----------------
The nb-enum-web-dirs namespace contains commands for discovering web content, directories and files.

Commands
--------
nb-enum-web-dirs-install      installs dependencies
nb-enum-web-dirs-robots       get robots.txt using curl
nb-enum-web-dirs-parsero      parse complex robots.txt with parsero
nb-enum-web-dirs-wfuzz        brute force dirs and files with wfuzz
nb-enum-web-dirs-ffuf         brute force dirs and files with ffuf
nb-enum-web-dirs-gobuster     brute force dirs and files with gobuster

DOC
}

nb-enum-web-dirs-install() {
    __info "Running $0..."
    __pkgs parsero gobuster wfuzz curl seclists wordlists ffuf httprobe
}

nb-enum-web-dirs-robots() {
    __check-project
    nb-vars-set-url
    print -z "curl -s -L --user-agent \"${__UA}\" \"${__URL}/robots.txt\" | tee $(__urlpath)/robots.txt"
}

nb-enum-web-dirs-parsero() {
    __check-project
    nb-vars-set-url
    print -z "parsero -u \"${__URL}\" -o -sb | tee $(__urlpath)/robots.txt"
}

nb-enum-web-dirs-wfuzz() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist
    local d && __askvar d "RECURSION DEPTH"
    print -z "wfuzz -s 0.1 -R${d} --hc=404 -w ${__WORDLIST} ${__URL}/FUZZ --oF $(__urlpath)/wfuzz-dirs.txt"
}

nb-enum-web-dirs-ffuf() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist
    __ask "Enter number of threads (default 40)"
    __check-threads
    print -z "ffuf -c -p 0.1 -t ${__THREADS} -H \"User-Agent: Mozilla\" -fs 5602 -fc 404 -w ${__WORDLIST} -u http://${__URL}/FUZZ -o $(__urlpath)/ffuf-dirs.csv -of csv"
}

nb-enum-web-dirs-gobuster() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist

    __ask "Enter number of threads (default 10)"
    __check-threads
    print -z "gobuster dir -u ${__URL} -a \"${__UA}\" -t ${__THREADS} -w ${__WORDLIST} -o $(__urlpath)/gobuster-dirs.txt "
}
