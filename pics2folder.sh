#!/bin/bash
####################
# sort pics to folder

function getTimeStamp ()
{
	local date=$(exiv2 -q -Pv -g Exif.Image.DateTime "${1}" |awk '{print $1}'|tr ':' ' ')
	if [[ "x"$date != "x" ]]; then
		read YEAR MONTH DAY <<<${date}
	else
		echo "No exif data!"
		YEAR=0000
		MONTH=00
		DAY=00
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
	for i in $(find "${SRCBASE}" -iname "*.${1}"); do
		getTimeStamp "${i}";
		if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
			echo "Skipping \"${i}\""
			continue
		fi
		createFolder "${DSTBASE}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
		for x in ${i%.*}.*; do
			local FILENAME=$(basename "${x}")
			local NAME=${FILENAME%.*}
			local EXT=$(echo ${FILENAME##*.} |tr "[:upper:]" "[:lower:]")
			if [[ ${EXT} != "jpg" ]]; then
				EXT=${FILENAME##*.}
			fi
			if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}" ]]; then
				echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}\" existiert! **"
			else
				cp -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${NAME}.${EXT}"
			fi
		done
	done
}

function movePicsToFolder ()
{
	local i
	local x
	for i in $(find "${SRCBASE}" -iname "*.${1}"); do
		getTimeStamp "${i}";
		if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
			echo "Skipping \"${i}\""
			continue
		fi
		createFolder "${DSTBASE}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
		for x in ${i%.*}.*; do
			local FILENAME=$(basename "${x}")
			local NAME=${FILENAME%.*}
			local EXT=$(echo ${FILENAME##*.} |tr "[:upper:]" "[:lower:]")
			if [[ ${EXT} != "jpg" ]]; then
				EXT=${FILENAME##*.}
			fi
			if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}" ]]; then
				echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}\" existiert! **"
			else
				mv -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${NAME}.${EXT}"
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
