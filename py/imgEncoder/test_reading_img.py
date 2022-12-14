import sys
from rebuild import *
from rle_inc import *


filename = sys.argv[1]
bankname = sys.argv[2]

#
with open(filename, "rb") as f:
    dataBin = f.read()
encode = []
for d in dataBin:
    encode.append(int(d))

#
with open(bankname, "rb") as f:
    dataBin = f.read()
bankData = []
for d in dataBin:
    bankData.append(int(d))

bank = []
for i in range(0, len(bankData), 16):
    chrTile = chr_2_tile(bankData[i:i+16])
    bank.append(chrTile)

decode = rleinc_decode(encode)
tileList = []
for i in range(len(decode)//2):
    d = decode[i] + (decode[i+len(decode)//2] << 8)
    tileList.append(d)
rebuild_bkg_img(tileList, bank).save("out.png")
