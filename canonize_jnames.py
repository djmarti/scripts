#!/usr/bin/env python

"""Given a BibTeX file (.bib) with with short and/or long journal names in it,
return a new .bib file with the journal names abbreviated (default) or
complete, using the standard abbreviatures of the the Congress Library (or
something like that)"""

import re
import os.path
import sys
import getopt
from UserDict import UserDict

try:
    opts, args = getopt.gnu_getopt(sys.argv[1:], "sl", ["short", "long"])
except getopt.GetoptError:
    sys.exit(2)

complete = True

for o, v in opts:
    if o in ("-s", "--short"):
        complete = False
    if o in ("-l", "--long"):
        complete = True

# Original algorithm by Xavier Defrang.
# http://aspn.activestate.com/ASPN/Cookbook/Python/Recipe/81330
# This implementation by alane@sourceforge.net.
class textsub(UserDict):
    """This recipe shows how to use the Python standard re module to perform
    single-pass multiple string substitution using a dictionary."""
    def __init__(self, dict = None):
        self.re = None
        self.regex = None
        UserDict.__init__(self, dict)

    def compile(self):
        if len(self.data) > 0:
            tmp = r"(\b%s\b)" % "|".join(self.data.keys())
            #tmp = r"(\b%s\b)" % "|".join(map(re.escape, self.data.keys()))
            tmp = tmp.replace(r"\ ", r"\s*")
            if self.re != tmp:
                self.re = tmp
                self.regex = re.compile(self.re)

    def __call__(self, match):
        return self.data[match.string[match.start():match.end()]]

    def replace(self, s):
        if len(self.data) == 0:
            return s
        return self.regex.sub(self, s)

jnames = {} # The dictionary we will use

#f_input = os.path.join(os.path.dirname(__file__), "journal_abbreviations.txt")
f_input = os.path.join(os.path.expanduser("~"), "share/journal_abbreviations.txt")
print f_input

fileIN = open(f_input, "r")
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
     (long, abbrv) = rows_re.search(l).group(1,2)
     jnames[long]=abbrv

# Read bib file (with full, long journal names)
b = open(args[0], "r")
s = b.read()
b.close()
s = s.rstrip('\n')

journal_pat = re.compile('(\s*journal\s*=\s*"(\\.|[^"])*)\n+\s*((\\.|[^"])*")')
s = journal_pat.sub(r"\1 \3", s)

X = textsub(jnames)
X.compile()
o = X.replace(s)
print o

