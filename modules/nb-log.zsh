#!/usr/bin/env zsh

############################################################# 
# nb-log
#############################################################
nb-log-help() {
    cat << "DOC" | bat --plain --language=help

nb-log
-------------
The log namespace provides commands that create a logbook in a directory specified by the __LOGBOOK variable.

Commands
--------
nb-log            ask user for an log entry in the logbook
nb-log-scan       pastes from clipboard to an entry in the logbook in code format (uses wl-clipboard)
nb-log-sc         append screenshot to the last logbook entry using $EDITOR
nb-log-full       asks for full detailed logs for an entry

DOC
}

nb-log() {
    __check-project
    __check-logbook

    # Log the timestamp to the logbook.org file
    local stamp=$(date +'%A %d-%m-%Y : %T %Z')

  	__ask "Enter the title (necessary)"
    local title && __askvar title TITLE

    if [[ -n "$title" ]]; then
      # Log the information to the logbook.org file
      echo " " >> ${__LOGBOOK}
      echo "** $title" >> ${__LOGBOOK}
      echo "#+date: ${stamp}" >> ${__LOGBOOK}
      echo " "
    else
      echo " "
      __warn "No title provided. Exiting."
      return
    fi

    __ask "Enter command you ran (necessary)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
      echo " " >> ${__LOGBOOK}
      echo "Command:" >> ${__LOGBOOK}
      echo "  - =$description=" >> ${__LOGBOOK}
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
    __check-project
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

nb-log-sc() {
    __check-project
    __check-logbook

    # Edit logbook
    echo " " >> ${__LOGBOOK}
    echo "Evidence:" >> ${__LOGBOOK}
    echo " " >> ${__LOGBOOK}
    eval $EDITOR ${__LOGBOOK}
    echo " "

    __info "Input appended to the last log entry in ${__LOGBOOK}"
}

nb-log-full() {
    __check-project
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
      echo " "
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
      echo " "
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
      echo " "
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
      echo " "
    fi

    __ask "Enter description for the log entry (necessary)"
    local description && __askvar description DESCRIPTION

    if [[ -n "$description" ]]; then
      echo " " >> ${__LOGBOOK}
      echo "Description:" >> ${__LOGBOOK}
      echo "  =$description=" >> ${__LOGBOOK}
      __info "Description logged to ${__LOGBOOK}"
      echo " "
    else
      echo " "
      __warn "No description provided. Exiting"
      return
    fi

    __info "Log entry added to ${__LOGBOOK}"
}
