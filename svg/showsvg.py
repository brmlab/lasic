#!/usr/bin/env python

import sys
from SvgProcessor import SvgProcessor


if len(sys.argv) < 2:
    print 'Usage: showsvg filename.svg'
    sys.exit(1)

sp = SvgProcessor()

sp.parseFile(sys.argv[1], 1)

