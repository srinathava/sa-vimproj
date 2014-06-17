#!/usr/bin/env python
import sys
import commands

fileName = sys.argv[1]

out = commands.getoutput('p4 fstat %s' % fileName)
if 'no such file' in out:
    commands.getoutput('p4 add %s' % fileName)

commands.getoutput('p4 edit %s' % fileName)

