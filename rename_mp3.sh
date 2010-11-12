#!/bin/bash
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Fr 25 Sep 2009 11:13:45 #u

SRCDIR="/Volumes/My Passport/Music/iTunes/iTunes Media/Music/"

TARGETDIR="/Users/krid/Music/tracks"

mkdir -vp "$TARGETDIR"

SUBCNT=0
SUBCNTP=$(printf %06d $SUBCNT)

find "$SRCDIR" -name "*.*3" -print0 | while read -d $'\0' file
do
	while [[ -e "$TARGETDIR/track-$SUBCNTP.mp3" ]]
	do
		let SUBCNT=$SUBCNT+1
		SUBCNTP=$(printf %06d $SUBCNT)
	done

	#echo mv -iv "$file" "$TARGETDIR/track-$SUBCNTP.mp3"
	cp -iv "$file" "$TARGETDIR/track-$SUBCNTP.mp3"

	let SUBCNT=$SUBCNT+1
	SUBCNTP=$(printf %06d $SUBCNT)
done



# vim: ts=2:sw=2:tw=0:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
