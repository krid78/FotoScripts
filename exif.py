#!/usr/bin/env python
# vim: ts=4:sw=4:sts=4:tw=120:expandtab:fileencoding=utf-8

"""
Source: https://gist.github.com/cefstat/229245

Change EXIF data with Python under Mac OS X using the Cocoa bindings

"""

import Quartz as Q
import CoreFoundation as CF
import os, sys

filename = os.path.abspath(sys.argv[1])
url = CF.CFURLCreateFromFileSystemRepresentation(None, filename, len(filename), False)

img_src = Q.CGImageSourceCreateWithURL(url, {})
properties = Q.CGImageSourceCopyPropertiesAtIndex(img_src, 0, None)

print properties

# try some dicts
exif = properties[Q.kCGImagePropertyExifDictionary]

if exif:
    print "==== Exif ===="
    print exif

#img_dest = Q.CGImageDestinationCreateWithURL(url, 'public.jpeg', 1, None)

#exif[Q.kCGImagePropertyExifDateTimeOriginal] = u'2009:06:17 21:03:18'

#Q.CGImageDestinationAddImageFromSource(\
#                                                      img_dest, img_src, 0,
#                                                    {Q.kCGImagePropertyExifDictionary: exif})

#Q.CGImageDestinationFinalize(img_dest)
