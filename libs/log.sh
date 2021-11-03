#!/usr/bin/env bash

log () {
    amend=false
    return_home=false

    if [ "$1" == "-n" ]; then
        shift 1;
        amend=true
    fi;

    if [ "$1" == "-r" ]; then
        shift 1;
        return_home=true
        amend=true
    fi;

    string=''
    case $1 in
        note)  shift 1; string=$( printf "\e[90m%s\e[0m" "$@" );;
        ok)    shift 1; string=$( printf "\e[32m%s\e[0m" "$@" );;
        good)  shift 1; string=$( printf "\e[1;32m%s\e[0m" "$@" );;
        warn)  shift 1; string=$( printf "\e[1;93m%s\e[0m" "$@" );;
        error) shift 1; string=$( printf "\e[1;91m%s\e[0m" "$@" );;
        *) string=$( printf "$@" );;
    esac


    simple_string=$( echo -e "$@" | strings )
    printf "$string"
    if [[ $return_home == true ]]; then
        echo -ne "\e[${#simple_string}D"
    fi;
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
    if [[ -n $2 ]]; then
        echo $1;
    else
        echo $(( $1 < $2 ? $1 : $2 )) || $1;
    fi;
}

function pad {
    printf "%-${log_padding}s" "$1";
}

cols=${COLUMNS:-80}
log_padding=$( min 40 $(( $cols - 10 )) )
