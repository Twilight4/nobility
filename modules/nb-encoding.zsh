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
nb-encrypt-aes256                encrypt file with a password, using openssl and aes256 cipher
nb-decrypt-aes256                decrypt aes256 password protected file using openssl

DOC
}

nb-encrypt-openssl() {
  local filename && __askvar filename "FILENAME"

  print -z "openssl enc -aes256 -iter 100000 -pbkdf2 -in $filename -out $filename.enc"
}

nb-decrypt-aes256() {
  local filename && __askvar filename "FILENAME"

  print -z "openssl enc -d -aes256 -iter 100000 -pbkdf2 -in $filename.enc -out $filename"
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
