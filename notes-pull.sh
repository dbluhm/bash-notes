#!/bin/bash
NOTESDIR="$HOME/.notes"

OLD_DIR=$(pwd)
cd $NOTESDIR
git pull
cd $OLD_DIR
