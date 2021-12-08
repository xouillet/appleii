import sys

eor = 0

with open(sys.argv[1], "rb") as f:
    while True:
        c = f.read(1)
        if len(c) == 0:
            break
        eor = eor ^ ord(c)

print(hex(eor))
