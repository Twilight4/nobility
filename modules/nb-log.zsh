#!/usr/bin/env zsh

############################################################# 
# nb-log
#############################################################
nb-log-help() {
    cat << "DOC" | bat --plain --language=help

nb-log
-------------
The log namespace provides commands that create a logbook in
a directory specified by the __LOGBOOK variable. Use nb-log to append entries
to the logbook. Display the log with nb-log-cat. Edit the log
with nb-log-edit.

Commands
--------
nb-log              alias ql, appends $@ to an entry in the logbook
nb-log-cat          alias qlc, cats the logbook
nb-log-edit         alias qle, edits the logbook using $EDITOR
nb-log-set          creates or uses existing logbook.org in the path specified

DOC
}

nb-log-set() {
    nb-vars-set-logbook
}
alias qls="nb-log-set"

nb-log-cat() {
    __check-logbook
    __info "${__LOGBOOK}"
    sed -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${__LOGBOOK} | command bat --language=org --style=plain --color=always
}
alias qlc="nb-log-cat"

nb-log-edit() {
    __check-logbook
    $EDITOR ${__LOGBOOK}
}
alias qle="nb-log-edit"

nb-log() {
    __check-logbook

    local stamp=$(date +'%m-%d-%Y : %r')
    echo "## ${stamp}" >> ${__LOGBOOK}
    echo "\`\`\`" >> ${__LOGBOOK}
    echo "$@" >> ${__LOGBOOK}
    echo "\`\`\`" >> ${__LOGBOOK}
    echo " " >> ${__LOGBOOK}

}
alias ql="nb-log"
