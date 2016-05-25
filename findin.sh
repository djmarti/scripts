#!/bin/sh
# A very simple but handy script. It looks for all the files with a given
# extension and greps a particular pattern on all of them. The search is done
# recursively.
find . -name "*.$1" -print0 | xargs -0 grep "$2"
