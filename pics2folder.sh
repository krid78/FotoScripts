#!/bin/bash
####################
# sort pics to folder

#set -x
MOVE=1
#DATETIME=yes
#MOVE=
DATETIME=

function getTimeStamp ()
{
	local date=$(exiv2 -q -Pv -g Exif.Image.DateTime "${1}" |awk '{print $1}'|tr ':' ' ')
	local ptime=$(exiv2 -q -Pv -g Exif.Image.DateTime "${1}" |awk '{print $2}'|tr ':' ' ')
	if [[ "x"$date != "x" ]]; then
		read YEAR MONTH DAY <<<${date}
		read HOUR MINUTE SECOND <<<${ptime}
	else
		echo "No Exif.Image.DateTime; trying Exif.Photo.DateTimeDigitized"
		date=$(exiv2 -q -Pv -g Exif.Photo.DateTimeDigitized "${1}" |awk '{print $1}'|tr ':' ' ')
		ptime=$(exiv2 -q -Pv -g Exif.Image.DateTime "${1}" |awk '{print $2}'|tr ':' ' ')
		if [[ "x"$date != "x" ]]; then
			read YEAR MONTH DAY <<<${date}
			read HOUR MINUTE SECOND <<<${ptime}
		else
			echo "No exif data!"
			YEAR=0000
			MONTH=00
			DAY=00
			HOUR=00
			MINUTE=00
			SECOND=00
		fi
	fi
}

function createFolder ()
{
	mkdir -vp "${1}"
}

function copyPicsToFolder ()
{
	local i
	local x
	#for i in $(find "${SRCBASE}" -iname "*.${1}"); do
	find "${SRCBASE}" -iname "*.${1}"|while read i; do
		getTimeStamp "${i}";
		if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
			echo "Skipping \"${i}\""
			continue
		fi
		createFolder "${DSTBASE}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
		for x in "${i%.*}".*; do
			local FILENAME=$(basename "${x}")
			local NAME=${FILENAME%.*}
			local EXT=$(echo ${FILENAME##*.} |tr "[:upper:]" "[:lower:]")
			if [[ ${EXT} != "jpg" ]]; then
				EXT=${FILENAME##*.}
			fi
			if [[ "x"${DATETIME} != "x" ]]; then
				if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_${NAME}.${EXT}" ]]; then
					echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_${NAME}.${EXT}\" existiert! **"
				else
					if [[ "x"${MOVE} != "x" ]]; then
						mv -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_"${NAME}.${EXT}"
					else
						cp -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_"${NAME}.${EXT}"
					fi
				fi
			else
				if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}" ]]; then
					echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}\" existiert! **"
				else
					if [[ "x"${MOVE} != "x" ]]; then
						mv -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${NAME}.${EXT}"
					else
						cp -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${NAME}.${EXT}"
					fi
				fi
			fi
		done
	done
}

####################
# adapt the PATH and DYLD_LIBRARY_PATH
####################

export PATH=$PATH:/Volumes/MY\ PASSPORT/Pictures/Fotos/Tools
export DYLD_LIBRARY_PATH=$DYLD_LIBRARY_PATH:/Volumes/MY\ PASSPORT/Pictures/Fotos/Tools

SRCBASE=${1:-.}
if [[ -d "${SRCBASE}" ]]; then
	pushd "${SRCBASE}"
	SRCBASE="${PWD}"
	popd
	echo "SRCBASE=\"${SRCBASE}\""
else
	exit
fi

DSTBASE=${2:-./Pictures}
if [[ -d "${DSTBASE}" ]]; then
	pushd "${DSTBASE}"
	DSTBASE="${PWD}"
	popd
	echo "DSTBASE=\"${DSTBASE}\""
else
	exit
fi

BASEEXT=${3:-jpg}
echo "BASEEXT=${BASEEXT}"

copyPicsToFolder "${BASEEXT}"
#movePicsToFolder "${BASEEXT}"

# vim: ts=2:sw=2:tw=0:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
