#!/usr/bin/env zsh

############################################################# 
# qq-kali
#############################################################
qq-kali-help() {
    cat << "DOC"

qq-kali
----------
The qq-kali namespace provides commands that assist with managing Kali linux.

Commands
--------
qq-kali-pkg-query            query if a package is installed or not  
qq-kali-pkg-fix              fix broken packages
qq-kali-pkg-go-update        update go modules and packages with go get
qq-kali-fs-mounted           show mounted file systems
qq-kali-fs-usage             show file system usage totals
qq-kali-fs-last3             show files modified in last 3 days in /etc
qq-kali-fs-large             show files larger than 1GB in the root fs
qq-kali-mem-top10            show top10 processes by memory usage
qq-kali-mem-free             show overall memory usage
qq-kali-disk-top10           show top 10 files by size in current directory
qq-kali-ps-tree              show a process tree
qq-kali-ps-grep              search list of processes
qq-kali-ps-dtach             run a script in the background
qq-kali-net-watch            display network active connections
qq-kali-net-open4            display open network connections ipv4
qq-kali-net-open6            display open network connections ipv6
qq-kali-net-routes           display the system routing table
qq-kali-net-ss               display open network connections
qq-kali-net-lsof             display open network connections
qq-kali-net-pubip            query for the public IP
qq-kali-pvpn-update          install or update proton vpn cli
qq-kali-pvpn-status          check proton vpn status
qq-kali-pvpn-connect-tcp     connect to proton vpn using tcp
qq-kali-pvpn-connect-udp     connect to proton vpn using udp
qq-kali-pvpn-disconnect      disconnect proton vpn
qq-kali-path-add             add a new path to the PATH environment variable
qq-kali-file-replace         replace an existing value in a file
qq-kali-file-dos-to-unix     convert file with dos endings to unix
qq-kali-file-unix-to-dos     convert file with unix endings to dos
qq-kali-file-sort-uniq       sort a file uniq in place 
qq-kali-file-sort-uniq-ip    sort a file of IP addresses uniq in place
qq-kali-sudoers-easy         removes the requirment for sudo for common commands like nmap
qq-kali-sudoers-harden       removes sudo exclusions

DOC
}

qq-kali-pkg-query() {
    local query && __askvar query PACKAGE 
    for pkg in "${query}"
    do
    dpkg -l | grep -qw $pkg && __ok "${pkg} is installed" || __warn "${pkg} not installed"
    done 
}

qq-arch-ps-grep() { 
    local query && __askvar query QUERY 
    print -z "ps aux | grep -v grep | grep -i -e VSZ -e ${query}" 
}

qq-kali-ps-dtach() { 
    __ask "Enter full path to script to run dtach'd"
    local p && __askpath p PATH $(pwd)
    dtach -A ${p} /bin/zsh 
}

qq-kali-path-add() { 
    __ask "Enter new path to append to current PATH"
    local p && __askpath p PATH /   
    print -z "echo \"export PATH=\$PATH:${p}\" | tee -a $HOME/.zshrc" 
}

qq-kali-file-replace() {
    local replace && __askvar replace REPLACE
    local with && __askvar with WITH
    local file && __askpath file FILE $(pwd)
    print -z "sed 's/${replace}/${with}/g' ${file} > ${file}"
} 

qq-kali-file-dos-to-unix() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "tr -d \"\015\" < ${file} > ${file}.unix"
}

qq-kali-file-unix-to-dos() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "sed -e 's/$/\r/' ${file} > ${file}.dos"
}

qq-kali-file-sort-uniq() {
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u -o ${file}"
}

qq-kali-file-sort-uniq-ip() { 
    local file=$1 
    [[ -z "${file}" ]] && __askpath file FILE $(pwd)
    print -z "cat ${file} | sort -u | sort -V -o ${file}"
}

qq-kali-sudoers-easy() {
    __warn "This is dangerous for OPSEC! Remove when done."
    print -z "echo \"$USER ALL=(ALL:ALL) NOPASSWD: /usr/bin/nmap, /usr/bin/masscan, /usr/sbin/tcpdump\" | sudo tee /etc/sudoers.d/$(whoami)"
}
alias easymode="qq-bounty-sudoers-easy"

qq-kali-sudoers-harden() {
    print -z "sudo rm /etc/sudoers.d/$(whoami)"
}
alias hardmode="qq-bounty-sudoers-harden"
