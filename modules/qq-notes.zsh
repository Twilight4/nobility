#!/usr/bin/env zsh

############################################################# 
# qq-notes
#############################################################
qq-notes-help() {
    cat << "DOC"

qq-notes
-------
The notes namespace provides searching and reading of markdown notes that are
stored in a directory specified by the __NOTES environment variable (qq-vars-global).

Commands
--------
qq-notes-install     installs dependencies
qq-notes             lists all notes in $__NOTES or searches notes by filename if $1 is supplied
qq-notes-content     list all notes in $__NOTES or searches notes by content if $1 is supplied
qq-notes-menu        display an interactive menu for reading notes

DOC
}

qq-notes-install() {
    __info "Running $0..."
    __pkgs fzf ripgrep
    qq-install-bat
}

qq-notes() {
    __check-notes
    __info "Use \$1 to search file names"
    select note in $(\ls -R --file-type ${__NOTES} | grep -ie ".org$" | grep -i "$1")
    do test -n ${note} && break
    exit
    done
    #[[ ! -z ${note} ]] && glow ${__NOTES}/${note}
	[[ ! -z ${note} ]] && sed -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${__NOTES}/${note} | \bat --language=org --style=plain --color=always
}

qq-notes-content() {
    __check-notes
    __info "Use \$1 to search content"
    select note in $(grep -rliw "$1" ${__NOTES}/*.org)
    do test -n ${note} && break
    exit
    done
    [[ ! -z ${note} ]] && glow ${note}
}

qq-notes-menu() {
    __check-notes
    pushd ${__NOTES} &> /dev/null
    rg --no-heading --no-line-number --with-filename --color=always --sort path -m1 "" *.org | fzf --tac --no-sort -d ':' --ansi --preview-window wrap --preview 'bat --style=plain --color=always ${1}' --reverse --bind "ctrl-q:preview-down,alt-q:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up"
    popd &> /dev/null
}
