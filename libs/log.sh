#!/usr/bin/env bash

log () {
    amend=false

    if [ "$1" == "-n" ]; then
        shift 1;
        amend=true
    fi;

    case $1 in
        note)  shift 1; printf "\e[90m%s\e[0m" "$@";;
        ok)    shift 1; printf "\e[32m%s\e[0m" "$@";;
        good)  shift 1; printf "\e[1;32m%s\e[0m" "$@";;
        warn)  shift 1; printf "\e[1;93m%s\e[0m" "$@";;
        error) shift 1; printf "\e[1;91m%s\e[0m" "$@";;
        *) printf "$@";;
    esac

    if [[ $amend == false ]]; then
        printf "\n";
    fi;
}

function max {
    if [[ -n $2 ]]; then
        echo $1;
    else
        echo $(( $1 > $2 ? $1 : $2 )) || $1;
    fi;
}

function min {
    echo $(( $1 < $2 ? $1 : $2 )) || $1
}

function pad {
    printf "%-${log_padding}s" "$1"
}

log_padding=$( min 40 $(( $( tput cols ) - 10 )) )