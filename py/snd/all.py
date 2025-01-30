import argparse
import os
import binpacking
from music import export_all, export_mus, export_mus_asm
from sfx import export_sfxbip


def export_music(fs, fm_file, out_folder, music_idx):
    # export all musics to each music
    indexes = [str(x) for x in music_idx.values()]
    musics, total_size = export_mus(fs, fm_file, out_folder, "", indexes)
    # find header size
    header_size = total_size - sum([x for x in musics.values()])
    # remoe temporary files
    os.remove(os.path.join(out_folder, "music.s"))

    # find best banks
    max_size = (1024 * 8) - header_size
    bins = binpacking.to_constant_volume(musics, max_size)

    # export music
    for i, b in enumerate(bins):
        print(f"export music bank {i} ({b.keys()})")
        indexes = []
        for name in b.keys():
            indexes.append(str(music_idx[name]))
        export_mus(fs, fm_file, out_folder, str(i), indexes)

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
