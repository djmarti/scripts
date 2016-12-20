#!/bin/bash
# set -x
# This script takes a pdf or a postscript file and scales and rotates
# the pages to fit in the sheet of paper. While many Pring Dialog boxes
# allow the user to do exactly that, this script lets the user fine-tune
# the scale factor, the width of the margins, the horizontal separation
# between pages in a 2-page layout, or the offsets. 

usage="Usage: `basename $0`  [-s factor] [-n pages per sheet] [-H hoffset] [-V voffset] [-C padding] [-p paper] [-b] [-h] file.{pdf,ps}\n
   -b adds a blank page at the beginning of the document (used mainly in 2-page-per-sheet copies)."
pages=1
factor=1.0
paper="A4"
hoffset=0
voffset=0
padding=0
blank=0


if [ -z $1 ]
then
    # Exit and complain if no argument(s) given.
    echo 1>&2   $usage
    exit $OPTERROR
fi  

while getopts "s:n:V:H:C:p:bh" options; do
    case $options in
	s ) factor=$OPTARG;;
        n ) pages=$OPTARG;;
        V ) voffset=$OPTARG;;
        H ) hoffset=$OPTARG;;
        C ) padding=$OPTARG;;
        p ) paper=$OPTARG;;
        b ) blank=1;;
	h ) echo $usage
            exit 1;;
	\? ) echo $usage
	exit 1;;
	* ) echo $usage
	exit 1;;
    esac
done

shift $(($OPTIND - 1))
# basename
file=$1
basename=`basename "$file"`
directory=`dirname "$file"`
# The opposite effect (trailing) is obtained using “%” and “%%”
basename_nopref="${basename%.*}"
extension="${basename##*.}"
output_file="/tmp/${basename_nopref}_tmp.ps"

echo $file
echo $basename
echo $directory
echo $base_name_nopref
# default factor: 1
if [ $paper == "A4" ]; then
    width=210
    height=297
    ratio=1.4142
elif [ $paper == "letter" ]; then
    width=215.9
    height=279.4
    ratio=1.2941
else
    echo "Paper option should be 'a4' or 'letter'"
    exit 1
fi

if [ $extension == "pdf" ]; then
    processed_input="/tmp/${basename_nopref}.ps"
    echo "Converting ${directory}/${basename} to ${processed_input}"
    pdftops -duplex -paper ${paper} $1 ${processed_input}
elif [ $extension == "ps" ]; then
    processed_input=$1
fi

cp_input=`mktemp -t`
cp ${processed_input} ${cp_input}

if [ $blank == 1 ]; then
    tmp=`mktemp -t`
    psselect -p _,1- ${cp_input} $tmp && mv $tmp ${cp_input}
fi

if [ $pages -eq 1 ]; then
    factormid=${factor}
    horizoffset=$(echo "scale=2; 0.5 * (1 - $factor) * $width + ${hoffset}" | bc)
    vertoffset=$(echo "scale=2; 0.5 * (1 - $factor) * $height + ${voffset}" | bc)
    firstspec="${factormid}(${horizoffset}mm,${vertoffset}mm)"
    specs="1:0L@${firstspec}"
    echo ${specs}
    echo "Generating ${output_file}..."
    echo "pstops -p ${paper} \"${specs}\" ${cp_input} ${output_file}"
    pstops -p ${paper} ${specs} ${cp_input} ${output_file}
    # echo "Suggested command:
    #     pstops -p $paper \"1:0@${firstspec}\" $cp_input $output_file"
elif [ $pages -eq 2 ]; then
    # scale factor, f=1.2 -> 1.2/sqrt(2) = 0.849
    # First offset:  horizontal [fH - 0.5(f - 1)H]/sqrt(2) = H * 0.5 (f + 1) /sqrt(2)
    #	           vertical -0.5 (f - 1)W / sqrt(2)
    # Second offset: horizontal (as before)
    #	           vertical -0.5 (f - 1)W + W = W (1.5 - 0.5f) / sqrt(2)
    factormid=$(echo "scale=2; $factor*$ratio/2.0" | bc) 
                    # "scale" determines how many decimal places.
    horizoffset=$(echo "scale=2; ($factormid*$height + $width) / 2.0 - ${voffset}" | bc)
    vertoffsetone=$(echo "scale=2; ${hoffset} -($factormid*${width} - $height/2.0) / 2.0 + ${padding}" | bc)
    vertoffsettwo=$(echo "scale=2; ${hoffset} -($factormid*${width} - $height/2.0) / 2.0 + ${height}/2.0 - ${padding}" | bc)
    firstspec="${factormid}(${horizoffset}mm,${vertoffsetone}mm)"
    secondspec="${factormid}(${horizoffset}mm,${vertoffsettwo}mm)"
    # pstops "2:0" $cp_input $output_file
    #echo "Suggested command:
    #    pstops -p $paper \"2:0L@${firstspec}+1L@${secondspec}\" $cp_input $output_file"
    echo "Generating ${output_file}..."
    specs="2:0L@${firstspec}+1L@${secondspec}"
    echo $output_file
    # Show the action
    tmp0=`mktemp -t`
    echo "pstops \"${specs}\" ${cp_input} ${output_file} && psduplex ${output_file} > ${tmp0} && mv -f ${tmp0} ${output_file}"
    pstops -p ${paper} ${specs} ${cp_input} ${output_file}
    #tmp1=`mktemp -t`
    #psduplex ${output_file} > ${tmp1}
    #mv -f ${tmp1} ${output_file}
else
    echo "The number of pages should be 1 or 2."
    exit 1
fi
echo "Output file written as ${output_file}"
echo -n "Do you want to view the document? <y/n> "
read REPLY
if [ "$REPLY" == "" ] || [ "$REPLY" == "yes" ] || [ "$REPLY" == "y" ] || [ "$REPLY" == "Y" ]; then
    see ${output_file}&
else
    exit 0
fi
