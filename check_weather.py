#!/usr/bin/env python
import subprocess
import re

output=subprocess.Popen(['weather', 'LFPG'], stdout=subprocess.PIPE).stdout.read()

p = re.compile("(?:.|\n)*Temperature:.*\(([-\d\.]*) C\)\n.*Humidity: (\d*%)\n(?:.*\n)(.*)")
m = p.match(output)
if m:
    print "%sC %s" % (m.group(1), m.group(2))
