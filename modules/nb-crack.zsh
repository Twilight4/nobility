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
nb-crack-hashcat          hashcat usage to crack hash
nb-crack-john             john usage to crack hash

DOC
}

nb-crack-hashcat() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  # Capture the output of hashid command and extract the third line
  ht=$(hashid ${__HASH} | awk 'NR==3{print $2}')
  __info "Hash type: $ht"

  # Determine hash mode based on hash type
  if [[ $ht == *"MD5"* ]]; then
      md=0
  elif [[ $ht == *"SHA-1"* ]]; then
      md=100
  elif [[ $ht == *"SHA-256"* ]]; then
      md=1400
  elif [[ $ht == *"NTLM"* ]]; then
      md=1000
  elif [[ $ht == *"LM"* ]]; then
      md=3000
  elif [[ $ht == *"NTLMv1"* ]]; then
      md=5500
  elif [[ $ht == *"NTLMv2"* ]]; then
      md=5600
  elif [[ $ht == *"MS-Cache"* ]]; then
      md=11000
  elif [[ $ht == *"DCC"* ]]; then
      md=2100
  elif [[ $ht == *"WPA"* ]]; then
      md=2500
  # Add more conditions for other hash types as needed
  else
      __warn "Hash type not recognized. Enter hashcat mode for the hash type."
      local md && __askvar md "HASHCAT MODE"
  fi

  echo
  print -z "hashcat -a 0 -m $md ${__HASH} ${__PASSLIST}"
}
