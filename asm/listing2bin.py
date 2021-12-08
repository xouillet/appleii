import re
import sys

code = bytearray([0] * 0x800)

for line in open(sys.argv[1], "r"):
    m = re.match("([0-9A-F]+): ([0-9A-F ]*)$", line)
    if m:
        addr = int(m.group(1), 16)
        ba = bytearray([int(e, 16) for e in m.group(2).split()])
        code[addr : addr + len(ba)] = ba

with open(f"{sys.argv[1]}.bin", "wb") as f:
    f.write(code)
