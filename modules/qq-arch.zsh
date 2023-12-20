#!/usr/bin/env zsh

############################################################# 
# qq-arch
#############################################################
qq-arch-help() {
    cat << "DOC"

qq-arch
----------
The qq-arch namespace provides commands that assist with managing Arch linux.

Commands
--------
qq-arch-pkg-query            query if a package is installed or not  
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
