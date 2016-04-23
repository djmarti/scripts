#!/bin/bash
# latexify - convert a plain text document into a LaTeX file.
#            (an ultrapoor-man's version of a text markup formatter)
#
#      This script takes a plain text document as argument and generates a
#      LaTeX file with the same name, but with suffix replaced by .tex. The
#      resulting file can then be compiled with pdflatex. The output file is
#      meant to be a first coarse LaTeX version of the document, with all
#      quotation marks, ampersands, dollar signs, percent signs, and em-dashes
#      properly formated for LaTeX consumption. Beyond that, the output
#      document may likely need some fine-tuning. In particular, the script
#      doesn't handle any fancy markup like headings, emphasis, lists or
#      tables---like any proper text markup format like reST or markdown would
#      do.

usage="Usage: `basename $0` text.txt"
output="${1%.txt}.tex"

cat > $output <<\EOF 
\documentclass[10pt,a4paper,oneside]{article}
\usepackage[T1]{fontenc} 
\usepackage[pdftex]{graphicx}
\usepackage{lmodern}
\usepackage[usenames,dvipsnames]{color}
\usepackage[hmargin=1.2cm,vmargin={1.5cm,1.0cm}, includefoot, footskip=7mm]{geometry}
\usepackage{amsmath}
\usepackage{float}
\usepackage{url}
\usepackage[T1]{fontenc}
%\usepackage{textcomp}
\usepackage{multicol}
\usepackage[pdftex,hyperfigures,breaklinks,colorlinks]{hyperref}
\usepackage[small,center]{titlesec}
\usepackage[english]{babel}

\definecolor{LinkColor}{rgb}{0, 0, 0.3}
\definecolor{ExtLinkColor}{rgb}{0, 0.3, 0}
\hypersetup{citecolor=LinkColor,linkcolor=LinkColor,urlcolor=ExtLinkColor}
\urlstyle{} %?
\setlength{\columnsep}{6mm}

\begin{document}
\begin{flushleft}
  {\huge «-Title-»}\\[1.5mm]
  {\large By «-author-»}\\[1.2mm]
  {\normalsize Published: «-date-»}
\end{flushleft}

\begin{multicols}{3}
  \noindent
EOF


if [ -z $1 ]
then
    # Exit and complain if no argument(s) given.
    echo 1>&2 $usage
    exit 1
fi

cat $1 | sed '
s/"\([^"]*\)"/``\1'\'\''/g
s/“/``/g
s/”/'\'\''/g
s/‘/`/g
s/’/'\''/g
s/—/---/g
s/ //g
s/\s\+-\+\s\+/---/g
s/%/\\%/g
s/\$/\\$/g
s/&/\\&/g' | fold -w 80 -s >> $output

cat >> $output <<\EOF
\end{multicols}
\end{document}'
EOF
