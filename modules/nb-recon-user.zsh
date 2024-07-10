#!/usr/bin/env zsh

############################################################# 
# nb-recon-user
#############################################################
nb-recon-user-help() {
    cat << "DOC" | bat --plain --language=help

nb-recon-user
-------------
The nb-recon-user namespace provides commands to search for user data.

Commands
--------
nb-recon-user-social-analyzer    command to analyze and find a person's profile in 1000 social media websites
nb-recon-user-socials            command to open social media websites with the provided name
nb-recon-user-email              command to check for valid email address
nb-recon-user-geolocation        command to search for gelocation data
nb-recon-user-images             command to search for images
nb-recon-user-metadata           command to check for file metadata
nb-recon-user-breached           command to search for breached data
nb-recon-user-google             command to search for google dorks
nb-recon-user-phone              command to check for valid phone number
nb-recon-user-username           command to search for valid usernames
nb-recon-user-install            command to install tools dependencies

DOC
}

nb-recon-user-install() {
    __pkgs social-analyzer sherlock osintgram
}

nb-recon-user-social-analyzer() {
    __check-project
    print -z "social-analyzer --username"
}

nb-recon-user-socials() {
    echo -n "First name: "
    read firstName
    
    # Check for no answer
    if [ -z $firstName ]; then
        __err "You need to provide first name"
        exit 1
    fi
    
    echo -n "Last name:  "
    read lastName
    
    # Check for no answer
    if [ -z $lastName ]; then
        __err "You need to provide last name"
        exit 1
    fi
    
    xdg-open https://www.411.com/name/$firstName-$lastName/ &
    sleep 1
    uripath="https://www.advancedbackgroundchecks.com/search/results.aspx?type=&fn=${firstName}&mi=&ln=${lastName}&age=&city=&state="
    xdg-open $uripath &
    sleep 1
    xdg-open https://www.linkedin.com/pub/dir/?first=$firstName\&last=$lastName\&search=Search &
    sleep 1
    xdg-open https://www.peekyou.com/$firstName%5f$lastName &
    sleep 1
    xdg-open https://www.addresses.com/people/$firstName+$lastName &
    sleep 1
    xdg-open https://www.spokeo.com/$firstName-$lastName &
    sleep 1
    xdg-open https://twitter.com/search?q=%22$firstName%20$lastName%22&src=typd &
    sleep 1
    xdg-open https://www.youtube.com/results?search_query=$firstName+$lastName &

    #tinder
}

nb-recon-user-username() {
    #sherlock
    #whatsmyname
    #osintgram
}
