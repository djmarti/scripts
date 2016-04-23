#!/bin/bash

DESTDIR=$1

echo "Preset=$PRESET Destination=$DESTDIR Source=`pwd`"

for a in *.flac
do
    OUTF=`echo "$a" | sed s/\.flac/.mp3/g`

    echo "Source=`pwd`/$a Destination=$DESTDIR/$OUTF"

    ARTIST=`metaflac "$a" --show-tag=ARTIST | sed s/.*=//g`
    TITLE=`metaflac "$a" --show-tag=TITLE | sed s/.*=//g`
    ALBUM=`metaflac "$a" --show-tag=ALBUM | sed s/.*=//g`
    GENRE=`metaflac "$a" --show-tag=GENRE | sed s/.*=//g`
    TRACKNUMBER=`metaflac "$a" --show-tag=TRACKNUMBER | sed s/.*=//g`
    YEAR=`metaflac "$a" --show-tag=DATE | sed s/.*=//g | cut -b -4`

    echo "Launching: flac -c -d $a | lame --preset standard - $DESTDIR/$OUTF"

    flac -c -d "$a" | lame --preset standard - "$DESTDIR/$OUTF"

    echo "Setting id3 ($TITLE, $TRACKNUMBER, $ARTIST, $ALBUM, $GENRE, $YEAR)"

    if test "x$TITLE" != "x"; then
        id3v2 -t "$TITLE" "$DESTDIR/$OUTF" > /dev/null
    fi

    if test "x$TRACKNUMBER" != "x"; then
        id3v2 -T "$TRACKNUMBER" "$DESTDIR/$OUTF" > /dev/null
    fi

    if test "x$ARTIST" != "x"; then
        id3v2 -a "$ARTIST" "$DESTDIR/$OUTF" > /dev/null
    fi

    if test "x$ALBUM" != "x"; then
        id3v2 -A "$ALBUM" "$DESTDIR/$OUTF" > /dev/null
    fi

    if test "x$GENRE" != "x"; then
        id3v2 -g "$GENRE" "$DESTDIR/$OUTF"
    fi

    if test "x$YEAR" != "x"; then
        id3v2 -y "$YEAR" "$DESTDIR/$OUTF"
    fi
done
