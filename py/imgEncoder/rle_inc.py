from rm_equal_tile import *

RLEINC_CMD_LIT = 0x00
RLEINC_CMD_END = 0x40
RLEINC_CMD_SEQ = 0x41
RLEINC_CMD_DBL = 0x80
RLEINC_CMD_RUN = 0xA0


def rleinc_next(data, i):
    return data[i], i + 1


def rleinc_runsize(data, i):
    d = data[i]
    run_size = 0
    while i < len(data) and d == data[i] and run_size < 0x5F:
        run_size += 1
        i += 1
    return run_size


def rleinc_seqsize(data, i):
    d = data[i]
    seq_size = 0
    while i < len(data) and d == data[i] and seq_size < 0x3E:
        seq_size += 1
        i += 1
        d += 1
    return seq_size


def rleinc_dblsize(data, i):
    d1 = data[i]
    d2 = data[i+1]
    dbl_size = 0
    while i+1 < len(data) and d1 == data[i] and d2 == data[i+1] and dbl_size < 0x1F*2:
        dbl_size += 2
        i += 2
    return dbl_size


def rleinc_encode(data):
    out = []
    i = 0
    while i < len(data):
        d1 = data[i]
        d2 = -1
        if i+1 < len(data):
            d2 = data[i+1]
        run_size = rleinc_runsize(data, i)
        seq_size = rleinc_seqsize(data, i)
        dbl_size = 0
        if d2 >= 0:
            dbl_size = rleinc_dblsize(data, i)

        # print(run_size, seq_size, dbl_size)

        if run_size < 2 and seq_size < 2 and dbl_size < 3:
            # print("LIT")
            out.append(0x00)
            out.append(d1)
            i += 1
        elif run_size >= seq_size and run_size >= dbl_size:
            # print("RUN", run_size)
            out.append(0x101 - run_size)
            out.append(d1)
            i += run_size
        elif seq_size >= run_size and seq_size >= dbl_size:
            # print("SEQ", seq_size)
            out.append(seq_size + 0x3F)
            out.append(d1)
            i += seq_size
        elif dbl_size >= run_size and dbl_size >= seq_size:
            # print("DBL", dbl_size)
            out.append(dbl_size + 0x7D)
            out.append(d1)
            out.append(d2)
            i += dbl_size
        else:
            print("ERROR")

    # print("END")
    out.append(RLEINC_CMD_END)
    return out


def rleinc_decode(data):
    out = []
    idx = 0
    while True:
        n, idx = rleinc_next(data, idx)
        if n == RLEINC_CMD_END:
            # print("[DECODE]: END")
            return out
        elif n < RLEINC_CMD_SEQ:
            # print("[DECODE]: LIT", n+1)
            for _ in range(n+1):
                b, idx = rleinc_next(data, idx)
                out.append(b)
        elif n < RLEINC_CMD_DBL:
            b, idx = rleinc_next(data, idx)
            # print("[DECODE]: SEQ", n-0x3F, b)
            for _ in range(n-0x3F):
                out.append(b)
                b += 1
        elif n < RLEINC_CMD_RUN:
            b1, idx = rleinc_next(data, idx)
            b2, idx = rleinc_next(data, idx)
            # print("[DECODE]: DBL", n-0x7D, b1, b2)
            for _ in range(n-0x7D):
                out.append(b1)
                b1, b2 = b2, b1
        elif n < 0x100:
            b, idx = rleinc_next(data, idx)
            # print("[DECODE]: RUN", 0x101-n, b)
            for _ in range(0x101-n):
                out.append(b)
        else:
            print("ERROR", n, idx)


if __name__ == "__main__":
    filename = sys.argv[1]

    print("reading...")
    with open(filename, "rb") as f:
        byteData = f.read()
    data = []
    for d in byteData:
        data.append(int(d))
    print("data size:", len(data))

    print("data before:")
    print(data)

    print("encoding...")
    encode = rleinc_encode(data)
    print("encode size:", len(encode))
    print("encode data:")
    print(encode)

    print("decoding...")
    decode = rleinc_decode(encode)

    print("data after:")
    print(decode)

    if len(data) != len(decode):
        print("ERROR: decoded data is of different size from source data:",
              len(data), len(decode))
    else:
        err = False
        for i in range(len(data)):
            if data[i] != decode[i]:
                print("ERROR at", i, data[i], decode[i])
                err = True
        if not err:
            print("OK. decoded data match source data")
