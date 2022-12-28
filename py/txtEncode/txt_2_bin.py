import sys
import re

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

END = 0x00 # END of dialog                                             |
LB  = 0x01 # Line Break                                                |
DB  = 0x02 # Dialog Break                                              |
FDB = 0x03 # Force Dialog Break                                        |
TD  = 0x04 # Toggle Dialog Box display                                 |
SCR = 0x05 # SCRoll to the other side of the scene                     |
SPD = 0x08 # SPeeD                                                     | 1: speed
DL  = 0x09 # DeLay                                                     | 1: delay
NAM = 0x0A # change NAMe of dialog box                                 | 1: name
FLH = 0x0B # FLasH                                                     | 1: color
FI  = 0x0C # Fade In                                                   | 1: color
FO  = 0x0D # Fade Out                                                  | 1: color
COL = 0x0E # change text COLor                                         | 1: color
BC  = 0x0F # change Background Color                                   | 1: color
BIP = 0x10 # change dialog BIP effect                                  | 1: bip
MUS = 0x11 # MUSic                                                     | 1: music
SND = 0x12 # SouND effect                                              | 1: sound
PHT = 0x13 # show PHoto                                                | 1: photo (0=remove)
CHR = 0x14 # CHaRacter to show                                         | 1: character (0=remove)
ANI = 0x15 # character ANImation                                       | 1: animation
BKG = 0x16 # change BacKGround                                         | 1: background
FNT = 0x17 # Change FoNT to use                                        | 1: font
JMP = 0x18 # JuMP to another dialog                                    | 3: adress\[0..6\], adress\[7..13\], adress\[14..20\]
ACT = 0x19 # jump to the dialog + offset depending on the player ACTion| 4: adress\[0..6\], adress\[7..13\], adress\[14..20\], nb_choice
BP  = 0x1A # Background Palette                                        | 4: palettes (pal 0 first)
SP  = 0x1B # Sprite Palette                                            | 4: palettes (pal 0 first)
RES = 0x1C # Reserved                                                  |
RES = 0x1D # Reserved                                                  |
EVT = 0x1E # EVenT                                                     | 1: function
EXT = 0x1F # EXTension command                                         | 1: ext command                                        


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

textbin = bytearray()

# parsing file
print(f"filtering...")
# remove control character and char not in CHAR_MAP
text = re.sub(r"[^\x20-\x7E]", "", text)
# remove unknow/unused metadata
text = re.sub(r"\[[0-9]+\]", r"", text)
print(f"parsing...")
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
        else:
            name, args = tag, []

        # transform tag to code
        if name == "b":
            textbin.append(LB)
        elif name == "p":
            textbin.append(DB)
        elif name == "nextpage_nobutton":
            textbin.append(FDB)
        elif name == "speed":
            textbin.append(SPD)
            textbin.append(min(127, int(args[0])))
        elif name == "wait":
            textbin.append(DL)
            textbin.append(min(127, int(args[0])))
        elif name == "name":
            textbin.append(NAM)
            textbin.append((int(args[0])//256) & 0x7F)
        elif name == "color":
            textbin.append(COL)
            col = int(args[0])
            if col == 0 or col > 4:
                col = 4
            textbin.append(col)

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
