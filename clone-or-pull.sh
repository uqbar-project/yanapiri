#!/bin/bash

DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$DIR" ]]; then DIR="$PWD"; fi
source "$DIR/common"

[[ -z "$GITHUB_TOKEN" ]] && { echo "GitHub token not found, please ensure it is stored on \$GITHUB_TOKEN variable. You can generate one on https://github.com/settings/tokens, with at least 'repo' scope." ; exit 1; }

function cloneOrPullRepo {
  re="^(https|git)(:\/\/|@)([^\/:]+)[\/:]([^\/:]+)\/(.+).git$"

  echo $1

  if [[ $1 =~ $re ]]; then
    REPO_HOME=${BASH_REMATCH[5]}
    REPO_USER=$(echo $REPO_HOME | rev | cut -d'-' -f 1 | rev)
    TP_NAME=$(echo $REPO_HOME | rev | cut -d'-' -f2-  | rev)
  fi

  if [ -d "$REPO_HOME" ]; then
    echo Pulling $REPO_HOME
    cd $REPO_HOME
    git pull
    cd ..
  else
    echo Cloning $REPO_HOME
    git clone $1
  fi
  # renameWollokProject $REPO_HOME $TP_NAME

}

EMPTY_RESPONSE="[]"
args=("$@")
TOKEN=$GITHUB_TOKEN
ORG=obj1-unahur-2019s1
URL="https://api.github.com/orgs/$ORG/repos?access_token=${TOKEN}&per_page=200"
KEY=${args[0]}

echo $URL

echo Searching repos for ${KEY}...
mkdir -p ${KEY}
cd ${KEY}
PAGE_NUMBER=1
REPOS_COUNT=0

while true ; do
  RESPONSE=$(curl  -s $URL"&page="$PAGE_NUMBER)
  # If response is [] then finish checking pages
  if [ "$(sed 's/ //g' <<< "$RESPONSE" | tr -d '\n')" == "$EMPTY_RESPONSE" ]; then
     break
  fi
  PAGE_NUMBER=$((PAGE_NUMBER + 1))

  for r in $( grep ssh_url <<< "$RESPONSE" | grep $KEY | sed '/[ ]*"ssh_url":/!d;s/[^:]*: "//;s/",$//' ); do
    cloneOrPullRepo $r &
  done

done

wait

REPOS_COUNT=$(ls -1A . | wc -l)

echo $REPOS_COUNT Cloned or updated.
