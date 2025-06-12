import argparse
import os
from char_maps import *
from utils import printv

TAG_START = "<"
TAG_END = ">"
TAG_PARAM = ":"
TAG_PARAM_NEXT = ","
COMMENT_START = "<!--"
COMMENT_END = "-->"
IGNORED_CHARS = [
    "\n",
    "\t",
]
SPECIAL_CHARS = [
    TAG_START,
    TAG_END,
    TAG_PARAM,
    TAG_PARAM_NEXT,
]
KEYWORDS = [
    "lt",
    "b",
    "p",
    "fp",
    "speed",
    "wait",
    "name",
    "color",
    "hidetextbox",
    "shake",
    "flash",
    "fade",
    "photo",
    "background",
    "character",
    "music",
    "sound",
    "bip",
    "set",
    "clear",
    "font",
    "jump",
    "act",
    "event",
    "save",
    "return",
    "box",
    "label",
    "const",
    "include",
]
KEYWORD_2_BYTE = {
    "lt": 0x3C,
    "b": 0x01,
    "p": 0x02,
    "fp": 0x03,
    "hidetextbox": 0x04,
    "set": 0x05,
    "clear": 0x06,
    "shake": 0x07,
    "speed": 0x08,
    "wait": 0x09,
    "name": 0x0A,
    "flash": 0x0B,
    "fade": 0x0C,
    "save": 0x0D,
    "color": 0x0E,
    "return": 0x0F,
    "bip": 0x10,
    "music": 0x11,
    "sound": 0x12,
    "photo": 0x13,
    "character": 0x14,
    "background": 0x16,
    "font": 0x17,
    "jump": 0x18,
    "act": 0x19,
    "event": 0x1E,
    "box": -1,
    "label": -1,
    "const": -1,
}
KEYWORD_N_ARG = {
    "lt": 0,
    "b": 0,
    "p": 0,
    "fp": 0,
    "hidetextbox": 0,
    "set": 1,
    "clear": 1,
    "shake": 2,
    "speed": 1,
    "wait": 1,
    "name": 1,
    "flash": 2,
    "fade": 2,
    "save": 0,
    "color": 3,
    "return": 0,
    "bip": 1,
    "music": 1,
    "sound": 1,
    "photo": 1,
    "character": 1,
    "background": 1,
    "font": 1,
    "jump": 4,
    "act": 0,
    "event": -1,
    "box": 5,
    "label": 1,
    "const": 2,
}
TAG_1_BYTE_SIMPLE_ARG = [
    "set",
    "clear",
    "speed",
    "wait",
    "bip",
    "sound",
    "music",
    "photo",
    "background",
    "name",
    "font",
]

# event chars
CR = 0x00
CRF = 0x01
CRO = 0x02
CRH = 0x03
CRS = 0x04
CRC = 0x05
CRI = 0x06
CRN = 0x07
HPT = 0x08
HPE = 0x09
HPS = 0x0A
HPA = 0x0B

text = ""
text_idx = 0
text_line = 0
text_pos = 0
cur_filename = ""

verbose = 0
error = False


class Token:
    def __init__(self, type=None, val=None):
        global text_line, text_pos
        self.type = type
        self.val = val
        self.pos = (text_line, text_pos)

    def __str__(self):
        return f"{self.type}={self.val}{self.pos}"


class Tag:
    def __init__(self, type=None, args: list[str] = [], pos=(0, 0)):
        self.type = type
        self.args = args
        self.pos = pos

    def __str__(self):
        return f"{self.type}{self.args}"


def pos2str(pos):
    global cur_filename
    return f"({cur_filename}:line {pos[0]}, char ~{pos[1]})"


def next_char_raw():
    global text, text_idx, text_line, text_pos

    if text_idx >= len(text):
        return None

    c = text[text_idx]
    text_idx += 1
    text_pos += 1
    if c == "\n":
        text_line += 1
        text_pos = 1
    return c


def next_char():
    global text, text_idx, text_line, text_pos

    c = next_char_raw()
    while c in IGNORED_CHARS:
        c = next_char_raw()
    printv(c, text_line, text_pos, text_idx, v=2)
    return c


def skip_n_char(n):
    global text, text_idx
    if n <= 0:
        return text[text_idx]
    for _ in range(n):
        c = next_char_raw()
    return c


def lex():
    global text, text_idx, text_line, text_pos

    tokens: list[Token] = []
    MAX_KEYWORD_LEN = max([len(k) for k in KEYWORDS])

    c = "dummy char"
    while c:
        # check for keywords
        k_idx = -1
        for i, k in enumerate(KEYWORDS):
            if text[text_idx : text_idx + MAX_KEYWORD_LEN].startswith(k):
                if k_idx < 0 or len(KEYWORDS[k_idx]) < len(KEYWORDS[i]):
                    k_idx = i

        # read next char
        c = next_char()

        # special char
        if c in SPECIAL_CHARS:
            # if comments
            if text[text_idx - 1 : text_idx - 1 + len(COMMENT_START)] == COMMENT_START:
                # skip comment
                c = skip_n_char(len(COMMENT_START) - 1)
                while text[text_idx : text_idx + len(COMMENT_END)] != COMMENT_END:
                    c = next_char()
                c = skip_n_char(len(COMMENT_END))
                continue
            # special char
            printv("lex: special", v=2)
            tokens.append(Token(c))
        # keyword
        elif k_idx >= 0:
            printv("lex: keyword", v=2)
            c = skip_n_char(len(KEYWORDS[k_idx]) - 1)
            tokens.append(Token("KEYWORD", KEYWORDS[k_idx]))
        # dialog
        else:
            printv("lex: dialog", v=2)
            dialog = ""
            while c and c not in SPECIAL_CHARS:
                dialog += c
                c = next_char()
            tokens.append(Token("DIALOG", dialog))
            tokens[-1].pos = (tokens[-1].pos[0], tokens[-1].pos[1] - 1)
            tokens.append(Token(c))

    return tokens


def parse(tokens: list[Token]):
    tags: list[Tag] = []
    t_idx = 0

    def next_token():
        nonlocal t_idx
        if t_idx >= len(tokens):
            return None
        t_idx += 1
        printv(tokens[t_idx - 1], v=1)
        return tokens[t_idx - 1]

    def expect(type):
        t = next_token()
        error = False
        if t is None or (t.type not in type if isinstance(type, list) else t.type != type):
            printv(f"ERROR {pos2str(t.pos)}: Expected {type}", param="e")
            error = True
        return t, error

    t = next_token()
    while t:
        if t.type == TAG_START:
            t, e = expect("KEYWORD")
            if e:
                continue
            tag_type = t.val
            params = []
            t = next_token()
            if t is not None and t.type == TAG_PARAM:
                while t.type != TAG_END:
                    t = next_token()
                    p = ""
                    while t is not None and t.type in ["DIALOG", "KEYWORD"]:
                        p += t.val
                        t = next_token()
                    params.append(p)
                    t_idx -= 1
                    t, e = expect([TAG_END, TAG_PARAM_NEXT])
                    if e:
                        continue
            t_idx -= 1
            t, e = expect(TAG_END)
            t = next_token()
            tags.append(Tag(tag_type, params, t.pos))
            printv(f"token: {tag_type} {params}", param="i", v=1)
            if e:
                continue
        else:
            dialog = ""
            while t and t.type != TAG_START:
                if t.type in ["DIALOG", "KEYWORD"]:
                    dialog += t.val
                elif t.type != None:
                    dialog += t.type
                t = next_token()
            tags.append(Tag("DIALOG", [dialog], t.pos if t is not None else (0, 0)))
            printv(f"dialog: '{dialog}'", param="i", v=1)

    return tags


def add_normal_char(c, pos=(0, 0)):
    bytes = bytearray()
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
        bytes.append(CHAR_MAP_ASCII.index(c))
    elif c in CHAR_MAP_HIRAGANA:
        bytes.append(CHAR_MAP_HIRAGANA.index(c))
    elif c in CHAR_MAP_KATAKANA:
        bytes.append(CHAR_MAP_KATAKANA.index(c))
    else:
        printv(f"ERROR {pos2str(pos)}: Unknow encoding for character '{c}'", param="e")
    # add marker if any
    if marker:
        bytes.append(marker)
    # return
    return bytes


def val2int(val, min=0, max=255, pos=(0, 0)):
    if val.isnumeric() and int(val) >= min and int(val) <= max:
        val = int(val)
    elif val[1:].isnumeric() and val[0] == "-" and int(val[1:]) >= min and int(val[1:]) <= max:
        val = -int(val[1:])
    else:
        val = min - 1
        printv(f"ERROR {pos2str(pos)}: Expected integer in range {min} to {max} (both included)", param="e")
    return val


def convert_event(t: Tag):
    bin = bytearray()
    dummy_vals = {}

    v = val2int(t.args[0], max=127, pos=t.pos)

    # add command
    bin.append(v)
    # no arg
    if v in [CR, CRF, CRO, HPT]:
        # check args
        if len(t.args) > 1:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
    # flag arg
    elif v in [CRS, CRC, CRI]:
        # check args
        if len(t.args) > 2:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 2:
            printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
        else:
            bin.append(val2int(t.args[1], max=127, pos=t.pos))
    # jump+n arg
    elif v in [CRH]:
        # check args
        if len(t.args) > 3:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 2:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
        else:
            # get address
            if t.args[1].isnumeric():
                adr = int(t.args[1])
            else:
                adr = 0
                dummy_vals[len(bin)] = (t.args[1], t.pos)
            # get next
            n = 0x40 if len(t.args) > 2 else 0
            # add bytes
            bin.append(((adr & 0x1F80) >> 7) + n)
            bin.append(adr & 0x7F)
            bin.append(adr >> 13)
    # flag+jump arg
    elif v in [CRN]:
        # check args
        if len(t.args) > 3:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 3:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
        else:
            # get address
            if t.args[2].isnumeric():
                adr = int(t.args[2])
            else:
                adr = 0
                dummy_vals[len(bin) + 1] = (t.args[2], t.pos)
            # get flag
            f = val2int(t.args[1], max=127, pos=t.pos)
            # add bytes
            bin.append(f)
            bin.append((adr & 0x1F80) >> 7)
            bin.append(adr & 0x7F)
            bin.append(adr >> 13)
    # hp arg
    elif v in [HPS]:
        # check args
        if len(t.args) > 3:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 3:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
        # get vals
        type = val2int(t.args[1], max=3, pos=t.pos)
        val = val2int(t.args[2], max=7, pos=t.pos)
        # add them
        bin.append((type << 3) + val)
    # hp arg (negative)
    elif v in [HPA]:
        # check args
        if len(t.args) > 3:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 3:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
        # get vals
        type = val2int(t.args[1], max=3, pos=t.pos)
        val = val2int(t.args[2], min=-8, max=7, pos=t.pos)
        # add them
        bin.append((type << 3) + abs(val) + (0x40 if val < 0 else 0))
    # hp+jump arg
    elif v in [HPE]:
        # check args
        if len(t.args) > 4:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        elif len(t.args) < 4:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
        else:
            # get address
            if t.args[3].isnumeric():
                adr = int(t.args[3])
            else:
                adr = 0
                dummy_vals[len(bin) + 1] = (t.args[3], t.pos)
            # get hp
            type = val2int(t.args[1], max=3, pos=t.pos)
            val = val2int(t.args[2], max=7, pos=t.pos)
            # add bytes
            bin.append((type << 3) + val)
            bin.append((adr & 0x1F80) >> 7)
            bin.append(adr & 0x7F)
            bin.append(adr >> 13)
    # unknow
    else:
        printv(f"WARNING {pos2str(t.pos)}: Unknow event char", param="w")
        for a in t.args[1:]:
            if a.isnumeric():
                bin.append(val2int(a, max=127, pos=t.pos))
            else:
                dummy_vals[len(bin)] = (a, t.pos)
                bin.extend([0, 0, 0])

    return bin, dummy_vals


def convert(tags: list[Tag], filename: str):
    global text, text_idx, text_line, text_pos, cur_filename
    bin = bytearray()

    # include pass
    for i, t in enumerate(tags[:]):
        # skip non include tag
        if t.type != "include":
            continue
        # check args
        if len(t.args) > 1:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        if len(t.args) < 1:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
            continue
        name = t.args[0]
        # remove tag
        tags.remove(t)
        # find relative path
        d = os.path.dirname(filename)
        inc_filename = os.path.normpath(os.path.join(d, name))
        # check file exist
        if not os.path.exists(inc_filename):
            printv(f"ERROR {pos2str(t.pos)}: Cannot include file '{name}'", param="e")
            continue
        # parse it
        text_idx = 0
        text_line = 1
        text_pos = 1
        cur_filename = inc_filename
        with open(inc_filename, "r", encoding="utf-8") as f:
            text = f.read()
        inc_tags = parse(lex())
        cur_filename = filename
        # extend tags
        for j in range(len(inc_tags) - 1, -1, -1):
            tags.insert(i, inc_tags[j])

    # const pass
    for t in tags[:]:
        # skip non const tag
        if t.type != "const":
            continue
        # check args
        if len(t.args) > 2:
            printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
        if len(t.args) < 2:
            printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
            continue
        name, val = t.args
        # remove tag
        tags.remove(t)
        # replace constant in all tags
        for t in tags:
            for i, a in enumerate(t.args):
                t.args[i] = a.replace(name, val)

    # binary pass
    labels = {}
    dummy_vals = {}
    for t in tags:
        if t.type == "DIALOG":
            l = len("".join(t.args))
            if l > 28:
                printv(f"WARNING {pos2str(t.pos)}: Text may go beyond dialog box size", param="w")
            for a in t.args:
                for c in a:
                    bin.extend(add_normal_char(c, t.pos))
        elif t.type == "label":
            # check args
            if len(t.args) > 1:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 1:
                printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
            else:
                labels[t.args[0]] = len(bin)
        # no arg tag
        elif KEYWORD_N_ARG[t.type] == 0:
            bin.append(KEYWORD_2_BYTE[t.type])
        # 1 arg tag with 1 to 1 binary
        elif t.type in TAG_1_BYTE_SIMPLE_ARG:
            # check args
            val = 0
            if len(t.args) > 1:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 1:
                printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
            else:
                val = val2int(t.args[0], max=127, pos=t.pos)
            #
            bin.append(KEYWORD_2_BYTE[t.type])
            bin.append(val)
        elif t.type == "character":
            # check args
            val = 0
            if len(t.args) > 1:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 1:
                printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
            else:
                val = val2int(t.args[0], max=16384, pos=t.pos)
            #
            bin.append(KEYWORD_2_BYTE[t.type])
            bin.append(val & 0x7F)
            bin.append(val >> 7)
        elif t.type == "jump":
            # check args
            val = 0
            if len(t.args) > 4:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 1:
                printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
            else:
                if t.args[0].isnumeric():
                    adr = int(t.args[0])
                else:
                    adr = 0
                    dummy_vals[len(bin)] = (t.args[0], t.pos)
                c = 0
                n = 0

                if (len(t.args) >= 2 and t.args[1] == "1") or len(t.args) < 2:
                    if len(bin) in dummy_vals:
                        del dummy_vals[len(bin)]
                    dummy_vals[len(bin) + 1] = (t.args[0], t.pos)
                    bin.append(KEYWORD_2_BYTE[t.type])

                if len(t.args) >= 3 and t.args[2] == "1":
                    n = 1 << 6

                if len(t.args) >= 4:
                    c = 1 << 6

                bin.append(((adr & 0x1F80) >> 7) + n)
                bin.append(adr & 0x7F)
                bin.append((adr >> 13) + c)
                if c != 0:
                    val = val2int(t.args[3], max=127, pos=t.pos)
                    bin.append(val)
        elif t.type == "event":
            # add event char
            bin.append(KEYWORD_2_BYTE[t.type])
            # convert event args
            tmp_bin, tmp_dummy = convert_event(t)
            # add args
            for k, v in tmp_dummy.items():
                dummy_vals[k + len(bin)] = v
            bin.extend(tmp_bin)
        elif t.type == "flash":
            # check args
            if len(t.args) > 2:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 2:
                printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
            #
            force = val2int(t.args[0], max=7, pos=t.pos)
            time = val2int(t.args[1], max=119, pos=t.pos)
            #
            bin.append(KEYWORD_2_BYTE[t.type])
            bin.append((force << 4) + time)
        elif t.type == "fade" or t.type == "shake":
            # check args
            if len(t.args) > 2:
                printv(f"WARNING {pos2str(t.pos)}: Garbadge arguments", param="w")
            elif len(t.args) < 2:
                printv(f"ERROR {pos2str(t.pos)}: Missing arguments", param="e")
            #
            force = val2int(t.args[0], max=7, pos=t.pos)
            time = val2int(t.args[1], max=119, pos=t.pos)
            #
            bin.append(KEYWORD_2_BYTE[t.type])
            bin.append((force << 4) + (time // 8))
        elif t.type == "color":
            if len(t.args) > 1:
                printv(f"ERROR {pos2str(t.pos)}: TODO {t}", param="e")
            elif len(t.args) < 1:
                printv(f"ERROR {pos2str(t.pos)}: Missing argument", param="e")
            else:
                val = val2int(t.args[0], max=3, pos=t.pos)
            bin.append(KEYWORD_2_BYTE[t.type])
            bin.append(val)
        else:
            printv(f"ERROR {pos2str(t.pos)}: Unknow tag {t}", param="e")

    # fix pass
    for idx, (name, pos) in dummy_vals.items():
        if name in labels:
            bin[idx + 0] |= (labels[name] >> 7) & 0x3F
            bin[idx + 1] |= labels[name] & 0x7F
            bin[idx + 2] |= (labels[name] >> 13) & 0x3F
        else:
            printv(f"ERROR {pos2str(pos)}: Undeclared name '{name}'", param="e")

    return bin


def main(input_filename, output_filename):
    global text, text_idx, text_line, text_pos, cur_filename
    # init global variables
    text_idx = 0
    text_line = 1
    text_pos = 1
    cur_filename = input_filename

    # read text file
    with open(input_filename, "r", encoding="utf-8") as f:
        text = f.read()

    # parse text
    tags = parse(lex())
    if error:
        printv(f"ERROR: Cannot parse file '{input_filename}'", param="e")
        return
    # convert text
    bin = convert(tags, input_filename)

    # write binary file
    with open(output_filename, "wb") as f:
        f.write(bin)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_file", help="Text file to convert to binary")
    parser.add_argument("-o", "--output_file", help="Output file to write converted text into")
    args = parser.parse_args()

    main(args.input_file, args.output_file)
