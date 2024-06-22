#!/usr/bin/env zsh

############################################################# 
# nb-lin
#############################################################
nb-lin-help() {
    cat << "DOC" | bat --plain --language=help

nb-lin
----------
The nb-lin namespace provides commands for managing your OS.

Commands
--------
nb-lin-pkg-query            query if a package is installed or not  
nb-lin-flush-iptables       flushes ip tables
nb-lin-download-html        download IP and print with html2text
nb-lin-scan-tcp             scan IP with masscan
nb-lin-scan-udp             scan IP with nmap
nb-lin-ps-dtach             run a script in the background
nb-lin-file-replace         replace an existing value in a file
nb-lin-file-sort-uniq       sort a file uniq in place 
nb-lin-file-sort-uniq-ip    sort a file of IP addresses uniq in place

DOC
}

nb-lin-pkg-query() {
    local query && __askvar query PACKAGE 
    for pkg in "${query}"
    do
    dpkg -l | grep -qw $pkg && __ok "${pkg} is installed" || __warn "${pkg} not installed"
    done 
}

nb-lin-flush-iptables() {
    echo ""
    echo ">>> Before flush <<<"
    echo "" 
    iptables -L
    iptables -F
    iptables -X
    iptables -t nat -F
    iptables -t nat -X
    iptables -t mangle -F
    iptables -t mangle -X
    iptables -t raw -F
    iptables -t raw -X
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT
    echo ""
    echo ""
    echo ">>> After flush <<<"
    echo "" 
    iptables -L
    echo ""
}

nb-lin-download-html() { 
	curl -s "${1:-$RHOST}:${80:-$RPORT}" | html2text -style pretty; 
}

nb-lin-scan-tcp() {
    IP=${1:-${__RHOST}
    INTERFACE=${2:-"tap0"}
    SAVEPATH=$(create_scan_directory "$IP")
	
    run() {
        masscan "$1" -e "$INTERFACE" --router-ip "$(nb-lin-get-gateway "$INTERFACE")" -p 0-65535 --rate 500 -oL "$SAVEPATH"/ports
    }
	
    run "$IP"
}

nb-lin-scan-udp() {
    IP=${1:-$RHOST}
    SAVEPATH=$(create_scan_directory "$IP")
	
    run() {
        grc nmap -sU -T4 --open --max-retries 1 "$1" -oX "$SAVEPATH"/ports-udp.xml
    }
	
    run "$IP"
}

nb-lin-ps-dtach() { 
    __ask "Enter full path to script to run dtach'd"
    local p && __askpath p PATH $(pwd)
    dtach -A ${p} /bin/zsh 
}

nb-lin-file-replace() {
    local replace && __askvar replace REPLACE
    local with && __askvar with WITH
    local file && __askpath file FILE $(pwd)
    print -z "sed 's/${replace}/${with}/g' ${file} > ${file}"
} 

nb-lin-file-sort-uniq() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u -o ${file}"
}

nb-lin-file-sort-uniq-ip() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u | sort -V -o ${file}"
}
