# __IDE_NAME__ Nautilus Extension
#
# Place me in ~/.local/share/nautilus-python/extensions/,
# ensure you have python-nautilus package, restart Nautilus, and enjoy :)
#
# This script is released to the public domain.

from gi.repository import Nautilus, GObject
from subprocess import call
import os

# path to ide (string)
IDE_COMMAND = '__IDE_COMMAND__'

# context menu name? (string)
IDE_NAME = '__IDE_NAME__'

# new window support (boolean)
NEW_WINDOW_SUPPORT = __NEW_WINDOW_SUPPORT__

# new window argument (string)
NEW_WINDOW_ARG = '__NEW_WINDOW_ARG__'

# always create new window? (boolean)
NEW_WINDOW_ALWAYS = __NEW_WINDOW_ALWAYS__



class __IDE_NAME__Extension(GObject.GObject, Nautilus.MenuProvider):

    def launch_ide(self, menu, files):
        safepaths = ''
        args = ''

        for file in files:
            filepath = file.get_location().get_path()
            safepaths += '"' + filepath + '" '

            # If one of the files we are trying to open is a folder
            # and IDE support new-window argument
            # create a new instance of ide
            if NEW_WINDOW_SUPPORT and os.path.isdir(filepath) and os.path.exists(filepath):
                args = NEW_WINDOW_ARG

        if NEW_WINDOW_ALWAYS:
            args = NEW_WINDOW_ARG

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
