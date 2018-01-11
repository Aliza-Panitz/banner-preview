# Sample config file for banner-preview program.
# don't be scared: the two commonest use cases are expected to be:
# (1)  no config file -- produce reasonable output from sliced download
# (2) configure a single item - the file list

# the default behavior
# of the program if there is no config supplied.

# Basic assumptions that will likely never change
# general:
    border=24
    tilesize=512
    rowsize=6
    htmlfile="index.html"

# How the output from the banner slicer is organized (on disk and screen)
# slicer:
    slicedir="badges"
    horizontalspacing=60
    verticalspacing=72

# If you don't supply a file or dir list, it will look for slicedir (under pwd)
#
# input:
		# specifying either tilelist or dirlist will blank out slicedir
    tilelist=""													# explicitly add tiles
    dirlist=""													# add images in dir, in lexical order
    # tilelist+="imageformission1.jpg "
    # tilelist+=" imageformission2.jpg imageformission2.jpg"
    # tilelist+=" imageformission3.png imageformission4.png"
    # Where do support files like the tile mask live?  Use the third option
    # if unsure.
    # etc="/usr/local/etc/banner-preview"
    etc="$HOME/.banner-preview"
    # etc="etc"
		# pad if not a multiple of 6; the keyword BLANK in a tilelist will get this
    padding="$supportdir/white.png"
    tileframe="$supportdir/badge-frame.png"
    # missionorder=true means tile 1 is lower right. 
    # false means first mission is upper left
    missionorder=true

# Defaults that will more often be overridden
		verbose=true
		debug=false

# output:
    # Where do the outputs go?
    outputdirectory="preview.output"
    timestampdirectories=false			# append timestamp to directory name

    # What should the preview files be named?
    # following the defaults below, the files will be named
    #     tile-30-01 etc. for a 30 image set.
    fileprefix="tile"
    appendsize=true
    # if you turn both sequence and original name off, filenames will collide
    appendsequence=true
    sizebeforesequence=true					# lexical sorting groups tiles from banner
    keeporiginalname=false
    maketarball=true

    # details of the index file
    title="Mission Banner"

