#!/usr/bin/env zsh

############################################################# 
# nb-recon-networks
#############################################################
nb-recon-networks-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-networks
-------------
The recon-networks namespace provides commands to recon ASNs and IP networks for an organization.
All network data is stored in $__PROJECT/networks.

Commands
--------
nb-recon-networks-install          installs dependencies
nb-recon-networks-amass-asn        find asns by domain
nb-recon-networks-bgp              use the bgp.he.net website to find asns and networks
nb-recon-networks-bgpview-ipv4     curl api.bgpview.io for ipv4 networks by asn
nb-recon-networks-bgpview-ipv6     curl api.bgpview.io for ipv6 networks by asn

DOC
}

nb-recon-networks-install() {
    __info "Running $0..."
    __pkgs curl jq amass
}

nb-recon-networks-bgp() {
    __info "Search https://bgp.he.net/"
}

nb-recon-networks-amass-asns() {
    __check-project || return
    __check-org
    mkdir ${__PROJECT}/networks
    print -z "amass intel -org ${__ORG} | cut -d, -f1 | tee -a ${__PROJECT}/networks/asns.txt "
}

nb-recon-networks-bgpview-ipv4() {
    __check-project || return
    __check-asn
    mkdir ${__PROJECT}/networks
    print -z "curl -s https://api.bgpview.io/asn/${__ASN}/prefixes | jq -r '.data | .ipv4_prefixes | .[].prefix' | tee -a ${__PROJECT}/networks/ipv4.txt"
}

nb-recon-networks-bgpview-ipv6() {
    __check-project || return
    __check-asn
    mkdir ${__PROJECT}/networks
    print -z "curl -s https://api.bgpview.io/asn/${__ASN}/prefixes | jq -r '.data | .ipv6_prefixes | .[].prefix'  | tee -a ${__PROJECT}/networks/ipv6.txt"
}
