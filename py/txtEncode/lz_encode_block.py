from lz_encode import *
import os.path

# const
BLOCK_SIZE = 8192
BANK_SIZE = 8192
STARTING_BANK = 1

# args
inputfile = sys.argv[1]
asmfile = "txt_data.asm"

#
print("start")
print("jump size:", JUMP_SIZE)
print("len size:", LEN_SIZE)

# read text from file
print("read file...")
with open(inputfile, "rb") as f:
    text = f.read()

# cut text into blocks
blocks = []
while len(text) > BLOCK_SIZE:
    blocks.append(text[:BLOCK_SIZE])
    text = text[BLOCK_SIZE:]
# write last block
blocks.append(text)
print("number of blocks:", len(blocks))

# encode blocks
i = 0
text = ""
block_bnk = []
for b in blocks:
    print("encode block", i)
    block_bnk.append((len(text) // BANK_SIZE) + 0x80 + STARTING_BANK)
    encode_block = lz_encode(b, outputfile="", do_print=False)
    l = len(encode_block) // 8
    print(f"block {i} size: {hex(l)}")
    if l > (BLOCK_SIZE - 2):
        print(f"ERROR: block {i} too large !")
    text += format(l % 256, "08b")
    text += format(l // 256, "08b")
    text += encode_block
    i += 1

# write results
outputfile = os.path.splitext(os.path.basename(inputfile))[0] + ".bin"
write_bit_stream(text, outputfile)
with open(asmfile, "w") as f:
    f.write("; TODO description\n")
    f.write("\n.segment \"TXT_BNK\"\n.incbin \"" + outputfile + "\"\n")
    f.write("\n.segment \"CODE_BNK\"\n")
    f.write("lz_bnk_table:\n")
    for b in block_bnk:
        f.write(".byte $" + "%0.2X" % b + "\n")
