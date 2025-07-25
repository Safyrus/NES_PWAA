import os
import re
import subprocess
from glob import glob

def export_sfxbip(fs, fm_file, out_folder, sfxs, out_file):
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

    # parse command output to get sfx names
    sfx_names = []
    bip_names = []
    i = 0
    SFX_STR = "Info: Effect ("
    export_text = cmd.stdout.decode("utf-8")
    for line in export_text.split("\n"):
        if SFX_STR in line:
            n = line.split(SFX_STR)[1].split("): ")[0]
            if n.lower().startswith("sfx"):
                sfx_names.append((n, i))
            else:
                bip_names.append((n, i))
            i += 1

    # export asm
    with open(out_file, "w", encoding="utf-8") as f:
        f.write("<!--\nThis file was generated\n-->\n")

        # write sfx list
        f.write(f"\n<!-- sfx constants -->\n")
        for (name, n) in sfx_names:
            name_filter = re.sub(r"[^a-zA-Z0-9]", "_", name).upper()
            name_filter = re.sub(r"\_+", "_", name_filter)
            f.write(f"<const:{name_filter},{n}>\n")

        # write bip list
        f.write(f"\n<!-- bip constants -->\n")
        for (name, n) in bip_names:
            name_filter = re.sub(r"[^a-zA-Z0-9]", "_", name).upper()
            name_filter = re.sub(r"\_+", "_", name_filter)
            f.write(f"<const:{name_filter},{n}>\n")
