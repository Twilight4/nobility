#!/usr/bin/env zsh

############################################################# 
# nb-recon-domains
#############################################################
nb-recon-domains-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-domains
-------------
The recon-domains namespace provides commands to recon horizontal domains of a root domain.
All domains stored in $__PROJECT/domains/domains.txt and $__PROJECT/amass.
You can sort unique this file in place with the "sfu" alias.

Commands
--------
nb-recon-domains-install          installs dependencies
nb-recon-domains-amass-whois      find domains with whois
nb-recon-domains-amass-asn        find domains by asn

DOC
}

nb-recon-domains-install() {
    __info "Running $0..."
    __pkgs amass 
}

nb-recon-domains-amass-whois() {
    __check-project
    nb-vars-set-domain
    mkdir -p ${__PROJECT}/amass
    mkdir -p ${__PROJECT}/domains
    print -z "amass intel -active -whois -d ${__DOMAIN} -dir ${__PROJECT}/amass | tee -a ${__PROJECT}/domains/domains.txt"
}

nb-recon-domains-amass-asn() {
    __check-project
    __check-asn
    mkdir -p ${__PROJECT}/amass
    mkdir -p ${__PROJECT}/domains
    print -z "amass intel -active -asn ${__ASN} -dir ${__PROJECT}/amass | tee -a ${__PROJECT}/domains/domains.txt"
}
