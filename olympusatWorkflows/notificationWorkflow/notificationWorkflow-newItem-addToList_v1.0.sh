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
export emailNotificationWorkflow=$2

echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Email Workflow - [$emailNotificationWorkflow]" >> "$logfile"

# Check Variable
if [[ "$emailNotificationWorkflow" == *"newItem"* ]];
then
    # emailNotificationWorkflow varialbe is set to newItem
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Checking for newItemFileDestination file" >> "$logfile"
    newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"
    if [[ ! -e "$newItemFileDestination" ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - newItemFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

        sleep 2

        echo "ItemId,Title,ContentType,VersionType,FileExtension" >> "$newItemFileDestination"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - New File created - [$newItemFileDestination]" >> "$logfile"
        
        sleep 5
    fi 

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
    itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
    itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
    itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
    itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Adding item metadata to newItemWorkflow csv" >> "$logfile"

    echo "$itemId,$itemTitle,$itemContentType,$itemVersionType,$itemOriginalExtension" >> "$newItemFileDestination"

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Process completed" >> "$logfile"

else
    # emailNotificationWorkflow variable is not supported
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - emailNotificationWorkflow variable is not supported" >> "$logfile"
fi

IFS=$saveIFS
