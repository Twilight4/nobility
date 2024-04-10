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
nb-crack-hashcat          crack password hash using hashcat with providing hash format
nb-crack-john             john alternative with hash format detection (use this if you don't know the hash format format)
nb-crack-john-passwd      convert linux password files to john-readable format (/etc/passwd and /etc/shadow files)
nb-crack-john-zip         crack a password protected zip archive
nb-crack-john-rar         crack a password protected rar archive
nb-crack-john-ssh         crack ssh key passwords

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
      __warn "Hash type not recognized. Enter hashcat type for the hash mode:"
	  __ask "  hashcat --help | grep <HASH_TYPE>"
      local md && __askvar md "HASHCAT MODE"
  fi

  echo
  print -z "hashcat -a 0 -m $md ${__HASH} ${__PASSLIST}"
}

nb-crack-john() {
	__ask "Enter the hash"
	__check-hash
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  print -z "john --wordlist=${__PASSLIST} --stdout ${__HASH}"
}

nb-crack-john-passwd() {
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  print -z "unshadow <PATH_TO_PASSWD> <PATH_TO_SHADOW> > unshadowed.txt"
  print -z "john --wordlist=${__PASSLIST} unshadowed.txt"
}

nb-crack-john-zip() {
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  __ask "Set the full path to the zip file."
  local d=$(__askpath DIR $PJ/)
  [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return

  print -z "zip2john $d > zip_hash.txt"
  print -z "john --wordlist=${__PASSLIST} zip_hash.txt"
}

nb-crack-john-rar() {
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  __ask "Set the full path to the rar file."
  local d=$(__askpath DIR $PJ/)
  [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return

  print -z "rar2john $d > rar_hash.txt"
  print -z "john --wordlist=${__PASSLIST} rar_hash.txt"
}

nb-crack-john-ssh() {
	__ask "Enter a password wordlist"
	nb-vars-set-passlist

  __ask "Set the full path to the id_rsa file."
  local d=$(__askpath DIR $PJ/)
  [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return

  print -z "ssh2john $d > id_rsa_hash.txt"
  print -z "john --wordlist=${__PASSLIST} id_rsa_hash.txt"
}
