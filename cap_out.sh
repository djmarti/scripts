#! /bin/bash
# cap_out.sh   remove first page from a pdf
#              (useful to get rid of the annoying banners added by Science
#              Magazine, JSTOR and others)
#
# This one-line script takes a pdf as input and removes its first page (where
# banners are). Be careful, as the original pdf will be lost. The script is
# basically a wrapper to the proper invocation of pdftk to do exactly that.#
#
# usage:
#	cap_out.sh file.pdf
#
# After calling the script, file.pdf doesn't contain its original first page.
#
TMPFILE=`mktemp` || exit 1
pdftk $1 cat 2-end output $TMPFILE
mv -f $TMPFILE $1
