#!/usr/bin/env zsh

############################################################# 
# qq-notes
#############################################################
qq-notes-help() {
    cat << "DOC" | bat --plain --language=help

qq-notes
-------
The notes namespace provides searching and reading of org-mode notes that are
stored in a directory specified by the __NOTES environment variable (qq-vars-global).

Commands
--------
qq-notes-install     installs dependencies
qq-notes             select which note to output in $__NOTES or search by stage if argument is supplied
qq-notes-content     select which note to output in $__NOTES with searching by content
qq-notes-edit        list all notes in $__NOTES and edit selected note

DOC
}

qq-notes-install() {
    __info "Running $0..."
    __pkgs fzf ripgrep
    qq-install-bat
	
	if [ ! -d "$HOME/documents/org" ]; then
		git clone --depth 1 git@github.com:Twilight4/org.git ~/documents/org && echo "Repository cloned successfully."
	else
		echo "Repository already exists."
	fi
}

qq-notes() {
    __check-notes
	
	arg="$1"

    # Check if the argument is "ad"
    if [ "$arg" = "ad" ]; then
        # If "ad" is provided, go to active-directory
        pushd "${__NOTES}/active-directory" &> /dev/null
    elif [ "$arg" = "ad-en" ]; then
        pushd "${__NOTES}/active-directory/domain-enumeration" &> /dev/null
    elif [ "$arg" = "ad-ex" ]; then
        pushd "${__NOTES}/active-directory/exploitation" &> /dev/null
    elif [ "$arg" = "ad-pe" ]; then
        pushd "${__NOTES}/active-directory/post-exploitation" &> /dev/null
    elif [ "$arg" = "pen" ]; then
        # If "pen" is provided, go to network-pentest directory
        pushd "${__NOTES}/network-pentest" &> /dev/null
    elif [ "$arg" = "pen-en" ]; then
        pushd "${__NOTES}/network-pentest/enumeration" &> /dev/null
    elif [ "$arg" = "pen-ex" ]; then
        pushd "${__NOTES}/network-pentest/exploitation" &> /dev/null
    elif [ "$arg" = "pen-pe" ]; then
        pushd "${__NOTES}/network-pentest/post-exploitation" &> /dev/null
    elif [ "$arg" = "red" ]; then
        # If "red" is provided, go to red-team directory
        pushd "${__NOTES}/red-team" &> /dev/null
    elif [ "$arg" = "red-re" ]; then
        pushd "${__NOTES}/red-team/recon" &> /dev/null
    elif [ "$arg" = "red-we" ]; then
        pushd "${__NOTES}/red-team/weaponization" &> /dev/null
    elif [ "$arg" = "red-in" ]; then
        pushd "${__NOTES}/red-team/initial-access" &> /dev/null
    elif [ "$arg" = "red-pe" ]; then
        pushd "${__NOTES}/red-team/post-exploitation" &> /dev/null
    elif [ "$arg" = "red-ao" ]; then
        pushd "${__NOTES}/red-team/action-on-objectives" &> /dev/null
    else
        # Otherwise, go to the default notes directory
        pushd "${__NOTES}" &> /dev/null
    fi

	# don't do ls after cd
	export ENHANCD_HOOK_AFTER_CD=""

    # Shift the processed argument
    shift

	# select a directory of notes using fzf
	cd .

	# select with preview which note to output
	selected_file=$(find . -type f | fzf --query="$1" --no-multi --select-1 --exit-0 \
    --reverse --bind "ctrl-q:preview-down,alt-q:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up" --preview 'bat --language=org --style=numbers --color=always --line-range :500 {}')
  
	# if file selected, output it
	if [[ -n "$selected_file" ]]; then
		sed -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' "$file" | command bat --language=org --style=plain --color=always
	fi
	
	# return to directory
	popd &> /dev/null
}

qq-notes-content() {
    __check-notes

	# similar to frg funcction in fzf-scripts but just within the notes directory
    __info "Use \$1 to search content"
    select note in $(grep -rliw "$1" ${__NOTES}/*.org)
    do test -n ${note} && break
    exit
    done
	[[ ! -z ${note} ]] && sed -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${note} | command bat --language=org --style=plain --color=always
}

qq-notes-edit() {
    __check-notes
    pushd "${__NOTES}" &> /dev/null

    selected_file=$(rg --files-with-matches --no-heading --no-line-number --with-filename --sort path -g '*.org' -m1 "" | fzf --tac --no-sort -d ':' --ansi --preview-window wrap --preview 'bat --style=plain --language=org --color=always ${1}' --reverse --bind "ctrl-q:preview-down,alt-q:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up" | sed 's/.*\///')

    if [ -n "$selected_file" ]; then
        eval "$EDITOR" "$selected_file"
    fi

    popd &> /dev/null
}
