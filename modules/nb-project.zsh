#!/usr/bin/env zsh

############################################################# 
# nb-project
#############################################################
nb-project-help() {
    cat << "DOC" | bat --plain --language=help

nb-project
----------
The nb-project namespace provides commands to setup scope for an engagement, directory structures
as well as commands for syncing data and managing a VPS.

Commands
--------
nb-project-install                        installs dependencies
nb-project-start                          create directory structure and logbook for new project
nb-project-end                            zips and removes directories and data for new project
nb-project-scope                          generate a scope regex by root word (matches all to the left and right)
nb-project-rescope-txt                    uses rescope to generate scope from a url
nb-project-rescope-burp                   uses rescope to generate burp scope (JSON) from a url
nb-project-sync-remote-to-local           sync data from a remote server directory to a local directory using SSHFS
nb-project-sync-local-file-to-remote      sync a local file to a remote server using rsync over SSH
nb-project-google-domain-dyn              update IP address using Google domains hosted dynamic record

DOC
}

nb-project-install() {
    __info "Running $0..."
    __pkgs fusermount sshfs rsync curl
    nb-install-golang
    go get -u github.com/root4loot/rescope
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

    __ok "Project $cname created."
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
    if [[ "${rmp}" =~ ^[Yy]$ ]] && print -z "trash -rf ${pd}"

    __ok "Project $pd ended."
}

nb-project-scope() {
    __check-project
    __check-org
    print -z "echo \"^.*?${__ORG}\..*\$ \" >> ${__PROJECT}/scope.txt"
}

nb-project-rescope-burp() {
    __check-project
    __ask "Enter the URL to the bug bounty scope description"
    nb-vars-set-url
    mkdir -p ${__PROJECT}/burp
    print -z "rescope --burp -u ${__URL} -o ${__PROJECT}/burp/scope.json"
}

nb-project-sync-remote-to-local() {
    __warn "Enter your SSH connection username@remote_host"
    local ssh && __askvar ssh SSH
    __warn "Enter the full remote path to the directory your want to copy from"
    local rdir && __askvar rdir "REMOTE DIR"
    __warn "Enter the full local path to the directory to use as a mount point"
    local mnt && __askpath mnt "LOCAL MOUNT" /mnt
    __warn "Enter the full local path to the directory to sync the data to"
    local ldir && __askpath lidr "LOCAL DIR" $HOME

    sudo mkdir -p $mnt

    __ok "Mounting $rdir to $mnt ..."
    sudo sshfs ${ssh}:${rdir} ${mnt}

    __ok "Syncing data from $mnt to $ldir ..."
    sudo rsync -avuc ${mnt} ${ldir}

    __ok "Unmounting $mnt. ..."
    sudo fusermount -u ${mnt}

    __ok "Sync Completed"
}

nb-project-sync-local-file-to-remote() {
    __warn "Enter your SSH connection username@remote_host"
    local ssh && __askvar ssh SSH
    __warn "Enter the full local path to the file you want to copy to your remote server"
    local lfile && __askpath lfile "LOCAL FILE" $HOME
    __warn "Enter the full remote path to the directory your want to copy the file to"
    local rdir && __askvar rdir "REMOTE DIR"
    print -z "rsync -avz -e \"ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null\" --progress $lfile $ssh:$rdir"
}

nb-project-google-domain-dyn() {
    local u && __askvar u USERNAME
    local p && __askvar p PASSWORD
    local d && __askvar d DOMAIN
    nb-vars-set-lhost 
    print -z "curl -s -a \"${__UA}\" https://$u:$p@domains.google.com/nic/update?hostname=${d}&myip=${__LHOST} "
}
