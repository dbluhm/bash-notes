#!/bin/bash
NOTESDIR="$HOME/.notes"

OLD_DIR=`pwd`
cd $NOTESDIR
git add .
modified=$(git diff --name-status HEAD)
if [ -z "$modified" ]; then
    echo "Nothing to commit"
    exit 0
fi
count=$(wc -l <<< "$modified")
git commit -m "$count file(s) changed

$modified"

read -p "Push? [y/n] " -n 1 -r
echo
if [[ $REPLY =~ ^[yY]$ ]]; then
    git push origin
else
    echo "Not pushing changes"
fi

cd $OLD_DIR
