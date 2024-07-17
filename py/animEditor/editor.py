from tkinter import *
from tkinter import ttk
from MainMenu import *
from LeftFrame import *
from MidFrame import *
import var


class MainWindow(Tk):
    def __init__(self, screenName: str | None = None, baseName: str | None = None, className: str = "Tk", useTk: bool = True, sync: bool = False, use: str | None = None) -> None:
        super().__init__(screenName, baseName, className, useTk, sync, use)
        self.title("Animation Editor")
        self.geometry("500x400")
        self.json_2_region = []

        self.menu = MainMenu(self)

        # create main frame
        self.mainframe = ttk.Frame(self, borderwidth=1, relief=SOLID, padding="4 4 4 4")
        self.mainframe.pack(expand=True, fill=BOTH)
        self.mainframe.columnconfigure(0, weight=1)
        self.mainframe.columnconfigure(1, weight=1)
        self.mainframe.columnconfigure(2, weight=1)
        self.mainframe.rowconfigure(0, weight=1)
        # create left frame
        self.leftframe = LeftFrame(self.mainframe, self)
        # create middle frame
        self.midframe = MidFrame(self.mainframe, self)
        # create left frame
        self.rightframe = ttk.Frame(self.mainframe, borderwidth=1, relief=SOLID)

        self.startinfo = ttk.Label(self.mainframe, text="Open or create a image project using the window menu")
        self.startinfo.pack()

    def update_jsonlist(self):
        # update list
        i = 0
        self.json_2_region = []
        self.leftframe.jsonlist.delete(0, self.leftframe.jsonlist.size())
        for ri, r in enumerate(var.project_data["regions"]):
            for anim in r["data"]:
                self.leftframe.jsonlist.insert(i, anim["filename"])
                self.json_2_region.append(ri)
                i += 1
        # update display
        self.startinfo.pack_forget()
        self.midframe.grid_forget()
        self.leftframe.grid(row=0, column=0, sticky="nwes")


# create window
window = MainWindow()
# start event loop
window.mainloop()
