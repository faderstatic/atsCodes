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

# Set Variable to check before continuing with script
export itemId=$1
export userName=$2
itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")

# Check versionType variable to make sure is conform, censored or original file
if [[ "$itemVersionType" == "originalFile" || "$itemVersionType" == "conformFile" || "$itemVersionType" == "censoredFile" ]];
then
    # versionType IS 'originalFile', 'conformFile' or 'censoredFile'-continue with process

    echo "$datetime - (reloadWorkflow) - [$itemId] - Version Type IS 'originalFile', 'conformFile' or 'censoredFile'" >> "$logfile"

    #---------------------------------------------------------------------------------------
    # Get item QC metadata from Cantemo
    itemOriginalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")
    itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")

    # Check item QC metadata & reset to Pending if necessary
    echo "$datetime - (reloadWorkflow) - [$itemId] - Checking & Updating QC Status Metadata" >> "$logfile"
    sleep 1

    if [[ "$itemOriginalQCStatus" == "approved" || "$itemOriginalQCStatus" == "rejected" ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - Setting Original QC Status to 'Pending'" >> "$logfile"

        updateVidispineMetadata $itemId "oly_originalContentQCStatus" "pending"

        sleep 1
    fi

    if [[ "$itemFinalQCStatus" == "approved" || "$itemFinalQCStatus" == "rejected" ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - Setting Final QC Status to 'Pending'" >> "$logfile"

        updateVidispineMetadata $itemId "oly_finalQCStatus" "pending"

        sleep 1
    fi
    #---------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------
    # Get item Archive metadata from Cantemo
    itemQuantumArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "portal_archive_status")
    itemAWSArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveStatusAWS")
    itemAWSArchiveId=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveIdAWS")

    # Check item Archive metadata & delete from Archive if necessary
    echo "$datetime - (reloadWorkflow) - [$itemId] - Checking if previously Archived" >> "$logfile"
    sleep 1

    if [[ "$itemAWSArchiveStatus" == "completed" ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - Deleting previous file from AWS Glacier" >> "$logfile"

        #bash -c "sudo /opt/olympusat/scriptsActive/glacierDeleteV1.sh $itemId $userName > /dev/null 2>&1 &"

        sleep 1
    fi

    if [[ "$itemQuantumArchiveStatus" == *Archived* ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - Deleting previous file from Quantum Archive" >> "$logfile"

        # Insert code/command to trigger Delete from Quantum Archive here

        sleep 1
    fi
    #---------------------------------------------------------------------------------------

    #---------------------------------------------------------------------------------------
    # Get item's shape information from Cantemo
    urlGetItemShapeInfo="http://10.1.1.34:8080/API/item/$itemId/shape"
	httpResponse=$(curl --location --request GET $urlGetItemShapeInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

    if [[ "$httpResponse" == *'<uri>OLY-'* ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - Deleting Shapes from Cantemo & Filesystem" >> "$logfile"

        urlDeleteShape="http://10.1.1.34:8080/API/item/$itemId/shape"
	    #httpResponse=$(curl --location --request DELETE $urlDeleteShape --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        sleep 1
    else
        echo "$datetime - (reloadWorkflow) - [$itemId] - No Shape(s) for Item in Cantemo" >> "$logfile"
    fi
    #---------------------------------------------------------------------------------------

    sleep 5

    #---------------------------------------------------------------------------------------
    # Check to confirm shapes were deleted
    urlGetItemShapeInfo="http://10.1.1.34:8080/API/item/$itemId/shape"
	httpResponse=$(curl --location --request GET $urlGetItemShapeInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

    if [[ "$httpResponse" != *'<uri>OLY-'* ]];
    then
        echo "$datetime - (reloadWorkflow) - [$itemId] - No Shapes Exist - Resetting Item to Placeholder" >> "$logfile"

        # Reset Item to Placeholder
        echo "$datetime - (reloadWorkflow) - [$itemId] - Resetting Item to Placeholder" >> "$logfile"
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")

        urlResetToPlaceholder="http://10.1.1.34/API/v2/items/$itemId/formats/"
	    #httpResponse=$(curl --location --request DELETE $urlResetToPlaceholder --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CUhJ240QCYOVA1GW8yARnGbTGKlcVxuMWuEabYLspdpzlmjwcaC1J91bABx7f2RW')

        echo "$datetime - (reloadWorkflow) - [$itemId] - Item Reset to Placeholder Completed" >> "$logfile"
        echo "$datetime - (reloadWorkflow) - [$itemId] - Updating Item Title {$itemTitle}" >> "$logfile"

        sleep 5

        #updateVidispineMetadata $itemId "title" "$itemTitle"

        echo "$datetime - (reloadWorkflow) - [$itemId] - Prepare for Reload Workflow Completed" >> "$logfile"

    else
        echo "$datetime - (reloadWorkflow) - [$itemId] - Shape(s) still exist for Item in Cantemo - Item NOT Reset to Placeholder" >> "$logfile"
    fi

    #---------------------------------------------------------------------------------------

else
    # versionType IS NOT 'originalFile, 'conformFile' nor 'censoredFile'-skip process
    echo "$datetime - (reloadWorkflow) - [$itemId] - Version Type is NOT 'originalFile', 'conformFile' nor 'censoredFile'" >> "$logfile"
fi

IFS=$saveIFS
