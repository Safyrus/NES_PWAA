import sys
import re

def append_byte(textbin, val, name, i):
    if val > 255:
        print(f"WARNING: {name} is > 255 (val={val}) at {i}. Replacing by 0")
        val = 0
    textbin.append(val)
    return textbin

CHAR_MAP = [
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
    "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_",
    "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", ",", "}", "~", " "
]

END = 0x00  # END of dialog                                             |
LB = 0x01  # Line Break                                                |
DB = 0x02  # Dialog Break                                              |
FDB = 0x03  # Force Dialog Break                                        |
TD = 0x04  # Toggle Dialog Box display                                 |
SET = 0x05  # Set flag                                                  | 1: index
CLR = 0x06  # Clear flag                                                | 1: index
SAK = 0x07  # |
SPD = 0x08  # SPeeD                                                     | 1: speed
DL = 0x09  # DeLay                                                     | 1: delay
NAM = 0x0A  # change NAMe of dialog box                                 | 1: name
FLH = 0x0B  # FLasH                                                     | 1: color
FI = 0x0C  # Fade In                                                   | 1: color
FO = 0x0D  # Fade Out                                                  | 1: color
COL = 0x0E  # change text COLor                                         | 1: color
BC = 0x0F  # change Background Color                                   | 1: color
BIP = 0x10  # change dialog BIP effect                                  | 1: bip
MUS = 0x11  # MUSic                                                     | 1: music
SND = 0x12  # SouND effect                                              | 1: sound
# show PHoto                                                | 1: photo (0=remove)
PHT = 0x13
# CHaRacter to show                                         | 1: character (0=remove)
CHR = 0x14
ANI = 0x15  # character ANImation                                       | 1: animation
BKG = 0x16  # change BacKGround                                         | 1: background
FNT = 0x17  # Change FoNT to use                                        | 1: font
# JuMP to another dialog                                    | jmp_adr, [condition]
JMP = 0x18
# jump to the selected choice (depend on the player ACTion) | (jmp_adr, [condition], text line)*nb_choice
ACT = 0x19
# Background Palette                                        | 4: palettes (pal 0 first)
BP = 0x1A
# Sprite Palette                                            | 4: palettes (pal 0 first)
SP = 0x1B
RES = 0x1C  # Reserved                                                  |
RES = 0x1D  # Reserved                                                  |
EVT = 0x1E  # EVenT                                                     | 1: function
EXT = 0x1F  # EXTension command                                         | 1: ext command

########
# MAIN #
########

# arguments
txtfile = sys.argv[1]
outputfile = sys.argv[2]

# read text file
print(f"reading file...")
with open(txtfile, "r") as f:
    text = f.read()

# filtering file
print(f"filtering...")
# remove control character and char not in CHAR_MAP
text = re.sub(r"[^\x20-\x7E]", "", text)
# remove unknow/unused metadata
text = re.sub(r"\[[0-9]+\]", "", text)
# remove comments
text = re.sub(r"<!--(.*?)-->", "", text)

# find labels
print(f"parsing... (labels)")
textbin = bytearray()
i = 0
labels = {}
consts = {}
while i < len(text):
    c = text[i]
    if c == "<":
        # get tag
        tag_end = text.find(">", i)
        tag = text[i+1:tag_end]
        # find tag name and args
        if ":" in tag:
            name, args = tag.split(":")
            args = args.split(",")
        else:
            name, args = tag, []

        # transform tag to code
        if name == "label":
            labels[args[0]] = len(textbin)
            print(f"label: '{args[0]}' at {hex(labels[args[0]])}")
        elif name == "jump":
            # add dummy character to keep the length correct
            if (len(args) >= 2 and args[1] == "1") or len(args) < 2:
                textbin.append(0)
            if len(args) >= 4:
                textbin.append(0)
            for _ in range(3):
                textbin.append(0)
        elif name == "const":
            consts[args[0]] = args[1]
            print(f"const: '{args[0]}' with value '{args[1]}'")
        elif name == "flash": # for now to skip arguments
            textbin.append(0)
        else:
            # add dummy character to keep the length correct
            textbin.append(0)
            for _ in range(len(args)):
                textbin.append(0)

        # update index
        i = tag_end+1
    else:
        # add char
        if c in CHAR_MAP:
            textbin.append(CHAR_MAP.index(c))
        # update index
        i += 1

# parsing file
print(f"parsing... (all)")
textbin = bytearray()
i = 0
while i < len(text):
    c = text[i]
    if c == "<":
        # get tag
        tag_end = text.find(">", i)
        tag = text[i+1:tag_end]
        # find tag name and args
        if ":" in tag:
            name, args = tag.split(":")
            args = args.split(",")
            # replace constants by values
            for j in range(len(args)):
                if args[j] in consts:
                    args[j] = consts[args[j]]
        else:
            name, args = tag, []

        # transform tag to code
        if name == "b":
            textbin.append(LB)
        elif name == "p":
            textbin.append(DB)
        elif name == "fp":
            textbin.append(FDB)
        elif name == "speed":
            textbin.append(SPD)
            textbin.append(min(127, int(args[0])))
        elif name == "wait":
            textbin.append(DL)
            textbin.append(min(127, int(args[0])))
        elif name == "name":
            textbin.append(NAM)
            textbin.append(min(127, int(args[0])))
        elif name == "color":
            textbin.append(COL)
            col = int(args[0])
            if col == 0 or col > 4:
                col = 4
            textbin.append(col)
        elif name == "hidetextbox":
            textbin.append(TD)
        elif name == "shake":
            textbin.append(SAK)
        elif name == "flash":
            textbin.append(FLH)
        elif name == "fade_out":
            textbin.append(FO)
        elif name == "fade_in":
            textbin.append(FI)
        elif name == "photo":
            textbin.append(PHT)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "background":
            textbin.append(BKG)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "character":
            textbin.append(CHR)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "animation":
            textbin.append(ANI)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "music":
            textbin.append(MUS)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "sound":
            textbin.append(SND)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "bip":
            textbin.append(BIP)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "set":
            textbin.append(SET)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "clear":
            textbin.append(CLR)
            textbin = append_byte(textbin, int(args[0]), name, i)
        elif name == "label":
            pass
        elif name == "const":
            pass
        elif name == "jump":
            adr = labels[args[0]]
            c = 0
            n = 0

            if (len(args) >= 2 and args[1] == "1") or len(args) < 2:
                textbin.append(JMP)

            if len(args) >= 3 and args[2] == "1":
                n = 1 << 6

            if len(args) >= 4:
                c = 1 << 6

            textbin.append(((adr & 0x1F80) >> 7) + n)
            textbin.append(adr & 0x7F)
            textbin.append((adr >> 13) + c)
            if c != 0:
                textbin.append(int(args[3]))
        elif name == "act":
            textbin.append(ACT)
        elif name == "event":
            textbin.append(EVT)
            for a in args:
                textbin = append_byte(textbin, int(a), name, i)
        else:
            print(f"Unknow tag '{name}' at {i}")

        # update index
        i = tag_end+1
    else:
        # add char
        if c in CHAR_MAP:
            textbin.append(CHAR_MAP.index(c))
        # update index
        i += 1

# check if all char are encoded with 7 bits
m = max(textbin)
if m > 127:
    print("ERROR: some character(s) use more than 7 bits")
    print("       largest char found:", m)
if 0 in textbin:
    print("WARNING: A 0 value has been detected. It may be interpreted has 'END'")


# outputing results
print(f"writing new file...")
with open(outputfile, "wb") as f:
    f.write(textbin)

print(f"done.")
