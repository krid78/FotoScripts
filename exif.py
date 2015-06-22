#!/usr/bin/env python
# vim: ts=4:sw=4:sts=4:tw=120:expandtab:fileencoding=utf-8

"""
Source: https://gist.github.com/cefstat/229245

Change EXIF data with Python under Mac OS X using the Cocoa bindings

"""

import Quartz
from Quartz import *
import CoreFoundation as CF
import os, sys

filename = os.path.abspath(sys.argv[1])
url = CF.CFURLCreateFromFileSystemRepresentation(None, filename, len(filename), False)

img_src = Quartz.ImageIO.CGImageSourceCreateWithURL(url, {})
properties = Quartz.ImageIO.CGImageSourceCopyPropertiesAtIndex(img_src, 0, None)
exif = properties[Quartz.ImageIO.kCGImagePropertyExifDictionary]

if exif:
    print exif

gps = properties[Quartz.ImageIO.kCGImagePropertyGpsDictionary]

if gps:
    print gps
#img_dest = Quartz.ImageIO.CGImageDestinationCreateWithURL(url, 'public.jpeg', 1, None)

#exif[Quartz.ImageIO.kCGImagePropertyExifDateTimeOriginal] = u'2009:06:17 21:03:18'

#Quartz.ImageIO.CGImageDestinationAddImageFromSource(\
#                                                      img_dest, img_src, 0,
#                                                    {Quartz.ImageIO.kCGImagePropertyExifDictionary: exif})

#Quartz.ImageIO.CGImageDestinationFinalize(img_dest)
