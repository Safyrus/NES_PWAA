from tkinter import filedialog
from tkinter import messagebox
import os
import json
import var


def cmd_new(event=None):
    print("Command: New")
    # ask for project folder
    folder = filedialog.askdirectory(title="Choose Image Project Folder", initialdir="./")
    print(folder)

    # if folder exist
    if not os.path.exists(folder):
        messagebox.showerror(title="Error Creating file", message="Selected folder does not exist")
        return False

    # if folder not empty
    if len(os.listdir(folder)) != 0:
        # ask for confirmation
        yes = messagebox.askyesno(
            title="Warning Creating file",
            message=f"Folder is not empty. This may erase some files present here. Are you sure want this folder ?\n({folder})",
        )
        # abort
        if not yes:
            return False

    # create project main file
    project_fn = os.path.join(folder, "image_project.json")
    with open(project_fn, "w") as f:
        data = {
            "region_0": "region_0.txt",
            "region_1": "region_1.txt",
            "region_2": "region_2.txt",
            "region_3": "region_3.txt",
            "photo": "photo.json",
        }
        json.dump(data, f, indent=2)

    # create other empty files
    for i in range(4):
        fn = os.path.join(folder, f"region_{i}.txt")
        with open(fn, "w") as f:
            pass
    fn = os.path.join(folder, f"photo.json")
    with open(fn, "w") as f:
        f.write("[]")

    # init project
    init_project(fn)
    return True


def init_project(fn):
    var.project_data = {
        "filename": fn,
        "regions": [
            {
                "filename": "region_0.txt",
                "data": [],
            },
            {
                "filename": "region_1.txt",
                "data": [],
            },
            {
                "filename": "region_2.txt",
                "data": [],
            },
            {
                "filename": "region_3.txt",
                "data": [],
            },
        ],
        "photo": {
            "filename": "photo.json",
            "data": [],
        },
    }
