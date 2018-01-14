#18 mission gold frame! /usr/bin/env bash
#
#  banner-preview.sh -- script to package up image files and create
# an html preview of how they would look as an Ingress mission mosaic.

# temp notes
# cp -L will copy the target of a symlink, not the link itself

usage() {
  if [ ! -z "$1" ]; then
    echo "$@"
    echo ""
  fi

  echo "Use the source, Luke!"

  cat << EOF
  Options:
    -c config file (if multiple supplied, all read in sequence)
    -d [directory of images]  (overrides dirlist in config)
    -D  debugging on
    -v  verbose mode
    -h  print this help and exit
EOF
  exit 1
}

parsecommandline() {

echo "Calling parsecommandline with ${@}"
while getopts "c:d:Dvh" opt; do
  case ${opt} in
    c)
      echo "c invokes with argument ${OPTARG}"
      configfile="${OPTARG}"
      if [ -r ${configfile} ]; then
        echo "Reading config file ${configfile}"
        source ${configfile}
      else
        echo "Cannot read config file ${configfile}"
        exit 1
      fi
      ;;
    d)
      dirlist+="${OPTARG}"
      # TODO: test -d
      echo "Dirlist now ${dirlist}"
      ;;
    h)
      usage "Here's the help."
      ;;
    v)
      verbose=1			# TODO: multiple levels of verbosity with multiple v flags
      ;;
    D)
      debug=1
      ;;
    \?)
      # not needed, shell already throws a useful error
      # echo "illegal option -$OPTARG" >&2
      usage "Oops"
      ;;
  esac
done

# the rest of the story
shift $((OPTIND-1))

if [ ! -z "${1}" ]; then
  # TODO: detect dir or file, then treat as dirlist or tilelist additions.
  # remember that a symlink to a dir is a file
  echo "Remaining arguments $@ -- currently ignored"
fi

}

defaultconfig() {

# the default behavior
# of the program if there is no config supplied.

# Basic assumptions that will likely never change
# general:
    border=24
    tilesize=512
    rowsize=6
    # htmlfile="index.html"

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
    # supportdir=/usr/local/etc/banner-preview
    supportdir=$HOME/.banner-preview
    # supportdir="etc"
		# pad if not a multiple of 6; the keyword BLANK in a tilelist will get this
    padding="$supportdir/white.png"
    tileframe="$supportdir/badge-frame.png"

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
    # fileprefix="tile-"
    appendsize=true
    # if you turn both sequence and original name off, filenames will collide
    appendsequence=true
    sizebeforesequence=true					# lexical sorting groups tiles from banner
    keeporiginalname=false
    maketarball=true

    # details of the index file
    title="Mission Banner"
    tag="banner"

}

setup() {
  me=$(basename $0)
  NOW=$(date +"%Y-%m-%dT%H-%M-%S")   # ISO standard 2018-01-08T20-47-13
  echo "running ${me} at ${NOW}"

  # I could get all complex and have cascading etc directories.  No.
  # Not for this version.
  globalconfig="/usr/local/etc/banner-preview/config"
  userconfig="${HOME}/.banner-preview/config"
  defaultconfig

  if [ -r ${globalconfig} ]; then
    echo "Reading global config ${globalconfig}"
    source ${globalconfig}
  fi

  if [ -r ${userconfig} ]; then
    echo "Reading user config ${userconfig}"
    source ${userconfig}
  fi

  verbose=0

  echo "Setting up the program."
  parsecommandline "${@}"

 outputdirectory="${tag}.output"
}

makeoutputdirectory() {
    if [ "${timestampdirectories}" == "true" ]; then
      outdir=${outputdirectory}-${NOW}
    else
      outdir=${outputdirectory}
   fi
   echo "Making directory ${outdir}"
   mkdir -p $outdir
   # error checking needed
}

main() {
  echo "Doing the work"
  makeoutputdirectory
  htmlfile="${tag}.html"
  htmlout=${outdir}/${htmlfile}
  echo "" > ${htmlout}
  cat ${etc}/head.html | sed -e "s/\${title}/${title}/ ; s/\${tag}/${tag}/" \
         >> ${htmlout}
  ln -f ${tileframe}  ${outdir}/frame.png
  echo "image files are ${tilelist}"
  # get count
  count=$(echo ${tilelist} | wc -w)
  # pad count with leading zeroes; no I don't support thousand-mission banners
  paddedcount=$(printf "%03d" ${count})
  if [ ! ${missionorder} ]; then
    revv=""
    for img in ${tilelist}; do
      revv="${img} ${revv}"
    done
    tilelist=revv
  fi
  sequence=1
  col=1
  for image in ${tilelist} ; do
    if [ "${image}" == "BLANK" ]; then
      image=${padding}
    fi
    # TODO All this should be a hlper function
    # pad sequence with leading zeroes
    paddedsequence=$(printf "%03d" ${sequence})
    # All these config options and I'm just ignoring them. #TODO
    # really only need to support 2 options --
    #    fully tagged and numbered -- for easiest canned downloads
    #    fully original filenames -- many banners can share one source dir
    if [ "${keeporiginalname}" == "true" ]; then
      targetfile="$(basename ${image})"
    else
      targetfile="${tag}-${paddedcount}-${paddedsequence}-$(basename ${image})"
    fi
    ln -f $image $outdir/${targetfile}
    cat ${etc}/one-tile.html | sed -e "s/\${targetfile}/${targetfile}/" \
           >> ${outdir}/${htmlfile}
    sequence=$((sequence+1))
    if [ $col == 6 ]; then
      col=1
      cat ${etc}/end-row.html >> ${outdir}/${htmlfile}
    else
      col=$((col+1))    # not POSIX.
    fi
  done
  # Pad row with blanks
  # not quite right but not harmful
  if [ ${col} -gt 1 ]; then
    image=${padding}
    targetfile="${tag}-${paddedcount}-${paddedsequence}-$(basename ${image})"
    ln -f $image $outdir/${targetfile}
    for place in ${col}..6 ; do
      cat ${etc}/one-tile.html | sed -e "s/\${targetfile}/${targetfile}/" >> ${outdir}/${htmlfile}
    done
    cat ${etc}/end-row.html >> ${outdir}/${htmlfile}
  fi
  cat ${etc}/tail.html | sed -e "s/\${author}/${author}/" >> ${outdir}/${htmlfile}

  # http://www.paulhammond.org/webkit2png/ - python script
  # or could have just used firefox -screenshot
  # webkit2png -T -s 0.06 -o ${outdir}/${tag}-preview ${outdir}/${htmlfile}
  # webkit2png -F -z 0.25 -o ${outdir}/${tag}-preview ${outdir}/${htmlfile}
  # webkit2png -s 0.05 -z 0.25 -o ${outdir}/${tag}-preview ${outdir}/${htmlfile}
  webkit2png -z 0.25 -o ${outdir}/${tag}-preview ${outdir}/${htmlfile}

  # Save a minimal config file
  echo "tag=${tag}" >> ${outdir}/${tag}.${NOW}.config
  echo "title=${title}" >> ${outdir}/${tag}.${NOW}.config
  echo "author=${author}" >> ${outdir}/${tag}.${NOW}.config
  echo "" >> ${outdir}/${tag}.${NOW}.config
  echo "tilelist=${tilelist}" >> ${outdir}/${tag}.${NOW}.config


  # make the tar ball
  if [ "${maketarball}" == "true" ]; then
    tarball="${outdir}/${tag}.tar"
    rm -f ${tarball}
    # throws all kinds of errors...
    tar -rf ${tarball} ${outdir}/*.png
    tar -rf ${tarball} ${outdir}/*.jpg
    tar -rf ${tarball} ${outdir}/*.jpeg
    tar -rf ${tarball} ${outdir}/*.html
    tar -rf ${tarball} ${outdir}/*.config
  fi

  if [ "${makezip}" == "true" ]; then
    zip -q -r -X ${tag}.zip ${outdir}
  fi

  if [ -d "${repository}" ]; then
    ln -f ${tag}.zip ${repository}/${tag}.zip
    ln -f ${outdir}/${tag}-preview-full.png ${repository}/${tag}-preview.png
    ln -f ${outdir}/${tag}-preview-thumb.png ${repository}/${tag}-preview-thumb.png

  fi

}


setup "${@}"
main

