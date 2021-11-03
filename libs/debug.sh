#!/usr/bin/env bash

traperror () {
    local err=$1 # error status
    local line=$2 # LINENO
    local linecallfunc=$3
    local command="$4"
    local funcstack="$5"
    log error "[ERROR]"
    log error "    line $line - command '$command' exited with status: $err"
    if [ "$funcstack" != "::" ]; then
        log -n error "    ... Error at ${funcstack} "
        if [ "$linecallfunc" != "" ]; then
            log error "called at line $linecallfunc"
        fi
    else
        log error "    ... internal debug info from function ${FUNCNAME} (line $linecallfunc)"
    fi
    log error "[/ERROR]"
}

set -o errexit # exit on errors
set -o nounset # exit on use of uninitialized variable
set -o errtrace # inherits trap on ERR in function and subshell

trap 'traperror $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]:-})' ERR
# trap 'traperror $? $LINENO $BASH_LINENO "$BASH_COMMAND" $(printf "::%s" ${FUNCNAME[@]})'  ERR
