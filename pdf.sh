#!/bin/bash
NOTES_DIR="$HOME/.notes"

SOURCE=$1
EXPORTED_DOC=$2
TEMPLATE=$3
PANDOC=`which pandoc`
if [ -z $TEMPLATE  ]; then
    PANDOC_PDF_TEMPLATE="--template=$NOTES_DIR/template.latex"
else
    PANDOC_PDF_TEMPLATE="--template=$NOTES_DIR/$TEMPLATE.latex"
fi
PANDOC_OPTIONS="--pdf-engine=xelatex --mathjax --filter pandoc-citeproc -f markdown -V margin-left:.75in -V margin-right:.75in -V margin-top:.5in -V margin-bottom:1in"

if ! hash pandoc 2>/dev/null 1>&2; then
    echo "pandoc is not installed"
    exit 1
fi

if ! hash pandoc-citeproc 2>/dev/null 1>&2; then
    echo "pandoc-citeproc is not installed"
    exit 1
fi

if [ ! -f "$NOTES_DIR/template.latex" ]; then
    echo "Could not find template, pandoc default template"
    eval "$PANDOC $PANDOC_OPTIONS -o $EXPORTED_DOC < $SOURCE"
else
    eval "$PANDOC $PANDOC_OPTIONS $PANDOC_PDF_TEMPLATE -o $EXPORTED_DOC < $SOURCE"
fi
