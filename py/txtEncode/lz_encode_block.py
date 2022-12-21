from lz_encode import *
import os.path

# const
BLOCK_SIZE = 8192

# args
inputfile = sys.argv[1]

#
print("start")
print("jump size:", JUMP_SIZE)
print("len size:", LEN_SIZE)

# read text from file
print("read file...")
with open(inputfile, "r") as f:
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
for b in blocks:
    print("encode block", i)
    text += lz_encode(b, outputfile="", do_print=False)
    i += 1

# write results
outputfile = os.path.splitext(os.path.basename(inputfile))[0] + "_blocks.bin"
write_bit_stream(text, outputfile)
