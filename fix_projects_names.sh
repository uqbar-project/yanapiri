#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/common"

for d in */ ; do
    REPO_HOME=${d:0:${#d}-1}
    REPO_USER=$(echo $REPO_HOME | rev | cut -d'-' -f 1 | rev)
    TP_NAME=$(echo $REPO_HOME | rev | cut -d'-' -f2-  | rev)
    renameWollokProject $REPO_HOME $TP_NAME
done
