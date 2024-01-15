#!/usr/bin/env zsh

############################################################# 
# nb-log
#############################################################
nb-log-help() {
    cat << "DOC" | bat --plain --language=help

nb-log
-------------
The log namespace provides commands that create a logbook in
a directory specified by the __LOGBOOK variable.

Commands
--------
nb-log            ask user for an log entry in the logbook
nb-log-set        creates or uses existing logbook.org in the path specified
nb-log-cat        cats the logbook
nb-log-edit       edits the logbook using $EDITOR
nb-log-clear      deletes the logbook
nb-log-scan       pastes from clipboard to an entry in the logbook in code format (uses wl-clipboard)
nb-log-full       asks for full detailed logs for an entry

DOC
}

nb-log-set() {
    nb-vars-set-logbook
}

nb-log-cat() {
    __check-logbook
    __info "${__LOGBOOK}"
	sed -e 's/^\* .*$/\x1b[94m&\x1b[0m/' -e 's/^\*\*.*$/\x1b[96m&\x1b[0m/' -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${__LOGBOOK} | command bat --language=org --style=plain --color=always
}

nb-log-edit() {
    __check-logbook
    eval $EDITOR ${__LOGBOOK}
}

nb-log-clear() {
    __check-logbook
    rm -v -i ${__LOGBOOK}
}

nb-log() {
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')
    echo " " >> ${__LOGBOOK}
    echo "*** ${stamp}" >> ${__LOGBOOK}

    __ask "Enter description for the log entry (press Enter to skip)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
        echo "Description: =$description=" >> ${__LOGBOOK}
    else
        __warn "No description provided." >> ${__LOGBOOK}
    fi

    __info "Log entry added to ${__LOGBOOK}"
}

nb-log-scan() {
    __check-logbook

    local stamp=$(date +'%A %d-%m-%Y : %T %Z')
    echo " " >> ${__LOGBOOK}
	echo "*** ${stamp}" >> ${__LOGBOOK}
    echo "#+begin_src bash" >> ${__LOGBOOK}
	echo "$(wl-paste)" >> ${__LOGBOOK}
    #echo "$@" >> ${__LOGBOOK}
	echo "#+end_src" >> ${__LOGBOOK}
}

nb-log-full() {
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')
    echo " " >> ${__LOGBOOK}
    echo "*** ${stamp}" >> ${__LOGBOOK}

	__ask "Enter server IP (press Enter to skip)"
	local server_ip && __askvar server_ip SERVER_IP

    if [[ -n "$server_ip" ]]; then
        # Log the information to the logbook.org file
        echo "Server IP: =$server_ip=" >> ${__LOGBOOK}
        __info "Server information logged to ${__LOGBOOK}"
		echo " "
    else
		echo " "
        __warn "No server IP provided. Skipping log entry."
		return
    fi

    __ask "Enter description for the log entry (press Enter to skip)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
        echo "Description: =$description=" >> ${__LOGBOOK}
    else
        __warn "No description provided." >> ${__LOGBOOK}
    fi

    __info "Log entry added to ${__LOGBOOK}"
}
