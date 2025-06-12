import sys

# arguments
txtfile = sys.argv[1]
outputfile = sys.argv[2]
pairfile = sys.argv[3]

# read text file
print(f"reading file...")
with open(txtfile, "rb") as f:
    text = f.read()

pair_char = []
char_idx = 0
pair_cnt = {}

# count pairs
print(f"count pairs...")
for i in range(len(text)-1):
    pair = text[i:i+2]
    if pair not in pair_cnt:
        pair_cnt[pair] = 0
    pair_cnt[pair] += 1

# sort pairs
print(f"sort pairs...")
pair_cnt = {k: v for k, v in reversed(sorted(pair_cnt.items(), key=lambda item: item[1]))}

# replace
print(f"replace pairs...")
for k,v in pair_cnt.items():
    if char_idx >= 128:
        break
    print(char_idx, k, v)
    pair_char.append(k)
    text = text.replace(k, (128+char_idx).to_bytes(1, "big"))
    char_idx += 1

# write
print(f"write data...")
with open(outputfile, "wb") as f:
    f.write(text)

print(f"write pairs...")
with open(pairfile, "wb") as f:
    for p in pair_char:
        f.write(p)

print(f"done.")
