import wave

w = wave.open("pipo.wav")

c = 0

last = None

laststate, state = -1, -1  # 0: header, 1: data, 2: sync

out = bytearray()
b = 0
cb = 0

while True:
    sample = w.readframes(1)
    if not sample:
        break

    binsample = round(ord(sample) / (0xFF * w.getsampwidth()))
    if last is None:
        last = binsample

    if binsample != last:
        if binsample == 1:
            if c >= 600:
                state = 0
            elif c <= 150:
                state = 2
            else:
                state = 1
                if c >= 375:
                    bit = 1
                else:
                    bit = 0

                b = (b << 1) + bit
                cb += 1
                if cb == 8:
                    out.append(b)
                    b = 0
                    cb = 0

        if state != laststate:
            print(f"{w.tell()} -> {state}")
            print(c)

        c = 0

    last = binsample
    laststate = state
    c += 1e6 / w.getframerate()

eor = 0xFF
for e in out[:-1]:
    print(hex(e), end=" ")
    eor ^= e
print("")

if eor == out[-1]:
    print("Checksum ok !")
else:
    print(f"Checksum bad :(, expected {hex(out[-1])} got {hex(eor)}")

with open("out.bin", "wb") as f:
    f.write(out[:-1])
