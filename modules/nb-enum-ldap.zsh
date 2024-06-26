#!/usr/bin/env zsh

############################################################# 
# nb-enum-ldap
#############################################################
nb-enum-ldap-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-ldap
------------
The nb-enum-ldap namespace contains commands for scanning and 
enumerating Active Directory DC, GC and LDAP servers.

Check Authentication
--------------------
nb-enum-ldap-nmap-sweep     scan a network for services
nb-enum-ldap-search-anon    connect with anonymous bind and query ldap
nb-enum-ldap-search-auth    connect with authenticated bind and query ldap

Enumeration - Without Authentication
------------------------------------
nb-enum-ldap-search-anon-dc                 use ldap anonymous search to enumerate namingcontexts (needed for other ldapsearch commands)
nb-enum-ldap-search-anon-pass-pol           retrieve password policy using ldapsearch
nb-enum-ldap-search-anon-users              use ldap anonymous search to enumerate valid usernames
nb-enum-ldap-wsearch-anon-users             use windapsearch.py to enumerate users

Enumeration - With Authentication
---------------------------------
nb-enum-ldap-search-auth-users              use authenticated ldapsearch to enumerate valid usernames
nb-enum-ldap-search-auth-kerb              use authenticated ldapsearch to enumerate kerberoastable accounts
nb-enum-ldap-wsearch-auth-domain-admins     use windapsearch.py to enumerate domain admin users
nb-enum-ldap-wsearch-auth-privileged-users  use windapsearch.py to enumerate privileged users

Commands
--------
nb-enum-ldap-install        installs dependencies
nb-enum-ldap-tcpdump        capture traffic to and from a host
nb-enum-ldap-ctx            query ldap naming contexts
nb-enum-ldap-whoami         send ldap whoami request
nb-enum-ldap-hydra          brute force passwords for a user account

DOC
}

nb-enum-ldap-wsearch-anon-users() {
    __check-project
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    local dc && __askvar dc DC_IP

    print -z "python3 windapsearch.py -d ${__DOMAIN} --dc-ip $dc -U | tee $(__netadpath)/wsearch-users.txt"
}

nb-enum-ldap-wsearch-auth-domain-admins-auth() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC controller"
    local dc && __askvar dc DC_IP

    print -z "python3 windapsearch.py --dc-ip $dc -u ${__USER}@${__DOMAIN} -p ${__PASS} --da | tee $(__netadpath)/wsearch-domain-admins.txt"
}

nb-enum-ldap-wsearch-auth-privileged-users-auth() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass
    nb-vars-set-domain

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "python3 windapsearch.py --dc-ip $dc -u ${__USER}@${__DOMAIN} -p ${__PASS} -PU | tee $(__netadpath)/wsearch-users.txt"
}

nb-enum-ldap-search-anon-users() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN
    
    print -z "ldapsearch -H ldap://$dc:389 -x -b \"$dn\" -s sub \"(&(objectclass=user))\" | grep sAMAccountName: | cut -f2 -d\" \" | tee $(__netadpath)/ldapsearch-users.txt"
    #print -z "ldapsearch -H ldap://$dc:389 -x -b \"DC=${__DOMAIN},DC=LOCAL\" '(objectClass=user)' sAMAccountName | grep sAMAccountName | awk '{print $2}'"
}

nb-enum-ldap-search-auth-users() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H 'ldap://$dc' -D '${__USER}' -w '${__PASS}' -b \"$dn\" -s sub \"(&(objectCategory=person)(objectClass=user)(! (useraccountcontrol:1.2.840.113556.1.4.803:=2)))\" samaccountname | grep sAMAccountName | tee $(__netadpath)/ldapsearch-users.txt"
}

nb-enum-ldap-search-auth-kerb() {
    __check-project
    nb-vars-set-user
    nb-vars-set-pass

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H 'ldap://$dc' -D '${__USER}' -w '${__PASS}' -b \"$dn\" -s sub \"(&(objectCategory=person)(objectClass=user)(! (useraccountcontrol:1.2.840.113556.1.4.803:=2))(serviceprincipalname=*/*))\" serviceprincipalname | grep -B 1 servicePrincipalName | tee $(__netadpath)/ldapsearch-kerberoastable.txt"
}

nb-enum-ldap-search-anon-dc() {
    __check-project
    
	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "ldapsearch -H ldap://$dc:389 -x -s base namingcontexts"
}

nb-enum-ldap-search-anon-pass-pol() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -H ldap://$dc -x -b \"$dn\" -s sub "*" | grep -m 1 -B 10 pwdHistoryLength | tee $(__netadpath)/ldapsearch-pass-pol.txt"
}

nb-enum-ldap-install() {
    __info "Running $0..."
    __pkgs tcpdump nmap ldap-utils hydra
}

nb-enum-ldap-nmap-sweep() {
    __check-project
    nb-vars-set-network
    print -z "sudo grc nmap -v -n -Pn -sS -sU -p389,636,3269 ${__NETWORK} -oA $(__netadpath)/ldap-sweep"
}

nb-enum-ldap-tcpdump() {
    __check-project
    nb-vars-set-iface
    nb-vars-set-rhost
    print -z "sudo tcpdump -i ${__IFACE} host ${__RHOST} and tcp port 389 and port 636 and port 3269 -w $(__hostpath)/ldap.pcap"
}

nb-enum-ldap-ctx() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "ldapsearch -x -H ldap://$dc:389 -s base namingcontexts"
}

nb-enum-ldap-search-anon() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://$dc:389 -s sub -b \"${dn}\" "
}

nb-enum-ldap-search-auth() {
    __check-project
    nb-vars-set-user

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    __ask "Enter a distinguished name (DN), such as: 'dc=htb,dc=local'"
    local dn && __askvar dn DN

    print -z "ldapsearch -x -H ldap://$dc:389 -D '${dn}' \"(objectClass=*)\" -w \"${__USER}\" "
}

nb-enum-ldap-whoami() {
    __check-project

	  __ask "Enter the IP address of the target DC server"
    local dc && __askvar dc DC_IP

    print -z "ldapwhoami -H ldap://$dc:389 -w \"non-existing-user\" "
}

nb-enum-ldap-hydra() {
    __check-project
    nb-vars-set-rhost
    nb-vars-set-user
    print -z "hydra -l ${__USER} -P ${__PASSLIST} -e -o $(__hostpath)/ldap-hydra-brute.txt ${__RHOST} LDAP -F"
}
