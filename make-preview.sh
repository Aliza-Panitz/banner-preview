#!/usr/bin/env bash

# autodetect name and number of badges

SIZE=$(find badges/*.png -type f | tail -1 | sed -e "s/.png//" | sed -e "s/^.*-//g")
NAME=$(ls *.png | tail -1 | sed -e "s/.png$//")

paddedsize=$(printf "%02d" $SIZE)
echo "Setting up ${NAME} at size ${paddedsize}"

mkdir -v preview
cp ${NAME}.png preview/original.png
cp preview-tools/badge-frame-516.png preview/
cp preview-tools/badge-frame.png preview/
cp preview-tools/${SIZE}-banner.html preview/index.html

for num in $( seq 1 ${SIZE} )
do
		paddednum=$(printf "%02d" $num)
    cp badges/${NAME}-${paddednum}.png preview/tile-${paddedsize}-${paddednum}.png
done


# It should be possible to generate the HTML file from this script, which
# would also eliminate the need to copy the original .png file to the preview
# directory, but the need to break and pad rows after each 6 is a bit more 
# than I want to tackle for version 0.0.1
