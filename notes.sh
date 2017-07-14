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
    local ul="\e[4m"
    local it="\e[3m"
    local cl="\e[0m"
    echo -e "Usage:
\tnotes $ul${it}notebook$cl [${ul}${it}nested notebook ...$cl] [${ul}${it}note$cl]
\t\tEdit or create a note. Omitting a note name will create a new note but
\t\tleave it unnamed.

\tnotes [--search|-s] $ul${it}SEARCH_TERM$cl
\t\tSearch notes for $ul${it}SEARCH_TERM$cl.

\tnotes [--remove|-r] $ul${it}notebook$cl [${ul}${it}nested notebook ...$cl] [${ul}${it}note$cl]
\t\tRemove an entire notebook or just a note within a notebook.

\tnotes [--add|-a] [${ul}${it}parent notebook ...$cl] $ul${it}notebook$cl
\t\tCreate a new notebook"
    exit 1
}

__edit() {
    if [ ! -d "$NOTESDIR/$1" ]; then
        echo "Error: notebook \"$1\" does not exist!"
        exit 1
    fi

    if [ -z "$2" ]; then
        echo "Opening new note in \"$1\""
        edit=""
    else
        echo "Opening \"$2.md\" from notebook \"$1\""
        edit="$NOTESDIR/$1/$2.md"
    fi

    if [[ $EDITOR == "nvim" ]] && hash nvim >/dev/null 2>&1; then
        nvim "+cd $NOTESDIR/$1" "+Goyo" "$edit"
    elif [ -n "$EDITOR" ] && hash $EDITOR >/dev/null 2>&1; then
        old=$(pwd)
        cd $NOTESDIR/$1 && $EDITOR "$edit"; cd $old
    elif hash vi >/dev/null 2>&1; then
        echo "Warning: Your EDITOR environment variable is not configured."
        echo "Attempting to use vi"
        old=$(pwd)
        cd $NOTESDIR/$1 && vi "$edit"; cd $old
    else
        echo "Error: Your EDITOR environment variable is not configured"
        echo "and vi could not be used as a backup."
        exit 1
    fi
}

__search() {
    if hash ag  >/dev/null 2>&1; then
        ag "$1" "$2"
    else
        grep --color=auto --exclude-dir .git -iR "$1" "$2"
    fi
}

__remove() {
    if [ ! -d "$NOTESDIR/$1" ]; then
        echo "Error: $1 is not a valid notebook name"
        exit 1
    elif [ -n "$2" ] && [ ! -f "$NOTESDIR/$1/$2.md" ]; then
        echo "Error: Note \"$2.md\" could not be found in \"$1\""
        exit 1
    fi
    if [ -z "$2" ]; then
        echo "Warning: Deleting notebook \"$1\". This will remove all notes within this notebook."
        path_to_delete="$1"
    else
        echo "Warning: Deleting note \"$2.md\" from notebook \"$1\". You will not be able to recover this note easily."
        path_to_delete="$1$2.md"
    fi
    read -p "Are you sure? [y/n] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[yY]$ ]]; then
        rm -rf "$NOTESDIR/$path_to_delete"
        if [ $? -eq 0 ]; then echo "\"$path_to_delete\" removed."; else echo "Error while deleting \"$path_to_delete\""; exit 1; fi
    else
        echo "Cancelled"
    fi
    exit 0
}

__path_until_file() {
    path=""
    n=$(eval "echo $1")
    while [ -d "$NOTESDIR/$path$n" ] && [ $# -gt 0 ]; do
        path="$path$n/"
        shift
        n=$(eval "echo $1")
    done
    echo $path
}

if [[ $# -gt 1 ]]; then
    case "$1" in
        -s|--search)
            shift
            SEARCHSTR=$@
            ;;
        -r|--remove)
            NOTEBOOKREMOVEPATH=$(__path_until_file "${@:2}")
            NOTEREMOVEPATH=$(eval "echo ${@: -1}")
            [ -f "$NOTESDIR/$NOTEBOOKREMOVEPATH/$NOTEREMOVEPATH.md" ] || unset NOTEREMOVEPATH
            ;;
        -a|--add)
            ADDPATH=$(__path_until_file "${@:2}")
            ADDNAME=$(eval "echo ${@: -1}")
            ;;
        *)
            NOTEBOOK=$(__path_until_file "${@:1}")
            NOTE=$(eval "echo ${@: -1}")
            ;;
    esac
else
    __usage "Invalid number of parameters"
fi

if [ -n "$SEARCHSTR" ]; then
    echo "Searching all notebooks for \"$SEARCHSTR...\""
    __search "$SEARCHSTR" "$NOTESDIR"
    exit 0;
elif [ -n "$NOTEBOOKREMOVEPATH" ]; then
    __remove "$NOTEBOOKREMOVEPATH" "$NOTEREMOVEPATH"
elif [ -n "$ADDNAME" ]; then
    echo "Creating new notebook $ADDPATH$ADDNAME..."
    mkdir "$NOTESDIR/$ADDPATH$ADDNAME"
    if [ -d "$NOTESDIR/$ADDPATH$ADDNAME" ]; then
        echo "Notebook \"$ADDNAME\" successfully created"
    else
        echo "Error while creating Notbook \"$ADDNAME\""
    fi
elif [ -n "$NOTEBOOK" ]; then
    __edit "$NOTEBOOK" "$NOTE" #If note not set, create a new one
fi
