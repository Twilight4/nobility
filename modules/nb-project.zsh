#!/usr/bin/env zsh

############################################################# 
# nb-project
#############################################################
nb-project-help() {
    cat << "DOC" | bat --plain --language=help

nb-project
----------
The project namespace provides commands that help with setting up scope for an engagement or bug bounty, as well as commands for
syncing data and managing a VPS.

Commands
--------
nb-project-install                        installs dependencies
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
