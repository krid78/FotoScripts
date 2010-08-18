#!/bin/bash
########################################################################
# $Id: $
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Do 24 Sep 2009 22:31:54 #u
########################################################################

BASEDIR=${1:-.}
pushd ${BASEDIR}
BASEDIR=${PWD}
popd

FILELIST=$(gfind ${BASEDIR} -iname 'CIMG*.JPG')

for i in ${FILELIST}; do
	jhead -nf'%Y-%m-%d-%H%M%S' $i
done

# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
