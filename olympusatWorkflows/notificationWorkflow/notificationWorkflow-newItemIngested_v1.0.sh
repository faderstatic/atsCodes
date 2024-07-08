#!/bin/bash

#::***************************************************************************************************************************
#::This shell script is the initial trigger to create list of items to send email notification
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/08/2024
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

# Set Variables to check before continuing with script
export itemId=$1
export emailWorkflow=$2

echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - Email Workflow - [$emailWorkflow]" >> "$logfile"

# Check Variable
if [[ "$emailWorkflow" == *"newItem"* ]];
then
    # emailWorkflow varialbe is set to newItem
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - Checking for newItemFileDestination file" >> "$logfile"
    newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"
    if [[ ! -e "$newItemFileDestination" ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - newItemFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

        sleep 2

        echo "ItemId,ContentType,VersionType" >> "$newItemFileDestination"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - New File created - [$newItemFileDestination]" >> "$logfile"
        
        sleep 5
    fi 

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
    itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
    itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - Adding item metadata to newItemWorkflow csv" >> "$logfile"

    echo "$itemId,$itemContentType,$itemVersionType" >> "$newItemFileDestination"

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - Process completed" >> "$logfile"

else
    # emailWorkflow variable is not supported
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailWorkflow) - ($itemId) - emailWorkflow variable is not supported" >> "$logfile"
fi

IFS=$saveIFS
