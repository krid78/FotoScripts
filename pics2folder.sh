#!/bin/bash
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Fr 25 Sep 2009 11:13:45 #u

#TODO
# finde eine Lösung, wie du elegant den Namen des Fotos herausbekommst, um so vor dem kopieren zu bestimmen, ob du das musst
function createFilelist ()
{
	local SORTLIST=""
	local i
	FILELIST=""
	SORTLIST=$(gfind "${BASEDIR}" -iname "${1}" |xargs basename |sort -u)
	for i in ${SORTLIST}; do
		FILELIST="${FILELIST} $(gfind "${BASEDIR}" -name ${i})"
	done
}

function getDirNameByExif ()
{
	local TMP="$(exiv2 ${1} |grep Zeitstempel)"
	TMP="$(echo ${TMP} |cut -d ' ' -f 4 |sed 's/^[ \t]*//;s/[ \t]*$//')"
	local YEAR="$(echo ${TMP} |cut -d ':' -f 1 |sed 's/^[ \t]*//;s/[ \t]*$//')"
	local MONTH="$(echo ${TMP} |cut -d ':' -f 2 |sed 's/^[ \t]*//;s/[ \t]*$//')"
	local DAY="$(echo ${TMP} |cut -d ':' -f 3 |sed 's/^[ \t]*//;s/[ \t]*$//')"
	#DIRNAME=${TARGETBASE}/${YEAR}/${YEAR}_${MONTH}
	DIRNAME=${TARGETBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}
	FILEDATE=${YEAR}${MONTH}${DAY}
}

function sortToFolder ()
{
	local i
	for i in ${FILELIST}; do
		getDirNameByExif ${i}

		FILE="$(basename ${i})"

		mkdir -p ${DIRNAME}

		# Ignoriere Duplikate!
		if [[ -e "${DIRNAME}/${FILE}" ]]; then
			echo "** \"${DIRNAME}/${FILE}\" existiert! **"
			rm -v ${i%.*}.*
		else
			for x in ${i%.*}.*; do
				#jhead -exonly -nf'%Y%m%d-%f' "${i}" # immer noch nicht das, was ich will
				mv -iv "${x}" "${DIRNAME}/$(basename ${x})"
			done
		fi

	done
}

BASEDIR=${1:-.}
pushd ${BASEDIR}
BASEDIR=${PWD}
popd
echo "BASEDIR=${BASEDIR}"

TARGETBASE=${2:-./FotosNeu}
pushd ${TARGETBASE}
TARGETBASE=${PWD}
popd
echo "TARGETBASE=${TARGETBASE}"

BASEEXT=${3:-jpg}
echo "BASEEXT=${BASEEXT}"

createFilelist "*.${BASEEXT}"
sortToFolder


# vim: ts=2:sw=2:tw=0:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
