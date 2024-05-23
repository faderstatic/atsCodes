#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will run a series of events to prepare item for "reload" of new version of file
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 05/23/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"

#Set Variable to check before continuing with script
export itemId=$1
itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")

#Check Variable
if [[ "$itemVersionType" == "conformFile" || "$itemVersionType" == "censoredFile" ]];
then
    #versionType IS 'conformFile' or 'censoredFile'-continue with process

    echo "$datetime - (reloadWorkflow) - [$itemId] - Version Type IS 'conformFile' or 'censoredFile'" >> "$logfile"
    echo "YEEESSSSS [$itemId] - Version Type IS 'conformFile' or 'censoredFile'"

else
    if [[ "$itemVersionType" == "originalFile" ]];
    then
        #versionType IS 'originalFile'-contine with process

        echo "$datetime - (reloadWorkflow) - [$itemId] - Version Type IS 'originalFile'" >> "$logfile"
        echo "YEEESSSSS [$itemId] - Version Type IS 'originalFile'"

    else
        #versionType IS NOT 'conformFile' nor 'censoredFile' nor 'originalFile'-skip process

        echo "$datetime - (reloadWorkflow) - [$itemId] - Version Type is NOT 'conformFile' nor 'censoredFile' nor 'originalFile'" >> "$logfile"
        echo "NOOOOOOOO [$itemId] - Version Type is NOT 'conformFile' nor 'censoredFile' nor 'originalFile'"

    fi
fi

case "$itemVersionType" in

    "conformFile"|"censoredFile")
        echo "$datetime - (reloadWorkflow) - [$itemId] - Case - Version Type IS 'conformFile' or 'censoredFile'" >> "$logfile"
        echo "Case-YEEESSSSS [$itemId] - Version Type IS 'conformFile' or 'censoredFile'"
    ;;

    "originalFile")
        echo "$datetime - (reloadWorkflow) - [$itemId] - Case - Version Type IS 'originalFile'" >> "$logfile"
        echo "Case-YEEESSSSS [$itemId] - Version Type IS 'originalFile'"
    ;;

    *)
        echo "$datetime - (reloadWorkflow) - [$itemId] - Case - Version Type is NOT 'conformFile' nor 'censoredFile' nor 'originalFile'" >> "$logfile"
        echo "Case-NOOOOOOOO [$itemId] - Version Type is NOT 'conformFile' nor 'censoredFile' nor 'originalFile'"
    ;;

esac

IFS=$saveIFS
