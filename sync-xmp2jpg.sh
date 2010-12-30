	#!/bin/bash
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Mi 04 Nov 2009 10:52:30 #u
# Last Modified :  <So 03 Jan 2010 11:57:28 krid>
#
# sync information from xmp file to jpg file
########################################################################

# DEBUG
# set -x

src=${1:-"."}

for i in $(find "$src" -name '*.xmp'); do
	if [ -f "${i%.*}.jpg" ]; then 
		exiv2 -v -iX "${i%.*}.jpg"
		rm -vf "$i"
	fi
done

# end of file
# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
