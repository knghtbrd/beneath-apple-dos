#! /usr/bin/env python3

"""extract_piewriter.py <filename> [<filename>...]

Extracts PIEWriter documents extracted as raw "#064000" (binary blob) files
from Apple DOS 3.3 disks.  Performs the following conversions:

 - Strips high bits from printable ASCII characters that have it set.
 - Converts Mac-style CR-delimited lines to UNIX-style LF-delimited.
 - Replaces any other character with its C-style escaped hex representation
   (e.g., NUL is replaced with \\x00)

The output is rough, but its enough to check it in to a git repository and
begin cleaning up now properly text files.
"""

import sys

if len(sys.argv) == 1:
    print(sys.modules[__name__].__doc__)
    sys.exit(1)

for arg in sys.argv[1:]:
    with open(arg, 'rb') as f:
        infile = f.read()

    outfile = bytearray()

    for val in infile:
        if 0xa0 <= val < 0xff:
            outfile.append(val & 0x7f)
        elif val in (0x0d, 0x8d, 0x8a):
            outfile.append(0x0a)
        else:
            outfile.extend('\\x{:02x}'.format(val).encode('ASCII'))

    outname = ''.join((arg, '.txt'))
    print('Saving', outname)
    with open(outname, 'wb') as f:
        f.write(outfile)
