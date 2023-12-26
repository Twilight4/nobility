#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-ssl
#############################################################
nb-enum-web-ssl-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-ssl
----------------
The enum-web-ssl namespace contains commands for enumerating SSL/TLS.

Commands
--------
nb-enum-web-ssl-install              installs dependencies
nb-enum-web-ssl-tcpdump              capture traffic to and from target
nb-enum-web-ssl-der-to-crt           convert a .der file to .crt
nb-enum-web-ssl-crt-ca-install       install a root certificate (.crt)
nb-enum-web-ssl-certs                display cert from a url
nb-enum-web-ssl-cert-download        download certs from a url
nb-enum-web-ssl-testssl-full         fully test ssl cert
nb-enum-web-ssl-testssl-ciphers      test ssl cert ciphets

DOC
}

nb-enum-web-ssl-install() {
    __info "Running $0..."
    __pkgs curl nmap tcpdump openssl testssl
}

nb-enum-web-ssl-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 443 -w $(__hostpath)/ssl.pcap"
}

nb-enum-web-ssl-der-to-crt() {
    __ask "Select the cacert.der file"
    local f && __askpath f FILE $(pwd)
    print -z "sudo openssl x509 -inform DER -in ${f} -out cacert.crt"
}

nb-enum-web-ssl-crt-ca-install() {
    __ask "Select the cacert.crt file"
    local f && __askpath f FILE $(pwd)
    print -z "sudo cp ${f} /usr/local/share/ca-certificates/. && sudo update-ca-certificates"
}

nb-enum-web-ssl-certs() {
    nb-vars-set-url
    print -z "openssl s_client -showcerts -connect ${__URL}:443" 
}

nb-enum-web-ssl-cert-download() {
    __check-project
    nb-vars-set-url
	local d=$(echo "${__URL}" | cut -d/ -f3)
	print -z "openssl s_client -servername ${d} -connect ${d}:443 </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-DOC CERTIFICATE-/p' > $(__urlpath)/ssl.certificate.`date +"%Y%m%d-%H%M%S"`.pem"
}

nb-enum-web-ssl-testssl-full() {
    __check-project
    nb-vars-set-url
	print -z "testssl --color=3 -oA $(__urlpath)/testssl.full.`date +"%Y%m%d-%H%M%S"` ${__URL} "
}

nb-enum-web-ssl-testssl-ciphers() {
    __check-project
    nb-vars-set-url
	print -z "testssl -E --color=3 -oA $(__urlpath)/testssl.ciphers.`date +"%Y%m%d-%H%M%S"` ${__URL} "
}
