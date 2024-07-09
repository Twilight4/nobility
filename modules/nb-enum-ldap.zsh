#!/usr/bin/env zsh

############################################################# 
# nb-enum-ldap
#############################################################
nb-enum-ldap-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-ldap
------------
The nb-enum-ldap namespace contains commands for scanning and enumerating LDAP servers.

Check Authentication
--------------------
nb-enum-ldap-nmap-sweep                     scan a network for services
nb-enum-ldap-search-anon                    check if LDAP anonymous binds are permitted using ldapsearch
nb-enum-ldap-wsearch-anon                   check if LDAP anonymous binds are permitted using windapsearch
nb-enum-ldap-search-auth                    connect with authenticated bind and query ldap
nb-enum-ldap-search-ctx                     query ldap naming contexts

Enumeration
============================================
ANON Session
------------
nb-enum-ldap-anon-search-ctb                general all query but ctb (cut the bullshit)
nb-enum-ldap-anon-wsearch-all               dump all attributes from LDAP (look for passwords in descriptions or other fields)
nb-enum-ldap-anon-search-users              use ldap anonymous search to enumerate valid usernames
nb-enum-ldap-anon-wsearch-users             use windapsearch.py to enumerate users
nb-enum-ldap-anon-search-pass-pol           retrieve password policy using ldapsearch
nb-enum-ldap-anon-search-kerb               use authenticated ldapsearch to enumerate kerberoastable accounts
nb-enum-ldap-anon-wsearch-domain-admins     use windapsearch.py to enumerate domain admin users
nb-enum-ldap-anon-wsearch-privileged-users  use windapsearch.py to enumerate privileged users
nb-enum-ldap-anon-wsearch-group-rmu         use windapsearch.py to enumerate users in Remote Management Users group

AUTH Session
------------
nb-enum-ldap-auth-search-ctb                general all query but ctb (cut the bullshit)
nb-enum-ldap-auth-wsearch-all               dump all attributes from LDAP (look for passwords in descriptions or other fields)
nb-enum-ldap-auth-search-users              use authenticated ldapsearch to enumerate valid usernames
nb-enum-ldap-auth-wsearch-users             use windapsearch.py to enumerate users
nb-enum-ldap-auth-search-pass-pol           retrieve password policy using ldapsearch
nb-enum-ldap-auth-search-kerb               use authenticated ldapsearch to enumerate kerberoastable accounts
nb-enum-ldap-auth-wsearch-domain-admins     use windapsearch.py to enumerate domain admin users
nb-enum-ldap-auth-wsearch-privileged-users  use windapsearch.py to enumerate privileged users
nb-enum-ldap-auth-wsearch-group-rmu         use windapsearch.py to enumerate users in Remote Management Users group

Commands
--------
nb-enum-ldap-install        installs dependencies
nb-enum-ldap-tcpdump        capture traffic to and from a host
nb-enum-ldap-hydra          brute force passwords for a user account

DOC
}

nb-enum-ldap-anon-wsearch-users() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    #print -z "windapsearch.py -u '' -d ${__DOMAIN} --dc-ip ${__DCHOST} -U --admin-objects | tee $(__dcpath)/wsearch-users.txt"
    print -z "windapsearch.py -u '' --dc-ip ${__DCHOST} -d ${__DOMAIN} -U | grep '@' | cut -d ' ' -f 2 | cut -d '@' -f 1 | uniq | tee users.list"
}

nb-enum-ldap-auth-wsearch-domain-admins() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    print -z "windapsearch.py --dc-ip ${__DCHOST} -u '${__USER}@${__DOMAIN}' -p '${__PASS}' --da | tee $(__dcpath)/wsearch-domain-admins.txt"
}

nb-enum-ldap-anon-wsearch-domain-admins() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    print -z "windapsearch.py -u '' --dc-ip ${__DCHOST} -d ${__DOMAIN} --da | tee $(__dcpath)/wsearch-domain-admins.txt"
}

nb-enum-ldap-auth-wsearch-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    nb-vars-set-dchost

    #print -z "windapsearch.py --dc-ip ${__DCHOST} -u '${__USER}@${__DOMAIN}' -p '${__PASS}' -U | tee $(__dcpath)/wsearch-users.txt"
    print -z "windapsearch.py -u '${__USER}@${__DOMAIN}' --dc-ip ${__DCHOST} -p '${__PASS}' -U | grep '@' | cut -d ' ' -f 2 | cut -d '@' -f 1 | uniq | tee users.list"
}

nb-enum-ldap-auth-wsearch-privileged-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py --dc-ip ${__DCHOST} -u '${__USER}@${__DOMAIN}' -p '${__PASS}' -PU | tee $(__dcpath)/wsearch-users.txt"
}

nb-enum-ldap-anon-wsearch-group-rmu() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py -u '' --dc-ip ${__DCHOST} -d ${__DOMAIN} -U -m \"Remote Management Users\" | tee $(__dcpath)/wsearch-rmu-users.txt"
}

nb-enum-ldap-auth-wsearch-group-rmu() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py --dc-ip ${__DCHOST} -u '${__USER}@${__DOMAIN}' -p ${__PASS} -U -m \"Remote Management Users\" | tee $(__dcpath)/wsearch-rmu-users.txt"
}

nb-enum-ldap-anon-wsearch-privileged-users() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py -u '' --dc-ip ${__DCHOST} -d ${__DOMAIN} -PU | tee $(__dcpath)/wsearch-users.txt"
}

nb-enum-ldap-anon-wsearch-all() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py -u '' -d ${__DOMAIN} --dc-ip ${__DCHOST} -U --full | grep Password | tee $(__dcpath)/wsearch-all.txt"
}

nb-enum-ldap-auth-wsearch-all() {
    __check-project
    nb-vars-set-domain
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "windapsearch.py -u '${__USER}@${__DOMAIN}' -p '${__PASS}' --dc-ip ${__DCHOST} -U --full | grep Password | tee $(__dcpath)/wsearch-all.txt"
}

nb-enum-ldap-anon-search-users() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN
    
    print -z "ldapsearch -H ldap://${__DCHOST}:389 -x -b \"$dn\" -s sub \"(&(objectclass=user))\" | grep sAMAccountName: | cut -f2 -d\" \" | tee $(__dcpath)/ldapsearch-users.txt"
    #print -z "ldapsearch -H ldap://${__DCHOST}:389 -x -b \"DC=${__DOMAIN},DC=LOCAL\" '(objectClass=user)' sAMAccountName | grep sAMAccountName | awk '{print $2}'"
}

nb-enum-ldap-auth-search-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H 'ldap://${__DCHOST}:389' -D '${__USER}@${__DOMAIN}' -w '${__PASS}' -b \"$dn\" -s sub \"(&(objectCategory=person)(objectClass=user)(! (useraccountcontrol:1.2.840.113556.1.4.803:=2)))\" samaccountname | grep sAMAccountName | tee $(__dcpath)/ldapsearch-users.txt"
}

nb-enum-ldap-auth-search-kerb() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H 'ldap://${__DCHOST}:389' -D '${__USER}@${__DOMAIN}' -w '${__PASS}' -b \"$dn\" -s sub \"(&(objectCategory=person)(objectClass=user)(! (useraccountcontrol:1.2.840.113556.1.4.803:=2))(serviceprincipalname=*/*))\" serviceprincipalname | grep -B 1 servicePrincipalName | tee $(__dcpath)/ldapsearch-kerberoastable.txt"
}

nb-enum-ldap-anon-search-kerb() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H 'ldap://${__DCHOST}:389' -b \"$dn\" -s sub \"(&(objectCategory=person)(objectClass=user)(! (useraccountcontrol:1.2.840.113556.1.4.803:=2))(serviceprincipalname=*/*))\" serviceprincipalname | grep -B 1 servicePrincipalName | tee $(__dcpath)/ldapsearch-kerberoastable.txt"
}

nb-enum-ldap-anon-search-pass-pol() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -H ldap://${__DCHOST}:389 -x -b \"$dn\" -s sub \"*\" | grep -m 1 -B 10 pwdHistoryLength | tee $(__dcpath)/ldapsearch-pass-pol.txt"
}

nb-enum-ldap-auth-search-pass-pol() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -H ldap://${__DCHOST}:389 -D '${__USER}@${__DOMAIN}' -w '${__PASS}' -x -b \"$dn\" -s sub \"*\" | grep -m 1 -B 10 pwdHistoryLength | tee $(__dcpath)/ldapsearch-pass-pol.txt"
}

nb-enum-ldap-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap ldap-utils hydra
}

nb-enum-ldap-nmap-sweep() {
    __check-project

    __ask "Do you want to scan a network subnet or a host? (n/h)"
    local scan && __askvar scan "SCAN_TYPE"

    if [[ $scan == "h" ]]; then
      nb-vars-set-rhost
      print -z "sudo grc nmap -v -n -Pn -sS -sU -p389,636,3269 ${__RHOST} -oA $(__hostpath)/ldap-sweep"
    elif [[ $scan == "n" ]]; then
      nb-vars-set-network
      print -z "sudo grc nmap -v -n -Pn -sS -sU -p389,636,3269 ${__NETWORK} -oA $(__netpath)/ldap-sweep"
    else
      echo
      __err "Invalid option. Please choose 'n' for network or 'h' for host."
    fi
}

nb-enum-ldap-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 389 and port 636 and port 3269 -w $(__hostpath)/ldap.pcap"
}

nb-enum-ldap-search-ctx() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "ldapsearch -x -H ldap://${__DCHOST}:389 -s base namingcontexts"
}

nb-enum-ldap-search-anon() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://${__DCHOST}:389 -s sub -b \"${dn}\" "
}

nb-enum-ldap-wsearch-anon() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    print -z "python windapsearch.py -u "" --dc-ip ${__DCHOST}"
}

nb-enum-ldap-search-auth() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://${__DCHOST}:389 -D '${__USER}@${__DOMAIN}' -b '${dn}' -w '${__PASS}' \"(objectClass=*)\""
}

nb-enum-ldap-auth-search-ctb() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://${__DCHOST}:389 -D '${__USER}@${__DOMAIN}' -b '${dn}' -w '${__PASS}' -s sub \"objectClass\" \"cn\" \"displayName\""
}

nb-enum-ldap-anon-search-ctb() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    nb-vars-set-dchost

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://${__DCHOST}:389 -b '${dn}' -s sub \"objectClass\" \"cn\" \"displayName\""
}

nb-enum-ldap-hydra() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/ldap-hydra-brute.txt ${__RHOST} LDAP -F"
}
