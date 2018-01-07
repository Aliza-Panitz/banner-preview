# banner-preview

Quick and dirty tools to display a preview of an Ingress mission banner
mosaic, and download one or all images.

This tool assumes that you have used the banner slicer at
http://www.giacintogarcea.com/ingress/tools/missionset/
and altered the resulting tiles, and want to see what it looks like
when reassembled.

With only minor changes this tool can also be used to preview mission
banners slices using other methods, or mosaics built up out of tiles generated
another way.

(1) Create the image you want to use for your banner.
(2) Run it through the slicer at http://www.giacintogarcea.com/ingress/tools/missionset/ ( http://tiny.cc/missionset )
(3) Unzip the downloaded tarball
(4) cd to the directory you just created
(5) Untar the banner-preview tarball
(6) run make-preview.sh
(7) Browse to index.html in the preview directory

