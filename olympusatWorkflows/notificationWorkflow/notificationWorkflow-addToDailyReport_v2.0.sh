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
logfile="/opt/olympusat/logs/notificationWorkflow-$mydate.log"

# Set Variables to check before continuing with script
export itemId=$1
export emailNotificationWorkflow=$2

echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Email Workflow - [$emailNotificationWorkflow]" >> "$logfile"

# Check Variable
if [[ "$emailNotificationWorkflow" == "newItem" ]];
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
    if [[ "$emailNotificationWorkflow" == "originalContentQcPending" ]];
    then
        # emailNotificationWorkflow varialbe is set to originalContentQcPending
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Checking for originalContentQcPendingFileDestination file" >> "$logfile"
        originalContentQcPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/originalContentQcPending/originalContentQcPending-$mydate.csv"
        if [[ ! -e "$originalContentQcPendingFileDestination" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - originalContentQcPendingFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

            sleep 2

            echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,OriginalQCStatus" >> "$originalContentQcPendingFileDestination"

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - New File created - [$originalContentQcPendingFileDestination]" >> "$logfile"
            
            sleep 5
        fi 

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
        itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
        itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
        itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')
        itemOriginalContentQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")

        urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
        httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *"legacycontent"* ]];
        then
            itemContentFlags="legacyContent"
        else
            itemContentFlags=""
        fi

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Adding item metadata to newItemWorkflow csv" >> "$logfile"

        echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemOriginalContentQCStatus" >> "$newItemFileDestination"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Process completed" >> "$logfile"

    else
        if [[ "$emailNotificationWorkflow" == "finalQcPending" ]];
        then
            # emailNotificationWorkflow varialbe is set to finalQcPending
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Checking for finalQcPendingFileDestination file" >> "$logfile"
            finalQcPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/finalQcPending/finalQcPending-$mydate.csv"
            if [[ ! -e "$finalQcPendingFileDestination" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - finalQcPendingFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                sleep 2

                echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,FinalQCStatus" >> "$finalQcPendingFileDestination"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - New File created - [$finalQcPendingFileDestination]" >> "$logfile"
                
                sleep 5
            fi 

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
            itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
            itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
            itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
            itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
            itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
            itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')
            itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")

            urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
            httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

            if [[ "$httpResponse" == *"legacycontent"* ]];
            then
                itemContentFlags="legacyContent"
            else
                itemContentFlags=""
            fi

            sleep 2

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Adding item metadata to newItemWorkflow csv" >> "$logfile"

            echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemFinalQCStatus" >> "$newItemFileDestination"

            sleep 2

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - Process completed" >> "$logfile"

        else
            # emailNotificationWorkflow variable is not supported
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - emailNotificationWorkflow variable is not supported" >> "$logfile"
        fi
    fi
fi

IFS=$saveIFS
