import sys

# parameters
output_filename = "empty.chr"
size = 0x40000 # 256K

# args check
if len(sys.argv) > 1:
    a1 = sys.argv[1]
    if a1 == "-h" or a1 == "help" or a1 == "--help":
        print(f"use: {sys.argv[0]} <size in bytes (default=256K)> <filename (default={output_filename})>")
        exit(0)
    else:
        size = int(sys.argv[1])
if len(sys.argv) > 2:
    output_filename = sys.argv[2]

# write empty file
with open(output_filename, "wb") as f:
    f.write(bytes(size))
