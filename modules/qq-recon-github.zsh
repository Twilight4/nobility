#!/usr/bin/env zsh

############################################################# 
# qq-recon-github
#############################################################

qq-recon-github-help() {
    cat << "DOC"

qq-recon-github
------------
The recon-github namespace provides commands for the recon of github repos.
All output will be stored under $__PROJECT/source

Commands
--------
qq-recon-github-install:        installs dependencies
qq-recon-github-user-repos:     uses curl to get a list of repos for a github user
qq-recon-github-endpoints:      gets a list of urls from all repos of a domain on github
qq-recon-github-gitrob:         clones (in mem) repos and searches for github dorks
qq-recon-github-api-set:        set github API key global variable

DOC
}

qq-recon-github-install() {
    __info "Running $0..."
    __pkgs curl jq python3 
    qq-install-golang
    qq-install-github-search
    qq-install-git-secrets
    qq-install-gitrob
}

qq-recon-github-user-repos() {
    __check-project
    __check-user
    mkdir -p ${__PROJECT}/source
    print -z "curl -s \"https://api.github.com/users/${__USER}/repos?per_page=1000\" | jq '.[].git_url' | tee -a ${__PROJECT}/source/${__USER}.txt "
}

qq-recon-github-endpoints() {
    __check-api-github
    __check-project
    qq-vars-set-domain
    mkdir -p ${__PROJECT}/source
    print -z "github-endpoints.py -t ${__API_GITHUB} -d ${__DOMAIN} | tee -a ${__PROJECT}/source/${__DOMAIN}.endpoints.txt "
}

qq-recon-github-gitrob() {
    __check-api-github
    __check-project
    __check-user
    local d=${__PROJECT}/source/${__USER}
    mkdir -p $d
    cp $HOME/go/src/github.com/codeEmitter/gitrob/filesignatures.json $d
    __info "Gitrob UI: http://127.0.0.1:9393/"
    print -z "pushd $d ;gitrob -in-mem-clone -save \"$d/output.json\" -github-access-token $__API_GITHUB ${__USER} && popd"
}
