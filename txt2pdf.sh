#!/bin/sh
# iconv -f UTF-8 -t latin1 $1 | a2ps -o $1{%.txt}.ps
outfile=${1%.txt}.pdf
paps $1 --font="Cousine 12" --left-margin 70 --right-margin 70 --top-margin 65 | ps2pdf - $outfile
echo "Output file as $outfile"
