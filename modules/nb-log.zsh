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
nb-log            appends $@ to an entry in the logbook
nb-log-set        creates or uses existing logbook.org in the path specified
nb-log-cat        cats the logbook
nb-log-edit       edits the logbook using $EDITOR
nb-log-edit       deletes the logbook

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

    local stamp=$(date +'%A %d-%m-%Y : %T %Z')
    echo " " >> ${__LOGBOOK}
    echo "*** ${stamp}" >> ${__LOGBOOK}
    echo "- =$@=" >> ${__LOGBOOK}
}
