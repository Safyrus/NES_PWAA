import os
import json
import var

def cmd_save(event=None):
    print("Command: Save")
    # save main file
    with open(var.project_data["filename"], "w") as f:
        o = {
            "region_0": var.project_data["regions"][0]["filename"],
            "region_1": var.project_data["regions"][1]["filename"],
            "region_2": var.project_data["regions"][2]["filename"],
            "region_3": var.project_data["regions"][3]["filename"],
            "photo": var.project_data["photo"]["filename"],
        }
        json.dump(o, f, indent=2)
    dir = os.path.dirname(var.project_data["filename"])

    # save photo
    fn_photo = os.path.join(dir, var.project_data["photo"]["filename"])
    with open(fn_photo, "w") as f:
        json.dump(var.project_data["photo"]["data"], f, indent=2)

    # save regions
    for i in range(4):
        fn_region = os.path.join(dir, var.project_data["regions"][i]["filename"])
        with open(fn_region, "w") as txt:
            for d in var.project_data["regions"][i]["data"]:
                txt.write(f"{d['filename']}\n")
                fn_anim = os.path.join(os.path.dirname(fn_region), d["filename"])
                with open(fn_anim, "w") as anim:
                    json.dump(d["data"], anim, indent=2)
