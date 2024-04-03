#!/usr/bin/env zsh

############################################################# 
# nb-project
#############################################################
nb-project-help() {
    cat << "DOC" | bat --plain --language=help

nb-project
-----------------
The nb-project namespace provides commands to setup project
directory structures and variables for users that have specific requirements.

Commands
--------
nb-project-start              create directory structure and logbook for new project
nb-project-end                zips and removes directories and data for new project

DOC
}

nb-project-start() {
    __check-project

    local cname && __askvar cname "COMPANY NAME"
    local fullpath=${__PROJECT}/${cname}

    # create dir structure
    mkdir -p ${fullpath}/{burp/{log,intruder,http-requests},client-supplied-info/emails,files/{downloads,uploads},notes/screenshots,scans/{raw,pretty},ssl,tool-output}
    
    # set project to be tool-output
    __PROJECT=${fullpath}/tool-output

    # wanted this to be an optional step, sometimes I'll create folders in advance due to calls with clients ahead of the test or prep work
    local setlog && read "setlog?$fg[cyan]Add a log file for this project (y/n)?:$reset_color "
    case "$setlog" in 
        y|Y ) 
            nb-log-set
            ;;
        n|N ) 
            echo ""
            ;;
        * ) 
            echo ""
            ;;
    esac   
# Move to the project directory
    cd "$fullpath"

    echo "Project '$proj_name' created with assessment type '$assessment_type'."
}

nb-project-end() {
    __check-project

    __ask "Select a project folder: "
    local pd=$(__menu $(find $__PROJECT -mindepth 1 -maxdepth 1 -type d))
    __ok "Selected: ${pd}"


    # Task 1: delete all empty folders
    local df && read "df?$fg[cyan]Delete empty folders? (Y/n)?:$reset_color "
    if [[ "$df" =~ ^[Yy]$ ]]
    then
        find ${pd} -type d -empty -delete 
        __ok "Empty folders deleted."
    fi

    # Task 2: create tree
    cd ${pd}
    tree -C -F -H ./ > ${pd}/tree.html 
    [[ -f "${pd}/tree.html" ]] && __ok "Created ${pd}/tree.html." || __err "Failed creating ${pd}/tree.html"
    cd - > /dev/null 2>&1

    # Task 3: zip up engagement folder
    local zf=$(basename ${pd})
    7z a -t7z -m0=lzma2 -mx=9 -mfb=64 -md=1024m -ms=on ${__PROJECT}/${zf}.7z ${pd} > /dev/null 2>&1
    [[ -f ${__PROJECT}/${zf}.7z ]] && __ok "Zipped files into ${__PROJECT}/${zf}.7z." || __err "Failed to zip ${pd}"

    # Task 4: Delete engagement folder
    local rmp && read "rmp?$fg[cyan]Delete project folder? (Y/n)?:$reset_color "
    if [[ "${rmp}" =~ ^[Yy]$ ]] && print -z "rm -rf ${pd}"

    __ok "Project ended."
}
