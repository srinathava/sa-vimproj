#!/usr/bin/env python

import commands, re, time
import subprocess
import sys

def startMatlab(extraArgs):
    if ('-nojvm' in extraArgs) or ('-nodesktop' in extraArgs):
        useXterm = True
    else:
        useXterm = False

    extraArgs = extraArgs.split()
    if useXterm:
        pid = subprocess.Popen(['xterm', '-e', 'sb'] + extraArgs).pid
    else:
        pid = subprocess.Popen(['sb'] + extraArgs).pid

    # wait for the correct MATLAB process to be loaded.
    n = 0
    while 1:
        pst = commands.getoutput('pstree -p %d' % pid)
        m = re.search(r'MATLAB\((\d+)\)', pst)
        if m:
            return int(m.group(1))

        time.sleep(0.5)
        n += 1
        if n == 10:
            return 0

if __name__ == "__main__":
    pid = startMatlab(' '.join(sys.argv[1:]))
    print pid

