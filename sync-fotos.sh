#!/bin/bash
########################################################################
# $Id: $
# General Header #######################################################
# File          :  sync-fotos.sh
# Project       :  sync fotos
# Author(s)     :  Daniel Kriesten
# Email         :  daniel.kriesten@etit.tu-chemnitz.de
# Creation Date :  Fr 04 Jan 2008 09:52:40 #u
# Contents      :  Synchronisiert Fotos zwischen 2 Verzeichnissen
########################################################################


# TODO
# - optional (-k) originalbild mit kopieren
# - Bildnamen: thumb_* small_* *
# - dann im PHP gucken ob zum small_* ein thumb_* existiert (wie schon jetzt)
# - und ob zum small_* ein <bildname> existiert
# - dann von thumb_ ein Link zu small_ und von small_ zu <bildname>

#--------------------------------------------------
# size of the pictures
# 480801@ == 800x600
# 10800@  == 120x95
# mit @ wird das Bild xdim*ydim pixel bei Erhalt des Verhältnisses von xdim zu ydim
#-------------------------------------------------- 
picturesize=480801@
picqual=75
thumbsize=10800@
thumbqual=50


#--------------------------------------------------
# directories src and dst
#-------------------------------------------------- 
thisdir=$(pwd)
src=${1:-$thisdir}
dst=${2:-$thisdir}

#--------------------------------------------------
# tools
#-------------------------------------------------- 
jhead=$(which jhead)
convert=$(which convert)
mogrify=$(which mogrify)
find=$(which find)

#--------------------------------------------------
# Functions
#-------------------------------------------------- 
function DoDir()
{
	# remove whitespace
	nwsrc=$(echo $1 | sed 's/\([^\]\) /\1\\ /g')
	nwdst=$(echo $2 | sed 's/\([^\]\) /\1\\ /g')

	find $nwsrc -mindepth 1 -maxdepth 1 -type d -printf 'mkdir -vp $nwdst/"%p\n"' | sh

	i=$(find "$nwdst" -mindepth 1 -maxdepth 1 -type d -empty)

	echo "x"
	for x in $i; do
		echo $x
	done
}

function DoPicture()
{
	echo "copy and resize $1"
	if [ "$src" = "$thisdir" -a "$dst" = "$thisdir" ]; then
		"$mogrify" -quality "$picqual" -resize "$picturesize" "$1"
	else
		"$convert" -quality "$picqual" -resize "$picturesize" "$src/$1" "$dst/$1"
	fi

}

function DoRename()
{
	echo "renaming $1"
	"$jhead" -autorot -nf%Y-%m-%d-%H%M%S "$1"
}

function DoThumb()
{
	echo "creating thumbnail for $1"
	"$convert" -quality "$thumbqual" -resize "$thumbsize" "$1" "thumb_$1"
}

DoHtaccess()
{
	if [ ! -f "$1"/.htaccess ]; then 
		cat > "$1"/.htaccess << STOP
#http://www.tu-chemnitz.de/urz/www/access.html
 DirectoryIndex /~krid/index.php?page=fotos
 SSLRequireSSL
 ErrorDocument 403 /errors/403ssl.shtml
 AuthName "Nutzername + Passwort"
 AuthType Basic
 AuthUserFile /afs/tu-chemnitz.de/home/urz/k/krid/public_html/_general/.htpasswd
 AuthGroupFile /afs/tu-chemnitz.de/home/urz/k/krid/public_html/_general/.htgroup

# zugriff für alle nutzer!
#require valid-user

# zugriff einschraenken
 Require user krid wij
#Require group friends

# Rechner zulassen/verbieten
#order deny,allow
#deny from all
#allow from .de .at
STOP
	fi
}

#--------------------------------------------------
# Main
#-------------------------------------------------- 
if [ -z "$jhead" ]; then
	echo "Error: missing jhead"
	exit 1
fi

if [ -z "$convert" ]; then
	echo "Error: missing convert"
	exit 1
fi

if [ -z "$mogrify" ]; then
	echo "Error: missing mogrify"
	exit 1
fi

# remove whitespace
# src=$(echo $src | sed 's/\([^\]\) /\1\\ /g')
# dst=$(echo $dst | sed 's/\([^\]\) /\1\\ /g')

#--------------------------------------------------
# echo "Da muss noch was getan werden!!!"
# echo "Erst mit DoDir verzeichnisse erstellen:"
# echo 'cd $src; find . -mindepth 1 -maxdepth 1 -printf "mkdir -vp $dst/%p\n"|sh'
# echo "i=find-empty in dst & erstelle fotos von src/i ind dst/i"
# DoDir "$src" "$dst"
# exit 1
#-------------------------------------------------- 

if [ ! -d $dst ]; then
	echo "Error: target directory does not exist"
	exit 1
fi

echo "creating album using files in:"
echo -e "\t '$src'"
echo "target dir is:"
echo -e "\t '$dst'"

for i in "$src"/*.{JPG,jpg}; do
	echo "checking: $i"
	if [ -f "$i" ]; then 
		echo "processing: $i"
		file=$(basename "$i")
		DoPicture "$file"
		DoRename "$dst/$file"
	fi
done
pushd "$dst"
for i in *.jpg; do
	if [ -f "$i" ]; then
		DoThumb "$i"
	fi
done
popd
DoHtaccess "$dst"

# Modelines for ViM & Xemacs ###########################################
# vim: ts=2:sw=2:tw=80:fileformat=unix
# vim: comments& comments+=b\:# formatoptions& formatoptions+=or
########################################################################
