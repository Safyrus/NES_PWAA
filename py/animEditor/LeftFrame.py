from tkinter import *
from tkinter import ttk
from tkinter import messagebox
from tkinter import filedialog
from tkinter import simpledialog
from AskMultiple import *
import var
import os


class LeftFrame(ttk.Frame):
    def __init__(self, master: Misc, window) -> None:
        super().__init__(master, borderwidth=1, relief=SOLID)
        self.window = window
        self.last_json_select = 0
        self.last_anim_select = 0

        #
        self.jsonlabel = ttk.Label(self, text="JSON List:")
        self.jsonlabel.grid(row=0, column=0, sticky="w")
        #
        self.jsonframe = ttk.Frame(self)
        self.jsonframe.grid(row=1, column=0)
        #
        self.jsonlist = Listbox(self.jsonframe)
        self.jsonlist.bind("<<ListboxSelect>>", self.update_anim)
        self.jsonlist.bind("<Button-3>", self.popup_json)
        self.jsonlist.pack(side=LEFT, fill=BOTH)
        #
        self.jsonscroll = Scrollbar(self.jsonframe)
        self.jsonscroll.pack(side=RIGHT, fill=BOTH)
        self.jsonscroll.config(command=self.jsonlist.yview)
        self.jsonlist.config(yscrollcommand=self.jsonscroll.set)

        #
        self.animlabel = ttk.Label(self, text="Anim List:")
        self.animlabel.grid(row=2, column=0, sticky="w")
        #
        self.animframe = ttk.Frame(self)
        self.animframe.grid(row=3, column=0)
        #
        self.animlist = Listbox(self.animframe)
        self.animlist.bind("<<ListboxSelect>>", self.update_midframe)
        self.animlist.bind("<Button-3>", self.popup_anim)
        self.animlist.pack(side=LEFT, fill=BOTH)
        #
        self.animscroll = Scrollbar(self.animframe)
        self.animscroll.pack(side=RIGHT, fill=BOTH)
        self.animlist.config(yscrollcommand=self.animscroll.set)
        self.animscroll.config(command=self.animlist.yview)

    def update_anim(self, event=None):
        # get selection index
        selection = self.jsonlist.curselection()
        if selection:
            self.last_json_select = selection[0]
            # get anim
            data = self.jsonlist.get(selection[0])
            anim = self.get_json(data)
            # update anim list
            self.animlist.delete(0, self.animlist.size())
            for i, a in enumerate(anim):
                self.animlist.insert(i, a["name"])
            self.window.midframe.grid_forget()
            self.window.rightframe.grid_forget()
            #
            self.animlabel.config(text=f"Anim List ({data}):")

    def update_midframe(self, event):
        # get selection index
        selection = event.widget.curselection()
        if selection:
            self.last_anim_select = selection[0]
            # update name
            n = event.widget.get(selection[0])
            self.window.midframe.name.set(n)
            # get anim
            i = self.window.json_2_region[self.last_json_select]
            anim = var.project_data["regions"][i]["data"][self.last_json_select]["data"][self.last_anim_select]
            # update idx
            v = anim["idx"]
            self.window.midframe.idxval.set(v)
            # update type
            v = anim["character"]
            self.window.midframe.typeval.set(int(len(v) > 0))
            # update background
            v = anim["background"]
            self.window.midframe.bkgimg.set(v)
            # update background palette
            if "palettes" in anim:
                v = anim["palettes"][0]
            else:
                v = [0, 0, 0, 0]
            self.window.midframe.bkgpalv0.set(v[0])
            self.window.midframe.bkgpalv1.set(v[1])
            self.window.midframe.bkgpalv2.set(v[2])
            self.window.midframe.bkgpalv3.set(v[3])
            # update character palette
            if "palettes" in anim:
                v = anim["palettes"][1]
            else:
                v = [0, 0, 0, 0, 0, 0]
            self.window.midframe.chrpalv0.set(v[0])
            self.window.midframe.chrpalv1.set(v[1])
            self.window.midframe.chrpalv2.set(v[2])
            self.window.midframe.chrpalv3.set(v[3])
            self.window.midframe.chrpalv4.set(v[4])
            self.window.midframe.chrpalv5.set(v[5])
            # display midframe
            self.window.midframe.update_type()
            self.window.midframe.grid(row=0, column=1, sticky="nwes")

    def popup_json(self, event):
        self.window.popup(event, self.callback_add_json, self.callback_remove_json)

    def popup_anim(self, event):
        self.window.popup(event, self.callback_add_anim, self.callback_remove_anim)

    def callback_add_json(self):

        # ask for filename
        filetypes = (("JSON files", "*.json"), ("All files", "*.*"))
        init_dir = os.path.dirname(var.project_data["filename"])
        fn = filedialog.asksaveasfilename(title="Enter new JSON filename", initialdir=init_dir, filetypes=filetypes)

        if not fn:
            return

        # if already exist
        if os.path.exists(fn):
            # ask for confirmation
            yes = messagebox.askyesno(title="Warning Add JSON", message=f"This file already exist. Its content will be erase. Are you sure ?")
            if not yes:
                return

        values = ["1", "2", "3", "4"]
        ask = AskMultiple(self.window, "Ask for Region", "What region ?", values)
        if ask.result not in values:
            return

        region = var.project_data["regions"][int(ask.result) - 1]
        base_region = os.path.dirname(region["filename"])
        path = os.path.relpath(fn, init_dir)
        path = os.path.join(path, base_region)
        region["data"].append(
            {
                "filename": path[:-1],
                "data": [],
            }
        )
        self.window.update_jsonlist()

    def callback_remove_json(self):
        # get selection
        selection = self.jsonlist.curselection()
        if not selection:
            messagebox.showerror(title="Error Removing JSON file", message="No File was selected. Try right clicking on a file.")
            return

        # get name
        self.last_json_select = selection[0]
        name = self.jsonlist.get(selection[0])

        # ask for confirmation
        yes = messagebox.askyesno(title="Warning Remove JSON", message=f"Do you really want to remove '{name}' ?")
        if not yes:
            return

        # remove it
        self.remove_json(name)
        # update ui
        self.window.update_jsonlist()

    def callback_add_anim(self):
        # ask for name
        name = simpledialog.askstring("Name", "New Background/Animation name:")
        if not name:
            return

        # new anim
        anim = {
            "name": name,
            "idx": 0,
            "background": var.EMPTY_IMG,
            "character": [],
            "time": [],
        }

        # add it
        i = self.window.json_2_region[self.last_json_select]
        print(self.last_json_select, i)
        var.project_data["regions"][i]["data"][self.last_json_select]["data"].append(anim)
        # update UI
        self.jsonlist.selection_set(self.last_json_select)
        self.update_anim()

    def callback_remove_anim(self):
        # get selection
        selection = self.animlist.curselection()
        if not selection:
            messagebox.showerror(title="Error Removing Anim file", message="No File was selected. Try right clicking on a file.")
            return

        # get name
        self.last_anim_select = selection[0]
        name = self.animlist.get(selection[0])

        # ask for confirmation
        yes = messagebox.askyesno(title="Warning Remove Anim", message=f"Do you really want to remove '{name}' ?")
        if not yes:
            return

        # remove it
        i = self.window.json_2_region[self.last_json_select]
        del var.project_data["regions"][i]["data"][self.last_json_select]["data"][self.last_anim_select]
        # update ui
        self.jsonlist.selection_set(self.last_json_select)
        self.update_anim()

    def get_json(self, fn):
        for r in var.project_data["regions"]:
            for anim in r["data"]:
                if anim["filename"] == fn:
                    return anim["data"]

    def remove_json(self, fn):
        for r in var.project_data["regions"]:
            for i, anim in enumerate(r["data"]):
                if anim["filename"] == fn:
                    del r["data"][i]
                    return
