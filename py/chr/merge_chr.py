import argparse

parser = argparse.ArgumentParser()
parser.add_argument("chr", type=str, nargs="+")
parser.add_argument("-o", dest="out", type=str, default="out.chr")
args = parser.parse_args()

with open(args.out, "wb") as o:
    for c in args.chr:
        with open(c, "rb") as f:
            o.write(f.read())
