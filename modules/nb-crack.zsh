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
nb-crack-hashcat          crack password hash using hashcat with provided hash format
nb-crack-hashcat-list     crack password from provided hashlist
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

  # use hashid for hash identification
  # Capture the output of hashid command and extract the third line
  #ht=$(hashid ${__HASH} | awk 'NR==15{print $2}')
  #if [ $? -eq 0 ]; then
  #  __info "Hash type: $ht"
  #fi


# use hash-identifier for hash identification
# Create an expect script to interact with hash-identifier
expect << EOF > output.txt
spawn hash-identifier
expect " HASH: "
send "${__HASH}\r"
expect {
    "Possible Hashs:" {
        send_user "\nHash type identified\n"
    }
}
expect " HASH: "
send "exit\r"
expect eof
EOF

# Filter and save the relevant hash type information
ht=$(awk '/Possible Hashs:/ {getline; print $2}' output.txt)

# Check if hash type was identified
if [ -z "$ht" ]; then
  __err "Could not identify hash type"
  exit 1
fi

# Use the identified hash type with hashcat
__info "Hash type: $ht"

  # Determine hash mode based on hash type
  if [[ $ht == *"MD5"* ]]; then
      md=0
  elif [[ $ht == *"SHA-1"* ]]; then
      md=100
  elif [[ $ht == *"NTLM"* ]]; then
      md=1000
  elif [[ $ht == *"sha512crypt $6$, SHA512 (Unix)"* ]]; then
      md=1800
  elif [[ $ht == *"bcrypt $2*$, Blowfish (Unix)"* ]]; then
      md=3200
  elif [[ $ht == *"NTLMv1"* ]]; then
      md=5500
  elif [[ $ht == *"NTLMv2"* ]]; then
      md=5600
  elif [[ $ht == *"Kerberos 5 TGS-REP etype 23"* ]]; then
      md=13100
  elif [[ $ht == *"Kerberos 5, etype 23, AS-REP"* ]]; then
      md=18200
  else
      __warn "Hash type not recognized. Enter hashcat type for the hash mode:"
      __ask "  hashcat --help | grep <HASH_TYPE>"
      echo
      local md && __askvar md "HASHCAT MODE"
  fi

  echo
  print -z "hashcat -O -a 0 -m $md ${__HASH} ${__PASSLIST} -o $(__netpath)/hashcat-cracked.txt"
}

nb-crack-hashcat-list() {
  __check-project
	__ask "Enter the hashlist"
  local hs && __askpath hs "HASHLIST" $HOME/desktop/projects/

  __ask "Enter hashcat type for the hash mode:"
  local md && __askvar md "HASHCAT MODE"

  print -z "hashcat -O -a 0 -m $md ${hs} ${__PASSLIST} -o $(__netpath)/hashcat-cracked.txt"
}

nb-crack-john() {
  __check-project
	__ask "Enter the hash"
	__check-hash

  print -z "john --wordlist=${__PASSLIST} --stdout ${__HASH} -o $(__netpath)/john-cracked.txt"
}

nb-crack-john-passwd() {
  __check-project

  # Prompt the user for the full path to the file
  __ask "Set the full path to the passwd file."
  local d && __askpath d "PATH_TO_FILE" $PJ/

  # Prompt the user for the full path to the file
  __ask "Set the full path to the shadow file."
  local p && __askpath p "PATH_TO_FILE" $PJ/

  # Check if the path contains the tilde character
  if [[ "$d" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the path contains the tilde character
  if [[ "$p" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the rar file exists
  if [[ -f "$d" ]]; then
    __info "Generating the unshadowed file file using unshadow..."
    unshadow $d $p > unshadowed.txt
    __ok "Generated the unshadowed.txt file."

    # Run John the Ripper with the provided wordlist on the generated hash
    echo
    print -z "hashcat -O -m 1800 -a 0 unshadowed.txt ${__PASSLIST} -o unshadowed.cracked"
  else
    __err "File does not exist: $d and $p. Exiting."
    return
  fi
}

nb-crack-john-zip() {
  __check-project

  # Prompt the user for the full path to the zip file
  __ask "Set the full path to the zip file."
  local d && __askpath d "PATH_TO_FILE" $PJ/

  # Check if the path contains the tilde character
  if [[ "$d" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the zip file exists
  if [[ -f "$d" ]]; then
    __info "Generating the has of the zip file using zip2john..."
    zip2john $d > zip_hash.txt
    __ok "Generated the hash of the zip file as zip_hash.txt"

    # Run John the Ripper with the provided wordlist on the generated hash
    __info "To show the cracked hash use: john zip_hash.txt --show"
    print -z "john --wordlist=${__PASSLIST} zip_hash.txt"
  else
    __err "File does not exist: $d. Exiting."
    return
  fi
}

nb-crack-john-rar() {
  __check-project

  # Prompt the user for the full path to the file
  __ask "Set the full path to the rar file."
  local d && __askpath d "PATH_TO_FILE" $PJ/

  # Check if the path contains the tilde character
  if [[ "$d" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the rar file exists
  if [[ -f "$d" ]]; then
    __info "Generating the has of the file using rar2john..."
    rar2john $d > rar_hash.txt
    __ok "Generated the hash of the file as rar_hash.txt"

    # Run John the Ripper with the provided wordlist on the generated hash
    __info "To show the cracked hash use: john rar_hash.txt --show"
    print -z "john --wordlist=${__PASSLIST} rar_hash.txt"
  else
    __err "File does not exist: $d. Exiting."
    return
  fi
}

nb-crack-john-ssh() {
  __check-project

  __ask "Set the full path to the PRIVATE id_rsa file."
  local d && __askpath d "PATH_TO_FILE" $PJ/

  # Check if the path contains the tilde character
  if [[ "$d" == "~"* ]]; then
    __err "~ not allowed, use the full path"
    return
  fi

  # Check if the rar file exists
  if [[ -f "$d" ]]; then
    __info "Generating the hash of the rsa file using ssh2john..."
    ssh2john $d > id_rsa_hash.txt
    __ok "Generated the hash of the rsa file as id_rsa_hash.txt"

    # Run John the Ripper with the provided wordlist on the generated hash
    echo
    __info "To show the cracked hash use: john id_rsa_hash.txt --show"
    print -z "john --wordlist=${__PASSLIST} id_rsa_hash.txt"
  else
    __err "File does not exist: $d. Exiting."
    return
  fi
}
