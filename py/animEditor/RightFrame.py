from tkinter import *
from tkinter import ttk
from cmd_select_file import *
import var


class RightFrame(ttk.Frame):
    def __init__(self, master: Misc, window) -> None:
        super().__init__(master, borderwidth=1, relief=SOLID)
        self.window = window

        self.last_select = 0

        # Frame list
        self.listlabel = ttk.Label(self, text="Frames:")
        self.listlabel.grid(row=1, column=0, sticky="w")
        self.chrframe = ttk.Frame(self)
        self.chrframe.grid(row=1, column=1)
        self.chrlist = Listbox(self.chrframe)
        self.chrlist.pack(side=LEFT, fill=BOTH)
        self.chrlist.bind("<ButtonRelease-1>", self.select_chr)
        self.chrlist.bind("<Button-3>", self.popup_chr)
        self.chrscroll = Scrollbar(self.chrframe)
        self.chrscroll.pack(side=RIGHT, fill=BOTH)
        self.chrlist.config(yscrollcommand=self.chrscroll.set)
        self.chrscroll.config(command=self.chrlist.yview)

        # Character Image
        self.chrimglabel = ttk.Label(self, text="Image:")
        self.chrimg = StringVar()
        self.chrimgentry = ttk.Entry(self, textvariable=self.chrimg)
        self.chrimgentry.bind("<KeyRelease>", self.update_chrimg)
        self.chrimgbrowse = Button(self, text="Browse", command=self.callback_browse)

        # Time
        self.timelabel = ttk.Label(self, text="Time:")
        self.timeval = IntVar()
        self.timeentry = ttk.Entry(self, textvariable=self.timeval, width=3)
        self.timeentry.bind("<KeyRelease>", self.update_time)

        # ---- character palette each ----
        self.paleachlabel = ttk.Label(self, text="Character Palette:")
        self.paleachframe = ttk.Frame(self)
        self.paleachv0 = IntVar()
        self.paleachv1 = IntVar()
        self.paleachv2 = IntVar()
        self.paleachv3 = IntVar()
        self.paleachv4 = IntVar()
        self.paleachv5 = IntVar()
        self.paleachv0entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv0, width=2)
        self.paleachv0entry.grid(row=0, column=0, sticky="w")
        self.paleachv0entry.bind("<KeyRelease>", self.callback_paleach_0)
        self.paleachv1entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv1, width=2)
        self.paleachv1entry.grid(row=0, column=1, sticky="w")
        self.paleachv1entry.bind("<KeyRelease>", self.callback_paleach_1)
        self.paleachv2entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv2, width=2)
        self.paleachv2entry.grid(row=0, column=2, sticky="w")
        self.paleachv2entry.bind("<KeyRelease>", self.callback_paleach_2)
        self.paleachv3entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv3, width=2)
        self.paleachv3entry.grid(row=0, column=3, sticky="w")
        self.paleachv3entry.bind("<KeyRelease>", self.callback_paleach_3)
        self.paleachv4entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv4, width=2)
        self.paleachv4entry.grid(row=0, column=4, sticky="w")
        self.paleachv4entry.bind("<KeyRelease>", self.callback_paleach_4)
        self.paleachv5entry = ttk.Entry(self.paleachframe, textvariable=self.paleachv5, width=2)
        self.paleachv5entry.grid(row=0, column=5, sticky="w")
        self.paleachv5entry.bind("<KeyRelease>", self.callback_paleach_5)
        self.paleachremove = Button(self, text="Remove", command=self.callback_remove_pal)
        self.paleachadd = Button(self, text="Add", command=self.callback_add_pal)

    def callback_add_pal(self, event=None):
        # get anim
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        r = self.window.json_2_region[last_json]
        anim = var.project_data["regions"][r]["data"][last_json]["data"][last_anim]
        # remove palettes each
        if "palettes_each" not in anim:
            anim["palettes_each"] = []
        # update list UI
        i = self.last_select
        self.update_list()
        self.chrlist.select_set(i)
        self.select_chr()

    def callback_remove_pal(self, event=None):
        # get anim
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        r = self.window.json_2_region[last_json]
        anim = var.project_data["regions"][r]["data"][last_json]["data"][last_anim]
        # remove palettes each
        if "palettes_each" in anim:
            del anim["palettes_each"]
        # update list UI
        i = self.last_select
        self.update_list()
        self.chrlist.select_set(i)
        self.select_chr()

    def callback_paleach_0(self, event=None):
        self.callback_pal(0, self.paleachv0, self.paleachv0entry)

    def callback_paleach_1(self, event=None):
        self.callback_pal(1, self.paleachv1, self.paleachv1entry)

    def callback_paleach_2(self, event=None):
        self.callback_pal(2, self.paleachv2, self.paleachv2entry)

    def callback_paleach_3(self, event=None):
        self.callback_pal(3, self.paleachv3, self.paleachv3entry)

    def callback_paleach_4(self, event=None):
        self.callback_pal(4, self.paleachv4, self.paleachv4entry)

    def callback_paleach_5(self, event=None):
        self.callback_pal(5, self.paleachv5, self.paleachv5entry)

    def callback_pal(self, n, val, entry):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new index
        r = self.window.json_2_region[last_json]
        try:
            # get val
            v = val.get()

            # out of bound check
            if not (0 <= v <= 63):
                entry.config(foreground="red")
                print("Palette", n, "out of bound")
                return

            # get animation
            anim = var.project_data["regions"][r]["data"][last_json]["data"][last_anim]
            # add palette each if missing
            if "palettes_each" not in anim:
                anim["palettes_each"] = []
            # add palette for current and previous frames if missing
            while len(anim["palettes_each"]) <= self.last_select:
                anim["palettes_each"].append([[0, 0, 0, 0], [0, 0, 0, 0, 0, 0]])
            # set val
            anim["palettes_each"][self.last_select][1][n] = v
            entry.config(foreground="black")

        except Exception as error:
            entry.config(foreground="red")
            print("Error:", error)

    def update_list(self):
        # get current anim
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        i = self.window.json_2_region[last_json]
        anim = var.project_data["regions"][i]["data"][last_json]["data"][last_anim]

        self.chrlist.delete(0, self.chrlist.size())
        for i, name in enumerate(anim["character"]):
            self.chrlist.insert(i, f"{i}: {name}")

        self.hide_field()

    def hide_field(self):
        # hide frame fields
        self.chrimglabel.grid_forget()
        self.chrimgentry.grid_forget()
        self.chrimgbrowse.grid_forget()
        self.timelabel.grid_forget()
        self.timeentry.grid_forget()
        self.paleachlabel.grid_forget()
        self.paleachframe.grid_forget()
        self.paleachremove.grid_forget()
        self.paleachadd.grid_forget()

    def popup_chr(self, event=None):
        self.window.popup(event, self.callback_new, self.callback_remove)

    def callback_new(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        r = self.window.json_2_region[last_json]
        # add it
        var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["character"].append(var.EMPTY_IMG)
        var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["time"].append(0)
        # update list
        self.update_list()

    def callback_remove(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        r = self.window.json_2_region[last_json]
        i = self.last_select
        self.last_select = 0
        # remove it
        del var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["character"][i]
        del var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["time"][i]
        # update list
        self.update_list()

    def update_time(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        # set new index
        r = self.window.json_2_region[last_json]
        i = self.last_select
        try:
            v = self.timeval.get()
            var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["time"][i] = v
            self.timeentry.config(foreground="black")
        except Exception as error:
            self.timeentry.config(foreground="red")
            print(error)

    def callback_browse(self, event=None):
        fn, ok = cmd_select_file()
        if not ok:
            return
        base = var.project_data["filename"]
        fn = os.path.relpath(fn, os.path.dirname(base))
        self.chrimg.set(fn)
        self.update_chrimg()

    def update_chrimg(self, event=None):
        last_json = self.window.leftframe.last_json_select
        last_anim = self.window.leftframe.last_anim_select
        r = self.window.json_2_region[last_json]
        i = self.last_select
        v = self.chrimg.get()
        var.project_data["regions"][r]["data"][last_json]["data"][last_anim]["character"][i] = v
        # update list UI
        self.update_list()
        self.chrlist.select_set(i)
        self.select_chr()

    def select_chr(self, event=None):
        selection = self.chrlist.curselection()
        if selection:
            # get current anim
            last_json = self.window.leftframe.last_json_select
            last_anim = self.window.leftframe.last_anim_select
            r = self.window.json_2_region[last_json]
            anim = var.project_data["regions"][r]["data"][last_json]["data"][last_anim]
            # get selection
            s = int(selection[0])
            self.last_select = s
            # update fields
            self.chrimg.set(anim["character"][s])
            self.timeval.set(anim["time"][s])
            # display frame fields
            self.chrimglabel.grid(row=2, column=0, sticky="w")
            self.chrimgentry.grid(row=2, column=1, sticky="w")
            self.chrimgbrowse.grid(row=2, column=2, sticky="w")
            self.timelabel.grid(row=3, column=0, sticky="w")
            self.timeentry.grid(row=3, column=1, sticky="w")
            self.paleachlabel.grid(row=4, column=0, sticky="w")
            if "palettes_each" in anim:
                #
                self.paleachframe.grid(row=4, column=1, sticky="w")
                self.paleachremove.grid(row=4, column=2, sticky="w")
                # add palette for current and previous frames if missing
                while len(anim["palettes_each"]) <= self.last_select:
                    anim["palettes_each"].append([[0, 0, 0, 0], [0, 0, 0, 0, 0, 0]])
                #
                self.paleachv0.set(anim["palettes_each"][s][1][0])
                self.paleachv1.set(anim["palettes_each"][s][1][1])
                self.paleachv2.set(anim["palettes_each"][s][1][2])
                self.paleachv3.set(anim["palettes_each"][s][1][3])
                self.paleachv4.set(anim["palettes_each"][s][1][4])
                self.paleachv5.set(anim["palettes_each"][s][1][5])
            else:
                self.paleachadd.grid(row=4, column=1, sticky="w")
        else:
            self.hide_field()
