# Generic Nautilus IDE Extension
#
# Place me in ~/.local/share/nautilus-python/extensions/,
# ensure you have python-nautilus package, restart Nautilus, and enjoy :)
#
# This script is released to the public domain.

import os
import shlex
import subprocess

from gi.repository import GObject, Nautilus

IDE_ID = "__IDE_ID__"
IDE_LABEL = "__IDE_LABEL__"
IDE_COMMAND = "__IDE_COMMAND__"
NEW_WINDOW = "__IDE_NEW_WINDOW__".lower() == "true"


class __CLASS_NAME__(GObject.GObject, Nautilus.MenuProvider):
    __gtype_name__ = "__GTYPE_NAME__"

    @staticmethod
    def _build_command(files):
        filepaths = []
        open_in_new_window = NEW_WINDOW

        for file_ in files:
            filepath = file_.get_location().get_path()
            if not filepath:
                continue

            filepaths.append(filepath)
            if os.path.isdir(filepath) and os.path.exists(filepath):
                open_in_new_window = True

        if not filepaths:
            return None

        command = shlex.split(IDE_COMMAND)
        if open_in_new_window:
            command.append("--new-window")

        command.extend(filepaths)
        return command

    def launch_ide(self, menu, files):
        command = self._build_command(files)
        if command is None:
            return

        subprocess.Popen(command)

    def get_file_items(self, *args):
        files = args[-1]
        item = Nautilus.MenuItem(
            name=f"{IDE_ID}Open",
            label=f"Open in {IDE_LABEL}",
            tip=f"Opens the selected files with {IDE_LABEL}",
        )
        item.connect("activate", self.launch_ide, files)
        return [item]

    def get_background_items(self, *args):
        file_ = args[-1]
        item = Nautilus.MenuItem(
            name=f"{IDE_ID}OpenBackground",
            label=f"Open in {IDE_LABEL}",
            tip=f"Opens the current directory with {IDE_LABEL}",
        )
        item.connect("activate", self.launch_ide, [file_])
        return [item]
