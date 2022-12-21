import sys
import time

# const
JUMP_SIZE = 256*16
LEN_SIZE = 8
JUMP_BITS = (JUMP_SIZE-1).bit_length()
LEN_BITS = (LEN_SIZE-1).bit_length()
BITS_SIZE = JUMP_BITS+LEN_BITS

def write_bit_stream(text, filename):
    with open(filename, "wb") as f:
        i = 0
        while i < len(text)//8:
            b = int(text[(i*8):(i*8)+8], 2)
            f.write(b.to_bytes(1, byteorder='big'))
            i += 1
        remain = len(text) % 8
        if remain > 0:
            b = int(text[(i*8):(i*8)+remain], 2) << (7 - remain)
            f.write(b.to_bytes(1, byteorder='big'))

def lz_encode(text, outputfile="", do_print = True):

    # init variable
    slz_text = ""
    i = 0
    last_time = time.time()

    # loop in the text
    if do_print:
        print("process...")
    while i < len(text):
        # print progress from time to time
        now = time.time()
        if now - last_time > 2:
            last_time = now
            if do_print:
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
    if do_print:
        print("100 %")

    # write encoded text to file
    if outputfile != "":
        if do_print:
            print("writing...")
        write_bit_stream(slz_text, outputfile)

    if do_print:
        print("done")
    
    return slz_text

if __name__ == "__main__":
    # arg
    inputfile = sys.argv[1]
    outputfile = sys.argv[2]

    print("start")

    print("jump size:", JUMP_SIZE)
    print("len size:", LEN_SIZE)

    # read text from file
    print("read file...")
    with open(inputfile, "r") as f:
        text = f.read()

    # call
    lz_encode(text, outputfile)
