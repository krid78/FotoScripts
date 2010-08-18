#!/bin/bash
########################################################################
# ${Id}: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Do 24 Sep 2009 20:27:35 #u
########################################################################

function createFilelist ()
{
	SORTLIST=""
	FILELIST=""
	SORTLIST=$(gfind ${BASEDIR} -iname '2*.jpg' | xargs basename | sort -u)
	for i in ${SORTLIST}; do
		FILELIST="${FILELIST} $(gfind ${BASEDIR} -name ${i})"
	done
}

function renameIMG()
{
	OPENLIST=""
	lCMODEL=${1:-"EX-Z500"}
	lDSTBASE=${2:-"CIMG"}
	CNT=${3:-1}
	echo "*** ${lCMODEL} ${lDSTBASE} ${CNT} ***" >> discard.log
	for i in ${FILELIST}; do
		SRC=${i}
		DST=$(dirname ${SRC})
		if [ ! -z "$(jhead -model "${lCMODEL}" ${SRC})" ]; then 
			if [ ${CNT} -lt 10 ]; then
				DSTCNT="000${CNT}"
			elif [ ${CNT} -lt 100 ]; then
				DSTCNT="00${CNT}"
			elif [ ${CNT} -lt 1000 ]; then
				DSTCNT="0${CNT}"
			else
				DSTCNT="${CNT}"
			fi
			if [ -e "${DST}/${lDSTBASE}${DSTCNT}.JPG" ]; then
				SUBCNT=1
				while ( [ -e "${DST}/${lDSTBASE}${DSTCNT}_${SUBCNT}.JPG" ] ); do
					let SUBCNT=SUBCNT+1
				done
				SUBCNT="_${SUBCNT}"
			fi
			jhead -cmd "mv -vi &i ${DST}/${lDSTBASE}${DSTCNT}${SUBCNT}.JPG" ${SRC}
			exiv2 -T ${DST}/${lDSTBASE}${DSTCNT}${SUBCNT}.JPG
			#echo "${DST}/${lDSTBASE}${DSTCNT}${SUBCNT}.JPG"
			SUBCNT=""
			let CNT=CNT+1
		else
			echo "DISCARD: ${SRC}" >> discard.log
			echo $(exiv2 ${SRC} | grep hersteller) >> discard.log
			echo $(exiv2 ${SRC} | grep modell) >> discard.log
			echo $(exiv2 ${SRC} | grep nummer) >> discard.log
			OPENLIST="${OPENLIST} ${i}"
		fi
	done
	#echo OPENLIST: \"${OPENLIST}\"
}

BASEDIR=${1:-.}
pushd ${BASEDIR}
BASEDIR=${PWD}
popd
echo "BASEDIR=${BASEDIR}"

#CASIO
CMODEL="EX-Z500"
DSTBASE="CIMG"
createFilelist
renameIMG ${CMODEL} ${DSTBASE}

#CASIO
CMODEL="EX-Z11"
DSTBASE="CIMG"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#NIKON
CMODEL="D50"
DSTBASE="D50_DSC0"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#NIKON
CMODEL="D80"
DSTBASE="D80_DSC0"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#CANON
CMODEL="IXUS 40"
DSTBASE="113-"
#createFilelist
FILELIST=${OPENLIST}
renameIMG "${CMODEL}" ${DSTBASE} 1349

#CANON
CMODEL="PowerShot A95"
DSTBASE="141-"
#createFilelist
FILELIST=${OPENLIST}
renameIMG "${CMODEL}" ${DSTBASE} 4123

#KODAK
CMODEL="CX4230"
DSTBASE="000_"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#Sony Ericsson
CMODEL="W910i"
DSTBASE="DSC0"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#Panasonic
CMODEL="DMC-LZ7"
DSTBASE="DMC-DCM0"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#???
CMODEL="AL530"
DSTBASE="IMG_"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

#Unknown
CMODEL="Unknown"
DSTBASE="Unknown"
#createFilelist
FILELIST=${OPENLIST}
renameIMG ${CMODEL} ${DSTBASE}

echo "*** List of not renamed images ***" >> discard.log
echo "${OPENLIST}" >> discard.log
FILELIST=${OPENLIST}
echo "${FILELIST}" >> openfiles.log

#####################################################################
#CNT=1
#for i in ${FILELIST}; do
#SRC=${i}
#DST=$(dirname ${SRC})
#if [ ! -z "$(jhead -model "${CMODEL}" ${SRC})" ]; then 
#if [ ${CNT} -lt 10 ]; then
#DSTCNT="000${CNT}"
#elif [ ${CNT} -lt 100 ]; then
#DSTCNT="00${CNT}"
#elif [ ${CNT} -lt 1000 ]; then
#DSTCNT="0${CNT}"
#else
#DSTCNT="${CNT}"
#fi
#if [ -e "${DST}/${DSTBASE}${DSTCNT}.JPG" ]; then
#SUBCNT=1
#while ( [ -e "${DST}/${DSTBASE}${DSTCNT}_${SUBCNT}.JPG" ] ); do
#let SUBCNT=SUBCNT+1
#done
#SUBCNT="_${SUBCNT}"
#fi
#echo jhead -cmd "mv -i &i ${DST}/${DSTBASE}${DSTCNT}${SUBCNT}.JPG" ${SRC}
#echo exiv2 -T ${DST}/${DSTBASE}${DSTCNT}${SUBCNT}.JPG
#let CNT=CNT+1
#else
#echo "DISCARD: ${SRC}" >> discard.log
#echo $(exiv2 ${SRC} | grep hersteller) >> discard.log
#echo $(exiv2 ${SRC} | grep modell) >> discard.log
#echo $(exiv2 ${SRC} | grep nummer) >> discard.log
#fi
#done

# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or

