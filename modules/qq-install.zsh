#!/usr/bin/env zsh

############################################################# 
# qq-install
#############################################################
qq-install-help() {
    cat << "DOC" | bat --plain --language=help

qq-install
----------
The qq-install namespace provides commands that assist with installing
packages, repos and tools used in quiver.

Commands
--------
qq-install-all                installs all dependecies in all modules, calling qq-*-install 
qq-install-git-pull-tools     updates all install tools that are git repos
qq-install-dev                installs pyhton3, php, npm and libraries
qq-install-golang             installs golang and environment variables needed for "go get"

Tools
-----
These installers are for individual tools.

qq-install-wordlist-commonspeak
qq-install-wordlist-nerdlist
qq-install-massdns
qq-install-github-search
qq-install-s3scanner
qq-install-git-secrets
qq-install-gitrob
qq-install-pentest-tools
qq-install-protonvpn
qq-install-nmap-elasticsearch-nse
qq-install-link-finder

DOC
}

############################################################# 
# Helpers
#############################################################
__addpath() {
    echo "export PATH=\$PATH:$1" | tee -a ~/.config/zsh/.zshrc
    export PATH=$PATH:$1
}

__pkgs() {
    __info "checking for and installing dependencies..."
    for pkg in "$@"
    do
        __info "$pkg"
        pacman -Qq $pkg 2>/dev/null && __warn "already installed" || sudo pacman -S --noconfirm $pkg
    done 
}

qq-install-all() {
    __cyan "This will install/update all modules."
    __cyan "Ensure you have free disk space before proceeding."
    __ask "CONTINUE?"
    if __check-proceed
    then
        __info "Installing all modules..."
        #qq-encoding-install
        qq-enum-dhcp-install
        qq-enum-dns-install
        qq-enum-ftp-install
        qq-enum-host-install
        qq-enum-kerb-install
        qq-enum-ldap-install
        qq-enum-mssql-install
        qq-enum-mysql-install
        qq-enum-network-install
        qq-enum-nfs-install
        qq-enum-oracle-install
        qq-enum-pop3-install
        qq-enum-rdp-install
        qq-enum-smb-install
        qq-enum-web-aws-install
        qq-enum-web-dirs-install
        qq-enum-web-elastic-install
        qq-enum-web-fuzz-install
        qq-enum-web-js-install
        qq-enum-web-vuln-install
        qq-enum-web-php-install
        qq-enum-web-ssl-install
        qq-enum-web-install
        qq-exploit-install
        qq-notes-install
        qq-pivot-install
        qq-project-install
        qq-recon-domains-install
        qq-recon-github-install
        qq-recon-networks-install
        qq-recon-org-install
        qq-recon-subs-install
        qq-shell-handlers-msf-install
        qq-shell-handlers-install
        qq-srv-install
        __info "Install finished"
    fi
}

qq-install-git-pull-tools() {
    __cyan "This will git-pull all repos in ${__TOOLS}."
    __ask "CONTINUE?"
    if __check-proceed
    then
    cd ${__TOOLS}
    for d in $(ls -d */)
    do 
        cd $d
        __ok "Pulling ${d}"
        git pull 
        cd -
    done
    cd ${__TOOLS}
    fi
}

qq-install-dev(){
    __cyan "This will install php, npm and libraries."
    __ask "CONTINUE?"
    if __check-proceed
    then
        __pkgs python-pip php php-curl libldns-dev libssl-dev libcurl4-openssl-dev npm
    fi
}


######################################################
# Individual Tools
######################################################
qq-install-golang() {
    __pkgs golang

    if [[ -z "$(echo $GOPATH)" ]]
    then
        echo "export GOPATH=\$HOME/go" | tee -a $HOME/.config/zsh/.zshrc
        echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" | tee -a $HOME/.config/zsh/.zshrc
        export GOPATH=$HOME/go
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    fi 
}

qq-install-node() {
    __pkgs nodejs npm

    cd $HOME
    mkdir -p $HOME/.npm-global
    npm config set prefix '~/.npm-global'

    if ! $(echo $PATH | grep -q "npm-global")
    then
        echo "export PATH=\$PATH:\$HOME/.npm-global" | tee -a $HOME/.config/zsh/.zshrc
        export PATH=$PATH:$HOME/.npm-global
    fi
}

qq-install-wordlist-commonspeak() {
    local name="commonspeak2"
    local url="https://github.com/assetnote/commonspeak2-wordlists.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        popd
    fi
}

qq-install-wordlist-nerdlist() {
    local name="nerdlist"
    local url="https://github.com/tarahmarie/nerdlist.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        popd
    fi
}

qq-install-massdns() {
    local name="massdns"
    local url="https://github.com/blechschmidt/massdns.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        pushd $p
        make
        popd
        __addpath $p/bin
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        make
        popd
    fi
}

qq-install-github-search() {
    local name="github-search"
    local url="https://github.com/gwen001/github-search.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        pushd $p
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd
        __addpath $p
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd
    fi
}

qq-install-s3scanner() {
    local name="S3Scanner"
    local url="https://github.com/sa7mon/S3Scanner.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        pushd $p
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd
        __addpath $p
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd
    fi
}

qq-install-gf() {
    local name="gf"

    __info "$name"

    go get -u github.com/tomnomnom/gf
    echo "source \$GOPATH/src/github.com/tomnomnom/gf/gf-completion.zsh" >> $HOME/.zshrc
    cp -r $GOPATH/src/github.com/tomnomnom/gf/examples $HOME/.gf
}

qq-install-git-secrets() {
    local name="git-secrets"
    local url="https://github.com/awslabs/git-secrets.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then 
        git clone $url $p

        #after commands
        pushd $p
        sudo make install
        popd
        __addpath $p

    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        sudo make install
        popd
    fi
}

qq-install-gitrob() {

    local name="gitrob"

    __info "$name"

    go get -u github.com/golang/dep/cmd/dep
    go get -u github.com/codeEmitter/gitrob
    pushd ~/go/src/github.com/codeEmitter/gitrob
    dep ensure
    go build
    popd
}

qq-install-pentest-tools() {
    local name="pentest-tools"
    local url="https://github.com/gwen001/pentest-tools.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        __addpath $p

    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        popd
    fi
}

qq-install-protonvpn() {
    local name="protonvpn"
    __info "$name"

    sudo pacman -S --noconfirm --needed openvpn dialog python-pip python-setuptools protonvpn-cli
    __warn "ProtonVPN username and password required"
    print -z "sudo protonvpn init"
}

qq-install-nmap-elasticsearch-nse() {
    local name="nmap-elasticsearch-nse"
    local url="https://github.com/theMiddleBlue/nmap-elasticsearch-nse.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        pushd $p
        sudo cp elasticsearch.nse /usr/share/nmap/scripts/
        popd

    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        sudo cp elasticsearch.nse /usr/share/nmap/scripts/
        popd
    fi
}

qq-install-link-finder() {
    local name="LinkFinder"
    local url="https://github.com/GerbenJavado/LinkFinder.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p

        #after commands
        pushd $p 
        sudo python3 setup.py install
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd

    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        python3 setup.py install
        cat requirements.txt
        echo "Install tools listed in requirements using pacman"
        popd
    fi
}
