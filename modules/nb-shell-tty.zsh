#!/usr/bin/env zsh

############################################################# 
# nb-shell-tty
#############################################################
nb-shell-tty-help() {
    cat << "DOC" | bat --plain --language=help

nb-shell-tty
------------
The shell-tty namespace provides commands for fixing interactive command/reverse shells.

Commands
--------
nb-shell-tty-python2     command to spawn a tty shell
nb-shell-tty-python3     command to spawn a tty shell     
nb-shell-tty-perl        command to spawn a tty shell
nb-shell-tty-ruby        command to spawn a tty shell
nb-shell-tty-lua         command to spawn a tty shell
nb-shell-tty-expect      command to spawn a tty shell

DOC
}

nb-shell-tty-python2() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

python -c 'import pty;pty.spawn("/bin/sh")' 

DOC
}

nb-shell-tty-python3() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

python3 -c 'import pty;pty.spawn("/bin/sh")'

DOC
}

nb-shell-tty-perl() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

perl -e 'exec "/bin/sh";'

DOC
}

nb-shell-tty-ruby() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

ruby: exec "/bin/sh"

DOC
}

nb-shell-tty-lua() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

lua: os.execute('/bin/sh')

DOC
}

nb-shell-tty-expect() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 

/usr/bin/expect sh

DOC
}
