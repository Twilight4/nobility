#!/usr/bin/env zsh

############################################################# 
# nb-wep
#############################################################
nb-wep-help() {
    cat << "DOC" | bat --plain --language=help

nb-wep
-------
The wep namespace provides commands for weaponization/target profiling such as custom password and wordlists permutations.

Password Profiling
------------------
nb-wep-pwd-tools                show available interactive password wordlist generator tools from the list and run selected one
nb-wep-pass-rule                use hashcat rules to generated rule-based wordlist 
nb-wep-pass-policy              tailor the wordlist according to the password policy

Username Profiling
------------------
nb-wep-se-tools                 show available social engineering tools from the list and run selected one
nb-wep-user-anarchy             use username-anarchy to create common username permutations based on the full names 
nb-wep-user-generator           use username_generator.py to create common username permutations based on the full names 
nb-wep-user-l2username          use linkedin2username to create common username permutations based on the full names 

DOC
}

nb-wep-install() {
    __info "Running $0..."
    __pkgs hashcat cupp seeker blackeye ngrok set
}

nb-wep-user-l2username() {
    __check-project

    print -z "linkedin2username.py -c COMPANY [-n DOMAIN] [-d DEPTH] [-s SLEEP] [-k KEYWORDS] [-g] [-o OUTPUT]"
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

nb-wep-se-tools() {
    __check-project

    __ask "Available tools"
    echo "1) Storm-Breaker - Access Webcam & Microphone & Location Finder"
    echo "2) Seeker - Accurately Locate Smartphones using Social Engineering"
    echo "3) Zphisher - Phishing tool with 30+ templates"
    echo "4) Blackeye - Another Skiddie phishing tool"
    echo "5) SET - Social Engineering Toolkit"
    echo "6) Socialfish - Phishing Tool & Information Collector "
    echo
    local choice && __askvar choice "CHOICE"

    case $choice in
        1) 
          # Check if tool is installed
          if ! which /opt/Storm-Breaker/st.py > /dev/null; then
            __err "Storm-Breaker is not installed. Install with: nb-install-stormbreaker"
            exit 1
          fi

          # Run the tool
          pushd "${__TOOLS}/Storm-Breaker" &> /dev/null
          sudo python3 st.py
          popd &> /dev/null
          ;;
        2) 
          # Check if tool is installed
          if ! which seeker > /dev/null; then
            __err "Seeker is not installed."
            exit 1
          fi

          # Run the tool
          clear
          sudo seeker
          ;;
        3) 
          # Check if tool is installed
          if ! which zphisher > /dev/null; then
            __err "Zphisher is not installed. Install with: nb-install-zphisher."
          fi

          # Run the tool
          clear
          zphisher
          ;;
        4) 
          # Check if tool is installed
          if ! which blackeye > /dev/null; then
            __err "Blackeye is not installed."
          fi

          # Run the tool
          clear
          blackeye
          ;;
        5) 
          # Check if tool is installed
          if ! which setoolkit > /dev/null; then
            __err "Set is not installed."
          fi

          # Run the tool
          clear
          sudo setoolkit
          ;;
        6)
          # Check if tools is installed
          if ! which socialfish > /dev/null; then
            __err "Socialfish is not installed."
          fi

          # Run the tool
          clear
          nb-vars-set-user
          nb-vars-set-pass
          socialfish ${__USER} ${__PASS}
        *) 
          __err "Invalid selection"; return ;;
    esac
}

nb-wep-pwd-tools() {
    __check-project

    __ask "Available tools"
    echo "1) Pwdology - A victims-profile-based wordlist generating tool for social engineers and security researchers"
    echo "2) Cupp - use cupp to generate custom profiled passwords"
    echo
    local choice && __askvar choice "CHOICE"

    case $choice in
        1) 
          # Check if tool is installed
          if ! which pwdology > /dev/null; then
            __err "Pwdology is not installed."
            exit 1
          fi

          # Run the tool
          clear
          pwdlogy
          ;;
        2) 
          # Check if tool is installed
          if ! which cupp > /dev/null; then
            __err "Cupp is not installed."
            exit 1
          fi

          # Run the tool
          clear
          cupp -i
          ;;
        *) 
          __err "Invalid selection"; return ;;
    esac
}
