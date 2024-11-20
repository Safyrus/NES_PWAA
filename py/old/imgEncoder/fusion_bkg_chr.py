import os
import sys
import glob
from PIL import Image

if len(sys.argv) <= 3:
    print(sys.argv[0], "<background>", "<char folder>", "<output folder>", "[align]", "[x offset]", "[y offset]")
    exit(0)

# args
background_img = sys.argv[1]
character_folder = sys.argv[2]
output_folder = sys.argv[3]
align = 0  # 0=center, 1=left, 2=right
offset_x = 0
offset_y = 0
if len(sys.argv) > 4:
    align = int(sys.argv[4])
if len(sys.argv) > 5:
    offset_x = int(sys.argv[5])
if len(sys.argv) > 6:
    offset_y = int(sys.argv[6])

# find all character images
files = glob.glob(character_folder + '/**/*.png', recursive=True)
print("number of images found:",len(files))

background = Image.open(background_img)

i = 0
w, h = background.size
for fn in files:
    char = Image.open(fn)
    tmp = background.copy()
    if align == 1:
        x = offset_x
    elif align == 2:
        x = w - char.size[0] - offset_x
    else:
        x = (w - char.size[0])//2
    y = h - char.size[1] - offset_y
    tmp.paste(char, (x, y), char)
    out_fn = os.path.splitext(os.path.basename(fn))[0]
    tmp.save(output_folder + out_fn + ".png")
    i += 1

print("done")
