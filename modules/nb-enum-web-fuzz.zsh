#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-fuzz
#############################################################
nb-enum-web-fuzz-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-fuzz
--------------
The nb-enum-web-fuzz namespace contains commands for fuzzing inputs of web applications

Commands
--------
nb-enum-web-fuzz-install                      installs dependencies
nb-enum-web-fuzz-auth-basic-payloads          generate base64 encoded credentials
nb-enum-web-fuzz-auth-basic-ffuf              brute force basic auth
nb-enum-web-fuzz-auth-json-ffuf               brute force basic auth with json post
nb-enum-web-fuzz-auth-post-ffuf               brute force auth with post
nb-enum-web-fuzz-auth-post-wfuzz              brute force auth with post
nb-enum-web-fuzz-hydra-get                    brute force auth with get
nb-enum-web-fuzz-password-hydra-form-post     brute force auth password with post request
nb-enum-web-fuzz-login-hydra-form-post        brute force auth login with post request

DOC
}

nb-enum-web-fuzz-install() {
    __info "Running $0..."
    __pkgs seclists wordlists wfuzz hydra ffuf
}

nb-enum-web-fuzz-auth-basic-payloads() {
    nb-vars-set-wordlist
    __check-user
    print -z "file=\"${f}\"; while IFS= read line; do; echo -n \"${__USER}:\$line\" | base64 ; done <\"\$file\" > payloads.b64"
}


############################################################# 
# ffuf
#############################################################
nb-enum-web-fuzz-auth-basic-ffuf() {
    nb-vars-set-url
    __ask "Select file containing authorization header payloads"
    local f && __askpath f FILE $(pwd)
    __check-threads
    print -z "ffuf -t ${__THREADS} -p \"0.1\" -w ${f} -H \"Authorization: Basic FUZZ\" -fc 401 -u ${__URL}  "
}

nb-enum-web-fuzz-auth-json-ffuf() {
    nb-vars-set-url
    __check-threads
    print -z "ffuf -t ${__THREADS} -p \"0.1\" -w /usr/share/seclists/Fuzzing/Databases/NoSQL.txt -u ${__URL} -X POST -H \"Content-Type: application/json\" -d '{\"username\": \"FUZZ\", \"password\": \"FUZZ\"}' -fr \"error\" "
}

nb-enum-web-fuzz-auth-post-ffuf() {
    nb-vars-set-url
    local uf && __askvar uf USER_FIELD
    local uv && __askvar uv USER_VALUE
    local pf && __askvar pf PASSWORD_FIELD
    __check-threads
    print -z "ffuf -t ${__THREADS}  -p \"0.1\" -w ${__PASSLIST}  -H \"Content-Type: application/x-www-form-urlencoded\" -X POST -d \"${uf}=${uv}&${pf}=FUZZ\" -u ${__URL} -fs 75 "
}


############################################################# 
# wfuzz
#############################################################
nb-enum-web-fuzz-auth-post-wfuzz() {
    nb-vars-set-url
    local uf && __askvar uf USER_FIELD
    local uv && __askvar uv USER_VALUE
    local pf && __askvar pf PASSWORD_FIELD
    print -z "wfuzz -c -w ${__PASSLIST} -d \"${uf}=${uv}&${pf}=FUZZ\" --sc 302 ${__URL}"
}

nb-enum-web-fuzz-hydra-get() {
    nb-vars-set-rhost
    __check-user
    __ask "Enter the URI for the get request, ex: /path"
    local uri && __askvar uri URI
    print -z "hydra -l ${__USER} -P ${__PASSLIST} ${__RHOST} http-get ${uri} -V"
}

nb-enum-web-fuzz-password-hydra-form-post() {
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
    print -z "hydra ${__RHOST} http-form-post \"${uri}:${uf}=^USER^&${pf}=^PASS^:${fm}\" -l ${un} -P ${__PASSLIST} -t 10 -w 30 -V"
}

nb-enum-web-fuzz-login-hydra-form-post() {
    nb-vars-set-rhost
    nb-vars-set-wordlist
    __ask "Enter the URI for the post request, ex: /path"
    local uri && __askvar uri URI
    local uf && __askvar uf USER_FIELD
    local pf && __askvar pf PASSWORD_FIELD
    __ask "Enter the response value to check for failure"
    local fm && __askvar fm FAILURE
    print -z "hydra ${__RHOST} http-form-post \"${uri}:${uf}=^USER^&${pf}=^PASS^:${fm}\" -l ${__WORDLIST} -p test -t 10 -w 30 -V"
}
