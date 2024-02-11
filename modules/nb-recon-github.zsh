#!/usr/bin/env zsh

############################################################# 
# nb-recon-github
#############################################################
nb-recon-github-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-github
------------
The recon-github namespace provides commands for the recon of github repos.
All output will be stored under $__PROJECT/source.

Commands
--------
nb-recon-github-install        installs dependencies
nb-recon-github-user-repos     uses curl to get a list of repos for a github user
nb-recon-github-endpoints      gets a list of urls from all repos of a domain on github
nb-recon-github-gitrob         clones (in mem) repos and searches for github dorks
nb-recon-github-api-set        set github API key global variable

DOC
}

nb-recon-github-install() {
    __info "Running $0..."
    __pkgs curl jq python gitrob
    nb-install-golang
    nb-install-github-search
    nb-install-git-secrets
}

nb-recon-github-user-repos() {
    __check-project
    __check-user
    mkdir -p ${__PROJECT}/source
    print -z "curl -s \"https://api.github.com/users/${__USER}/repos?per_page=1000\" | jq '.[].git_url' | tee -a ${__PROJECT}/source/${__USER}.txt "
}

nb-recon-github-endpoints() {
    __check-api-github
    __check-project
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/source
    print -z "github-endpoints.py -t ${__API_GITHUB} -d ${__DOMAIN} | tee -a ${__PROJECT}/source/${__DOMAIN}.endpoints.txt "
}
