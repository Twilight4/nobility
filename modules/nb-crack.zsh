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
nb-crack-hashcat-hashlist crack password from provided hashlist using hashcat with format auto-detection
nb-crack-john             john alternative with hash format detection (use this if you don't know the hash format format)
nb-crack-john-passwd      convert linux password files to john-readable format (/etc/passwd and /etc/shadow files)
nb-crack-john-zip         crack a password protected zip archive
nb-crack-john-rar         crack a password protected rar archive
nb-crack-john-ssh         crack ssh key passwords

DOC
}

nb-crack-hashcat() {
  __check-project
	__ask "Enter the hash"
	__check-hash
	#__ask "Enter a password wordlist"
	#nb-vars-set-passlist             # use the default one that is set in nb-vars.zsh

  # Capture the output of hashid command and extract the third line
  ht=$(hashid ${__HASH} | awk 'NR==15{print $2}')
  if [ $? -eq 0 ]; then
    __info "Hash type: $ht"
  fi

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
  elif [[ $ht == *"Kerberos 5"* ]]; then
      md=13100
  # This one is for hashes from performing asreproasting attack
  #elif [[ $ht == *"Kerberos 5, etype 23, AS-REP"* ]]; then
  #    md=18200
  else
      # Add more conditions for other hash types as needed
      __warn "Hash type not recognized. Enter hashcat type for the hash mode:"
      __ask "  hashcat --help | grep <HASH_TYPE>"
      echo
      local md && __askvar md "HASHCAT MODE"
  fi

  echo
  print -z "hashcat -O -a 0 -m $md ${__HASH} ${__PASSLIST} | tee $(__netpath)/hashcat"
}

nb-crack-hashcat-hashlist() {
  __check-project
	__ask "Enter the hashlist"
  local hs && __askvar hs "HASHLIST"

	#__ask "Enter a password wordlist"
	#nb-vars-set-passlist             # use the default one that is set in nb-vars.zsh

  echo
  print -z "hashcat -O -a 0 ${hs} ${__PASSLIST} | tee $(__netpath)/hashcat"
}

nb-crack-john() {
  __check-project
	__ask "Enter the hash"
	__check-hash

  print -z "john --wordlist=${__PASSLIST} --stdout ${__HASH} | tee $(__netpath)/john"
}

nb-crack-john-passwd() {
  __check-project

  print -z "unshadow <PATH_TO_PASSWD> <PATH_TO_SHADOW> > unshadowed.txt"
  print -z "john --wordlist=${__PASSLIST} unshadowed.txt"
}

nb-crack-john-zip() {
  __check-project

  # Prompt the user for the full path to the zip file
  __ask "Set the full path to the zip file."
  local d=$(__askpath DIR $PJ/)

  # Check if the path contains the tilde character
  if [[ "$d" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the zip file exists
  if [[ -f "$d" ]]; then
    # Generate the hash of the zip file using zip2john
    zip2john $d > zip_hash.txt

    # Run John the Ripper with the provided wordlist on the generated hash
    print -z "john --wordlist=${__PASSLIST} zip_hash.txt"
  else
    __err "File does not exist: $d"
    return
  fi
}

nb-crack-john-rar() {
  __check-project

  __ask "Set the full path to the rar file."
  local d=$(__askpath DIR $PJ/)
  [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return

  print -z "rar2john $d > rar_hash.txt"
  print -z "john --wordlist=${__PASSLIST} rar_hash.txt"
}

nb-crack-john-ssh() {
  __check-project

  __ask "Set the full path to the id_rsa file."
  local d=$(__askpath DIR $PJ/)
  [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return

  print -z "ssh2john $d > id_rsa_hash.txt"
  print -z "john --wordlist=${__PASSLIST} id_rsa_hash.txt"
}
