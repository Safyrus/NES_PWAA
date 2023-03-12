from lz_encode import *
import os.path

# const
BLOCK_SIZE = 8192
BANK_SIZE = 8192
STARTING_BANK = 8
STARTING_ADR = 0xA000

# args
inputfile = sys.argv[1]
outputfile = os.path.splitext(os.path.basename(inputfile))[0] + "_blocks.bin"
if len(sys.argv) > 2 :
    outputfile = sys.argv[2]
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
print("cut text in blocks...")
blocks = []
while len(text) > BLOCK_SIZE:
    blocks.append(text[:BLOCK_SIZE])
    text = text[BLOCK_SIZE:]
# write last block
blocks.append(text)
print("number of blocks:", len(blocks))

# encode blocks
print("compress blocks...")
i = 0
text = ""
block_bnk = []
block_adr = []
adr_tmp = 0
for b in blocks:
    print("encode block", i)

    lt = len(text) // 8
    bnk_idx = (lt // BANK_SIZE) + 0x80 + STARTING_BANK
    block_bnk.append(bnk_idx)
    block_adr.append((adr_tmp % BANK_SIZE) + STARTING_ADR)
    encode_block = lz_encode(b, outputfile="", do_print=False)

    l = len(encode_block) // 8
    adr_tmp += l+2
    print(f"block {i} size:{hex(l)} bnk:{hex(block_bnk[-1])} adr:{hex(block_adr[-1])}")
    if l > (BLOCK_SIZE - 2):
        print(f"ERROR: block {i} too large !")

    text += format(l % 256, "08b")
    text += format(l // 256, "08b")
    text += encode_block
    i += 1

print("number of banks:", (len(text) // 8) // BANK_SIZE)
print("total size:", len(text) // 8, "bytes")

# write results
write_bit_stream(text, outputfile)
with open(asmfile, "w") as f:
    f.write("; TODO description\n")
    f.write("\n.segment \"TXT_BNK\"\n.incbin \"" + outputfile + "\"\n")
    f.write("\n.segment \"CODE_BNK\"\n")
    f.write("lz_bnk_table:\n")
    for b in block_bnk:
        f.write(".byte $" + "%0.2X" % b + "\n")
    f.write("\nlz_adr_table_lo:\n")
    for b in block_adr:
        f.write(".byte $" + "%0.2X" % (b % 256) + "\n")
    f.write("\nlz_adr_table_hi:\n")
    for b in block_adr:
        f.write(".byte $" + "%0.2X" % (b // 256) + "\n")
