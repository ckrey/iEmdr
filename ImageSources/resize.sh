#!/bin/bash

INK=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
IMAGEW=imagew

if [[ -z "$1" ]] 
then
	echo "SVG file needed."
	exit;
fi

BASE=`basename "$1" .svg`
SVG="$1"
MYPWD=`pwd`

# need to use absolute paths in OSX
$INK -z -D -e "$MYPWD/iTunesArtwork.png" -f 	$MYPWD/$SVG -w 1024 -h 1024
$INK -z -D -e "$MYPWD/iTunesArtwork@2x.png" -f 	$MYPWD/$SVG -w 2048 -h 2048

$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-1920.png" -w 1920 -h 1920
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-1280.png" -w 1280 -h 1280
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-1136.png" -w 1136 -h 1136
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-960.png" -w 960 -h 960
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-400.png" -w 400 -h 400

# App Icons

$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-29.png" -w 29 -h 29
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-29@2x.png" -w 58 -h 58
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-29@3x.png" -w 87 -h 87

$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-40.png" -w 40 -h 40
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-40@2x.png" -w 80 -h 80
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-40@3x.png" -w 120 -h 120

$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-60@2x.png" -w 120 -h 120
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-60@3x.png" -w 180 -h 180

$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-76.png" -w 76 -h 76
$IMAGEW "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-76@2x.png" -w 152 -h 152

# Launch Images
$IMAGEW -crop 0,256,2048,1536 "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-2048x1536.png" -w 2048 -h 1536
$IMAGEW -crop 256,0,1536,2048 "$MYPWD/iTunesArtwork@2x.png" "$MYPWD/$BASE-1536x2028.png" -w 1536 -h 2048

$IMAGEW -crop 0,128,1024,768 "$MYPWD/iTunesArtwork.png" "$MYPWD/$BASE-1024x768.png" -w 1024 -h 768
$IMAGEW -crop 128,0,768,1024 "$MYPWD/iTunesArtwork.png" "$MYPWD/$BASE-768x1024.png" -w 768 -h 1024

$IMAGEW -crop 243,0,640,1136 "$MYPWD/$BASE-1136.png" "$MYPWD/$BASE-640x1136.png" -w 640 -h 1136
$IMAGEW -crop 160,0,640,960 "$MYPWD/$BASE-960.png" "$MYPWD/$BASE-640x960.png" -w 640 -h 960

# AppleTV
$IMAGEW -crop 0,0,1920,1080 "$MYPWD/$BASE-1920.png" "$MYPWD/LaunchImage-1920x1080.png" -w 1920 -h 1080
$IMAGEW -crop 0,0,1920,720 "$MYPWD/$BASE-1920.png" "$MYPWD/TopShelfImage-1920x720.png" -w 1920 -h 720

$IMAGEW -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Front.png" -w 1280 -h 768
$IMAGEW -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Middle.png" -w 1280 -h 768
$IMAGEW -bkgd 000 -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Back.png" -w 1280 -h 768

$IMAGEW -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Front.png" -w 400 -h 240
$IMAGEW -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Middle.png" -w 400 -h 240
$IMAGEW -bkgd 000 -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Back.png" -w 400 -h 240
