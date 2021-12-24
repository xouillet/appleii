import argparse
import logging
import wave
import sys

logger = logging.getLogger()


def parse_wav(fd, framerate, samplewidth, is_wav):

    out = []
    data = None

    lastbinsample = None
    us_lastbinsample = 0

    laststate, state = -1, -1  # 0: header, 1: data, 2: sync, 3:end

    byte = byte_counter = 0

    while True:
        if is_wav:
            sample = fd.readframes(1)
        else:
            sample = fd.read(samplewidth // 8)

        if not sample:
            break

        binsample = round(
            int.from_bytes(sample, byteorder="little") / (2 ** (samplewidth))
        )
        if lastbinsample is None:
            lastbinsample = binsample

        if binsample != lastbinsample:
            if binsample == 1:
                if us_lastbinsample >= 600:
                    state = 0
                elif us_lastbinsample <= 200:
                    state = 2
                elif us_lastbinsample > 200:
                    state = 1

                if state != laststate:
                    logger.info(f"{w.tell()} -> {state}")
                    if state == 1:
                        data = bytearray()
                        byte = byte_counter = 0
                    elif laststate == 1:
                        data, cksum = checksum(data)
                        if data:
                            out.append(data)

                if state == 1:
                    if us_lastbinsample >= 375:
                        bit = 1
                    else:
                        bit = 0

                    byte = (byte << 1) + bit
                    byte_counter += 1
                    if byte_counter == 8:
                        data.append(byte)
                        byte = byte_counter = 0

            us_lastbinsample = 0

        lastbinsample = binsample
        laststate = state

        us_lastbinsample += 1e6 / framerate

    data, cksum = checksum(data)
    if data:
        out.append(data)

    return out


def checksum(data):
    if not data:
        return None, None

    eor = 0xFF
    for byte in data[:-1]:
        eor ^= byte

    ok = eor == data[-1]
    if not ok:
        logger.error(f"Checksum bad :(, expected {hex(data[-1])} got {hex(eor)}")

    return data[:-1], ok


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)

    parser = argparse.ArgumentParser(description="t2c -- tape to code")
    group_mutex = parser.add_mutually_exclusive_group()
    group_mutex.add_argument("-w", "--wav", metavar="wav", type=str, help="wave file")
    group_mutex.add_argument(
        "-i", "--raw", metavar="rawfile", type=str, help="rawfile file"
    )
    parser.add_argument(
        "-r", "--rate", metavar="rate", type=int, help="rate in Hz for raw"
    )
    parser.add_argument(
        "-s",
        "--samplewidth",
        metavar="witdh",
        type=int,
        help="samplewidth in bits for raw",
    )

    args = parser.parse_args()

    if args.raw and not (args.rate and args.samplewidth):
        logger.error("Please specify sample rate and sample width for raw")
        sys.exit(1)

    if args.wav:
        w = wave.open(args.wav)
        out = parse_wav(w, w.getframerate(), w.getsampwidth() * 8, True)
    else:
        w = open(args.raw, "rb")
        out = parse_wav(w, args.rate, args.samplewidth, False)

    print("\n".join([e.hex() for e in out]))
