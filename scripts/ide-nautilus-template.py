# __IDE_NAME__ Nautilus Extension
#
# Place me in ~/.local/share/nautilus-python/extensions/,
# ensure you have python-nautilus package, restart Nautilus, and enjoy :)
#
# This script is released to the public domain.

from gi.repository import Nautilus, GObject
from subprocess import call
import os

# path to ide
IDE_COMMAND = '__IDE_COMMAND__'

# what name do you want to see in the context menu?
IDE_NAME = '__IDE_NAME__'

# always create new window?
NEWWINDOW = False


class __IDE_NAME__Extension(GObject.GObject, Nautilus.MenuProvider):

    def launch_ide(self, menu, files):
        safepaths = ''
        args = ''

        for file in files:
            filepath = file.get_location().get_path()
            safepaths += '"' + filepath + '" '

            # If one of the files we are trying to open is a folder
            # create a new instance of ide
            if os.path.isdir(filepath) and os.path.exists(filepath):
                args = '--new-window '

        if NEWWINDOW:
            args = '--new-window '

        call(IDE_COMMAND + ' ' + args + safepaths + '&', shell=True)

    def get_file_items(self, *args):
        files = args[-1]
        item = Nautilus.MenuItem(
            name=IDE_NAME + 'Open',
            label='Open in ' + IDE_NAME,
            tip='Opens the selected files with ' + IDE_NAME
        )
        item.connect('activate', self.launch_ide, files)

        return [item]

    def get_background_items(self, *args):
        file_ = args[-1]
        item = Nautilus.MenuItem(
            name=IDE_NAME + 'OpenBackground',
            label='Open in ' + IDE_NAME,
            tip='Opens the current directory in ' + IDE_NAME
        )
        item.connect('activate', self.launch_ide, [file_])

        return [item]
