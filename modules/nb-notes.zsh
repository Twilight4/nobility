#!/usr/bin/env zsh

############################################################# 
# nb-notes
#############################################################
nb-notes-help() {
    cat << "DOC" | bat --plain --language=help

nb-notes
-------
The notes namespace provides searching and reading of org-mode notes that are
stored in a directory specified by the __NOTES environment variable (nb-vars-global).

Commands
--------
nb-notes-install     installs dependencies
nb-notes             select directory to enter in $__NOTES
nb-notes-cat         select note to output
nb-notes-content     select note to output with searching by content
nb-notes-edit        select note to edit

DOC
}

nb-notes-install() {
    __info "Running $0..."
    __pkgs fzf ripgrep
	
	if [ ! -d "$HOME/documents/org" ]; then
		git clone --depth 1 git@github.com:Twilight4/org.git ~/documents/org && echo "Repository cloned successfully."
	else
		echo "Repository already exists."
	fi
}

nb-notes() {
    __check-notes
    pushd "${__NOTES}" &> /dev/null

        # Use fzf to select a directory from the first layer
        selected_directory=$(find . -maxdepth 1 -type d -not -name "." | sed 's|^\./||' | fzf --select-1 --exit-0 \
        --reverse --preview 'exa --tree --group-directories-first --git-ignore --level 2 {}')

        # If a directory is selected, change to it
        if [ -n "$selected_directory" ]; then
            pushd "$selected_directory" &> /dev/null
        else
            echo "No directory selected. Returning to the default notes directory."
            popd &> /dev/null
            return
        fi
    fi

	# don't do ls after cd
	#export ENHANCD_HOOK_AFTER_CD=""

	# return to directory
	popd &> /dev/null
}

nb-notes-cat() {
    __check-notes
    pushd "${__NOTES}" &> /dev/null

	# select with preview which note to output
	selected_file=$(find . -type f | fzf --query="$1" --no-multi --select-1 --exit-0 \
    --reverse --bind "ctrl-q:preview-down,alt-q:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up" --preview 'bat --language=org --style=numbers --color=always --line-range :500 {}')
  
	# if file selected, output it
	if [[ -n "$selected_file" ]]; then
		sed -e 's/^\* .*$/\x1b[94m&\x1b[0m/' -e 's/^\*\*.*$/\x1b[96m&\x1b[0m/' -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' "$selected_file" | command bat --language=org --style=plain --color=always
	fi

	# return to directory
	popd &> /dev/null
}

nb-notes-content() {
    __check-notes
    pushd "${__NOTES}" &> /dev/null

    # select by content which note to output
	if [ ! "$#" -gt 0 ]; then return 1; fi
	selected_file=$(rg --files-with-matches --no-messages "$1" \
    | fzf --preview "highlight -O ansi -l {} 2> /dev/null \
    | rg --colors 'match:bg:yellow' --ignore-case --pretty --context 10 '$1' \
    || rg --ignore-case --pretty --context 10 '$1' {}")

	# if file selected, output it
	if [[ -n "$selected_file" ]]; then
		sed -e 's/^\* .*$/\x1b[94m&\x1b[0m/' -e 's/^\*\*.*$/\x1b[96m&\x1b[0m/' -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' "$selected_file" | command bat --language=org --style=plain --color=always
	fi

	popd &> /dev/null
}

nb-notes-edit() {
    __check-notes
    pushd "${__NOTES}" &> /dev/null

    selected_file=$(rg --files-with-matches --no-heading --no-line-number --with-filename --sort path -g '*.org' -m1 "" | fzf --tac --no-sort -d ':' --ansi --preview-window wrap --preview 'bat --style=plain --language=org --color=always ${1}' --reverse --bind "ctrl-q:preview-down,alt-q:preview-up,ctrl-f:preview-page-down,ctrl-b:preview-page-up" | sed 's/.*\///')

    if [ -n "$selected_file" ]; then
        eval "$EDITOR" "$selected_file"
    fi

    popd &> /dev/null
}
