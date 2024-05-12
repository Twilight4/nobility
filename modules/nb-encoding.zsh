#!/usr/bin/env zsh

############################################################# 
# nb-encoding
#############################################################
nb-encoding-help() {
    cat << "DOC" | bat --plain --language=help

nb-encoding
----------
The encoding namespace provides commands for encoding and decoding values.

Commands
--------
nb-encoding-to-b64-powershell    copy powershell command to encode a file to base64
nb-encoding-to-b64               encodes plain text file to base64, optional $1 as file
nb-encoding-from-b64             decodes base64 file to plain text, optional $1 as file
nb-encoding-encrypt-aes256       encode and encrypt file with a password, using openssl and aes256 cipher
nb-encoding-decrypt-aes256       decode and decrypt aes256 password protected file using openssl
nb-encoding-encrypt-rsa          encode and encrypt file using rsa public key
nb-encoding-decrypt-rsa          decode and decrypt file using rsa private key 

DOC
}

nb-encoding-encrypt-rsa() {
  local filename && __askvar filename "FILENAME"

  # Prompt user for input
  echo "Do you want to generate a key pair? (Y/n)?"
  read choice
  
  # Convert input to lowercase for case-insensitivity
  choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]')
  
  # Check user input
  if [[ $choice == "y" || $choice == "yes" ]]; then
      echo
      __info "Generating key pair..."
      openssl genrsa -out pub_priv_pair.key 4096
      openssl rsa -in pub_priv_pair.key -pubout -out public_key.key
      __ok "Key pair generated successfully."
  elif [[ $choice == "n" || $choice == "no" ]]; then
      __info "No key pair generated."
  else
      __err "Invalid choice. No key pair generated."
  fi

  # Encrypt it with their public key
  echo
  __info "Encrypting the file with public RSA key..."
  __ok "Encrypted file saved as $filename.bin."
  openssl rsautl -encrypt -pubin -inkey public_key.key -in $filename -out $filename.bin -oaep

  # Encode it with base64
  echo
  __info "Encoding the file..."
  __ok "Encoded file saved as $filename-b64.txt"
  openssl base64 -in $filename.bin -out $filename-b64.txt

  echo
  __ok "The contents of base64 file copied to clipboard."
  __info "You can send the base64 plain text to someone:"
  cat $filename-b64.txt | wl-copy
  cat $filename-b64.txt
}

nb-encoding-decrypt-rsa() {
  local filename && __askvar filename "FILENAME"

  # Decode it
  echo
  __info "Decoding the file..."
  __ok "Decoded file saved as $filename.bin"
  openssl base64 -d -in $filename -out $filename.bin

  # Decrypt it
  echo
  __info "Decrypting the file with public RSA key..."
  __ok "Decrypted file saved as $filename-decrypted."
  openssl rsautl -decrypt -inkey pub_priv_pair.key -in $filename.bin -out $filename-decrypted -oaep
}

nb-encoding-encrypt-aes256() {
  local filename && __askvar filename "FILENAME"

  print -z "openssl enc -aes256 -iter 100000 -pbkdf2 -e -a -in $filename -out $filename-b64.txt"
}

nb-encoding-decrypt-aes256() {
  local filename && __askvar filename "FILENAME"

  print -z "openssl enc -d -aes256 -iter 100000 -a -pbkdf2 -in $filename-b64.txt -out $filename"
}

nb-encoding-to-b64-powershell() {
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND="[Convert]::ToBase64String((Get-Content -path "$path" -Encoding byte))"
  echo "$__COMMAND" | wl-copy

  __info "Command copied to clipboard"
}

nb-encoding-file-to-b64() {
    if [ "$#" -eq  "1" ]
    then
        print -z "cat $1 | base64 > $1.b64"
    else 
        local f && __askpath f FILE $(pwd)
        print -z "cat ${f} | base64 > ${f}.b64"
    fi
}

nb-encoding-file-from-b64() {
    if [ "$#" -eq  "1" ]
    then
        print -z "cat $1 | base64 -d > $1.txt"
    else 
        local f && __askpath f FILE $(pwd)
        print -z "cat ${f} | base64 -d > ${f}.txt"
    fi
}
