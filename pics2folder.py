#!/usr/bin/env python
# vim: ts=4:sw=4:sts=4:tw=120:expandtab:fileencoding=utf-8

"""
Package       :  pics2folder
Author(s)     :  Daniel Kriesten
Email         :  daniel.kriesten@etit.tu-chemnitz.de
Creation Date :  Mo 22 Jun 13:23:31 2015

Copy or move pictures from src-Folde to dst-Folder

at dst, create a new structure according to the image properties
Year/Year-Month

Rename the Images to YearMonthDay_<Filename>.<ext> or YearMonthDay_HHMMSS_<Filename>.<ext>



"""

import sys
import os
import shutil
import logging
__logger__ = logging.getLogger(__name__)
import logging.handlers
import argparse
import Quartz as Q
import CoreFoundation as CF

__DEFAULT_SOURCE__ = "~/Pictures/Fotos-Mediathek.photoslibrary/Masters"
__DEFAULT_DESTINATION__ = "/Volumes/photos"

class MyImage(object):

    """Represent a image file, containing
    the source and destiantion names, the creation date"""

    def __init__(self, src_filename, dst_basedir, move=None, name_with_time=None):
        """Initialize the Object
        """
        assert os.path.isfile(src_filename)

        self._move = move
        self._name_with_time = name_with_time
        self._pathparts = []
        self._dst_basedir = dst_basedir
        self._src_filename = os.path.abspath(src_filename)
        self._dst_filename = self._create_dst_filename()

    def _create_dst_filename(self):
        """create the destination path and the destination filename """
        filename, fileext = os.path.splitext(os.path.basename(self._src_filename))

        url = CF.CFURLCreateFromFileSystemRepresentation(None, self._src_filename, len(self._src_filename), False)
        img_src = Q.CGImageSourceCreateWithURL(url, {})
        properties = Q.CGImageSourceCopyPropertiesAtIndex(img_src, 0, None)
        __logger__.debug("==== properties ====\n%s", properties)
        if properties.has_key("{Exif}"):
            if properties["{Exif}"].has_key("DateTimeOriginal"):
                img_dt = properties["{Exif}"].has_key("DateTimeOriginal")
            elif properties["{Exif}"].has_key("DateTimeDigitized"):
                img_dt = properties["{Exif}"].has_key("DateTime")

        elif properties.has_key("{TIFF}"):
            img_dt = properties["{Exif}"].has_key("DateTime")
        else:
            __logger__.warning("%s: No Date and Time", self._src_filename)
            img_dt = u"0000:00:00 00:00:00"

        self._create_pathparts(timestr2list(img_dt))

        return ""

    def _create_pathparts(self, timelist):
        """create the parts of the destination path"""
        self._pathparts = [timelist[0], "-".join(timelist[1:3])]

    def _create_dst_dir(self, dst_path, pathparts=None):
        """Create the destination Directory """
        if not os.path.exists(dst_path):
            __logger__.debug("Will create %s", dst_path)
            # os.path.create(dst_path)

        if len(pathparts) >= 1:
            __logger__.debug("Go on unsing: %s", pathparts[1:])
            self._create_dst_dir(dst_path+"/"+pathparts[0], pathparts[1:])

    def copy_or_move(self):
        """Copy/Move source to destination """

        self._create_dst_dir(self._dst_basedir, self._pathparts)

        __logger__.debug("%s", self)
        if self._move:
            shutil.move(self._src_filename, self._dst_filename)
        else:
            shutil.copy2(self._src_filename, self._dst_filename)

    def __str__(self):
        """ pretty print the object"""
        thestr = ""
        if self._move:
            thestr = "Move "
        else:
            thestr = "Copy "

        return thestr + self._src_filename + " to " + self._dst_filename

def timestr2list(timestr):
    """Convert time string to list
    accepted input is: YYYY:MM:DD HH:MM:SS
    returns list seperated items
    """
    datetimelist = timestr.split(" :")
    assert len(datetimelist) == 6

    return datetimelist

def main():
    """The main function of this programm"""

    parser = argparse.ArgumentParser(
        description=u"Copy/Move pictures from src-Folder to dst-Folder, ordering them by time",
        conflict_handler="resolve")
    parser.add_argument("--version", action="version", version="%(prog)s 0.1")
    parser.add_argument("-v", "--verbose",
                        default=False,
                        action="count",
                        help=u"be verbose, repeat to increase level")
    parser.add_argument("-s", "--src_dir",
                        default=__DEFAULT_SOURCE__,
                        help="Source directory (default: "+__DEFAULT_SOURCE__+")")
    parser.add_argument("-d", "--dst_dir",
                        default=__DEFAULT_DESTINATION__,
                        help="Destination directory (default: "+__DEFAULT_DESTINATION__+")")
    parser.add_argument("-p", "--preserve", action="store_true", default=False, help="Only print what to do")

    options = parser.parse_args()

    ##########
    #python logger zur einfachen Ausgabe von Meldungen
    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)

    handler = logging.StreamHandler(stream=sys.stderr)

    ##########
    # logger Level ...
    if options.verbose > 1:
        handler.setLevel(logging.DEBUG)
    elif options.verbose:
        handler.setLevel(logging.INFO)
    else:
        handler.setLevel(logging.WARNING)

    handler.setFormatter(logging.Formatter("-- %(funcName)s [%(levelname)s]: %(message)s"))
    logger.addHandler(handler)

    dst_dir = os.path.abspath(os.path.expanduser(options.dst_dir))
    if not os.path.isdir(dst_dir):
        __logger__.error("%s is not a directory", dst_dir)
        return

    src_dir = os.path.abspath(os.path.expanduser(options.src_dir))
    if not os.path.isdir(src_dir):
        __logger__.error("%s is not a directory", src_dir)
        return

    logger.debug("src_dir: %s; dst_dir: %s", src_dir, dst_dir)

    # walk all levels of src_dir
    os.walk(src_dir)

if __name__ == '__main__':
    main()

