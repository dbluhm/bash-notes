#!/bin/bash
NOTESDIR="$HOME/.notes"

if [ ! -d "$NOTESDIR" ]; then
    mkdir $NOTESDIR
    if [ ! $? -eq 0 ]; then
        echo "Couldn't create $NOTESDIR"
        exit 1
    fi
fi

__usage() {
    echo $1
    echo "Usage text here"
    exit 1;
}

__edit() {
    path_to_notebook=$(find $NOTESDIR -type d -name $1) #Get full path
    if [ -z $2 ]; then
        echo "Opening new note in $1"
        edit=""
    else
        echo "Opening $2.md from notebook $path_to_notebook"
        edit="$path_to_notebook/$2.md"
    fi

    if hash nvim >/dev/null 2>&1; then
        nvim "+cd $path_to_notebook" "+Goyo" "$edit"
    elif hash $EDITOR >/dev/null 2>&1; then
        old=$(pwd)
        cd $path_to_notebook && $EDITOR "$edit"; cd $old
    else
        echo "Error: Your EDITOR environment variable is not configured!"
        exit 1
    fi
}

__search() {
    if hash ag  >/dev/null 2>&1; then
        ag $1 $2
    else
        grep --color=auto --exclude-dir .git -iR $1 $2
    fi
}

__remove() {
    if [ -z $2 ]; then
        echo "Warning: Deleting notebook $1. This will remove all notes within this notebook."
        path_to_delete=$1
    else
        echo "Warning: Deleting note $2.md from notebook $1. You will not be able to recover this note easily."
        path_to_delete="$1/$2.md"
    fi
    read -p "Are you sure? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
        rm -rf $NOTESDIR/$path_to_delete
        if [ $? -eq 0 ]; then echo "$path_to_delete removed."; else echo "Error while deleting $path_to_delete"; fi
    else
        echo "Cancelled"
    fi
    exit 0;
}


if [[ $# -gt 1 ]]; then
    case "$1" in
        -s|--search)
            SEARCHSTR="$2"
            ;;
        -r|--remove)
            NOTEBOOKREMOVEPATH="$2"
            NOTEREMOVEPATH="$3"
            ;;
        -a|--add)
            ADDNAME="$2"
            ;;
        *)
            NOTEBOOK="$1"
            shift
            NOTE="$1"
            shift
            ;;
    esac
else
    __usage "Invalid number of parameters"
fi

if [ -n "$SEARCHSTR" ]; then
    echo "Searching all notesbooks for $SEARCHSTR..."
    __search $SEARCHSTR $NOTESDIR
    exit 0;
elif [ -n "$NOTEBOOKREMOVEPATH" ]; then
    __remove $NOTEBOOKREMOVEPATH $NOTEREMOVEPATH
elif [ -n "$ADDNAME" ]; then
    echo "Creating new notebook $ADDNAME..."
    mkdir $NOTESDIR/$ADDNAME
    if [ -d $NOTESDIR/$ADDNAME ]; then
        echo "Notebook $ADDNAME successfully created"
    else
        echo "Error while creating Notbook $ADDNAME"
    fi
elif [ -n "$NOTEBOOK" ]; then
    #__edit $NOTEBOOK $NOTE #If note not set, create a new one
    echo "$NOTEBOOK; $NOTE"
fi
