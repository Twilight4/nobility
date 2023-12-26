#!/usr/bin/env zsh

############################################################# 
# qq-arch
#############################################################
qq-arch-help() {
    cat << "DOC" | bat --plain --language=help

qq-arch
----------
The qq-arch namespace provides commands that assist with managing Arch linux.

Commands
--------
qq-arch-pkg-query            query if a package is installed or not  
qq-arch-new-project          create a new project and go there
qq-arch-flush-iptables       flushes ip tables
qq-arch-get-gateway          get router IP address
qq-arch-get-hosts            get list of host IP addresses found via nmap
qq-arch-get-hostnames        get list of host names using nmap and the IP of a known DNS server
qq-arch-download-html        download IP and print with html2text
qq-arch-scan-tcp             scan IP with masscan
qq-arch-scan-udp             scan IP with nmap
qq-arch-ps-grep              search list of processes
qq-arch-ps-dtach             run a script in the background
qq-arch-path-add             add a new path to the PATH environment variable
qq-arch-file-replace         replace an existing value in a file
qq-arch-file-dos-to-unix     convert file with dos endings to unix
qq-arch-file-unix-to-dos     convert file with unix endings to dos
qq-arch-file-sort-uniq       sort a file uniq in place 
qq-arch-file-sort-uniq-ip    sort a file of IP addresses uniq in place
qq-arch-sudoers-easy         removes the requirment for sudo for common commands like nmap
qq-arch-sudoers-harden       removes sudo exclusions

DOC
}

qq-arch-pkg-query() {
    local query && __askvar query PACKAGE 
    for pkg in "${query}"
    do
    pacman -Q | grep -qw $pkg && __ok "${pkg} is installed" || __warn "${pkg} not installed"
    done 
}

qq-arch-new-project() {
    # Check if project name is provided
    if [ -z "$1" ]; then
        echo "Usage: nproj company-name"
        return 1
    fi

    # Ask for assessment type
    echo "Assessment types:"
    echo "1. red-team"
    echo "2. network-pentest"
    echo "3. osint"

    # Read assessment choice
    echo -n "Enter assessment type number: "
    read assessment_choice

    case $assessment_choice in
        1) assessment_type="red-team";;
        2) assessment_type="network-pentest";;
        3) assessment_type="osint";;
        *) echo -e "\nInvalid choice. Aborting."; return 1;;
    esac

    # Create a directory for assessment type if it doesn't exist
    assessment_dir="$HOME/desktop/projects/$assessment_type"
    mkdir -p "$assessment_dir"

    # Create the project directory
    proj_name="$1"
    proj_dir="$assessment_dir/$proj_name"
    mkdir -p "$proj_dir"

    # Move to the project directory
    cd "$proj_dir"

    echo "Project '$proj_name' created with assessment type '$assessment_type'."
}

qq-arch-flush-iptables() {
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

qq-arch-get-gateway() {
   INTERFACE=${1:-tap0}
   ip route | grep via | grep "$INTERFACE" | cut -d" " -f3 
}

qq-arch-get-hosts() {
    PORT=${1:-"none"}
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for ${NETWORK:0:-1}"
    get_ip() {
        cut -d" " -f5 $1
    }
    if [[ $PORT == "none" ]]; then
        nmap "$NETWORK"/24 -sn | grep "$PATTERN" | get_ip
    else
        nmap "$NETWORK"/24 -p "$PORT" --open | grep "$PATTERN" | get_ip
    fi
}

qq-arch-get-hostnames() {
    DNS=$1
    NETWORK=${2:-"10.11.1.0"}
    PATTERN="Nmap scan report for "
    get_ip() {
        cut -d" " -f5- $1
    }
    if [[ ${#1} -gt 0 ]]; then
        nmap "$NETWORK"/24 --dns-server "$DNS" -sn | grep "$PATTERN" | get_ip
    else
        echo "DNS server address required"
    fi
}

qq-arch-download-html() { 
	curl -s "${1:-$RHOST}:${80:-$RPORT}" | html2text -style pretty; 
}

qq-arch-scan-tcp() {
    IP=${1:-${__RHOST}
    INTERFACE=${2:-"tap0"}
    SAVEPATH=$(create_scan_directory "$IP")
    run() {
        masscan "$1" -e "$INTERFACE" --router-ip "$(qq-arch-get-gateway "$INTERFACE")" -p 0-65535 --rate 500 -oL "$SAVEPATH"/ports
    }
    run "$IP"
}

qq-arch-scan-udp() {
    IP=${1:-$RHOST}
    SAVEPATH=$(create_scan_directory "$IP")
    run() {
        nmap -sU -T4 --open --max-retries 1 "$1" -oX "$SAVEPATH"/ports-udp.xml
    }
    run "$IP"
}

qq-arch-ps-grep() { 
    local query && __askvar query QUERY 
    print -z "ps aux | grep -v grep | grep -i -e VSZ -e ${query}" 
}

qq-arch-ps-dtach() { 
    __ask "Enter full path to script to run dtach'd"
    local p && __askpath p PATH $(pwd)
    dtach -A ${p} /bin/zsh 
}

qq-qrch-path-add() { 
    __ask "Enter new path to append to current PATH"
    local p && __askpath p PATH /   
    print -z "echo \"export PATH=\$PATH:${p}\" | tee -a $HOME/.zshrc" 
}

qq-arch-file-replace() {
    local replace && __askvar replace REPLACE
    local with && __askvar with WITH
    local file && __askpath file FILE $(pwd)
    print -z "sed 's/${replace}/${with}/g' ${file} > ${file}"
} 

qq-arch-file-dos-to-unix() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "tr -d \"\015\" < ${file} > ${file}.unix"
}

qq-arch-file-unix-to-dos() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "sed -e 's/$/\r/' ${file} > ${file}.dos"
}

qq-arch-file-sort-uniq() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u -o ${file}"
}

qq-arch-file-sort-uniq-ip() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u | sort -V -o ${file}"
}

qq-arch-sudoers-easy() {
    __warn "This is dangerous for OPSEC! Remove when done."
    print -z "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/masscan, /usr/sbin/tcpdump\" | sudo tee /etc/sudoers.d/$(whoami)"
}

qq-arch-sudoers-harden() {
    print -z "sudo rm /etc/sudoers.d/$(whoami)"
}
