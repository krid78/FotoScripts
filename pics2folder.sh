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
		local FILENAME=$(basename "${i}")
		getTimeStamp "${i}";
		if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
			echo "Skipping \"${i}\""
			continue
		fi
		createFolder "${DSTBASE}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
		if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${FILENAME}" ]]; then
			echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${FILENAME}\" existiert! **"
		else
			for x in ${i%.*}.*; do
				cp -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${FILENAME}"
			done
		fi
	done
}

function movePicsToFolder ()
{
	local i
	local x
	for i in $(find "${SRCBASE}" -iname "*.${1}"); do
		local FILENAME=$(basename "${i}")
		getTimeStamp "${i}";
		if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
			echo "Skipping \"${i}\""
			continue
		fi
		createFolder "${DSTBASE}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
		if [[ -e "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${FILENAME}" ]]; then
			echo "** \"${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${FILENAME}\" existiert! **"
		else
			for x in ${i%.*}.*; do
				mv -iv "$x" "${DSTBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${FILENAME}"
			done
		fi
	done
}

SRCBASE=${1:-.}
if [[ -d ${SRCBASE} ]]; then
	pushd ${SRCBASE}
	SRCBASE=${PWD}
	popd
	echo "SRCBASE=${SRCBASE}"
else
	exit
fi

DSTBASE=${2:-./Pictures}
if [[ -d ${DSTBASE} ]]; then
	pushd ${DSTBASE}
	DSTBASE=${PWD}
	popd
	echo "DSTBASE=${DSTBASE}"
else
	exit
fi

BASEEXT=${3:-jpg}
echo "BASEEXT=${BASEEXT}"

#copyPicsToFolder "${BASEEXT}"
movePicsToFolder "${BASEEXT}"

# vim: ts=2:sw=2:tw=0:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
