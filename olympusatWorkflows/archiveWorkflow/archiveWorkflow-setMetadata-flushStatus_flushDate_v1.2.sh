#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will check item's metadata & either set Flush Metadata or Clear Flush Metadata on items in Cantemo
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 05/30/2024
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
itemPortalArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "portal_archive_status")
itemFlushStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_flushStatus")
itemFlushDate=$(filterVidispineItemMetadata $itemId "metadata" "oly_flushDate")

echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Portal Archive Status - {$itemPortalArchiveStatus}" >> "$logfile"

# Check Variable
if [[ "$itemPortalArchiveStatus" == "Archived" ]];
then
    # Archived and Offline-continue with process

    echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Archived & Offline - continue with process" >> "$logfile"

    if [[ "$itemFlushStatus" == "" && "$itemFlushDate" == "" ]];
    then
        # Both flushStatus & flushDate are empty-continue with process

        echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Both flushStatus & flushDate are Empty - continue with process" >> "$logfile"

        #------------------------------
        # Update flushStatus & flushDate info on item
        updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
        updateVidispineMetadata $itemId oly_flushDate $updateValue
        updateVidispineMetadata $itemId oly_flushStatus "completed"

        echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Flush metadata set on item" >> "$logfile"
        #------------------------------

        #------------------------------
        # Get & check restoreStatusAWS & restoreDateAWS info from item
        itemRestoreStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_restoreStatusAWS")
        itemRestoreDate=$(filterVidispineItemMetadata $itemId "metadata" "oly_restoreDateAWS")

        if [[ "$itemRestoreStatus" != "" || "$itemRestoreDate" != "" ]];
        then
            # Either restoreStatusAWS or restoreDatAWS are NOT empty-continue with process to clear restore metadata

            echo "$datetime - (archiveWorkflow-restoreMetadata) - [$itemId] - Either restoreStatusAWS or restoreDateAWS are NOT Empty - continue with process to clear restore metadata" >> "$logfile"

            updateVidispineMetadata $itemId oly_restoreDateAWS ""
            updateVidispineMetadata $itemId oly_restoreStatusAWS ""

            echo "$datetime - (archiveWorkflow-restoreMetadata) - [$itemId] - Restore metadata cleared from item" >> "$logfile"

        fi
        #------------------------------

    else
        # Either flushStatus & flushDate are NOT empty-skip process & exit

        echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Either flushStatus or flushDate are NOT Empty - skip process & exit" >> "$logfile"

    fi

else
    if [[ "$itemPortalArchiveStatus" == "Archived/Restored" ]];
    then
        # Archived and Restored-continue with process

        echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Archived & Restored - continue with process to clear metadata" >> "$logfile"

        if [[ "$itemFlushStatus" != "" && "$itemFlushDate" != "" ]];
        then
            # Both flushStatus & flushDate are not empty-continue with process

            echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Both flushStatus & flushDate are NOT Empty - continue with process to clear metadata" >> "$logfile"

            #------------------------------
            # Update flushStatus & flushDate
            updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
            updateVidispineMetadata $itemId oly_flushDate ""
            updateVidispineMetadata $itemId oly_flushStatus ""

            echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Flush metadata cleared from item" >> "$logfile"
            #------------------------------

        else
            # flushStatus & flushDate are empty-skip process & exit

            echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - flushStatus and flushDate are Empty - skip process & exit" >> "$logfile"

        fi

    else
        # Either NOT Archived or NOT Offline-skip process & exit

        echo "$datetime - (archiveWorkflow-flushMetadata) - [$itemId] - Either NOT Archived or NOT Offline - skip process & exit" >> "$logfile"

    fi
fi

IFS=$saveIFS
