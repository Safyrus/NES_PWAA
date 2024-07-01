import argparse
import json
import os


parser = argparse.ArgumentParser()
parser.add_argument("output", type=str)
parser.add_argument("-f", "--file", type=str, default="")
args = parser.parse_args()
args.input = []

if args.file != "":
    print(f"read file {args.file}")
    with open(args.file, "r") as f:
        for line in f.readlines():
            line = line[:-1] # remove new line
            if line == "":
                continue
            if not os.path.exists(line):
                print(f"Warning: file {line} does not exist")
                continue
            args.input.append(line)

print(f"merge {args.input} to {args.output}")

final_array = []
for filename in args.input:
    with open(filename) as f:
        array = json.load(f)
    final_array.extend(array)

with open(args.output, "w") as f:
    json.dump(final_array, f, indent=4)
