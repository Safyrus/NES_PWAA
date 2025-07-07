import argparse
import os

parser = argparse.ArgumentParser()
parser.add_argument("-i", "--input_folder")
parser.add_argument("-o", "--output_folder")
args = parser.parse_args()

with open(os.path.join(args.input_folder, "img_names.asm"), "r", encoding="utf-8") as fi:
    with open(os.path.join(args.output_folder, "image.txt"), "w", encoding="utf-8") as fo:
        fo.write(f"<!-- image constants -->\n")
        for line in fi.readlines():
            if not line:
                continue
            name, val = line.split("=")
            name = name.replace(" ", "").replace("\n", "")
            val = val.replace(" ", "").replace("\n", "")
            fo.write(f"<const:{name},{val}>\n")

with open(os.path.join(args.input_folder, "anim_names.asm"), "r", encoding="utf-8") as fi:
    with open(os.path.join(args.output_folder, "anim.txt"), "w", encoding="utf-8") as fo:
        fo.write(f"<!-- animation constants -->\n")
        for line in fi.readlines():
            if not line:
                continue
            name, val = line.split("=")
            name = name.replace(" ", "").replace("\n", "")
            val = val.replace(" ", "").replace("\n", "")
            fo.write(f"<const:{name},{val}>\n")
