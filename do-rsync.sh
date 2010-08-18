#!/bin/bash
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Mi 04 Nov 2009 10:52:30 #u
# Last Modified :  <Mi 18 Aug 2010 21:16:17 krid>
#
# do recursive rsync from $1 to $2 excluding $3 (and some defaults)
########################################################################
# cd /Users/krid/Pictures/iPhoto\ Library
# bash /Users/krid/Pictures/Fotos_JMT/Scripts/do-rsync.sh ./Originals/ /Users/krid/Pictures/ImportedFotos/iPhoto\ Library/

# DEBUG
# set -x

unset PATH

LOGFILE="${HOME}/do-rsync.log"
#LOGFILE="/dev/null"
#echo "----------" >> ${LOGFILE}
echo "----------" > ${LOGFILE}
echo $(/bin/date +"%Y-%m-%d %H:%M") >> ${LOGFILE}
echo "----------" >> ${LOGFILE}

# ------------- system commands used by this script --------------------
RM="/bin/rm"
MV="/bin/mv"
CP="/bin/cp"
CHMOD="/bin/chmod"
FIND="/Users/krid/bin/find"
RSYNC="/usr/bin/rsync"
TOUCH="/usr/bin/touch"
SED="/usr/bin/sed"
DATE="/bin/date"
CAT="/bin/cat"
TIME="/usr/bin/time"
SLEEP="/bin/sleep"
GREP="/usr/bin/grep"
TR="/usr/bin/tr"
SED="/usr/bin/sed"

# ------------- source directory -----------------------------------------------
SOURCE=${1:-"./"}
#pushd ${SOURCE} >& /dev/null
#SOURCE=${PWD}
#popd >& /dev/null


# ------------- destination directory ------------------------------------------
DESTINATION=${2:-"/Volumes/WD Passport"}
#pushd "${DESTINATION}" >& /dev/null
#DESTINATION=${PWD}
#popd >& /dev/null

# ------------- users given exclude --------------------------------------------
# TODO

#*******************************************************************************
#** This path is the important one
#** This is the location of the sync directories
#** NOTE: The path should NOT have a trailing /
#*******************************************************************************

# exclude list -----------------------------------------------------------------
EXCLUDE_FILE=`"${DATE}" +"/tmp/exclude_%y%m%d%H%M%S.rsync"`
"${CAT}" > ${EXCLUDE_FILE} << "EOF"
.Trash
.Trashes
.Spotlight-V100
.DS_Store
._.*
.*.swp
iMovie Thumbnails
EOF
# end exclude list -------------------------------------------------------------

# do dry run by default --------------------------------------------------------
DRY_RUN="--dry-run"

# command line arguments -------------------------------------------------------
for o in $@; do
	if [ "${o}" = "-x" ] ; then
		DRY_RUN=""
		continue
	else
		if [ $(echo ${o} | ${GREP} -c "^-") -gt 0 ]; then 
			echo "WARNING: Ignored ${o} unknown argument." >> ${LOGFILE}
		else
			echo "HINT: Ignored nonoption: ${o}" >> ${LOGFILE}
		fi
	fi
done

if [ "${DRY_RUN}" ]; then
	echo "Doing a dry run. Nothing is copied to ${DESTINATION}" >> ${LOGFILE}
else
	echo "Sync is executed. No dry run!" >> ${LOGFILE}
fi

# check destination path -------------------------------------------------------
if  [ -d "${DESTINATION}" ] && [ -w "${DESTINATION}" ]; then
	echo "Sync path ${DESTINATION} seems to be ok" >> ${LOGFILE}
else
	echo "ERROR: I have no write permissions to ${DESTINATION}" >> ${LOGFILE}
	echo "Exiting ...." >> ${LOGFILE}
	exit 1
fi

# rsync can now compare more than 2 versions and create hard links -------------
echo " \
${TIME} ${RSYNC} \
--rsync-path="${RSYNC}" \
${DRY_RUN} \
--verbose \
--human-readable \
--stats \
--progress \
--recursive \
--relative \
--update \
--size-only \
--sparse \
--delete \
--delete-excluded \
--exclude-from=\"${EXCLUDE_FILE}\" \
\"${SOURCE}\" \"${DESTINATION}\"" >> ${LOGFILE}

${TIME} ${RSYNC} \
--rsync-path="${RSYNC}" \
${DRY_RUN} \
--verbose \
--human-readable \
--stats \
--progress \
--recursive \
--relative \
--update \
--size-only \
--sparse \
--delete \
--delete-excluded \
--exclude-from="${EXCLUDE_FILE}" \
"${SOURCE}" "${DESTINATION}" 2>&1 | /usr/bin/tee -a "${LOGFILE}"

# exit cleanly -----------------------------------------------------------------
exit 0;

# end of file
# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
