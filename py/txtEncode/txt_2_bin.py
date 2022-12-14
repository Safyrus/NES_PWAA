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

END = 0x00  # (END of dialog)
LB = 0x01  # (Line Break)
DB = 0x02  # (Dialog Break)
FDB = 0x03  # (Force Dialog Break)
TGB = 0x04  # (ToGgle dailog Box display)
SCR = 0x05  # (SCRoll to the other side of the scene)
SPD = 0x08  # (SPeeD) (arg_1: speed)
DLY = 0x09  # (DeLaY) (arg_1: delay)
NAM = 0x0A  # (change NAMe of dialog box) (arg_1: idx)
FLH = 0x0B  # (FLasH) (arg_1: color)
FDI = 0x0C  # (FaDe In) (arg_1: color)
FDO = 0x0D  # (FaDe Out) (arg_1: color)
COL = 0x0E  # (change text COLor) (arg_1: color)
BKD = 0x0F  # (change BacKground color of the Dialog box) (arg_1: color)
BIP = 0x10  # (change dialog BIP effect) (arg_1: idx)
MUS = 0x11  # (MUSic) (arg_1: idx)
SND = 0x12  # (SouND efect) (arg_1: idx)
PHT = 0x13  # (show PHoto) (arg_1: idx (0=remove))
CSH = 0x14  # (Character SHow) (arg_1: idx (0=remove))
CAN = 0x15  # (Character ANimation) (arg_1: idx)
BKG = 0x16  # (change BacKGround) (arg_1: idx)
FNT = 0x17  # (Change FoNT to use) (arg_1: idx)
JMP = 0x18  # (JuMP to another dialog) (arg_1: idx_hi, arg_2: idx_lo)
CHC = 0x19  # (CHoiCe, jump to the dialog + offset depending on the player choice) (arg_1: idx_hi, arg_2: idx_lo, arg_3: nb_choice)
BPL = 0x1A  # (Background PaLette) (arg_1 to 4: palette)
SPL = 0x1B  # (Sprite PaLette) (arg_1 to 4: palette)
DC = 0x1C  # (short DiCtionnary) (arg_1: idx)
LDC = 0x1D  # (Long DiCtionnary) (arg_1: idx_hi, arg_2: idx_lo)
EVT = 0x1E  # (EVenT) (arg_1: fct_idx)
EXT = 0x1F  # (EXTension command) (arg_1: ext command)


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
            textbin.append(int(args[0])//2)
        elif name == "wait":
            textbin.append(DLY)
            textbin.append(int(args[0])//2)
        elif name == "name":
            textbin.append(NAM)
            textbin.append((int(args[0])//256) & 0x7F)
        elif name == "color":
            textbin.append(COL)
            if args[0] == "0":
                textbin.append(0x30)
            elif args[0] == "1":
                textbin.append(0x26)
            elif args[0] == "2":
                textbin.append(0x21)
            elif args[0] == "3":
                textbin.append(0x2A)
            else:
                textbin.append(int(args[0]) & 0x7F)

        # update index
        i = tag_end+1
    else:
        # add char
        if c in CHAR_MAP:
            textbin.append(CHAR_MAP.index(c))
        # update index
        i += 1

# outputing results
print(f"writing new file...")
with open(outputfile, "wb") as f:
    f.write(textbin)

print(f"done.")
