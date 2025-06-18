import argparse
import math
import os
import binpacking
from music import export_all, export_mus, export_mus_asm
from sfx import export_sfxbip


def export_music(fs, fm_file, out_folder, music_idx):
    # remove dpcm files
    i = 0
    while os.path.exists(os.path.join(out_folder, f"music_bank{i}.dmc")):
        os.remove(os.path.join(out_folder, f"music_bank{i}.dmc"))
        i += 1

    # export all music to get their sizes
    indexes = [str(x) for x in music_idx.values()]
    musics, total_size = export_mus(fs, fm_file, out_folder, "", indexes)
    print("number of music:", len(musics))

    # find best banks
    ok = False
    n_bin = math.ceil(total_size / (1024 * 8))
    bins = []
    MARGIN = 0
    while not ok:
        print("try to fit all in", n_bin, "banks")
        bins = binpacking.to_constant_bin_number(musics, n_bin)
        ok = True
        for i, b in enumerate(bins):
            indexes = [str(music_idx[name]) for name in b.keys()]
            _, s = export_mus(fs, fm_file, out_folder, str(i), indexes)
            if s > ((1024 * 8) - MARGIN):
                ok = False
                n_bin += 1
                break

    # remove temporary files
    os.remove(os.path.join(out_folder, "music.s"))
    i = 0
    while os.path.exists(os.path.join(out_folder, f"music_{i}.s")):
        os.remove(os.path.join(out_folder, f"music_{i}.s"))
        i += 1

    # export music
    music_size = 0
    total_size = 0
    for i, b in enumerate(bins):
        print(f"export music bank {i} ({b.keys()})")
        indexes = []
        for name in b.keys():
            indexes.append(str(music_idx[name]))
        m, size = export_mus(fs, fm_file, out_folder, str(i), indexes)
        h = size - sum([x for x in m.values()])
        music_size += sum(b.values())
        total_size += size
        print(f"size: {size} (music={sum(b.values())},header={h})")
    print("music size:", music_size, "bytes")
    print("total size (without dpcm):", total_size, "bytes")

    # export asm
    export_mus_asm(bins, list(music_idx.keys()), out_folder)


def sound_2_asm(fs, fm_file, out_folder):
    # get music titles
    names, _ = export_all(fs, fm_file, out_folder)
    names = list(names)

    # change music.s to dpcm.s
    dpcm_file = ""
    with open(f"{out_folder}/music.s", "r") as f:
        dpcm_file = f.read()
    project_name = [x[:-1] for x in dpcm_file.split("\n") if x.startswith("music_data_")][0]
    dpcm_file = dpcm_file.replace(project_name, "dpcm_data")
    project_name = "dpcm_data"
    with open(f"{out_folder}/dpcm.s", "w") as f:
        state = "header"
        for line in dpcm_file.split("\n"):
            if state == "header":
                f.write(line + "\n")
                if line.startswith(project_name):
                    state = "before_sample"
                    f.write("    .byte 0\n")
                    f.write("    .word 0\n")
                    f.write("    .word @samples\n\n")
            elif state == "before_sample":
                if line.startswith("@samples"):
                    state = "sample"
                    f.write(line + "\n")
            elif state == "sample":
                if line == "":
                    state = "end"
                    f.write(line + "\n")
                else:
                    sample = line.split(",")
                    sample[2] = sample[2].replace("$4", "$0")
                    line = ",".join(sample)
                    f.write(line + "\n")
            else:
                break

    # sort mus, sfx, bip
    musics = {}
    sfxs = {}
    for i, n in enumerate(names):
        if n.startswith("sfx ") or n.startswith("bip "):
            sfxs[n] = i
        else:
            musics[n] = i

    # export music
    export_music(fs, fm_file, out_folder, musics)
    # export sfx & bip
    export_sfxbip(fs, fm_file, out_folder, sfxs)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input_file")
    parser.add_argument("-fs", "--famistudio")
    parser.add_argument("-o", "--output_folder")
    args = parser.parse_args()

    sound_2_asm(args.famistudio, args.input_file, args.output_folder)
