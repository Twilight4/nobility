#!/usr/bin/env zsh

############################################################# 
# nb-enum-web-aws
#############################################################
nb-enum-web-aws-help() {
    cat << "DOC" | bat --plain --language=help

nb-enum-web-aws
---------------
The nb-enum-web-aws namespace contains commands for scanning and enumerating AWS hosted services.

Commands
--------
nb-enum-web-aws-install     installs dependencies
nb-enum-web-aws-s3-ls       use the awscli to list files in an S3 bucket
nb-enum-web-aws-s3-write    use the awscli to copy a local file to an S3 bucket
nb-enum-web-aws-s3-scanner  scan a list of buckets

DOC
}

nb-enum-web-aws-install() {
    __info "Running $0..."
    __pkgs awscli s3scanner
}

nb-enum-web-aws-s3-ls() {
    nb-vars-set-rhost
    print -z "aws s3 ls s3://${__RHOST} --recursive"
}

nb-enum-web-aws-s3-write() {
    nb-vars-set-rhost
    __ask "Select a file to copy to the S3 bucket"
    local f && __askpath f FILE $(pwd)
    print -z "aws s3 cp \"${f}\" s3://${__RHOST}"
}

nb-enum-web-aws-s3-scanner() {
    __ask "Select a file that contains a list of S3 buckets"
    local f && __askpath f FILE $(pwd)
    __info "Use -d to dump buckets to local path"
    print -z "python ${__TOOLS}/S3Scanner/s3scanner.py ${f}"
} 
