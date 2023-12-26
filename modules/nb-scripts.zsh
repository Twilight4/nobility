#!/usr/bin/env zsh

############################################################# 
# nb-scripts
#############################################################
# nb-scripts-help() {
#   cat << "DOC" | bat --plain --language=help

# nb-scripts
# -------
# The scripts namespace runs scripts from the nobility
# scripts directory.

# ** IN DEVELOPMENT, NOT READY FOR USE **

# Commands
# --------
# nb-scripts-recon: a zsh recon script
# nb-scripts-webrecon: a zsh webrecon script

# DOC
# }

# nb-scripts-recon() {
#   local d && read "d?$(__cyan DOMAIN: )"
#   local o && read "o?$(__cyan ORG: )"
#   local w && read "out?$(__cyan WORKING\(DIR\): )"
#   print -z "zsh ${__SCRIPTS}/recon.zsh ${d} \"${o}\" \"${w}\""
# }

# nb-scripts-webrecon() {
#   local f=$(rlwrap -S "$(__cyan FILE:\(DOMAINS\))" -e '' -c -o cat)
#   local w && read "out?$(__cyan WORKING\(DIR\): )"
#   pushd ${w}
#   print -z "zsh ${__SCRIPTS}/webrecon.zsh ${f}"
#   popd
# }
