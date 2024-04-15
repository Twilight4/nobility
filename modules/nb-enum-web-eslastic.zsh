#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-elastic
#############################################################
nb-enum-web-elastic-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-elastic
-------------------
The nb-enum-web-elastic namespace contains commands for scanning and enumerating elastic search services.

Commands
--------
nb-enum-web-elastic-install     installs dependencies
nb-enum-web-elastic-nmap        scan the target using the elasticsearch nmap nse script
nb-enum-web-elastic-health      query the target using curl for cluster health
nb-enum-web-elastic-indices     query the target using curl for indices
nb-enum-web-elastic-search      query an index using curl
nb-enum-web-elastic-all         query for 1000 records in an index using curl

DOC
}

nb-enum-web-elastic-install() {
    __info "Running $0..."
    __pkgs nmap curl
    nb-install-nmap-elasticsearch-nse
}

nb-enum-web-elastic-nmap() {
    __check-project || return
    nb-vars-set-rhost
    print -z "sudo grc nmap -n -Pn -p9200 --script=elasticsearch ${__RHOST} -oN $(__hostpath)/nmap-elastic.txt"
}

nb-enum-web-elastic-health() {
    nb-vars-set-url
    print -z "curl -A \"${__UA}\" -XGET \"${__URL}:9200/_cluster/health?pretty\""
}

nb-enum-web-elastic-indices() {
    nb-vars-set-url
    print -z "curl -A \"${__UA}\" -XGET \"${__URL}:9200/_cat/indices?v\""
}

nb-enum-web-elastic-search() {
  nb-vars-set-url
  local i && __askvar i "INDEX" 
   __ask "Enter a query, such as *:password"
  local q && __askvar q "QUERY"
  print -z "curl -A \"${__UA}\" -XGET \"${__URL}:9200/${i}/_search?q=${q}&size=10&pretty\""
}

nb-enum-web-elastic-all() {
  __check-project || return
  nb-vars-set-url
  local i && __askvar i "INDEX"
  print -z "curl -A \"${__UA}\" -XGET \"${__URL}:9200/${i}/_search?size=1000\" | tee $(__urlpath)/elastic-docs.json"
}
