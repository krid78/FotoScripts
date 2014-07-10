#!/bin/bash
# File          :  clearname.sh
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Do 10 Jul 17:43:16 2014
########################################################################

RAWIN=${1:-}
INNAME=${1// /_}

FNAME=${INNAME##*/}
DNAME=${INNAME%/*}

FNAMEPARTS=(${FNAME//-/ })

if [[ ${#FNAMEPARTS[@]} -gt 2 ]]; then
	if [[ ${FNAMEPARTS[0]} == ${FNAMEPARTS[1]} ]]; then
		NEWNAME="$DNAME/${FNAMEPARTS[${#FNAMEPARTS[@]} - 1]}"
		if [[ -e ${NEWNAME} ]]; then
			echo rm -fv "${RAWIN}"
		else
			echo mv -iv "$INNAME" "$DNAME"/${FNAMEPARTS[${#FNAMEPARTS[@]} - 1]}
		fi
	else
		echo "Unnormal Filename: $FNAME"
	fi
fi


# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or

