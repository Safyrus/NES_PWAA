import argparse
import json
import os
from encode_all import encode_all_constrain, write_files

REGION_SIZE = 1024*256

def main():
    global MAX_PIXEL_DIFF

    # argparse
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--inputs", dest="inputs", type=str, nargs="+", required=True)
    parser.add_argument("-bc", "--base-chr", dest="basechr", type=str, required=False, default=None)
    # parser.add_argument("-b", "--best", dest="best", type=bool, required=False, default=True)
    parser.add_argument("-cp", "--c-path", dest="cpath", type=str, required=False, default="c/")
    parser.add_argument("-exe", "--c-program-name", dest="exe", type=str, required=False, default="a.exe")
    parser.add_argument("-oc", "--output-char", dest="out_chr", type=str, required=False, default="CHR.chr")
    # parser.add_argument("-mc", "--max-chr-size", dest="max_chr_size", type=int, required=False, default=1024*1024)
    # parser.add_argument("-mp", "--max-prg-size", dest="max_prg_size", type=int, required=False, default=1024*512)
    # parser.add_argument("-bsc", "--bank-start-chr", dest="chr_start", type=int, required=False, default=1)
    # parser.add_argument("-bsp", "--bank-start-prg", dest="prg_start", type=int, required=False, default=0xC0)
    args = parser.parse_args()

    args.tile_chr_path = os.path.join(args.cpath, "CHR.chr")
    args.tile_maps_folder = os.path.join(args.cpath, "maps/")
    args.out = os.path.join(args.cpath, "imgs/")
    args.c_program = os.path.join(args.cpath, args.exe)

    ca65_info_all = {
        "pal_bank": []
    }
    all_frames = []
    CHR_roms = bytearray()
    basechr_size = 0
    if args.basechr:
        with open(args.basechr, "rb") as f:
            basechr_size = len(f.read())

    for region_bits, file in enumerate(args.inputs):
        if region_bits >= 4:
            print(f"too many region to encode. stop.")
            break
        print(f"encode region number {region_bits} - {file}")
        # open and read the json file
        with open(file) as f:
            json_anim = json.load(f)
        #
        args.json = file
        l = len(CHR_roms) + basechr_size
        args.chr_start = l // 4096 + (1 if l % 4096 != 0 else 0)
        args.max_prg_size = 1024*128
        args.max_chr_size = 1024*256
        args.start_dif = 0
        if region_bits == 0:
            args.max_chr_size -= basechr_size
        # encode all animations of the json file
        ca65_info, frames, CHR_rom = encode_all_constrain(args, json_anim, ca65_info_all["pal_bank"])
        # add frames
        for i in range(len(frames)):
            frames[i][0] |= region_bits
        all_frames.extend(frames)
        # add CHR rom
        l = len(CHR_rom) % REGION_SIZE
        if region_bits == 0:
            l += basechr_size
        CHR_roms.extend(CHR_rom)
        if l:
            CHR_roms.extend(bytes(REGION_SIZE - l))
        # add ca65 info
        for k in ca65_info.keys():
            if k not in ca65_info_all:
                ca65_info_all[k] = []
            ca65_info_all[k].extend(ca65_info[k])

    # write results
    write_files(ca65_info_all, all_frames, CHR_roms, basechr_file=args.basechr, chr_name=args.out_chr)


if __name__ == "__main__":
    main()

