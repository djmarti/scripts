#!/usr/bin/env python3

'''Given a BibTeX file (.bib) with with short and/or long journal names in it,
return a new .bib file with the journal names abbreviated (default) or
complete, using the standard abbreviatures of the the Congress Library
stored in a file called 'journal_abbreviations.txt'.

TODO: It would be cool to fill 'journal_abbreviations.txt' automatically.'''

import re
import os.path
import sys
import getopt

try:
    opts, args = getopt.gnu_getopt(sys.argv[1:], 'sl', ['short', 'long'])
except getopt.GetoptError:
    sys.exit(2)

complete = True

for o, v in opts:
    if o in ('-s', '--short'):
        complete = False
    if o in ('-l', '--long'):
        complete = True

# Original algorithm by Xavier Defrang.
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/81330
# This implementation by alane@sourceforge.net.
# Updated in
# http://stackoverflow.com/questions/15175142/how-can-i-do-multiple-substitutions-using-regex-in-python

def multiple_replace(d, text):
    '''This recipe shows how to use the Python standard re module to perform
    single-pass multiple string substitution using a dictionary.'''
    regex = re.compile('({})'.format('|'.join(map(re.escape, d.keys()))))
    return regex.sub(
        lambda mo: d[mo.string[mo.start():mo.end()]], text)

jnames = {}
f_input = os.path.join(os.path.dirname(__file__),
                       'journal_abbreviations.txt')

fileIN = open(f_input, 'r')
string = fileIN.read()
fileIN.close()

string = string.rstrip('\n')
lines = re.split('\n', string)

source, final = 1, 2
if complete:
    source = 2
    final = 1

# Fill dictionary with entries
rows_re = re.compile('^(\".*\"),\s*(\".*\")')
for l in lines:
    (long, abbrv) = rows_re.search(l).group(1, 2)
    jnames[long] = abbrv

# Read bib file (with full, long journal names)
b = open(args[0], 'r')
s = b.read()
b.close()
s = s.rstrip('\n')

journal_pat = re.compile('(\s*journal\s*=\s*"(\\.|[^"])*)\n+\s*((\\.|[^"])*")')
s = journal_pat.sub(r'\1 \3', s)

print(multiple_replace(jnames, s))
