#!/usr/bin/env bash

apk add git shunit2 $( cat ./INSTALL )

if [[ -z "$project_root" ]]; then
    project_root="$( realpath "$( dirname "$( realpath $0)" )" )"
fi;
source "$project_root/libs/require.sh"

require "git-deploy.service.sh"

. shunit2
