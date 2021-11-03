#!/usr/bin/env bash

if [[ -z "$project_root" ]]; then
    project_root="$( realpath "$( dirname "$( realpath $0)" )/.." )"
fi;
source "$project_root/libs/require.sh"

require "libs/log.sh"

UPDATES_LAST_CHECK=0

check () {
    log -n "$( pad "Checking for $1")"
    if [[ $(command -v $1) ]]; then
        log good  "[    found]";
    else
        log error "[not found]";
        return 1;
    fi;
}

check_requirements () {
    while read requirement; do
        check "$requirement"
    done < "$project_root/INSTALL";
}

check_updates () {
    while true; do

        log good "Checking updates"
        UPDATES_LAST_CHECK=$( date +%s )
        git fetch
        my_version="$(git rev-parse master)"
        server_version="$(git rev-parse origin/master)"
        if [[ "$my_version" != "$server_version" ]]; then
            git pull "$1" "$2"
        fi;
        # 3600 = 1 hour in seconds
        # 86400 = 24 hours in seconds
        sleep 3600;

    done;
}
