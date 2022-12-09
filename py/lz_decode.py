import sys

print("start")

# const
MAX_STATS_PRINT = 32
JUMP_SIZE = 256
LEN_SIZE = 8
JUMP_BITS = (JUMP_SIZE-1).bit_length()
LEN_BITS = (LEN_SIZE-1).bit_length()
BITS_SIZE = JUMP_BITS+LEN_BITS
print("jump size:", JUMP_SIZE)
print("len size:", LEN_SIZE)
print("bits size:", BITS_SIZE)

# arg
inputfile = sys.argv[1]
outputfile = sys.argv[2]

# read text from file
print("read file...")
slz_text = ""
with open(inputfile, "rb") as f:
    while (byte := f.read(1)):
        n = int.from_bytes(byte, "big")
        slz_text += format(n, "08b")

# stats
stats_l = [0]*LEN_SIZE
stats_j = [0]*JUMP_SIZE
#
text = ""
i = 0
while i < len(slz_text):
    first_bit = slz_text[i]
    i += 1
    if first_bit == "1":
        l = int(slz_text[i:i+LEN_BITS], 2) + 2
        j = int(slz_text[i+LEN_BITS:i+LEN_BITS+JUMP_BITS], 2)
        s = text[-j-1:-j-1+l]
        if len(s) != l:
            print("ERROR", l, j, len(text))
        i += BITS_SIZE
        # stats
        stats_l[l-2] += 1
        stats_j[j] += 1
    else:
        s = chr(int(slz_text[i:i+7], 2))
        i += 7
    text += s

# stats
print("### stats ###")
print("len:")
for _ in range(0, min(MAX_STATS_PRINT, len(stats_l))):
    max_val = max(stats_l)
    max_idx = stats_l.index(max_val)
    print(max_idx, ":", max_val)
    stats_l[max_idx] = 0
print("jmp:")
for _ in range(0, min(MAX_STATS_PRINT, len(stats_j))):
    max_val = max(stats_j)
    max_idx = stats_j.index(max_val)
    print(max_idx, ":", max_val)
    stats_j[max_idx] = 0

# write decoded text to file
print("writing...")
with open(outputfile, "w") as f:
    f.write(text)

print("done")
