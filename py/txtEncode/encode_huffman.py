import sys
import huffman

NB_CHAR = 128

# arguments
txtfile = sys.argv[1]
outputfile = sys.argv[2]

# read text file
print(f"reading file...")
with open(txtfile, "rb") as f:
    text = f.read()

# huffman tree
print(f"compressing...")
proba = []
for i in range(NB_CHAR):
    cnt = text.count(i)
    if cnt > 0:
        proba.append((i, cnt))
        print(i, "found", cnt)
huff_tree = huffman.codebook(proba)

# print tree
print(f"huffman tree:")
for k, v in huff_tree.items():
    print(k, v)

huff_txt_str = ""
for c in text:
    huff_txt_str += huff_tree[c]

# outputing results
print(f"writing new file...")
with open(outputfile, "wb") as f:
    for i in range(0, len(huff_txt_str), 8):
        b = huff_txt_str[i:i+8]
        f.write(int(b, base=2).to_bytes(1, "big"))
    rest = len(huff_txt_str) % 8
    b = huff_txt_str[-rest-1:-1]
    f.write(int(b, base=2).to_bytes(1, "big"))

print(f"done.")
