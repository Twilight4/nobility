#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-js
#############################################################
nb-enum-web-js-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-js
--------------
The nb-enum-web-js namespace contains commands for enumerating
javascript files and mining for urls and secrets.

Commands
--------
nb-enum-web-js-install             installs dependencies
nb-enum-web-js-beautify            beautify JS file
nb-enum-web-js-link-finder-url     run linkfinder on a file
nb-enum-web-js-link-finder-domain  run linkfinder on all files of a site
nb-enum-web-js-curl                enumerate links using curl

DOC
}

nb-enum-web-js-install() {
    __info "Running $0..."
    __pkgs jsbeautifier nb-install-link-finder
    nb-install-node
    npm i -g eslint
}

nb-enum-web-js-beautify() {
    local f && __askpath f FILE $(pwd)
    print -z "js-beautify ${f} > source-$(basename ${f})"
}

nb-enum-web-js-link-finder-url() {
    __check-project
    __ask "Set the URL of a javascript file"
    nb-vars-set-url
    print -z "python3 linkfinder.py -i ${__URL} -o $(__urlpath)/js-links.html"
}

nb-enum-web-js-link-finder-domain() {
    __check-project
    nb-vars-set-url
    print -z "python3 linkfinder.py -i ${__URL} -d -o $(__urlpath)/js-links-all.html"
}

nb-enum-web-js-curl() {
    nb-vars-set-url
    curl -Lks ${__URL} | tac | sed "s#\\\/#\/#g" | egrep -o "src['\"]?\s*[=:]\s*['\"]?[^'\"]+.js[^'\"> ]*" | sed -r "s/^src['\"]?[=:]['\"]//g" | awk -v url=${__URL} '{if(length($1)) if($1 ~/^http/) print $1; else if($1 ~/^\/\//) print "https:"$1; else print url"/"$1}' | sort -fu | xargs -I '%' sh -c "echo \"'##### %\";curl -k -s \"%\" | sed \"s/[;}\)>]/\n/g\" | grep -Po \"('#####.*)|(['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})|(\.(get|post|ajax|load)\s*\(\s*['\\\"](https?:)?[/]{1,2}[^'\\\"> ]{5,})\" | sort -fu" | tr -d "'\""
}


