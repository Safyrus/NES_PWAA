import argparse
import json


parser = argparse.ArgumentParser()
parser.add_argument("input", type=str, nargs="+")
parser.add_argument("output", type=str)
args = parser.parse_args()

print(f"merge {args.input} to {args.output}")

final_array = []
for filename in args.input:
    with open(filename) as f:
        array = json.load(f)
    final_array.extend(array)

with open(args.output, "w") as f:
    json.dump(final_array, f, indent=4)
