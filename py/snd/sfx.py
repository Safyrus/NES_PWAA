import os
import subprocess
from glob import glob

def export_sfxbip(fs, fm_file, out_folder, sfxs):
    # export sfx to find their sizes
    indexes = [str(x) for x in sfxs.values()]
    print("export sfx")
    cmd = subprocess.run(
        [
            f"{fs}",
            f"{fm_file}",
            "famistudio-asm-sfx-export",
            f"{out_folder}/sfx.s",
            "-famistudio-asm-format:ca65",
            f"-export-songs:{','.join(indexes)}",
        ],
        stdout=subprocess.PIPE,
    )

    # remove dpcm files
    for filename in glob("sfx*.dmc", root_dir=out_folder):
        dpcm_file = os.path.join(out_folder, filename)
        os.remove(dpcm_file)
