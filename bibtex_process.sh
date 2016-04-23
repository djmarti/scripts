#!/bin/sh
# bibtex_process.sh: clean, sort, and check bibtex files.
#
#     bibtex process.sh is a wrapper for bibtool and bibclean tools (which
#     should be installed in your system).
bibtool -s -v -d -i $1 | bibclean -align-equals > tmp.bib
mv -f tmp.bib $1
