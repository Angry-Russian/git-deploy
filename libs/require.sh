#!/usr/bin/env bash

if [[ -z "$project_root" ]]; then
    project_root="$( realpath "$( dirname "$( realpath $0)" )/.." )"
fi;

logPath="$( realpath "$project_root/libs/log.sh" )"
source "$logPath"

declare -a required=( "$( realpath "$project_root/libs/require.sh" )" "$logPath" );

require () {
    optional=false

    if [[ "$1" == "-o" ]]; then
        shift 1;
        optional=true
    fi;

    path="$( realpath "$project_root/$1" )"

    log -r note   "[  ....  ] sourcing $( $optional && echo "optional " )file '$path'"
    if [[ -f "$path" ]]; then
        for p in "${required[@]}"
        do
            [[ "$p" == "$path" ]] && {
                log note "[ ✗ dupe ]"
            } && return 0;
        done;
        log ok    "[ ✓ done ]"
        source "$path"
        required+=("$path")

    elif $optional; then
        log note  "[ ✗ opt  ]"

    else
        log error "[ ✘ err  ]"
        exit 1;
    fi;
}

show_required () {
    printf "Loaded files in order of invocation:\n"
    printf "    '%s'\n" "${required[@]}"
}
