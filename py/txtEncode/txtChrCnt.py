import sys
import huffman
from math import *

txtfile = sys.argv[1]
wordsfile = "words.txt"

# read text file
print(f"reading file...")
with open(txtfile, "r") as f:
    lines = f.readlines()

# count words and chars
print(f"counting chars and words...")
chr_lst = []
chr_lst_cnt = []
chr_cnt = 0
wrd_lst = []
wrd_cnt = 0
wrd_cnt_chr = 0
for l in lines:
    # count chars
    for c in l:
        if c not in chr_lst:
            chr_lst.append(c)
            chr_lst_cnt.append(0)
        chr_cnt += 1
        chr_lst_cnt[chr_lst.index(c)] += 1
    # count words
    words = l.split()
    for w in words:
        wrd_cnt += 1
        if w not in wrd_lst:
            wrd_lst.append(w)
            wrd_cnt_chr += len(w)

# print statistics
print(f"chars count: {chr_cnt}")
print(f"unique chars count: {len(chr_lst)}")
print(f"lines count: {len(lines)}")
print(f"words count: {wrd_cnt}")
print(f"unique words count: {len(wrd_lst)}")

# huffman
proba = []
for i in range(len(chr_lst)):
    proba.append((chr_lst[i], chr_lst_cnt[i]))
huff_res = huffman.codebook(proba)

# estimate sizes
size = chr_cnt
size_ptr = len(lines)*2
size_7bit = ceil((size * 7) / 8)
size_dict = (wrd_cnt * 3) + wrd_cnt_chr + len(wrd_lst)
size_7dict = ceil((size_dict * 7)/8)
size_huff = 0
for k,v in huff_res.items():
    idx = chr_lst.index(k)
    size_huff += len(v) * chr_lst_cnt[idx]
size_huff = ceil(size_huff / 8)
size_7huff = ceil((size_huff * 7) / 8)
size_all = (wrd_cnt*3) * (size_huff/size) + wrd_cnt_chr + len(wrd_lst)
size_all = ceil((size_all * 7) / 8)

# print estimate sizes
print()
print(f"size (uncompressed)                     : {size+size_ptr} bytes + ptr size:{size_ptr} bytes")
print(f"size (7-bit char compression)           : {size_7bit} bytes ({ceil((size_7bit*100)/size)}%)")
print(f"estimate size (dict compression)        : {size_dict} bytes ({ceil((size_dict*100)/size)}%)")
print(f"estimate size (7-bit + dict)            : {size_7dict} bytes ({ceil((size_7dict*100)/size)}%)")
print(f"estimate size (huffman compression)     : {size_huff} bytes ({ceil((size_huff*100)/size)}%)")
print(f"estimate size (7-bit + huffman)         : {size_7huff} bytes ({ceil((size_7huff*100)/size)}%)")
print(f"estimate size (7-bit + dict + huffman)  : {size_all} bytes ({ceil((size_all*100)/size)}%)")

# write words to file
with open(wordsfile, "w") as f:
    f.write(f"unique chars:\n")
    for i in range(len(chr_lst)):
        f.write(f"{repr(chr_lst[i])}: {chr_lst_cnt[i]} times\n")
    f.write(f"\nwords:\n")
    for w in wrd_lst:
        f.write(w+"\n")
