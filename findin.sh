#!/bin/sh
find . -name "*.$1" -print0 | xargs -0 grep "$2"
