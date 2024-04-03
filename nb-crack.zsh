#!/usr/bin/env zsh

############################################################# 
# nb-crack
#############################################################
nb-crack-help() {
    cat << "DOC" | bat --plain --language=help

nb-crack
----------
The crack namespace provides commands for crackign password hashes.

Commands
--------
nb-crack-hash-classic          Classic hashcat usage to crack a hash

DOC
}

nb-crack-hash() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  # Capture the output of hashid command and extract the third line
  ht=$(hashid ${__HASH} | awk 'NR==3{print $2}')
  __info "Hash type: $ht"

  hashcat --help | grep $ht

  echo
  print -z "hashcat -a 0 -m $md ${__HASH} ${__PASSLIST}"
}
