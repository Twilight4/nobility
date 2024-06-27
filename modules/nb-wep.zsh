#!/usr/bin/env zsh

############################################################# 
# nb-wep
#############################################################
nb-wep-help() {
    cat << "DOC" | bat --plain --language=help

nb-wep
-------
The wep namespace provides commands for weaponization/target profiling such as custom password and user lists permutations.

Password Profiling
------------------------
nb-wep-pass-cewl
nb-wep-pass-pwdology
nb-wep-pass-cupp

Username Profiling
------------------------
nb-wep-user-anarchy       use username-anarchy to create common username permutations based on the full names 
nb-wep-user-generator     use username_generator.py to create common username permutations based on the full names 
nb-wep-user-l2username    use linkedin2username to create common username permutations based on the full names 

Commands
------------------------
# password rules
# password policy

DOC
}

nb-wep-install() {
    __info "Running $0..."
    nb-install-username-anarchy
    nb-install-username-generator
}

nb-wep-user-anarchy() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __ask "Provide filename with list of potential names"
    local filename && __askpath filename "FILENAME"
    
    print -z "/opt/username-anarchy/username-anarchy --input-file $filename --select-format first,flast,first.last,firstl > unames.txt"
}
