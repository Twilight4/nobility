#!/usr/bin/env zsh

############################################################# 
# nb-vars-global
#############################################################
nb-vars-global-help() {
    cat << "DOC" | bat --plain --language=help

nb-vars-global
--------------
The vars global namespace manages environment variables used in other functions
that are saved between sessions.  Values are stored as files the .nobility/globals
directory and can contain sensitive information like API keys. These variables
are used to supply arguments to commands in other modules.

Variables
---------
__EXT_PHP        a list of file extensions used on PHP webservers
__EXT_DOCS       a list of common documents file types
__API_GITHUB     your personal Github API key
__RESOLVERS      path to public resolvers file 
__MNU_UA         path to the file containing user-agent strings
__MNU_WORDLISTS  path to the file containing a list of favorite wordlists
__TCP_PORTS      path to the file of favorite TCP ports
__SHELL_SSL_CERT path to the file of an impersonated SSL cert used for reverse shell IDS evasion

Commands
--------
nb-vars-global            list all current global variable values
nb-vars-global-set-*      used to set and save each individual variable

DOC
}

nb-vars-global() {
    echo "$(__cyan EXT_PHP: ) ${__EXT_PHP}"
    echo "$(__cyan EXT_DOCS: ) ${__EXT_DOCS}"
    echo "$(__cyan API_GITHUB: ) ${__API_GITHUB}"
    echo "$(__cyan RESOLVERS: ) ${__RESOLVERS}"
    echo "$(__cyan MNU_UA: ) ${__MNU_UA}"
    echo "$(__cyan MNU_WORDLISTS: ) ${__MNU_WORDLISTS}"
    echo "$(__cyan TCP_PORTS: ) ${__TCP_PORTS}"
    echo "$(__cyan SHELL_SSL_CERT: ) ${__SHELL_SSL_CERT}"
}

# Set default __PAYLOADS variable to nobility/payloads dir
export __PAYLOADS=~/.config/zsh/plugins/nobility/payloads


############################################################# 
# __EXT_PHP
#############################################################
export __EXT_PHP=$(cat ${__GLOBALS}/EXT_PHP 2> /dev/null || echo "php,phtml,pht,xml,inc,log,sql,cgi")

nb-vars-global-set-ext-php() {
    __ask "Enter a csv list of PHP server file extensions, ex: php,php3,pht"
    __askvar __EXT_PHP EXTENSIONS
    echo "${__EXT_PHP}" > ${__GLOBALS}/EXT_PHP
}

__check-ext-php()  { [[ -z "${__EXT_PHP}" ]] && nb-vars-global-set-ext-php } 


############################################################# 
# __EXT_DOCS
#############################################################
export __EXT_DOCS=$(cat ${__GLOBALS}/EXT_DOC 2> /dev/null || echo "doc,docx,pdf,xls,xlsx,txt,rtf,odt,ppt,pptx,pps,xml")

nb-vars-global-set-ext-docs() {
    __ask "Enter a csv list of document file extensions, ex: doc,xls,ppt"
    __askvar __EXT_DOCS EXTENSIONS
    echo "${__EXT_DOCS}" > ${__GLOBALS}/EXT_DOCS
}

__check-ext-docs()  { [[ -z "${__EXT_DOCS}" ]] && nb-vars-global-set-ext-docs } 


############################################################# 
# __API_GITHUB
#############################################################
export __API_GITHUB="$(cat ${__GLOBALS}/API_GITHUB 2> /dev/null)"

nb-vars-global-set-api-github() {
    __ask "Enter your github API key below."
    __askvar __API_GITHUB API_GITHUB
    echo "${__API_GITHUB}" > ${__GLOBALS}/API_GITHUB
}

__check-api-github()  { [[ -z "${__API_GITHUB}" ]] && nb-vars-global-set-api-github } 


############################################################# 
# __RESOLVERS
#############################################################
export __RESOLVERS=$(cat ${__GLOBALS}/RESOLVERS 2> /dev/null || echo "${__PAYLOADS}/resolvers.txt")

nb-vars-global-set-resolvers() {
    __ask "Set the full path to the file containing a list of resolvers."
    __askpath __RESOLVERS FILE $HOME
    echo "${__RESOLVERS}" > ${__GLOBALS}/RESOLVERS
}

__check-resolvers() { [[ -z "${__RESOLVERS}" ]] && nb-vars-global-set-resolvers }


############################################################# 
# __MNU_UA
#############################################################
export __MNU_UA="$(cat ${__GLOBALS}/MNU_UA 2> /dev/null || echo "${__PAYLOADS}/user-agents.txt")"

nb-vars-global-set-mnu-ua() {
    __ask "Set the full path to the file containing a list of user agent strings"
    __askpath __MNU_UA FILE $HOME
    echo "${__MNU_UA}" > ${__GLOBALS}/MNU_UA
}


############################################################# 
# __MNU_WORDLISTS
#############################################################
export __MNU_WORDLISTS="$(cat ${__GLOBALS}/MNU_WORDLISTS 2> /dev/null || echo "${__PAYLOADS}/wordlists.txt")"

nb-vars-global-set-mnu-wordlists() {
    __ask "Set the full path to the file containing a list of favorite wordlists"
    __askpath __MNU_WORDLISTS FILE $HOME
    echo "${__MNU_WORDLISTS}" > ${__GLOBALS}/MNU_WORDLISTS
}


############################################################# 
# __TCP_PORTS
#############################################################
export __TCP_PORTS="$(cat ${__GLOBALS}/TCP_PORTS 2> /dev/null || echo "${__PAYLOADS}/tcp-ports.txt")"

nb-vars-global-set-tcp-ports() {
    __ask "Set the full path to the file containing a list of favorite TCP ports"
    __askpath __TCP_PORTS FILE $HOME
    echo "${__TCP_PORTS}" > ${__GLOBALS}/TCP_PORTS
}


############################################################# 
# __SHELL_SSL_CERT
#############################################################
export __SHELL_SSL_CERT="$(cat ${__GLOBALS}/SHELL_SSL_CERT 2> /dev/null || echo "${__PAYLOADS}/aka.ms.pem")"

nb-vars-global-set-shell-ssl-cert() {
    __ask "Set the full path to an impersonated SSL certificate in PEM format to use with reverse shells"
    __askpath __SHELL_SSL_CERT FILE $HOME
    echo "${__SHELL_SSL_CERT}" > ${__GLOBALS}/SHELL_SSL_CERT
}
