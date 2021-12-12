#!/usr/bin/env python3
import sys
import operator
import functools

with open(sys.argv[1], "rb") as f:
    c = bytearray(f.read())

print(hex(functools.reduce(operator.xor, c)))
