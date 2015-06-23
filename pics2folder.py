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
import datetime as dt
import Quartz as Q
import CoreFoundation as CF

__DEFAULT_SOURCE__ = "~/Pictures/Fotos-Mediathek.photoslibrary/Masters"
__DEFAULT_DESTINATION__ = "/Volumes/photo"

class MyImage(object):

    """Represent a image file, containing
    the source and destiantion names, the creation date"""

    def __init__(self, src_filename, dst_basedir, pretend=None, move=None, with_time=None):
        """Initialize the Object
        """
        assert os.path.isfile(src_filename)

        # Flags
        self._move = move
        self._pretend = pretend
        self._with_time = with_time
        __logger__.debug("Flags: pretend=%s, move=%s, with_time=%s", self._pretend, self._move, self._with_time)
        self._pathparts = []
        self._dst_basedir = dst_basedir
        self._src_filename = os.path.abspath(src_filename)
        self._dst_filename = self._create_dst_filename()

    def set_flags(self, pretend=None, move=None, with_time=None):
        """set the varios flags of this class"""
        self._move = move
        self._pretend = pretend
        self._with_time = with_time
        __logger__.debug("Flags: pretend=%s, move=%s, with_time=%s", self._pretend, self._move, self._with_time)
        self._dst_filename = self._create_dst_filename()

    def _create_dst_filename(self):
        """create the destination path and the destination filename """
        filename, fileext = os.path.splitext(os.path.basename(self._src_filename))

        url = CF.CFURLCreateFromFileSystemRepresentation(None, self._src_filename, len(self._src_filename), False)
        img_src = Q.CGImageSourceCreateWithURL(url, {})
        properties = Q.CGImageSourceCopyPropertiesAtIndex(img_src, 0, None)

        img_dt = self._handle_properties(properties)
        img_dt_list = timestr2list(img_dt)

        self._create_pathparts(img_dt_list)

        dst_filename = self._dst_basedir+os.path.sep+os.path.sep.join(self._pathparts)
        dst_filename += os.path.sep
        dst_filename += "".join(img_dt_list[0:3])
        dst_filename += "_"
        if self._with_time:
            dst_filename += "".join(img_dt_list[3:6])
            dst_filename += "_"

        dst_filename += filename+fileext.lower()

        __logger__.debug("Destination: %s", dst_filename)

        return dst_filename

    def _handle_properties(self, properties):
        """Search for DateTime-Field in properties
        """
        if properties:
            try:
                return properties["{Exif}"]["DateTimeOriginal"]
            except KeyError:
                pass

            try:
                return properties["{Exif}"]["DateTimeDigitized"]
            except KeyError:
                pass

            try:
                return properties["{Exif}"]["DateTime"]
            except KeyError:
                pass

            try:
                tstamp = properties["{ExifAux}"]["Regions"]["RegionList"][0]["Timestamp"]
                return dt.datetime.fromtimestamp(tstamp).strftime("%Y:%m:%d %H:%M:%S")
            except KeyError:
                pass

        __logger__.warning("%s: No Date and Time (ctime: %s)", self._src_filename, dt.datetime.fromtimestamp(
            os.path.getctime(self._src_filename)).strftime("%Y:%m:%d %H:%M:%S"))
        __logger__.info("==== properties ====\n%s", properties)

        return u"0000:00:00 00:00:00"

    def _create_pathparts(self, timelist):
        """create the parts of the destination path"""
        # TODO add more flexibility
        # use a dict for timelist and create the path from a option
        # --path year year-month day ==> 2015/2015-03/72
        # or use strftime
        self._pathparts = [timelist[0], "-".join(timelist[0:3])]

    def _create_dst_dir(self):
        """Create the destination Directory """
        dst_path = os.path.dirname(self._dst_filename)

        if os.path.exists(dst_path):
            return

        __logger__.info("Will create %s", dst_path)
        if self._pretend:
            sys.stdout.write("mkdir -vp %s\n" % dst_path)
        else:
            os.makedirs(dst_path)

    def copy_or_move(self):
        """Copy/Move source to destination """

        self._create_dst_dir()

        if os.path.exists(self._dst_filename):
            sys.stdout.write("Ignore existing: %s\n" % self._dst_filename)
            return

        if self._pretend:
            sys.stdout.write("%s\n" % self)
            return

        __logger__.debug("%s", self)
        if self._move:
            shutil.move(self._src_filename, self._dst_filename)
        else:
            shutil.copy2(self._src_filename, self._dst_filename)

    def __str__(self):
        """ pretty print the object"""
        thestr = ""
        if self._pretend:
            thestr += "Pretend to "

        if self._move:
            thestr += "Move "
        else:
            thestr += "Copy "

        return thestr + self._src_filename + " to " + self._dst_filename

def timestr2list(timestr):
    """Convert time string to list
    accepted input is: YYYY:MM:DD HH:MM:SS
    returns list seperated items
    """
    date_, time_ = timestr.split(" ")
    datetimelist = date_.split(":") + time_.split(":")
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
    parser.add_argument("-s", "--src",
                        default=__DEFAULT_SOURCE__,
                        help="Source directory (default: "+__DEFAULT_SOURCE__+")")
    parser.add_argument("-d", "--dst_dir",
                        default=__DEFAULT_DESTINATION__,
                        help="Destination directory (default: "+__DEFAULT_DESTINATION__+")")
    parser.add_argument("-e", "--extensions", default=["JPG"], nargs='+', help="Search for these extension")
    parser.add_argument("-t", "--with-time", action="store_true", default=False, help="use time in filenames as well")
    parser.add_argument("-p", "--pretend", action="store_true", default=False, help="Only print what to do")
    parser.add_argument("-m", "--move", action="store_true", default=False, help="Move the files")
    # TODO add options for destination path structure

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

    handler.setFormatter(logging.Formatter("[%(levelname)s %(funcName)s] %(message)s"))
    logger.addHandler(handler)

    dst_dir = os.path.abspath(os.path.expanduser(options.dst_dir))
    if not os.path.isdir(dst_dir):
        __logger__.error("%s is not a directory", dst_dir)
        return

    src = os.path.abspath(os.path.expanduser(options.src))
    if not os.path.isdir(src):
        __logger__.info("directly working on %s", src)
        myimg = MyImage(src, dst_dir, options.pretend, options.move, options.with_time)
        myimg.copy_or_move()
        return

    logger.info("src dir: %s", src)
    logger.info("dst dir: %s", dst_dir)
    logger.info("Extensions: %s", options.extensions)

    handle_count = 0
    # walk all levels of src
    for root, dirs, files in os.walk(src):
        for afile in files:
            if afile.endswith(tuple(options.extensions)):
                logger.debug("Hit: %s", root+os.path.sep+afile)
                myimg = MyImage(root+os.path.sep+afile, dst_dir, options.pretend, options.move, options.with_time)
                myimg.copy_or_move()
                handle_count += 1

    sys.stdout.write("Handeled %d images in XX seconds" % handle_count)

if __name__ == '__main__':
    main()

