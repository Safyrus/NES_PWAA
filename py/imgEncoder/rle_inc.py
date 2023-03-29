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


def rleinc_allsize(data, i):
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
    return run_size, seq_size, dbl_size, d1, d2


def rleinc_encode(data, doprint=False):
    out = []
    i = 0
    while i < len(data):
        # 
        lit_data = []
        run_size, seq_size, dbl_size, d1, d2 = rleinc_allsize(data, i)
        while (run_size < 2 and seq_size < 2 and dbl_size < 3) and len(lit_data) < 0x40:
            lit_data.append(data[i])
            i += 1
            if i >= len(data):
                break
            run_size, seq_size, dbl_size, d1, d2 = rleinc_allsize(data, i)
        if i >= len(data):
            if len(lit_data) > 0:
                if doprint:
                    print("[ENCODE]: LIT", len(lit_data)-1, i)
                out.append(len(lit_data)-1)
                for d in lit_data:
                    out.append(d)
            break

        #
        if len(lit_data) > 0:
            if doprint:
                print("[ENCODE]: LIT", len(lit_data)-1, i)
            out.append(len(lit_data)-1)
            for d in lit_data:
                out.append(d)
        #
        if len(lit_data) == 0x40:
            continue

        #
        if run_size >= seq_size and run_size >= dbl_size:
            if doprint:
                print("[ENCODE]: RUN", 0x101 - run_size, d1, i)
            out.append(0x101 - run_size)
            out.append(d1)
            i += run_size
        #
        elif seq_size >= run_size and seq_size >= dbl_size:
            if doprint:
                print("[ENCODE]: SEQ", seq_size + 0x3F, d1, i)
            out.append(seq_size + 0x3F)
            out.append(d1)
            i += seq_size
        #
        elif dbl_size >= run_size and dbl_size >= seq_size:
            if doprint:
                print("[ENCODE]: DBL", dbl_size + 0x7D, d1, d2, i)
            out.append(dbl_size + 0x7D)
            out.append(d1)
            out.append(d2)
            i += dbl_size
        #
        else:
            print("ERROR")

    if doprint:
        print("[ENCODE]: END", i)
    out.append(RLEINC_CMD_END)
    return out


def rleinc_decode(data, doprint=False):
    out = []
    idx = 0
    while True:
        n, idx = rleinc_next(data, idx)
        if n == RLEINC_CMD_END:
            if doprint:
                print("[DECODE]: END", len(out))
            return out
        elif n < RLEINC_CMD_SEQ:
            if doprint:
                print("[DECODE]: LIT", n, len(out))
            for _ in range(n+1):
                b, idx = rleinc_next(data, idx)
                out.append(b)
        elif n < RLEINC_CMD_DBL:
            b, idx = rleinc_next(data, idx)
            if doprint:
                print("[DECODE]: SEQ", n, b, len(out))
            for _ in range(n-0x3F):
                out.append(b)
                b += 1
        elif n < RLEINC_CMD_RUN:
            b1, idx = rleinc_next(data, idx)
            b2, idx = rleinc_next(data, idx)
            if doprint:
                print("[DECODE]: DBL", n, b1, b2, len(out))
            for _ in range(n-0x7D):
                out.append(b1)
                b1, b2 = b2, b1
        elif n < 0x100:
            b, idx = rleinc_next(data, idx)
            if doprint:
                print("[DECODE]: RUN", n, b, len(out))
            for _ in range(0x101-n):
                out.append(b)
        else:
            print("ERROR", n, idx)
