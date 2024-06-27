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
nb-wep-pass-cupp                use cupp to generate custom profiled passwords
nb-wep-pass-rule                use hashcat rules to generated rule-based wordlist 
nb-wep-pass-policy              tailor the wordlist according to the password policy

Username Profiling
------------------------
nb-wep-user-anarchy             use username-anarchy to create common username permutations based on the full names 
nb-wep-user-generator           use username_generator.py to create common username permutations based on the full names 
nb-wep-user-l2username          use linkedin2username to create common username permutations based on the full names 

DOC
}

nb-wep-install() {
    __info "Running $0..."
    nb-install-username-anarchy
    nb-install-username-generator
}

nb-wep-pass-rule() {
    __check-project

    __info "To list available rules for hashcat run command:"
    __ok "ls /usr/share/hashcat/rules/"

    __ask "Provide filename with list of potential passwords"
    local filename && __askpath filename "FILENAME"

    __ask "Enter password rule for mutation"
    local rule && __askvar rule "RULE"

    print -z "hashcat --force $filename -r $rule --stdout | sort -u > mut_password.list"
}

nb-wep-user-anarchy() {
    __check-project

    __ask "Provide filename with list of potential names"
    local filename && __askpath filename "FILENAME"
    
    print -z "/opt/username-anarchy/username-anarchy --input-file $filename --select-format first,flast,first.last,firstl > unames.txt"
}

nb-wep-user-generator() {
    __check-project

    __ask "Provide filename with list of potential names"
    local filename && __askpath filename "FILENAME"
    
    print -z "python3 /opt/username_generator/username_generator.py -w $filename > gen-users.txt"
}

nb-wep-pass-cupp() {
    __check-project

    print -z "cupp -i"
}

nb-wep-pass-policy() {
    __check-project

    __ask "Remove shorter than:"
    local n && __askvar n "NUMBER"

    __ask "Remove no special chars?"
    local ans && __askvar ans "ANSWER"

    __ask "Remove no special chars?"
    local nn && __askvar nn "ANSWER"

    # remove shorter than 8
    #sed -ri '/^.{,7}$/d' $filename

    # remove no special chars
    #sed -ri '/[!-/:-@\[-`\{-~]+/!d' $filename

    # remove no numbers
    #sed -ri '/[0-9]+/!d' $filename
}
