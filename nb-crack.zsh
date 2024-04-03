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
nb-crack-
nb-crack-

DOC
}

nb-crack-hash() {

  cd downloads
  echo '${hs}' > hash.txt
  hashid $hs
  hashcat -a 0 -m 0 hash.txt /usr/share/wordlists/rockyou.txt
}
