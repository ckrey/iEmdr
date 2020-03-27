#!/bin/bash

#INK=/Applications/Inkscape.app/Contents/Resources/bin/inkscape
INK="/Applications/Inkscape.app/Contents/MacOS/inkscape --batch-process --export-background=ffffff"
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
$INK -z -D -o "$MYPWD/$BASE-1024.png" -w 1024 -h 1024 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-1334.png" -w 1334 -h 1334 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-2048.png" -w 2048 -h 2048 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-2208.png" -w 2208 -h 2208 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-3072.png" -w 3072 -h 3072 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-3840.png" -w 3840 -h 3840 $MYPWD/$SVG
$INK -z -D -o "$MYPWD/$BASE-4640.png" -w 4640 -h 4640 $MYPWD/$SVG

$IMAGEW -bkgd 000 "$MYPWD/$BASE-3840.png" "$MYPWD/$BASE-2320.png" -w 2320 -h 2320
$IMAGEW -bkgd 000 "$MYPWD/$BASE-3840.png" "$MYPWD/$BASE-2560.png" -w 2560 -h 2560
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-1920.png" -w 1920 -h 1920
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-1280.png" -w 1280 -h 1280
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-1136.png" -w 1136 -h 1136
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-960.png" -w 960 -h 960
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-800.png" -w 800 -h 800
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-400.png" -w 400 -h 400

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/iTunesArtwork@2x.png" 
$IMAGEW -bkgd 000 "$MYPWD/$BASE-1024.png" "$MYPWD/iTunesArtwork.png"

# App Icons

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-16.png" -w 16 -h 16
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-16@2x.png" -w 32 -h 32

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-20.png" -w 20 -h 20
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-20@2x.png" -w 40 -h 40
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-20@3x.png" -w 60 -h 60

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-29.png" -w 29 -h 29
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-29@2x.png" -w 58 -h 58
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-29@3x.png" -w 87 -h 87

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-32.png" -w 32 -h 32
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-32@2x.png" -w 64 -h 64

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-40.png" -w 40 -h 40
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-40@2x.png" -w 80 -h 80
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-40@3x.png" -w 120 -h 120

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-60@2x.png" -w 120 -h 120
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-60@3x.png" -w 180 -h 180

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-76.png" -w 76 -h 76
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-76@2x.png" -w 152 -h 152

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-83-5@2x.png" -w 167 -h 167

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-128.png" -w 128 -h 128
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-128@2x.png" -w 256 -h 256

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-256.png" -w 256 -h 256
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-256@2x.png" -w 512 -h 512

$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-512.png" -w 512 -h 512
$IMAGEW -bkgd 000 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-512@2x.png" -w 1024 -h 1024

# App Store Image
$IMAGEW -bkgd 000 -crop 0,0,1024,1024 "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-1024x1024.png" -w 1024 -h 1024

# Launch Images
$IMAGEW -bkgd 000 -crop 0,483,2208,1242 "$MYPWD/$BASE-2208.png" "$MYPWD/$BASE-2208x1242.png" -w 2208 -h 1242
$IMAGEW -bkgd 000 -crop 483,0,1242,2208 "$MYPWD/$BASE-2208.png" "$MYPWD/$BASE-1242x2208.png" -w 1242 -h 2208

$IMAGEW -bkgd 000 -crop 0,256,2048,1536 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-2048x1536.png" -w 2048 -h 1536
$IMAGEW -bkgd 000 -crop 256,0,1536,2048 "$MYPWD/$BASE-2048.png" "$MYPWD/$BASE-1536x2048.png" -w 1536 -h 2048

$IMAGEW -bkgd 000 -crop 0,128,1024,768 "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-1024x768.png" -w 1024 -h 768
$IMAGEW -bkgd 000 -crop 128,0,768,1024 "$MYPWD/$BASE-1024.png" "$MYPWD/$BASE-768x1024.png" -w 768 -h 1024

$IMAGEW -bkgd 000 -crop 292,0,750,1334 "$MYPWD/$BASE-1334.png" "$MYPWD/$BASE-750x1334.png" -w 750 -h 1334

$IMAGEW -bkgd 000 -crop 243,0,640,1136 "$MYPWD/$BASE-1136.png" "$MYPWD/$BASE-640x1136.png" -w 640 -h 1136

$IMAGEW -bkgd 000 -crop 160,0,640,960 "$MYPWD/$BASE-960.png" "$MYPWD/$BASE-640x960.png" -w 640 -h 960

# AppleTV
$IMAGEW -bkgd 000 -crop 0,0,1920,1080 "$MYPWD/$BASE-1920.png" "$MYPWD/LaunchImage-1920x1080.png" -w 1920 -h 1080
$IMAGEW -bkgd 000 -crop 0,0,3840,2160 "$MYPWD/$BASE-3840.png" "$MYPWD/LaunchImage-1920x1080@2x.png" -w 3840 -h 2160

$IMAGEW -bkgd 000 -crop 0,360,1920,720 "$MYPWD/$BASE-1920.png" "$MYPWD/TopShelfImage-1920x720.png" -w 1920 -h 720
$IMAGEW -bkgd 000 -crop 0,720,3840,1440 "$MYPWD/$BASE-3840.png" "$MYPWD/TopShelfImage-1920x720@2x.png" -w 3840 -h 1440
$IMAGEW -bkgd 000 -crop 0,360,2320,720 "$MYPWD/$BASE-2320.png" "$MYPWD/TopShelfImage-2320x720.png" -w 2320 -h 720
$IMAGEW -bkgd 000 -crop 0,720,4640,1440 "$MYPWD/$BASE-4640.png" "$MYPWD/TopShelfImage-2320x720@2x.png" -w 4640 -h 1440

$IMAGEW -bkgd 000 -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Front.png" -w 1280 -h 768
$IMAGEW -bkgd 000 -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Middle.png" -w 1280 -h 768
$IMAGEW -bkgd 000 -crop 0,0,1280,768 "$MYPWD/$BASE-1280.png" "$MYPWD/$BASE-1280x768-Back.png" -w 1280 -h 768
$IMAGEW -bkgd 000 -crop 0,0,2560,1536 "$MYPWD/$BASE-2560.png" "$MYPWD/$BASE-1280x768-Front@2x.png" -w 2560 -h 1536
$IMAGEW -bkgd 000 -crop 0,0,2560,1536 "$MYPWD/$BASE-2560.png" "$MYPWD/$BASE-1280x768-Middle@2x.png" -w 2560 -h 1536
$IMAGEW -bkgd 000 -crop 0,0,2560,1536 "$MYPWD/$BASE-2560.png" "$MYPWD/$BASE-1280x768-Back@2x.png" -w 2560 -h 1536

$IMAGEW -bkgd 000 -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Front.png" -w 400 -h 240
$IMAGEW -bkgd 000 -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Middle.png" -w 400 -h 240
$IMAGEW -bkgd 000 -crop 0,0,400,240 "$MYPWD/$BASE-400.png" "$MYPWD/$BASE-400x240-Back.png" -w 400 -h 240
$IMAGEW -bkgd 000 -crop 0,0,800,480 "$MYPWD/$BASE-800.png" "$MYPWD/$BASE-400x240-Front@2x.png" -w 800 -h 480
$IMAGEW -bkgd 000 -crop 0,0,800,480 "$MYPWD/$BASE-800.png" "$MYPWD/$BASE-400x240-Middle@2x.png" -w 800 -h 480
$IMAGEW -bkgd 000 -crop 0,0,800,480 "$MYPWD/$BASE-800.png" "$MYPWD/$BASE-400x240-Back@2x.png" -w 800 -h 480
