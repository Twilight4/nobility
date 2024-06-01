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
nb-lin-get-gateway          get router IP address
nb-lin-get-hosts            get list of host IP addresses found via nmap
nb-lin-get-hostnames        get list of host names using nmap and the IP of a known DNS server
nb-lin-download-html        download IP and print with html2text
nb-lin-scan-tcp             scan IP with masscan
nb-lin-scan-udp             scan IP with nmap
nb-lin-ps-grep              search list of processes
nb-lin-ps-dtach             run a script in the background
nb-lin-path-add             add a new path to the PATH environment variable
nb-lin-file-replace         replace an existing value in a file
nb-lin-file-dos-to-unix     convert file with dos endings to unix
nb-lin-file-unix-to-dos     convert file with unix endings to dos
nb-lin-file-sort-uniq       sort a file uniq in place 
nb-lin-file-sort-uniq-ip    sort a file of IP addresses uniq in place
nb-lin-sudoers-easy         removes the requirment for sudo for common commands like nmap
nb-lin-sudoers-harden       removes sudo exclusions

DOC
}

nb-lin-pkg-query() {
    local query && __askvar query PACKAGE 
    for pkg in "${query}"
    do
    pacman -Q | grep -qw $pkg && __ok "${pkg} is installed" || __warn "${pkg} not installed"
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

nb-lin-get-gateway() {
   INTERFACE=${1:-tap0}
   ip route | grep via | grep "$INTERFACE" | cut -d" " -f3 
}

nb-lin-get-hosts() {
    PORT=${1:-"none"}
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for ${NETWORK:0:-1}"

    get_ip() {
        cut -d" " -f5 $1
    }
	
    if [[ $PORT == "none" ]]; then
        print -z 'grc nmap "$NETWORK"/24 -sn | grep "$PATTERN" | get_ip'
    else
        print -z 'grc nmap "$NETWORK"/24 -p "$PORT" --open | grep "$PATTERN" | get_ip'
    fi
}

nb-lin-get-hostnames() {
    DNS=$1
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for "

    get_ip() {
        cut -d" " -f5- $1
    }

    if [[ ${#1} -gt 0 ]]; then
        grc nmap "$NETWORK"/24 --dns-server "$DNS" -sn | grep "$PATTERN" | get_ip
    else
        echo "DNS server address required"
    fi
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

nb-lin-ps-grep() { 
    local query && __askvar query QUERY 
    print -z "ps aux | grep -v grep | grep -i -e VSZ -e ${query}" 
}

nb-lin-ps-dtach() { 
    __ask "Enter full path to script to run dtach'd"
    local p && __askpath p PATH $(pwd)
    dtach -A ${p} /bin/zsh 
}

nb-lin-path-add() { 
    __ask "Enter new path to append to current PATH"
    local p && __askpath p PATH /   
    print -z "echo \"export PATH=\$PATH:${p}\" | tee -a $HOME/.config/zsh/.zshrc"
}

nb-lin-file-replace() {
    local replace && __askvar replace REPLACE
    local with && __askvar with WITH
    local file && __askpath file FILE $(pwd)
    print -z "sed 's/${replace}/${with}/g' ${file} > ${file}"
} 

nb-lin-file-dos-to-unix() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "tr -d \"\015\" < ${file} > ${file}.unix"
}

nb-lin-file-unix-to-dos() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "sed -e 's/$/\r/' ${file} > ${file}.dos"
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

nb-lin-sudoers-easy() {
    __warn "This is dangerous for OPSEC! Remove when done."
	
    print -z "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/masscan, /usr/sbin/tcpdump\" | sudo tee /etc/sudoers.d/$(whoami)"
}

nb-lin-sudoers-harden() {
    print -z "sudo rm /etc/sudoers.d/$(whoami)"
}
