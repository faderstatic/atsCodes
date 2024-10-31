#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will mark items as to be deleted & with who requested it
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 05/24/2024
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
export userName=$2
itemDeleteRequestedBy=$(filterVidispineItemMetadata $itemId "metadata" "oly_deleteRequestedBy")

#Check Variable
if [[ -z "$itemDeleteRequestedBy" ]];
then
    #deleteRequestedBy IS empty-continue with process

    echo "$datetime - (mediaManagerWorkflow) - [$itemId] - In Progress-Mark as to be Deleted by {$userName}" >> "$logfile"
    
    updateVidispineMetadata $itemId "oly_mediaManagerFlags" "markedastobedeleted"
    updateVidispineMetadata $itemId "oly_deleteRequestedBy" "$userName"

    sleep 1

    echo "$datetime - (mediaManagerWorkflow) - [$itemId] - Completed-Mark as to be Deleted by {$userName}" >> "$logfile"

else
   #deleteRequestedBy IS NOT empty-skip process

        echo "$datetime - (mediaManagerWorkflow) - [$itemId] - Item ALREADY Marked as to be Deleted-not marking again {$userName}" >> "$logfile"

fi

IFS=$saveIFS
