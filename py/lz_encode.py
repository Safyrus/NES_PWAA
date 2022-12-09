import sys
import time

print("start")

# const
JUMP_SIZE = 256*16
LEN_SIZE = 8
JUMP_BITS = (JUMP_SIZE-1).bit_length()
LEN_BITS = (LEN_SIZE-1).bit_length()
BITS_SIZE = JUMP_BITS+LEN_BITS
print("jump size:", JUMP_SIZE)
print("len size:", LEN_SIZE)

# arg
inputfile = sys.argv[1]
outputfile = sys.argv[2]

# read text from file
print("read file...")
with open(inputfile, "r") as f:
    text = f.read()

# init variable
slz_text = ""
i = 0
last_time = time.time()

# loop in the text
print("process...")
while i < len(text):
    # print progress from time to time
    now = time.time()
    if now - last_time > 2:
        last_time = now
        print(str(int((i/len(text))*100)+1) + " %")

    # get the window
    window = text[max(0, i-JUMP_SIZE):i]

    # put the current character by default
    seq = format(ord(text[i]), "08b")
    foundLen = 1
    foundJmp = -1

    # for each sequence of size l from the current character
    for l in range(2, LEN_SIZE+2):
        str2match = text[i:i+l]
        # look in the window
        j = window.find(str2match)
        maxJmp = max(0,len(window))
        jmp = maxJmp-j-1
        # if it is present
        if j >= 0 and jmp >= l:
            # then output special code
            seq = "1" + format(l-2, "0"+str(LEN_BITS)+"b") + format(jmp, "0"+str(JUMP_BITS)+"b")
            foundLen = l
            foundJmp = jmp

    # increment to the next position in the text
    i += foundLen
    # and add result string
    slz_text += seq
print("100 %")

# write encoded text to file
print("writing...")
with open(outputfile, "wb") as f:
    i = 0
    while i < len(slz_text)//8:
        b = int(slz_text[(i*8):(i*8)+8], 2)
        f.write(b.to_bytes(1, byteorder='big'))
        i += 1
    remain = len(slz_text) % 8
    if remain > 0:
        b = int(slz_text[(i*8):(i*8)+remain], 2) << (7 - remain)
        f.write(b.to_bytes(1, byteorder='big'))

print("done")
