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
        self.timelabel.grid(row=3, column=0, sticky="w")
        self.timeval = IntVar()
        self.timeentry = ttk.Entry(self, textvariable=self.timeval, width=3)
        self.timeentry.bind("<KeyRelease>", self.update_time)

        # Palette
        self.paleachlabel = ttk.Label(self, text="Each Palette:")

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
        self.timeentry.grid_forget()
        self.paleachlabel.grid_forget()

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
        selection = self.chrlist.selection_get()
        if selection:
            # get current anim
            last_json = self.window.leftframe.last_json_select
            last_anim = self.window.leftframe.last_anim_select
            r = self.window.json_2_region[last_json]
            anim = var.project_data["regions"][r]["data"][last_json]["data"][last_anim]
            s = int(selection[0])
            self.last_select = s
            print(self.last_select)
            # update fields
            self.chrimg.set(anim["character"][s])
            self.timeval.set(anim["time"][s])
            # display frame fields
            self.chrimglabel.grid(row=2, column=0, sticky="w")
            self.chrimgentry.grid(row=2, column=1, sticky="w")
            self.chrimgbrowse.grid(row=2, column=2, sticky="w")
            self.timeentry.grid(row=3, column=1, sticky="w")
            self.paleachlabel.grid(row=4, column=0, sticky="w")
        else:
            self.hide_field()
