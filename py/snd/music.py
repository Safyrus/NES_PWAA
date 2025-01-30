import argparse
import os
import subprocess
from glob import glob


TOTAL_SIZE_STR = "Info: Total assembly file size: "
SONG_STR = "Info: Song "


def export_all(fs, file, folder):
    musics = {}

    # export music to find their sizes
    cmd = subprocess.run(
        [
            f"{fs}",
            f"{file}",
            "famistudio-asm-export",
            f"{folder}/music.s",
            "-famistudio-asm-format:ca65",
        ],
        stdout=subprocess.PIPE,
    )

    # parse command output
    export_text = cmd.stdout.decode("utf-8")
    for line in export_text.split("\n"):
        # parse total size
        if TOTAL_SIZE_STR in line:
            total_size = int(line.split(TOTAL_SIZE_STR)[1].split(" ")[0])
        # parse music sizes
        if SONG_STR in line:
            name, size = line.split(SONG_STR)[1].split(" size: ")
            name = name[1:-1]
            size = int(size.split(" ")[0])
            musics[name] = size

    # remove dpcm file
    dpcm_file = os.path.join(folder, "music.dmc")
    if os.path.exists(dpcm_file):
        os.remove(dpcm_file)

    return musics, total_size


def export_mus(fs, file, folder, name_idx, indexes):
    if name_idx:
        asm_filepath = f"{folder}/music_{name_idx}.s"
    else:
        asm_filepath = f"{folder}/music.s"

    # export music to find their sizes
    cmd = subprocess.run(
        [
            f"{fs}",
            f"{file}",
            "famistudio-asm-export",
            asm_filepath,
            "-famistudio-asm-format:ca65",
            f"-export-songs:{','.join(indexes)}",
        ],
        stdout=subprocess.PIPE,
    )

    # parse command output
    musics = {}
    export_text = cmd.stdout.decode("utf-8")
    for line in export_text.split("\n"):
        # parse total size
        if TOTAL_SIZE_STR in line:
            total_size = int(line.split(TOTAL_SIZE_STR)[1].split(" ")[0])
        # parse music sizes
        if SONG_STR in line:
            name, size = line.split(SONG_STR)[1].split(" size: ")
            name = name[1:-1]
            size = int(size.split(" ")[0])
            musics[name] = size

    # remove dpcm file
    dpcm_file = os.path.join(folder, "music.dmc")
    if os.path.exists(dpcm_file):
        os.remove(dpcm_file)

    #
    if name_idx:
        # edit asm file label name
        with open(asm_filepath, "r") as f:
            asm_file = f.read()
        project_name = ""
        for line in asm_file.split("\n"):
            if line.startswith("music_data_"):
                project_name = line.split(":")[0]
                break
        asm_file = asm_file.replace(project_name, f"{project_name}_{name_idx}")
        with open(asm_filepath, "w") as f:
            f.write(asm_file)

        # remove other dpcm files
        dpcms = glob(f"music_{name_idx}*.dmc", root_dir=folder)
        for dpcm in dpcms:
            os.remove(os.path.join(folder, dpcm))

    return musics, total_size


def export_mus_asm(bins, music_names, out_folder):
    # export asm
    with open(os.path.join(out_folder, "inc.asm"), "w", encoding="utf-8") as f:
        f.write("; This file was generated\n\n")

        f.write(f"; Include SFX\n")
        f.write(f'.segment "SFX_BNK"\n')
        f.write(f'.include "sfx.s"\n')
        f.write(f'.include "dpcm.s"\n')

        # include music data
        f.write(f"; Include music data\n")
        for i in range(len(bins)):
            f.write(f'.segment "MUS_BNK{i}"\n')
            f.write(f'.include "music_{i}.s"\n')

        # include dpcm
        n_dpcm = len(glob("music_bank*.dmc", root_dir=out_folder))
        f.write(f"; Include DPCM\n")
        for i in range(n_dpcm):
            f.write(f'.segment "DPCM_BNK{i}"\n')
            f.write(f'.incbin "music_bank{i}.dmc"\n')

        # write music index list
        f.write(f'\n.segment "LAST_BNK"\n')
        f.write("\nmusic_idx_table:\n")
        idxs = [0] * len(bins)
        for n, name in enumerate(music_names):
            for i, b in enumerate(bins):
                if name in b.keys():
                    f.write(f"    .byte ${hex(idxs[i])[2:]} ; {n} - {name}\n")
                    idxs[i] += 1
                    break

        # write music bank list
        f.write("\nmusic_bank_table:\n")
        for n, name in enumerate(music_names):
            for i, b in enumerate(bins):
                if name in b.keys():
                    f.write(f"    .byte ${hex(i)[2:]}+MUS_BNK ; {n} - {name}\n")
                    break
