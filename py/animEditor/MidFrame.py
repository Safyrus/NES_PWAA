from tkinter import *
from tkinter import ttk
import var
import os
from cmd_bkg import *


class MidFrame(ttk.Frame):
    def __init__(self, master: Misc, window) -> None:
        super().__init__(master, borderwidth=1, relief=SOLID)
        self.window = window
        self.columnconfigure(0, weight=1)

        # --- Name ----
        self.namelabel = ttk.Label(self, text="Name:")
        self.namelabel.grid(row=0, column=0, sticky="w")
        self.name = StringVar()
        self.nameentry = ttk.Entry(self, textvariable=self.name)
        self.nameentry.grid(row=0, column=1, sticky="w")
        self.nameentry.bind("<KeyRelease>", self.update_name)

        # --- Idx ----
        self.idxlabel = ttk.Label(self, text="Index:")
        self.idxlabel.grid(row=1, column=0, sticky="w")
        self.idxval = IntVar()
        self.idxentry = ttk.Entry(self, textvariable=self.idxval, width=6)
        self.idxentry.grid(row=1, column=1, sticky="w")
        self.idxentry.bind("<KeyRelease>", self.update_idx)

        # --- BKG / CHR ----
        self.typelabel = ttk.Label(self, text="Type:")
        self.typelabel.grid(row=2, column=0, sticky="w")
        self.typeval = IntVar()
        self.radio_bkg = Radiobutton(
            self,
            text="Background",
            variable=self.typeval,
            value=0,
            command=self.callback_update_type,
        )
        self.radio_bkg.grid(row=2, column=1, sticky="w")
        self.radio_chr = Radiobutton(
            self,
            text="Animation",
            variable=self.typeval,
            value=1,
            command=self.callback_update_type,
        )
        self.radio_chr.grid(row=2, column=2, sticky="w")

        # ---- background image ----
        self.bkgimglabel = ttk.Label(self, text="Background Image:")
        self.bkgimglabel.grid(row=3, column=0, sticky="w")
        self.bkgimg = StringVar()
        self.bkgimgentry = ttk.Entry(self, textvariable=self.bkgimg)
        self.bkgimgentry.grid(row=3, column=1, sticky="w")
        self.bkgimgentry.bind("<KeyRelease>", self.update_bkg)
        self.bkgimgbrowse = Button(self, text="Browse", command=self.callback_bkg)
        self.bkgimgbrowse.grid(row=3, column=2, sticky="w")

        # ---- background palette ----
        self.bkgpallabel = ttk.Label(self, text="Background Palette:")
        self.bkgpallabel.grid(row=4, column=0, sticky="w")
        self.bkgpalframe = ttk.Frame(self)
        self.bkgpalframe.grid(row=4, column=1, sticky="w")
        self.bkgpalv0 = IntVar()
        self.bkgpalv1 = IntVar()
        self.bkgpalv2 = IntVar()
        self.bkgpalv3 = IntVar()
        self.bkgpalv0entry = ttk.Entry(self.bkgpalframe, textvariable=self.bkgpalv0, width=2)
        self.bkgpalv0entry.grid(row=0, column=0, sticky="w")
        self.bkgpalv0entry.bind("<KeyRelease>", self.callback_bkgpal_0)
        self.bkgpalv1entry = ttk.Entry(self.bkgpalframe, textvariable=self.bkgpalv1, width=2)
        self.bkgpalv1entry.grid(row=0, column=1, sticky="w")
        self.bkgpalv1entry.bind("<KeyRelease>", self.callback_bkgpal_1)
        self.bkgpalv2entry = ttk.Entry(self.bkgpalframe, textvariable=self.bkgpalv2, width=2)
        self.bkgpalv2entry.grid(row=0, column=2, sticky="w")
        self.bkgpalv2entry.bind("<KeyRelease>", self.callback_bkgpal_2)
        self.bkgpalv3entry = ttk.Entry(self.bkgpalframe, textvariable=self.bkgpalv3, width=2)
        self.bkgpalv3entry.grid(row=0, column=3, sticky="w")
        self.bkgpalv3entry.bind("<KeyRelease>", self.callback_bkgpal_3)
        self.bkgpalremove = Button(self, text="Remove", command=self.callback_remove_pal)
        self.bkgpalremove.grid(row=4, column=2, sticky="w")

        #
        self.image = PhotoImage(file="nes_pal_dec.png")
        self.palimg = ttk.Label(self, image=self.image, borderwidth=1, relief=SOLID)
        self.palimg.grid(row=5, column=0, columnspan=3)

    def callback_remove_pal(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # remove val
        i = self.window.json_2_region[last_json]
        anim = var.project_data["regions"][i]["data"][last_json]["data"][last_anim]
        if "palettes" in anim:
            del anim["palettes"]

        self.bkgpalv0.set(0)
        self.bkgpalv1.set(0)
        self.bkgpalv2.set(0)
        self.bkgpalv3.set(0)
        self.bkgpalv0entry.config(foreground="black")
        self.bkgpalv1entry.config(foreground="black")
        self.bkgpalv2entry.config(foreground="black")
        self.bkgpalv3entry.config(foreground="black")

    def callback_bkgpal_0(self, even=None):
        self.callback_bkgpal(0, self.bkgpalv0, self.bkgpalv0entry)

    def callback_bkgpal_1(self, even=None):
        self.callback_bkgpal(1, self.bkgpalv1, self.bkgpalv1entry)

    def callback_bkgpal_2(self, even=None):
        self.callback_bkgpal(2, self.bkgpalv2, self.bkgpalv2entry)

    def callback_bkgpal_3(self, even=None):
        self.callback_bkgpal(3, self.bkgpalv3, self.bkgpalv3entry)

    def callback_bkgpal(self, n, val, entry):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new index
        i = self.window.json_2_region[last_json]
        try:
            # get val
            v = val.get()

            # out of bound check
            if not (0 <= v <= 63):
                entry.config(foreground="red")
                print("Palette", n, "out of bound")
                return

            # set val
            anim = var.project_data["regions"][i]["data"][last_json]["data"][last_anim]
            if "palettes" not in anim:
                anim["palettes"] = [[0, 0, 0, 0], [0, 0, 0, 0, 0, 0]]
            anim["palettes"][0][n] = v
            entry.config(foreground="black")

        except Exception as error:
            entry.config(foreground="red")
            print("Error:", error)

    def callback_bkg(self):
        fn, ok = cmd_bkg()
        if not ok:
            return
        base = var.project_data["filename"]
        fn = os.path.relpath(fn, os.path.dirname(base))
        self.bkgimg.set(fn)
        self.update_bkg()

    def callback_update_type(self):
        # background
        if self.typeval.get() == 0:
            # ask for confirmation
            yes = messagebox.askyesno(
                title="Warning Remove JSON",
                message=f"Switching to background will remove animation values. Are you sure ?",
            )
            if not yes:
                self.typeval.set(1)
                return
        self.update_type()

    def update_name(self, event):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new name
        i = self.window.json_2_region[last_json]
        n = self.name.get()
        var.project_data["regions"][i]["data"][last_json]["data"][last_anim]["name"] = n
        # update anim list
        anim = var.project_data["regions"][i]["data"][last_json]["data"]
        self.window.leftframe.animlist.delete(0, self.window.leftframe.animlist.size())
        for i, a in enumerate(anim):
            self.window.leftframe.animlist.insert(i, a["name"])
        self.window.leftframe.animlist.select_set(last_anim)

    def update_idx(self, event):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new index
        i = self.window.json_2_region[last_json]
        try:
            v = self.idxval.get()
            var.project_data["regions"][i]["data"][last_json]["data"][last_anim]["idx"] = v
            self.idxentry.config(foreground="black")
        except Exception as error:
            self.idxentry.config(foreground="red")
            print(error)

    def update_bkg(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new bkg
        i = self.window.json_2_region[last_json]
        v = self.bkgimg.get()
        var.project_data["regions"][i]["data"][last_json]["data"][last_anim]["background"] = v

    def update_type(self):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        i = self.window.json_2_region[last_json]
        anim = var.project_data["regions"][i]["data"][last_json]["data"][last_anim]
        if self.typeval.get() == 0:
            # background
            anim["character"] = []
            anim["time"] = []
            if "palettes_each" in anim:
                del anim["palettes_each"]
        else:
            # animation
            pass
