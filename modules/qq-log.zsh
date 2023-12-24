#!/usr/bin/env zsh

############################################################# 
# qq-log
#############################################################
qq-log-help() {
    cat << "DOC"

qq-log
-------------
The log namespace provides commands that create a logbook in
a directory specified by the __LOGBOOK variable. Use qq-log to append entries
to the logbook. Display the log with qq-log-cat. Edit the log
with qq-log-edit.

Commands
--------
qq-log              alias ql, appends $@ to an entry in the logbook
qq-log-cat          alias qlc, cats the logbook
qq-log-edit         alias qle, edits the logbook using $EDITOR
qq-log-set          creates or uses existing logbook.org in the path specified

DOC
}

qq-log-set() {
    qq-vars-set-logbook
}
alias qls="qq-log-set"

qq-log-cat() {
    __check-logbook
    __info "${__LOGBOOK}"
    sed -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${__LOGBOOK} | command bat --language=org --style=plain --color=always
}
alias qlc="qq-log-cat"

qq-log-edit() {
    __check-logbook
    $EDITOR ${__LOGBOOK}
}
alias qle="qq-log-edit"

qq-log() {
    __check-logbook

    local stamp=$(date +'%m-%d-%Y : %r')
    echo "## ${stamp}" >> ${__LOGBOOK}
    echo "\`\`\`" >> ${__LOGBOOK}
    echo "$@" >> ${__LOGBOOK}
    echo "\`\`\`" >> ${__LOGBOOK}
    echo " " >> ${__LOGBOOK}

}
alias ql="qq-log"
