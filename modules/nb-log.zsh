#!/usr/bin/env zsh

############################################################# 
# nb-log
#############################################################
nb-log-help() {
    cat << "DOC" | bat --plain --language=help

nb-log
-------------
The log namespace provides commands that create a logbook in
a directory specified by the __LOGBOOK variable.

Commands
--------
nb-log            ask user for an log entry in the logbook
nb-log-set        creates or uses existing logbook.org in the path specified
nb-log-cat        cats the logbook
nb-log-edit       edits the logbook using $EDITOR
nb-log-clear      deletes the logbook
nb-log-scan       pastes from clipboard to an entry in the logbook in code format (uses wl-clipboard)
nb-log-append     append additional information to the last logbook entry
nb-log-full       asks for full detailed logs for an entry

DOC
}

nb-log-set() {
    nb-vars-set-logbook
}

nb-log-cat() {
    __check-logbook
    __info "${__LOGBOOK}" 
    echo " " 
    sed -e 's/^\* .*$/\x1b[94m&\x1b[0m/' -e 's/^\*\*.*$/\x1b[96m&\x1b[0m/' -e 's/=\([^=]*\)=/\o033[1;32m\1\o033[0m/g; s/^\( \{0,6\}\)-/•/g' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' -e '/^\(:PROPERTIES:\|:ID:\|:END:\|#\+date:\)/d' ${__LOGBOOK} | command bat --language=org --style=plain --color=always
}

nb-log-edit() {
    __check-logbook
    eval $EDITOR ${__LOGBOOK}
}

nb-log-clear() {
    __check-logbook
    rm -v -i ${__LOGBOOK}
}

nb-log() {
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')

  	__ask "Enter the title (necessary)"
    local title && __askvar title TITLE

    if [[ -n "$title" ]]; then
      # Log the information to the logbook.org file
      echo " " >> ${__LOGBOOK}
      echo "*** $title" >> ${__LOGBOOK}
      echo "#+date: ${stamp}" >> ${__LOGBOOK}
      echo " "
    else
      echo " "
      __warn "No title provided. Exiting."
      return
    fi

    __ask "Enter description for the log entry (necessary)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
      echo " " >> ${__LOGBOOK}
      echo "Description: =$description=" >> ${__LOGBOOK}
      __info "Description logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No description provided. Exiting"
      return
    fi

    __info "Log entry added to ${__LOGBOOK}"
}

nb-log-scan() {
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')

    __ask "Enter the title (necessary)"
    local title && __askvar title TITLE

    if [[ -n "$title" ]]; then
      # Log the information to the logbook.org file
      echo " " >> ${__LOGBOOK}
      echo "*** $title" >> ${__LOGBOOK}
      echo "#+date: ${stamp}" >> ${__LOGBOOK}
      echo " "
    else
      echo " "
      __warn "No title provided. Exiting."
      return
    fi

  # Paste the contents of clipboard to logbook.org file in source block
  echo " " >> ${__LOGBOOK}
  echo "#+begin_src bash" >> ${__LOGBOOK}
  echo "$(wl-paste)" >> ${__LOGBOOK}
  echo "#+end_src" >> ${__LOGBOOK}

  __info "Log entry added to ${__LOGBOOK}"
}

nb-log-append() {
    __check-logbook

    __ask "Enter additional information for the last log entry"
    local additional_info && __askvar additional_info ADDITIONAL_INFO

    if [[ -n "$additional_info" ]]; then
      echo " " >> ${__LOGBOOK}
      echo "Additional Information: =$additional_info=" >> ${__LOGBOOK}
      __info "Additional Information logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No additional information provided. Exiting"
      return
    fi

    __info "Input appended to the last log entry in ${__LOGBOOK}"
}

nb-log-full() {
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')

    __ask "Enter the title (necessary)"
    local title && __askvar title TITLE

    if [[ -n "$title" ]]; then
      # Log the information to the logbook.org file
      echo " " >> ${__LOGBOOK}
      echo "*** $title" >> ${__LOGBOOK}
      echo "#+date: ${stamp}" >> ${__LOGBOOK}
      echo " "
    else
      echo " "
      __warn "No title provided. Exiting."
      return
    fi

    __ask "Enter server IP (press Enter to skip)"
    local server_ip && __askvar server_ip SERVER_IP

    if [[ -n "$server_ip" ]]; then
      # Log the information to the logbook.org file
      echo "#+server_ip: $server_ip" >> ${__LOGBOOK}
      __info "Server IP logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
       __warn "No server IP provided. Skipping."
    fi

    __ask "Enter information about impact for the log entry (press Enter to skip)"
    local impact && __askvar impact IMPACT

    if [[ -n "$impact" ]]; then
      echo "#+impact: $impact" >> ${__LOGBOOK}
      __info "Information about impact logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
       __warn "No information about impact provided. Skipping."
    fi

    __ask "Enter information about triggered alerts for the log entry (press Enter to skip)"
    local alerts && __askvar alerts ALERTS

    if [[ -n "$alerts" ]]; then
      echo "#+alerts_triggered: $alerts" >> ${__LOGBOOK}
      __info "Information about triggered alerts logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No information about triggered alerts provided. Skipping."
    fi

    __ask "Provide attachments for the log entry (press Enter to skip)"
    local attachments && __askvar attachments ATTACHMENTS

    if [[ -n "$attachments" ]]; then
      echo "#+attachments: $attachments" >> ${__LOGBOOK}
      __info "Information about attachments logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No attachments provided. Skipping."
    fi

    __ask "Enter description for the log entry (necessary)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
      echo " " >> ${__LOGBOOK}
      echo "Description: =$description=" >> ${__LOGBOOK}
      __info "Description logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No description provided. Exiting"
      return
    fi

    __info "Log entry added to ${__LOGBOOK}"
}
