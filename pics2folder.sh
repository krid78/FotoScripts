#!/bin/bash
####################
# sort pics to folder

# Debugging
#set -x

#########################
# functions
function DEBUG()
{
  if [[ ! -z $VOPT ]]; then
    echo ${1}
  fi
}

function getCleanDirPath()
{
  local CDP
  local __result=$1
  pushd "${2}" >& /dev/null
  CDP="${PWD}"
  popd >& /dev/null
  eval $__result="'$CDP'"
}

function getTimeStamp ()
{
  DEBUG "Trying Exif.Photo.DateTimeDigitized"
  local pdate
  local ptime
  read pdate ptime <<<"$(exiv2 -q -Pv -g Exif.Photo.DateTimeDigitized "${1}")"
  if [[ "x"$pdate = "x" ]]; then
    DEBUG "No Exif.Photo.DateTimeDigitized; trying Exif.Photo.DateTimeOriginal"
    read pdate ptime <<<"$(exiv2 -q -Pv -g Exif.Photo.DateTimeOriginal "${1}")"
  fi
  if [[ "x"$pdate = "x" ]]; then
    DEBUG "No Exif.Photo.DateTimeOriginal; trying Exif.Image.DateTime;"
    read pdate ptime <<<"$(exiv2 -q -Pv -g Exif.Image.DateTime "${1}")"
  fi
  if [[ "x"$pdate = "x" ]]; then
    echo "***** No exif data! *****"
    #TODO: use file date & time
    pdate="0000:00:00"
    ptime="00:00:00"
  fi
  read YEAR MONTH DAY <<<$(echo ${pdate}|tr ':' ' ')
  read HOUR MINUTE SECOND <<<$(echo ${ptime}|tr ':' ' ')
}

function createFolder ()
{
  ${ECHO} mkdir ${VOPT} -p "${1}"
}

function copyPicsToFolder ()
{
  local i
  local x
  find "${SRCDIR}" -iname "*.${1}"|while read i; do
    getTimeStamp "${i}";
    if [[ "x"${YEAR}${MONTH}${DAY} == "x00000000" ]]; then
      echo "Skipping \"${i}\""
      continue
    fi
    createFolder "${DSTDIR}"/${YEAR}/${YEAR}-${MONTH}-${DAY}
    for x in "${i%.*}".*; do
      local FILENAME=$(basename "${x}")
      local NAME=${FILENAME%.*}
      local EXT=$(echo ${FILENAME##*.} |tr "[:upper:]" "[:lower:]")
      if [[ ${EXT} != "jpg" ]]; then
        EXT=${FILENAME##*.}
      fi
      if [[ -e "${DSTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_${NAME}.${EXT}" || -e "${DSTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}/${YEAR}${MONTH}${DAY}_${NAME}.${EXT}" ]]; then
          echo "** \"${DSTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}/<TIME_STAMP>_${NAME}.${EXT}\" existiert! **"
        else
          if [[ "x"${DATETIME} != "x" ]]; then
            ${ECHO} ${CPCOMMAND} ${VOPT} "$x" "${DSTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_${HOUR}${MINUTE}${SECOND}_"${NAME}.${EXT}"
          else
            ${ECHO} ${CPCOMMAND} ${VOPT} "$x" "${DSTDIR}/${YEAR}/${YEAR}-${MONTH}-${DAY}"/${YEAR}${MONTH}${DAY}_"${NAME}.${EXT}"
          fi
      fi
    done
  done
}

#########################
# initialize variables
VERSION=0.9.1
ECHO=
CPCOMMAND="cp -i"
VOPT=
getCleanDirPath SRCDIR "./"
DSTDIR="${HOME}/Pictures"
DATETIME=
BASEEXT="jpg"

#########################
# Main
NAME=$(basename $0)
USAGE="== ${NAME}; Version: ${VERSION} ==\n\
\n\
Usage: $0 <options> \n\
\n\
Options:\n\
  -s <dir>\t Source Directory (default: ${SRCDIR})\n\
  -d <dir>\t Destiantion Directory (default: ${DSTDIR})\n\
  -e <ext>\t Extension for Files (default: ${BASEEXT})\n\
  -m \t\t Move files (default is to copy them) \n\
  -n \t\t Only print the commands, but do nothing \n\
  -t \t\t Use date and time to name the files \n\
  -p <path>\t Path to append to systems Path, eg. for exiv2\n\
  -v \t\t Be verbose \n\
  -h \t\t This Help \n"

if [[ $# -lt 1 ]]; then 
  echo -e $USAGE
  exit 0
fi

while getopts "hvs:d:e:mtnp:" options; do
  #echo "Option: $options"
  case $options in
    m)
      CPCOMMAND="mv -i"
      ;;
    s)
      if [[ -d "${OPTARG}" ]]; then
        getCleanDirPath SRCDIR "${OPTARG}"
      else
        echo "Not a Directory: ${OPTARG}!"
        exit 2
      fi
      ;;
    d)
      if [[ -d "${OPTARG}" ]]; then
        getCleanDirPath DSTDIR "${OPTARG}"
      else
        echo "Not a Directory: ${OPTARG}!"
        exit 2
      fi
      ;;
    e)
      BASEEXT="${OPTARG}"
      ;;
    t)
      DATETIME="yes"
      ;;
    v)
      VOPT="-v"
      ;;
    n)
      ECHO="echo "
      ;;
    p)
      if [[ -d ${OPTARG} ]]; then
        PATH=${OPTARG}
      else
        echo "Not a Directory: ${OPTARG}!"
        exit 2
      fi
      ;;
    h)
      echo -e $USAGE
      exit 0
      ;;
    *)
      echo -e $USAGE
      exit 1
      ;;
  esac
done

if [[ ! -z $VOPT ]]; then
  echo -e "Settings: \n\
    CPCOMMAND=${CPCOMMAND} \n\
    VOPT=${VOPT} \n\
    ECHO=${ECHO} \n\
    PATH=${PATH} \n\
    SRCDIR=${SRCDIR} \n\
    DSTDIR=${DSTDIR} \n\
    DATETIME=${DATETIME} \n\
    BASEEXT=${BASEEXT} \n"
fi

#TODO: handle some special extensions, like mov

copyPicsToFolder "${BASEEXT}"

# vim: ts=2:sts=2:sw=2:expandtab:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
