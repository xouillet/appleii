#!/usr/bin/env python3
import sys

eor = 0
with open(sys.argv[1], "rb") as f:
    while True:
        c = f.read(1)
        if not c:
            break
        eor ^= ord(c)

print(hex(eor))
