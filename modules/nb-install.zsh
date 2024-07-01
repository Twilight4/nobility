#!/usr/bin/env zsh

############################################################# 
# nb-install
#############################################################
nb-install-help() {
    cat << "DOC" | bat --plain --language=help

nb-install
----------
The nb-install namespace provides commands that assist with installing packages, repos and tools used in nobility.

Commands
--------
nb-install-all                installs all dependecies in all modules, calling nb-*-install 
nb-install-git-pull-tools     updates all install tools that are git repos
nb-install-dev                installs python, php, npm and libraries
nb-install-golang             installs golang and environment variables needed for "go get"

Tools
-----
These installers are for individual tools.

nb-install-generic
nb-install-seclists
nb-install-payloadallthethings
nb-install-github-search
nb-install-git-secrets
nb-install-pentest-tools
nb-install-nmap-elasticsearch-nse
nb-install-link-finder
nb-install-winpeas
nb-install-linpeas
nb-install-amsi-bypass
nb-install-pipmykali
nb-install-fluxion
nb-install-rpivot
nb-install-rustscan
nb-install-nessus
nb-install-dnscat2
nb-install-dnscat2-powershell
nb-install-chisel
nb-install-kerbrute
nb-install-protonvpn
nb-install-impacket
nb-install-ldapdomaindump
nb-install-windapsearch
nb-install-username-anarchy
nb-install-username-generator

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

    if command -v apt-get &>/dev/null; then
        __info "Updating packages..."
        sudo apt-get update
        __info "Installing packages..."
        for pkg in "$@"; do
            __info "$pkg"
            dpkg -s $pkg &>/dev/null && __warn "$pkg already installed" || sudo apt-get install -y $pkg
        done
    else
        __warn "apt-get not found. Can not install packages."
    fi
}

nb-install-all() {
    __cyan "This will install/update all modules."
    __cyan "Ensure you have free disk space before proceeding."
    __ask "CONTINUE?"
    if __check-proceed
    then
        __info "Installing all modules..."
        #nb-encoding-install
        nb-enum-dhcp-install
        nb-enum-dns-install
        nb-enum-ftp-install
        nb-enum-host-install
        nb-ad-kerb-install
        nb-ad-ldap-install
        nb-ad-pth-install
        nb-ad-smb-relay-install
        nb-ad-asrep-roast-install
        nb-enum-mssql-install
        nb-enum-mysql-install
        nb-enum-network-install
        nb-enum-nfs-install
        nb-enum-oracle-install
        nb-enum-pop3-install
        nb-enum-rdp-install
        nb-enum-smb-install
        nb-enum-web-aws-install
        nb-enum-web-dirs-install
        nb-enum-web-elastic-install
        nb-enum-web-fuzz-install
        nb-enum-web-js-install
        nb-enum-web-vuln-install
        nb-enum-web-php-install
        nb-enum-web-ssl-install
        nb-enum-web-install
        nb-exploit-install
        nb-pivot-install
        nb-project-install
        nb-recon-domains-install
        nb-recon-github-install
        nb-recon-networks-install
        nb-recon-org-install
        nb-recon-subs-install
        nb-shell-handlers-msf-install
        nb-shell-handlers-install
        nb-srv-install
        __info "Install finished"
    fi
}

nb-install-git-pull-tools() {
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

nb-install-dev(){
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
nb-install-golang() {
    __pkgs golang

    if [[ -z "$(echo $GOPATH)" ]]
    then
        echo "export GOPATH=\$HOME/go" | tee -a $HOME/.config/zsh/.zshrc
        echo "export PATH=\$PATH:/usr/local/go/bin:\$GOPATH/bin" | tee -a $HOME/.config/zsh/.zshrc
        export GOPATH=$HOME/go
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    fi 
}

nb-install-node() {
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

nb-install-seclists() {
    local name="seclists"
    local url="https://github.com/danielmiessler/SecLists"
    local p="/usr/share/$name"

    __info "Installing $name..."

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $p
        __info "Successfully installed $name... in $p"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-wordlist-payloadallthethings() {
    local name="PayloadsAllTheThings"
    local url="https://github.com/swisskyrepo/PayloadsAllTheThings"
    local path="/usr/share/wordlists/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        git clone --depth 1 $url $path
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-github-search() {
    local name="github-search"
    local url="https://github.com/gwen001/github-search.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p
        pushd $p
        pip3 install -r requirements.txt
        popd
        __addpath $p
    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        pip3 install -r requirements.txt
        popd
    fi
}

nb-install-gf() {
    local name="gf"

    __info "$name"

    go get -u github.com/tomnomnom/gf
    echo "source \$GOPATH/src/github.com/tomnomnom/gf/gf-completion.zsh" >> $HOME/.zshrc
    cp -r $GOPATH/src/github.com/tomnomnom/gf/examples $HOME/.gf
}

nb-install-git-secrets() {
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

nb-install-pentest-tools() {
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

nb-install-nmap-elasticsearch-nse() {
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

nb-install-link-finder() {
    local name="LinkFinder"
    local url="https://github.com/GerbenJavado/LinkFinder.git"
    local p="$__TOOLS/$name"

    __info "$name"

    if [[ ! -d $p ]]
    then
        git clone $url $p
        pushd $p 
        sudo python setup.py install
        pip3 install -r requirements.txt
        popd

    else
        __warn "already installed in $p"
        pushd $p 
        git pull
        python setup.py install
        pip3 install -r requirements.txt
        popd
    fi
}

nb-install-winpeas() {
    local win="$SV/winPEASx64.exe"

    # Check if file already exists
    if [ -f "$win" ]; then
        echo "WinPEASx64.exe is already installed."
        return
    fi

    __cyan "This will install WinPEASx64.exe"
    __ask "CONTINUE?"
    if __check-proceed; then
        wget https://github.com/peass-ng/PEASS-ng/releases/download/20240609-52b58bf5/winPEASx64.exe -O "$win"
    fi
}

nb-install-linpeas() {
    local lin="$SV/linpeas.sh"

    # Check if file already exists
    if [ -f "$lin" ]; then
        echo "LinPEAS.sh is already installed."
        return
    fi

    __cyan "This will install LinPEAS.sh"
    __ask "CONTINUE?"
    if __check-proceed; then
        wget https://github.com/peass-ng/PEASS-ng/releases/download/20240609-52b58bf5/linpeas.sh -O "$lin"
    fi
}

nb-install-amsi-bypass() {
    local amsi_path="$SV/amsi.ps1"

    # Check if file already exists
    if [ -f "$amsi_path" ]; then
        echo "amsi.ps1 is already installed."
        return
    fi

    __cyan "This will install amsi.ps1"
    __ask "CONTINUE?"
    if __check-proceed; then
        wget https://gist.githubusercontent.com/shantanu561993/6483e524dc225a188de04465c8512909/raw/db219421ea911b820e9a484754f03a26fbfb9c27/AMSI_bypass_Reflection.ps1 -O "$amsi_path"
    fi
}

nb-install-pipmykali() {
    local name="pipmykali"
    local url="https://github.com/Dewalt-arch/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-fluxion() {
    local name="fluxion"
    local url="https://github.com/FluxionNetwork/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
        sudo ln -sf /opt/$name/fluxion.sh /bin/$name
        __info "'which fluxion' should be: aliased to 'xhost +SI:localuser:root && sudo fluxion'"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-rpivot() {
    local name="rpivot"
    local url="https://github.com/klsecservices/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-rustscan() {
    # Check for the newest version manually
    local download_url="https://github.com/RustScan/RustScan/releases/download/2.2.3/rustscan_2.2.3_amd64.deb"

    # Download RustScan .deb file
    __info "Downloading RustScan..."
    wget "$download_url" -P /tmp || { echo "Failed to download RustScan."; return 1; }

    # Install RustScan
    __info "Installing RustScan..."
    sudo dpkg -i "/tmp/rustscan_2.2.3_amd64.deb" || { echo "Failed to install RustScan."; return 1; }

    # Clean up
    __info "Cleaning up..."
    rm "/tmp/rustscan_2.2.3_amd64.deb" || { echo "Failed to clean up."; return 1; }

    __ok "RustScan installed successfully."
}

nb-install-nessus() {
    # Download the binary
    curl --request GET \
      --url 'https://www.tenable.com/downloads/api/v2/pages/nessus/files/Nessus-10.7.2-debian10_amd64.deb' \
      --output ~/downloads/Nessus-10.7.2-debian10_amd64.deb

    # Install the nessus package
    sudo dpkg -i ~/downloads/Nessus-*debian10_amd64.deb

    # Start nesssus service
    sudo systemctl start nessusd.service

    __info 'Fill the email to get there the activation code:'
    __info '    https://www.tenable.com/products/nessus/nessus-essentials'

    __info 'Then go to https://kali:8834/ - select Nessus Essentials for the free version, and then enter the activation code'
    __info 'If you get Nessus Invalid Field: Bad Format - check if theres no leading space in the activation code form'
}

nb-install-dnscat2() {
    local name="dnscat2"
    local url="https://github.com/klsecservices/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
        sudo ln -sf /opt/$name/server/dnscat2.rb /bin/dnscat2
        __warn "If you get the error 'cannot load such file --ecdsa (loaderror)', run commands:"
        __ok "sudo gem install bundler"
        __ok "sudo bundle install"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-dnscat2-powershell() {
    local cat="$SV/dnscat2.ps1"

    # Check if file already exists
    if [ -f "$cat" ]; then
        echo "dnscat2.ps1 is already installed."
        return
    fi

    __cyan "This will install dnscat2.ps1"
    __ask "CONTINUE?"
    if __check-proceed; then
        curl -L https://raw.githubusercontent.com/lukebaggett/dnscat2-powershell/master/dnscat2.ps1 -O "$cat"
    fi
}

nb-install-chisel() {
    local name="chisel"
    local url="https://github.com/jpillora/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
        cd $path
        go build
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-kerbrute() {
    # Check for the newest version manually
    local ver="1.0.3"
    local file="kerbrute_linux_amd64"
    local download_url="https://github.com/ropnop/kerbrute/releases/download/v$ver/$file"

    # Download precompiled kerbrute binary
    __info "Downloading kerbrute ${ver}..."
    wget "$download_url" -O /tmp/kerbrute || { echo "Failed to download kerbrute."; return 1; }

    # Move kerbrute to path
    __info "Installing kerbrute ${ver}..."
    sudo chmod +x /tmp/kerbrute
    sudo mv "/tmp/kerbrute" /bin/kerbrute || { echo "Failed to install kerbrute."; return 1; }
    __ok "kerbrute ${ver} installed successfully."
}

nb-install-protonvpn() {
    # can't log in issue - https://www.reddit.com/r/ProtonVPN/comments/wogofb/cant_log_into_proton_vpn_linux_app_any_more/
    # first try just rebooting, if doens't help - uninstall strongswan and related packages and reboot
    wget https://repo.protonvpn.com/debian/dists/unstable/main/binary-all/protonvpn-beta-release_1.0.3-3_all.deb
    sudo dpkg -i ./protonvpn-beta-release_1.0.3-3_all.deb && sudo apt update

    # Check for the newest version manually (beta app) - https://protonvpn.com/support/official-linux-vpn-debian/ 
    local version="1.0.3-3"
    local file="protonvpn-beta-release_${version}_all.deb"
    local download_url="https://repo.protonvpn.com/debian/dists/unstable/main/binary-all/${file}"

    # Download RustScan .deb file
    __info "Downloading ProtonVPN deb package ${version}..."
    wget "$download_url" -P /tmp || { echo "Failed to download ProtonVPN."; return 1; }

    # Install ProtonVPN
    __info "Installing ProtonVPN ${version}..."
    sudo dpkg -i "/tmp/${file}" && sudo apt update || { echo "Failed to install ProtonVPN."; return 1; }
    sudo apt install proton-vpn-gnome-desktop

    # Clean up
    __info "Cleaning up..."
    rm "/tmp/${file}" || { echo "Failed to clean up."; return 1; }

    __ok "ProtonVPN ${version} installed successfully."
}

nb-install-impacket() {
    local name="impacket"
    local url="https://github.com/fortra/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $path
        pushd $path 
        sudo python3 -m pip install .
        popd
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-ldapdomaindump() {
    local name="ldapdomaindump"
    local url="https://github.com/dirkjanm/$name"
    local path="/opt/$name"

    __info "$name"

    if [[ ! -d $path ]]
    then
        sudo apt remove python3-ldapdomaindump
        sudo git clone --depth 1 $url $path
        sudo chmod +x /opt/ldapdomaindump/bin/*
        sudo ln -sf /opt/ldapdomaindump/bin/* /bin/
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-windapsearch() {
    local name="windapsearch"
    local url="https://github.com/ropnop/windapsearch"
    local p="/opt/$name"

    __info "Installing $name..."

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $p
        sudo ln -s /opt/windapsearch/windapsearch.py /bin/
        __info "Successfully installed $name... in $p"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-username-anarchy() {
    local name="username-anarchy"
    local url="https://github.com/urbanadventurer/username-anarchy"
    local p="/opt/$name"

    __info "Installing $name..."

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $p
        __info "Successfully installed $name... in $p"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-windapsearch() {
    local name="username_generator"
    local url="https://github.com/shroudri/username_generator"
    local p="/opt/$name"

    __info "Installing $name..."

    if [[ ! -d $path ]]
    then
        sudo git clone --depth 1 $url $p
        __info "Successfully installed $name... in $p"
    else
        __warn "already installed in $path"
        pushd $path 
        git pull
        popd
    fi
}

nb-install-arch-generic() {
    paru --needed -S nmap metasploit postgresql gobuster whatweb exploitdb masscan john bloodhound python-bloodhound python-neo4j sliver-bin
}
