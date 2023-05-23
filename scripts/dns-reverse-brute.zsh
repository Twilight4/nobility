#!/usr/bin/env zsh

############################################################# 
# dns-reverse-brute
#############################################################

#[[ -z $1 ]] && echo -e "[!] Missing argument.\nUsage: zsh $0 <file>" && exit

cat $1 | while read domain; do if host -t A "$domain" | awk '{print $NF}' | grep -E '^(192\.168\.|172\.1[6789]\.|172\.2[0-9]\.|172\.3[01]\.|10\.)' &>/dev/null; then echo $domain; fi; done
