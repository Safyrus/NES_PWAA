from tkinter import *
from tkinter import messagebox
from cmd_new import *
from cmd_open import *
from cmd_save import *


class MainMenu(Menu):
    def __init__(self, window) -> None:
        super().__init__()
        self.window = window
        window.config(menu=self)

        file_menu = Menu(self, tearoff=False)
        self.add_cascade(menu=file_menu, label="File")
        file_menu.add_command(label="New", command=self.callback_new, accelerator="Ctrl+N")
        file_menu.add_command(label="Open", command=self.callback_open, accelerator="Ctrl+O")
        file_menu.add_command(label="Save", command=self.callback_save, accelerator="Ctrl+S")

        help_menu = Menu(self, tearoff=False)
        self.add_cascade(menu=help_menu, label="Help")
        help_menu.add_command(label="About", command=self.callback_about, accelerator="Ctrl+H")

        window.bind_all("<Control-n>", self.callback_new)
        window.bind_all("<Control-o>", self.callback_open)
        window.bind_all("<Control-s>", self.callback_save)
        window.bind_all("<Control-h>", self.callback_about)

    def callback_open(self, event=None):
        if cmd_open():
            self.window.update_jsonlist()

    def callback_new(self, event=None):
        if cmd_new():
            self.window.update_jsonlist()

    def callback_save(self, event=None):
        cmd_save()

    def callback_about(self, event=None):
        messagebox.showinfo("About", message="""
/!\ Still WIP /!\\

This barebone application should help you create animations for the NES-VN engine.
It just help creating and editing JSON files containing all backgrounds, animations and photos.

If you want, you can still edit the files by hand, but it's more cumbersome and prone to error.
(you can learn about the used JSON structure in the tutorial)

Also, creating this sort of app is not my thing. So, if you want to help, don't hesitate to do so.

Other Info:
- You can right click on the JSON or animation list to add or remove an element.

For Me / TODO:
- [X] background
- [.] animation
- [ ] photo
- [ ] Save warning
- [ ] Export Config
- [ ] Better UI (look, rescale, ...)
""")
