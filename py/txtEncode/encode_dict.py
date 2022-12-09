import sys

DICT_MAX = 128
LDICT_MAX = (128*128)
SPACE = 0x20.to_bytes(1, "big")
CHAR_DICT = 0x1C.to_bytes(1, "big")
CHAR_LDICT = 0x1D.to_bytes(1, "big")

# arguments
txtfile = sys.argv[1]
outputfile = sys.argv[2]
dictile = sys.argv[3]

# read text file
print(f"reading file...")
with open(txtfile, "rb") as f:
    text = f.read()

print(f"splitting...")
text_split = text.split(SPACE)
print("number of words:", len(text_split))

print(f"counting words...")
words_txt = []
words_cnt = []
for w in text_split:
    if w not in words_txt:
        words_txt.append(w)
        words_cnt.append(0)
    idx = words_txt.index(w)
    words_cnt[idx] += 1
print("number of unique words:", len(words_txt))

print("sorting...")
l = len(words_cnt)
for i in range(l):
    max = words_cnt[i]
    max_idx = i
    for j in range(i, l):
        if words_cnt[j] > max:
            max = words_cnt[j]
            max_idx = j
    # swap
    words_cnt[i], words_cnt[max_idx] = words_cnt[max_idx], words_cnt[i]
    words_txt[i], words_txt[max_idx] = words_txt[max_idx], words_txt[i]

print("cutting...")
for w in words_txt:
    if len(w) <= 2:
        idx = words_txt.index(w)
        del words_txt[idx]
        del words_cnt[idx]
if len(words_txt) > DICT_MAX:
    words_txt = words_txt[:LDICT_MAX+DICT_MAX]
    words_cnt = words_cnt[:LDICT_MAX+DICT_MAX]
print("number of words remaining:", len(words_txt))

print("writting dict...")
with open(dictile, "wb") as f:
    for w in words_txt:
        f.write(len(w).to_bytes(1, "big"))
        f.write(w)

print("encoding & writting data...")
with open(outputfile, "wb") as f:
    for w in text_split:
        if w in words_txt:
            idx = words_txt.index(w)
            if idx < DICT_MAX:
                f.write(CHAR_DICT)
                f.write(idx.to_bytes(1, "big"))
            else:
                idx -= DICT_MAX
                f.write(CHAR_LDICT)
                f.write((idx // 128).to_bytes(1, "big"))
                f.write((idx % 128).to_bytes(1, "big"))
        else:
            f.write(w)
            f.write(SPACE)


print("done")
