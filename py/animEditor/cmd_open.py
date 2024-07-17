from tkinter import filedialog
from tkinter import messagebox
import os
import json
import var


def cmd_open(event=None):
    print("Command: Open")
    # ask for file
    filetypes = (("JSON files", "*.json"), ("All files", "*.*"))
    fn = filedialog.askopenfilename(title="Choose Image Project File", initialdir="./", filetypes=filetypes)

    # if does not exist
    if not os.path.exists(fn):
        if fn == "":
            return False
        messagebox.showerror(title="Error Opening file", message="Selected file does not exist")
        return False

    # check file
    with open(fn, "r") as f:
        # read json
        try:
            data = json.load(f)
        except Exception as error:
            print(error)
            messagebox.showerror(title="Error Opening file", message=f"Cannot read file:\n{error}")
            return False

        # check json
        fields = ["region_0", "region_1", "region_2", "region_3", "photo"]
        for field in fields:
            if field not in data:
                messagebox.showerror(title="Error Opening file", message=f"Missing field '{field}' in project file")
                return False
            f = os.path.join(os.path.dirname(fn), data[field])
            if not os.path.exists(f):
                messagebox.showerror(title="Error Opening file", message=f"'{field}': file '{f}' does not exist")
                return False

    # load project
    load_project(fn, data)
    return True


def load_project(fn, data):
    r0, e = load_region(os.path.join(os.path.dirname(fn), data["region_0"]))
    if e:
        return
    r1, e = load_region(os.path.join(os.path.dirname(fn), data["region_1"]))
    if e:
        return
    r2, e = load_region(os.path.join(os.path.dirname(fn), data["region_2"]))
    if e:
        return
    r3, e = load_region(os.path.join(os.path.dirname(fn), data["region_3"]))
    if e:
        return
    p, e = load_photo(os.path.join(os.path.dirname(fn), data["photo"]))
    if e:
        return

    var.project_data = {
        "filename": fn,
        "regions": [
            {
                "filename": data["region_0"],
                "data": r0,
            },
            {
                "filename": data["region_1"],
                "data": r1,
            },
            {
                "filename": data["region_2"],
                "data": r2,
            },
            {
                "filename": data["region_3"],
                "data": r3,
            },
        ],
        "photo": {
            "filename": data["photo"],
            "data": p,
        },
    }


def load_region(fn):
    # if does not exist
    if not os.path.exists(fn):
        messagebox.showerror(title="Error Loading Region", message="File does not exist")
        return

    data = []
    with open(fn) as f:
        for l in f.readlines():
            n = os.path.join(os.path.dirname(fn), l[:-1])
            a, e = load_anim(n)
            if e:
                return data, True
            data.append(
                {
                    "filename": l[:-1],
                    "data": a,
                }
            )
    return data, False


def load_anim(fn):
    return load_json(fn, "Error Loading Anim")


def load_photo(fn):
    return load_json(fn, "Error Loading Photo")


def load_json(fn, error_name):
    # if does not exist
    if not os.path.exists(fn):
        messagebox.showerror(title=error_name, message=f"File '{fn}' does not exist")
        return [], True

    with open(fn) as f:
        # read json
        try:
            data = json.load(f)
        except Exception as error:
            print(error)
            messagebox.showerror(title=error_name, message=f"{error}")
            return [], True
        #
        return data, False
