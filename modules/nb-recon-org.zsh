#!/usr/bin/env zsh

############################################################# 
# nb-recon-org
#############################################################
nb-recon-org-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-org
------------
The recon namespace provides commands for the recon of an organization.
Data from commands will be stored in $__PROJECT/recon.

Commands
--------
nb-recon-org-install               installs dependencies
nb-recon-org-files-metagoofil      uses metagoofil to search and download files for a domain
nb-recon-org-files-urls            uses gf to search and download files for a domain
nb-recon-org-wordlist-cewl         uses cewl to create a custom wordlist from a url
nb-recon-org-theharvester          uses theHarvester to mine data about a target domain

DOC
}

nb-recon-org-install() {
    __info "Running $0..."
    __pkgs whois metagoofil cewl theharvester
}

nb-recon-org-files-metagoofil() {
    __check-project || return
    __check-ext-docs
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/recon/files
    print -z "metagoofil -u \"${__UA}\" -d ${__DOMAIN} -t ${__EXT_DOCS} -o ${__PROJECT}/recon/files"
}

nb-recon-org-files-urls() {
    __check-project || return
    nb-vars-set-domain
    print -z "strings * | gf urls | grep $__DOMAIN | tee -a ${__PROJECT}/recon/urls.txt"
}

nb-recon-org-wordlist-by-url-cewl() {
    __check-project || return
    nb-vars-set-url
    mkdir -p ${__PROJECT}/recon
    print -z "cewl -a -d 3 -m 5 -u \"${__UA}\" -w ${__PROJECT}/recon/cewl.txt ${__URL}"
}

nb-recon-org-theharvester() {
    __check-project || return
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/recon
    print -z "theHarvester -d ${__DOMAIN} -l 50 -b all -f ${__PROJECT}/recon/harvested.txt"
}

nb-recon-org-cse() {
    __info "Use https://cse.google.com/cse/all to create a custom search engine"
}
