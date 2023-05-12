import sys

# args check
helplist = ["-h", "--help", "help"]
if len(sys.argv) <= 3 or (len(sys.argv) > 1 and sys.argv[1] in helplist):
    print(f"use: {sys.argv[0]} <input> <output> <size to add (in hex bytes)>")
    exit(len(sys.argv) <= 1 or sys.argv[1] not in helplist)

# parameters
input_filename = sys.argv[1]
output_filename = sys.argv[2]
size = int(sys.argv[3], base=16)

# extend file
with open(input_filename, "rb") as i:
    data = i.read()
with open(output_filename, "wb") as o:
    o.write(data)
    o.write(bytes(size))
