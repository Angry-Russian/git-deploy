#!/usr/bin/env bash

if [[ -z "$project_root" ]]; then
    project_root="$( realpath "$( dirname "$( realpath $0)" )" )"
fi;
source "$project_root/libs/require.sh"

require -o ".env";
require "libs/require.sh"
require "libs/debug.sh"
require "libs/log.sh"
require "libs/checks.sh"
require "libs/sanitize.sh"

EXEC=true

config () {
    trap 'cleanup' EXIT

    config_file="${project_root}/git-deploy.config.json"
    track_updates=$( jq -r ".trackUpdates" $config_file )
    track_branch=$( jq -r ".trackBranch" $config_file )
    user=$( jq -r ".deployUser" $config_file )
    group=$( jq -r ".deployGroup" $config_file )
    listener=$( jq -r ".deployPipe" $config_file )
    updates_PID=''

    if [[ ! -p "$listener" ]]; then
        mkfifo -m 775 "${listener:-/tmp/git-deploy.pipe}"
        chown $user:$group "$listener"
    fi
}

cleanup() {
    EXEC=false
    log note "loop terminated, cleaning up..."
    if [[ ! -p "$listener" ]]; then
        rm -v "$listener"
    fi;
    if [[ -n "$updates_PID" ]]; then
        kill -9 $updates_PID
        updates_PID=''
    fi;
    log note "... done."
}

read_pipe () {
    if read usr src dst rev post_deploy < $listener; then
        if [[ "$usr" == "exit" || ! $EXEC ]]; then
            EXEC=false;
            return 0;
        fi;

        # check that the user, source and the revision actually exist
        if [[ ! $( id -u "${usr%:*}" ) ]]; then
            log error "supplied user doesn't exist, ignoring. $usr";
        elif [[ ! $( git --git-dir="$src" log -n1 ) ]]; then
            log error "supplied dir is not a git dir or has no commits. $src";
        elif [[ ! $( git --git-dir="$src" show "$rev" ) ]]; then
            log error "supplied dir does not contain the target revision. $src";
        else
            log note "Running deploy script in $PWD"
            log ok   "Deploying $rev from $src to $dst as $usr";
            oldref=$( cat "$src/HEAD" | { read a b; [[ -n "$b" ]] && echo "$b" || echo "$a"; } );
            mkdir -p "$dst"
            git --git-dir="$src" archive "$rev" | tar -x -C "$dst" # <- exports the revision to specified folder
            chown "$usr" -R "$dst"

            if [[ -n "$post_deploy" ]]; then
                log note "running post-deploy script: '$post_deploy'";
                (
                    cd "$dst";
                    run_sanitized "$post_deploy"
                )
            fi;
        fi;
    fi
}

main () {
    log ok "Running main loop, listening on $listener"
    while $EXEC
    do
        read_pipe;
    done
}

# if script is being called (not sourced), run main.
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    check_requirements || {
        log error "Missing requirements, cannot proceed."
        exit 1;
    }
    config && {
        [[ "$track_updates" == "true" ]] && {
            # check if update script already running by checking PID
            # if not, launch it, save its PID
            if [[ -n "$updates_PID" ]]; then
                check_updates origin "$track_branch" & updates_PID="$!"
            fi;
        } || log note "not tracking updates";
    } && main
fi;
