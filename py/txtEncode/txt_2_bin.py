import sys
import re
from datetime import datetime

CHAR_MAP_ASCII = [
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    " ", "!", "\"", "#", "$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/",
    "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", ":", ";", "<", "=", ">", "?",
    "@", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O",
    "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "[", "\\", "]", "^", "_",
    "`", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o",
    "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "{", ",", "}", "~", " "
]

CHAR_MAP_HIRAGANA = [
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "　", "。", "「", "」", "、", "・", "を", "ぁ", "ぃ", "ぅ", "ぇ", "ぉ", "ゃ", "ゅ", "ょ", "っ",
    "ー", "あ", "い", "う", "え", "お", "か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ",
    "た", "ち", "つ", "て", "と", "な", "に", "ぬ", "ね", "の", "は", "ひ", "ふ", "へ", "ほ", "ま",
    "み", "む", "め", "も", "や", "ゆ", "よ", "ら", "り", "る", "れ", "ろ", "わ", "ん", "゛", "゜",
    "￥", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
]

CHAR_MAP_KATAKANA = [
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "ヲ", "ァ", "ィ", "ゥ", "ェ", "ォ", "ャ", "ュ", "ョ", "ッ",
    "", "ア", "イ", "ウ", "エ", "オ", "カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ",
    "タ", "チ", "ツ", "テ", "ト", "ナ", "ニ", "ヌ", "ネ", "ノ", "ハ", "ヒ", "フ", "ヘ", "ホ", "マ",
    "ミ", "ム", "メ", "モ", "ヤ", "ユ", "ヨ", "ラ", "リ", "ル", "レ", "ロ", "ワ", "ン", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
    "", "", "", "", "", "", "", "", "", "", "", "", "", "", "", "",
]

CHAR_HIRAGANA_VOICE_MARKER_IN = ["が", "ぎ", "ぐ", "げ", "ご", "ざ", "じ", "ず", "ぜ", "ぞ", "だ", "ぢ", "づ", "で", "ど", "ば", "び", "ぶ", "べ", "ぼ"]
CHAR_HIRAGANA_VOICE_MARKER_OUT = ["か", "き", "く", "け", "こ", "さ", "し", "す", "せ", "そ", "た", "ち", "つ", "て", "と", "は", "ひ", "ふ", "へ", "ほ"]
CHAR_HIRAGANA_SEMIVOICE_MARKER_IN = ["ぱ", "ぴ", "ぷ", "ぺ", "ぽ"]
CHAR_HIRAGANA_SEMIVOICE_MARKER_OUT = ["は", "ひ", "ふ", "へ", "ほ"]
CHAR_KATAKANA_VOICE_MARKER_IN = ["ガ", "ギ", "グ", "ゲ", "ゴ", "ザ", "ジ", "ズ", "ゼ", "ゾ", "ダ", "ヂ", "ヅ", "デ", "ド", "バ", "ビ", "ブ", "ベ", "ボ"]
CHAR_KATAKANA_VOICE_MARKER_OUT = ["カ", "キ", "ク", "ケ", "コ", "サ", "シ", "ス", "セ", "ソ", "タ", "チ", "ツ", "テ", "ト", "ハ", "ヒ", "フ", "ヘ", "ホ"]
CHAR_KATAKANA_SEMIVOICE_MARKER_IN = ["パ", "ピ", "プ", "ペ", "ポ"]
CHAR_KATAKANA_SEMIVOICE_MARKER_OUT = ["ハ", "ヒ", "フ", "ヘ", "ホ"]

TXT_COL_MAP = [3, 0, 1, 2]

END = 0x00
LB = 0x01
DB = 0x02
FDB = 0x03
TD = 0x04
SET = 0x05
CLR = 0x06
SAK = 0x07
SPD = 0x08
DL = 0x09
NAM = 0x0A
FLH = 0x0B
FAD = 0x0C
SAV = 0x0D
COL = 0x0E
RET = 0x0F
BIP = 0x10
MUS = 0x11
SND = 0x12
PHT = 0x13
CHR = 0x14
R15 = 0x15
BKG = 0x16
FNT = 0x17
JMP = 0x18
ACT = 0x19
R1A = 0x1A
R1B = 0x1B
R1C = 0x1C
R1D = 0x1D
EVT = 0x1E
EXT = 0x1F

verbose = 0


def printv(*str, param="", v=0, sep=" ", end="\n", flush=False):
    global verbose
    if v > verbose:
        return

    if "e" in param:
        print("\033[31m", end="", flush=flush)
    if "w" in param:
        print("\033[33m", end="", flush=flush)
    if "i" in param:
        print("\033[34m", end="", flush=flush)
    if "t" in param:
        now = datetime.now()
        print(f"[{now}] ", end="", flush=flush)

    for s in str:
        print(s, end=sep, flush=flush)

    if "w" in param or "e" in param or "i" in param:
        print("\033[0m", end="", flush=flush)
    print("", end=end)


def val_2_int(val):
    global consts

    while val in consts:
        val = consts[val]
    if val.isnumeric():
        val = int(val)
    else:
        printv(f"ERROR: cosntant '{val}' is not declared at {i}. Replacing by 0", param="te")
        val = 0
    
    return val


def append_val(textbin, val, name, i):
    val = val_2_int(val)

    if val > 127:
        printv(f"WARNING: {name} is > 127 (val={val}) at {i}. Replacing by 0", param="tw")
        val = 0
    textbin.append(val)

    return textbin


def add_normal_char(textbin, c):
    marker = None
    # separate marker from character
    if c in CHAR_HIRAGANA_VOICE_MARKER_IN:
        c = CHAR_HIRAGANA_VOICE_MARKER_OUT[CHAR_HIRAGANA_VOICE_MARKER_IN.index(c)]
        marker = CHAR_MAP_HIRAGANA.index("゛")
    elif c in CHAR_HIRAGANA_SEMIVOICE_MARKER_IN:
        c = CHAR_HIRAGANA_SEMIVOICE_MARKER_OUT[CHAR_HIRAGANA_SEMIVOICE_MARKER_IN.index(c)]
        marker = CHAR_MAP_HIRAGANA.index("゜")
    elif c in CHAR_KATAKANA_VOICE_MARKER_IN:
        c = CHAR_KATAKANA_VOICE_MARKER_OUT[CHAR_KATAKANA_VOICE_MARKER_IN.index(c)]
        marker = CHAR_MAP_HIRAGANA.index("゛")
    elif c in CHAR_KATAKANA_SEMIVOICE_MARKER_IN:
        c = CHAR_KATAKANA_SEMIVOICE_MARKER_OUT[CHAR_KATAKANA_SEMIVOICE_MARKER_IN.index(c)]
        marker = CHAR_MAP_HIRAGANA.index("゜")
    # add character
    if c in CHAR_MAP_ASCII:
        textbin.append(CHAR_MAP_ASCII.index(c))
    elif c in CHAR_MAP_HIRAGANA:
        textbin.append(CHAR_MAP_HIRAGANA.index(c))
    elif c in CHAR_MAP_KATAKANA:
        textbin.append(CHAR_MAP_KATAKANA.index(c))
    else:
        printv(f"unknow encoding for character '{c}'", param="w")
    # add marker if any
    if marker:
        textbin.append(marker)
    # return
    return textbin


########
# MAIN #
########

# arguments
txtfile = sys.argv[1]
outputfile = sys.argv[2]
if len(sys.argv) > 3:
    verbose = int(sys.argv[3])

# read text file
printv(f"reading file...", param="t")
with open(txtfile, "r", encoding="utf-8") as f:
    text = f.read()

# filtering file
printv(f"filtering...", param="t")
# remove control character
text = re.sub(r"[\x00-\x1E]", "", text)
# remove comments
text = re.sub(r"<!--(.*?)-->", "", text)

# parsing file
dummy_vals = {}
labels = {}
consts = {}
printv(f"parsing...", param="t")
textbin = bytearray()
i = 0
while i < len(text):
    c = text[i]
    if c == "<":
        # get tag
        tag_end = text.find(">", i)
        tag = text[i + 1 : tag_end]
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
        elif name == "fp":
            textbin.append(FDB)
        elif name == "speed":
            textbin.append(SPD)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "wait":
            textbin.append(DL)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "name":
            textbin.append(NAM)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "color":
            textbin.append(COL)
            if len(args) > 1:
                col = val_2_int(args[0])
                if col > 0x3F:
                    printv(f"Color value of {col} at {i} is too high. replace by 0", param="wt")
                    col = 0
                pal_idx = val_2_int(args[1])
                if pal_idx > 0x0F:
                    printv(f"Palette index of {pal_idx} at {i} is too high. replace by 0", param="wt")
                    pal_idx = 0
                col_idx = val_2_int(args[2])
                if col_idx > 0x03:
                    printv(f"Color index of {col_idx} at {i} is too high. replace by 0", param="wt")
                    col_idx = 0

                pal_idx = (pal_idx << 2) + col_idx
                col |= 0x40
                textbin.append(col)
                textbin.append(pal_idx)
            else:
                col = val_2_int(args[0])
                if col > 3:
                    printv(f"Color value of {col} at {i} is too high. replace by 0", param="wt")
                    col = 0
                col = TXT_COL_MAP[col]
                textbin.append(col)
        elif name == "hidetextbox":
            textbin.append(TD)
        elif name == "shake":
            textbin.append(SAK)
            force = val_2_int(args[0])
            if force > 7:
                printv(f"Force value of {force} at {i} is too high. replace by 0", param="wt")
                force = 0
            time = val_2_int(args[1])
            if time > 120:
                printv(f"Time value of {time} at {i} is too high. replace by 0", param="wt")
                time = 0
            val = (force << 4) + (time // 8)
            textbin.append(val)
        elif name == "flash":
            textbin.append(FLH)
            force = val_2_int(args[0])
            if force > 7:
                printv(f"Force value of {force} at {i} is too high. replace by 0", param="wt")
                force = 0
            time = val_2_int(args[1])
            if time > 120:
                printv(f"Time value of {time} at {i} is too high. replace by 0", param="wt")
                time = 0
            val = (force << 4) + time
            textbin.append(val)
        elif name == "fade":
            textbin.append(FAD)
            force = val_2_int(args[0])
            if force > 7:
                printv(f"Force value of {force} at {i} is too high. replace by 0", param="wt")
                force = 0
            time = val_2_int(args[1])
            if time > 120:
                printv(f"Time value of {time} at {i} is too high. replace by 0", param="wt")
                time = 0
            val = (force << 4) + (time // 8)
            textbin.append(val)
        elif name == "photo":
            textbin.append(PHT)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "background":
            textbin.append(BKG)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "character":
            textbin.append(CHR)
            c = val_2_int(args[0])
            textbin.append(c % 128)
            textbin.append(c // 128)
        elif name == "music":
            textbin.append(MUS)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "sound":
            textbin.append(SND)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "bip":
            textbin.append(BIP)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "set":
            textbin.append(SET)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "clear":
            textbin.append(CLR)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "font":
            textbin.append(FNT)
            textbin = append_val(textbin, args[0], name, i)
        elif name == "jump":
            if args[0].isnumeric():
                adr = int(args[0])
            else:
                adr = 0
                dummy_vals[len(textbin)] = args[0]
            c = 0
            n = 0

            if (len(args) >= 2 and args[1] == "1") or len(args) < 2:
                if len(textbin) in dummy_vals:
                    del dummy_vals[len(textbin)]
                dummy_vals[len(textbin)+1] = args[0]
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
                textbin = append_val(textbin, a, name, i)
        elif name == "save":
            textbin.append(SAV)
        elif name == "return":
            textbin.append(RET)
        elif name == "box":
            # Char:   0         1         2
            # Bits:   6543210   6543210   6543210
            # Name:   nXxxxxY   yyyyWww   wwHhhhh
            #         |||||||   |||||||   ||+++++-- height of the hitbox (W=MSB)
            #         |||||||   ||||+++---++------- width of the hitbox (W=MSB)
            #         ||||||+---++++--------------- y position of the hitbox (Y=MSB)
            #         |+++++----------------------- x position of the hitbox (X=MSB)
            #         +---------------------------- Next flag (1=another data block after this one
            #                                                 0=last data block)
            x = int(args[0])
            y = int(args[1])
            w = int(args[2])
            h = int(args[3])
            n = int(args[4])
            b0 = (x << 1) | ((y & 0x10) >> 4) | n << 6
            b1 = ((y & 0x0F) << 3) | ((w & 0x1C) >> 2)
            b2 = ((w & 0x03) << 5) | h
            textbin.append(b0)
            textbin.append(b1)
            textbin.append(b2)
        elif name == "label":
            labels[args[0]] = len(textbin)
            printv(f"label: '{args[0]}' at {hex(len(textbin))}", param="it", v=2)
        elif name == "const":
            consts[args[0]] = args[1]
            printv(f"const: '{args[0]}' with value '{args[1]}'", param="it", v=2)
        else:
            printv(f"Unknown tag '{name}' at {i}", param="tw", v=1)

        # update index
        i = tag_end + 1
    else:
        # add char
        textbin = add_normal_char(textbin, c)
        # update index
        i += 1

# replace dummy values
printv(f"fixing...", param="t")
for idx, name in dummy_vals.items():
    if name in labels:
        textbin[idx+0] |= (labels[name] >> 7) & 0x3F
        textbin[idx+1] |= labels[name] & 0x7F
        textbin[idx+2] |= (labels[name] >> 13) & 0x3F
    else:
        printv(f"ERROR: undeclared name '{name}' at {idx}", param="et")

# check if all char are encoded with 7 bits
m = max(textbin)
if m > 127:
    printv("ERROR: some character(s) use more than 7 bits", param="et")
    printv("       largest char found:", m, param="et")
if 0 in textbin:
    printv("WARNING: A 0 value has been detected. It may be interpreted has 'END'", param="wt")
printv("text size:", len(textbin), param="t")

# outputting results
printv(f"writing new file...", param="t")
with open(outputfile, "wb") as f:
    f.write(textbin)

printv(f"done", param="t")
