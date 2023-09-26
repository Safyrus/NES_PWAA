import argparse
import glob
import huffman

parser = argparse.ArgumentParser()
parser.add_argument("folder", type=str)
args = parser.parse_args()

files = glob.glob(args.folder + '/**/*.bin', recursive=True)

stat = {}

for filename in files:
    with open(filename, "rb") as f:
        while True:
            b = f.read(1)
            if not b:
                break
            b = int.from_bytes(b)
            if b in stat:
                stat[b] += 1
            else:
                stat[b] = 1

stat = dict(sorted(stat.items(), key=lambda x: x[1], reverse=True))
s1 = sum(stat.values())

proba = []
print("stats:")
for k,v in stat.items():
    print(hex(k), ":", v)
    proba.append((k, v))

huff_tree = huffman.codebook(proba)
print("huffman tree:")
s2 = 0
for k, v in huff_tree.items():
    print(hex(k).rjust(4), v)
    s2 += stat[k] * len(v)
mean_bit = s2 / s1
s2 = (s2 // 8) + (1 if s2 % 8 else 0)

print("size:")
print("before:", s1)
print("after :", s2, "(mean bit len:", mean_bit ,")")

