#! /bin/bash

#--------------------------------------------------
# External funtions to include
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export myDate=$(date "+%Y-%m-%d")
export logArchiveDate=$(date -d "14 day ago" +"%s")
export logTarDate=$(date -d "28 day ago" +"%s")
#--------------------------------------------------
export sourceAaxFolder=$1
export destinationM4aFolder=$2
#--------------------------------------------------

for everyAaxFile in $(ls $sourceAaxFolder)
do
    echo "Working on Audible file: "$sourceAaxFolder$everyAaxFile
    aaxFilename=$(basename $everyAaxFile .aax)
    ffmpeg -activation_bytes 5b86a806 -i "$sourceAaxFolder$everyAaxFile" $destinationM4aFolder$aaxFilename.mp3
done

IFS=$saveIFS