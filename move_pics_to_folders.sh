#!/bin/bash
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Fr 25 Sep 2009 11:13:45 #u

function createFilelist ()
{
	SORTLIST=""
	FILELIST=""
	SORTLIST=$(gfind "${BASEDIR}" -iname "${1}" | xargs basename | sort -u)
	for i in ${SORTLIST}; do
		FILELIST="${FILELIST} $(gfind "${BASEDIR}" -name ${i})"
	done
}

#function createFolder ()
#{
#	for j in $(gfind ${BASEDIR} -maxdepth 1 -type d); do
#		i="$(basename ${j})"
#		i="$(basename${1})"
#		echo $i
#		YEAR="$(echo ${i}  | cut -d '-' -f 1 | sed 's/[ \t]*//;s/[ \t]*$//')"
#		MONTH="$(echo ${i} | cut -d '-' -f 2 | sed 's/[ \t]*//;s/[ \t]*$//')"
#		EVENT="$(echo ${i} | cut -d '-' -f 4 | sed 's/[ \t]*//;s/[ \t]*$//')"
#		echo ${YEAR}/${YEAR}_${MONTH}_${EVENT}
#	done
#}

function getDirNameByExif ()
{
	TMP="$(exiv2 "${1}" | grep Zeitstempel)"
	TMP="$(echo ${TMP} | cut -d ' ' -f 4 | sed 's/^[ \t]*//;s/[ \t]*$//')"
	YEAR="$(echo ${TMP} | cut -d ':' -f 1 | sed 's/^[ \t]*//;s/[ \t]*$//')"
	MONTH="$(echo ${TMP} | cut -d ':' -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//')"
	DAY="$(echo ${TMP} | cut -d ':' -f 3 | sed 's/^[ \t]*//;s/[ \t]*$//')"
	#DIRNAME=${TARGETBASE}/${YEAR}/${YEAR}_${MONTH}
	DIRNAME=${TARGETBASE}/${YEAR}/${YEAR}-${MONTH}-${DAY}
}

function getDirNameByEvent ()
{
	li="$(basename ${1})"
	YEAR="$(echo ${li}  | cut -d '-' -f 1 | sed 's/[ \t]*//;s/[ \t]*$//')"
	MONTH="$(echo ${li} | cut -d '-' -f 2 | sed 's/[ \t]*//;s/[ \t]*$//')"
	EVENT="$(echo ${li} | cut -d '-' -f 4 | sed 's/[ \t]*//;s/[ \t]*$//')"
	if [ ! -z ${EVENT} ]; then
		EVENT=_"$EVENT"
	fi
	echo \"$YEAR\" \"$MONTH\" \"$EVENT\"
	DIRNAME=${TARGETBASE}/${YEAR}/${YEAR}_${MONTH}${EVENT}
}

function sortToFolder ()
{
	for i in ${FILELIST}; do
		#getDirNameByEvent $(dirname ${i})
		getDirNameByExif ${i}
		FILE="$(basename ${i})"

		mkdir -p ${DIRNAME}
		if [ -e "${DIRNAME}/${FILE}" ]; then
			SUBCNT=1
			while ( [ -e "${DIRNAME}/${FILE}_${SUBCNT}" ] ); do
				let SUBCNT=SUBCNT+1
			done
			SUBCNT="_${SUBCNT}"
		fi

		#mv -iv "${i}" "${DIRNAME}/${FILE}${SUBCNT}"
		cp -iv "${i}" "${DIRNAME}/${FILE}${SUBCNT}"
		#jhead -nf'%Y%m%d-%f' "${DIRNAME}/${FILE}${SUBCNT}"

		SUBCNT=""
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
