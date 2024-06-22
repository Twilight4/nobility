#!/usr/bin/env zsh

############################################################# 
# nb-compile
#############################################################
nb-compile-help() {
    cat << "DOC" | bat --plain --language=help

nb-compile
----------
The compile namespace provides commands that assist with compilation and cross-compilation commands for exploits.

Commands
--------
nb-compile-install               installs dependencies
nb-compile-searchsploit-nmap     use searchsploit with an nmap xml results file
nb-compile-gcc                   compile a linux exploit
nb-compile-gcc-32                compile a linux 32 exploit on 64
nb-compile-c-win32               cross compile a C win32 exploit
nb-compile-c-win64               cross compile a C wind64 exploit
nb-compile-c++-win32             cross compile a C++ win32 exploit
nb-compile-c++-win64             cross compile a C++ win64 exploit

DOC
}

nb-compile-install() {
    __info "Running $0..."
    __pkgs exploitdb mingw-w64 gcc gcc-multilib
}

nb-compile-searchsploit-nmap() {
    __check-project
    __ask "Select nmap xml scan results file"
    local f && __askpath f FILE ${__PROJECT}
    print -z "searchsploit -x --nmap ${f}"
}

nb-compile-compile-gcc() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "gcc -o ${out} ${src}"
}

nb-compile-compile-gcc-32() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "gcc -m32 -o ${out} ${src}"
}

nb-compile-compile-c-win32() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "i686-w64-mingw32-gcc ${src} -o ${out}"
}

nb-compile-compile-c-win64() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "x86_64-w64-mingw32-gcc ${src} -o ${out}"
}

nb-compile-compile-c++-win32() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "i686-w64-mingw32-g++ ${src} -o ${out}"
}

nb-compile-compile-c++-win64() {
    __check-project
    mkdir -p ${__PROJECT}/exploits
    local src && __askpath src SOURCE ${__PROJECT}/exploits
    local out && __askpath out OUTPUT ${__PROJECT}/exploits
    print -z "x86_64-w64-mingw32-g++ ${src} -o ${out}"
}

nb-compile-compile-notes-winsock() {
    __info "use -lws2_32"
}

nb-compile-compile-notes-static() {
    __info "-static-libstdc++"
    __info "-static-libgcc"
}
