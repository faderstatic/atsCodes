#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will run a series of events to prepare item for "reload" of new version of file
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 08/08/2024
#::Rev A:
#::Rev B: Added support for passcode encripting & checking passcode entered in item by user
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

#--------------------------------------------------
# Internal funtions to include
# Function to hash input passcode
hashPasscode() {
    echo -n "$1" | openssl dgst -sha256 -binary | base64
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M:%S)

logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"

# Set Variable to check before continuing with script
export itemId=$1
export userName=$2

userReloadPasscode=$(filterVidispineItemMetadata $itemId "metadata" "oly_reloadPasscode")

# Read the stored hashed passcode
storedHashPasscode=$(cat /opt/olympusat/resources/reloadWorkflow/hashedPasscode.txt)

# Hash the passcode provided by user
userHashPasscode=$(hashPasscode "$userReloadPasscode")

if [[ "$userHashPasscode" != "$storedHashPasscode" ]];
then
    # Users passcode does NOT match stored passcode-exiting script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Users Passcode does NOT match the Stored Passcode - NOT Preparing item for Reload" >> "$logfile"
    # Update the reloadLogDetail field in Cantemo with timestamp, user and status
    newReloadLogDetail="$(date +%Y/%m/%d_%H:%M:%S)-Prepare for Reload FAILED-{$userName}-Passcode does NOT match"
    itemReloadLogDetail=$(filterVidispineItemMetadata $itemId "metadata" "oly_reloadLogDetail")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - itemReloadLogDetail - [$itemReloadLogDetail]" >> "$logfile"
    if [[ "$itemReloadLogDetail" == "" ]];
    then
        #updateVidispineMetadata $itemId oly_reloadLogDetail "$newReloadLogDetail"
        export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
        bodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_reloadLogDetail</name><value>$newReloadLogDetail</value></field><field><name>oly_reloadPasscode</name><value></value></field></timespan></MetadataDocument>"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - BodyData - [$bodyData]" >> "$logfile"
        httpResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=QNywVlUaFfG0jc0UgFYvbSf0tKWtIeLQMfpUloBlTHMIXz9IJT11Xuqxlb3e5rcZ' --data $bodyData)
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - HttpResponse - [$httpResponse]" >> "$logfile"
    else
        export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
        bodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_reloadLogDetail</name><value>$newReloadLogDetail \n $itemReloadLogDetail</value></field><field><name>oly_reloadPasscode</name><value></value></field></timespan></MetadataDocument>"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - BodyData - [$bodyData]" >> "$logfile"
        httpResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=QNywVlUaFfG0jc0UgFYvbSf0tKWtIeLQMfpUloBlTHMIXz9IJT11Xuqxlb3e5rcZ' --data $bodyData)
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - HttpResponse - [$httpResponse]" >> "$logfile"
    fi
else
    # Users passcode DOES match stored passcode-continuing with script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Users Passcode DOES match the Stored Passcode - Continuing with Process" >> "$logfile"

    itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")

    # Check versionType variable to make sure is conform, censored or original file
    if [[ "$itemVersionType" == "originalFile" || "$itemVersionType" == "conformFile" || "$itemVersionType" == "conformFile-spanish" || "$itemVersionType" == "conformFile-english" || "$itemVersionType" == "censoredFile" || "$itemVersionType" == "censoredFile-spanish" || "$itemVersionType" == "censoredFile-english" ]];
    then
        # versionType IS 'originalFile', 'conformFile' or 'censoredFile'-continue with process

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Version Type IS 'originalFile', 'conformFile' or 'censoredFile'" >> "$logfile"

        #---------------------------------------------------------------------------------------
        # Get item QC metadata from Cantemo
        itemOriginalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")
        itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")

        # Check item QC metadata & reset to Pending if necessary
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Checking & Updating QC Status Metadata" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Original Content QC Status - {$itemOriginalQCStatus}" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Final QC Status - {$itemFinalQCStatus}" >> "$logfile"

        sleep 1

        if [[ "$itemOriginalQCStatus" == "approved" || "$itemOriginalQCStatus" == "rejected" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Setting Original QC Status to 'Pending'" >> "$logfile"

            updateVidispineSubgroupMetadata $itemId "Original Content" "oly_originalContentQCStatus" "pending"
            updateVidispineSubgroupMetadata $itemId "Original Content" "oly_originalContentQCBy" ""
            updateVidispineSubgroupMetadata $itemId "Original Content" "oly_originalContentQCDate" ""

            sleep 1
        fi

        if [[ "$itemFinalQCStatus" == "approved" || "$itemFinalQCStatus" == "rejected" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Setting Final QC Status to 'Pending'" >> "$logfile"

            updateVidispineSubgroupMetadata $itemId "Final Content" "oly_finalQCStatus" "pending"
            updateVidispineSubgroupMetadata $itemId "Final Content" "oly_finalQCBy" ""
            updateVidispineSubgroupMetadata $itemId "Final Content" "oly_finalQCDate" ""

            sleep 1
        fi
        #---------------------------------------------------------------------------------------

        #---------------------------------------------------------------------------------------
        # Get item Archive metadata from Cantemo
        itemQuantumArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "portal_archive_status")
        itemAWSArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveStatusAWS")
        itemAWSArchiveId=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveIdAWS")

        # Check item Archive metadata & delete from Archive if necessary
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Checking if previously Archived" >> "$logfile"
        sleep 1

        if [[ "$itemAWSArchiveStatus" == "completed" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Deleting previous file from AWS Glacier" >> "$logfile"

            bash -c "sudo /opt/olympusat/scriptsActive/glacierDeleteV1.sh $itemId $userName > /dev/null 2>&1 &"
            updateVidispineMetadata $itemId oly_archiveStatusAWS ""
            updateVidispineMetadata $itemId oly_archiveDateAWS ""
            updateVidispineMetadata $itemId oly_archiveIdAWS ""
            updateVidispineMetadata $itemId oly_flushDate ""
            updateVidispineMetadata $itemId oly_flushStatus ""
            updateVidispineMetadata $itemId oly_restoreStatusAWS ""
            updateVidispineMetadata $itemId oly_restoreDateAWS ""

            sleep 1
        fi

        if [[ "$itemQuantumArchiveStatus" == "Archived/Restored" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Deleting previous file from Quantum Archive" >> "$logfile"

            urlDeleteFromQuantumArchive="http://10.1.1.34/archive_framework/items/delete/"
            deleteFromQuantumBody="{ \"ignore_list\": [], \"item_ids\": [\"$itemId\"]}"
            deleteFromQuantumHttpResponse=$(curl --location --request POST $urlDeleteFromQuantumArchive --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $deleteFromQuantumBody)

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Response from Cantemo {$deleteFromQuantumHttpResponse}" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Delay 10 sec - Check for Shape Information" >> "$logfile"

            sleep 10
        fi
        #---------------------------------------------------------------------------------------

        #---------------------------------------------------------------------------------------
        # Get item's shape information from Cantemo
        urlGetItemShapeInfo="http://10.1.1.34:8080/API/item/$itemId/shape"
        httpResponse=$(curl --location --request GET $urlGetItemShapeInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *'<uri>OLY-'* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Deleting Shapes from Vidispine, Cantemo & Filesystem" >> "$logfile"

            urlDeleteShape="http://10.1.1.34:8080/API/item/$itemId/shape"
            deleteShapeHttpResponse=$(curl --location --request DELETE $urlDeleteShape --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Response from Vidispine {$deleteShapeHttpResponse}" >> "$logfile"

            sleep 1
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - No Shape(s) for Item in Cantemo" >> "$logfile"
        fi
        #---------------------------------------------------------------------------------------

        sleep 5

        #---------------------------------------------------------------------------------------
        # Check to confirm shapes were deleted
        
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Checking to make sure Shapes were deleted" >> "$logfile"

        urlGetItemShapeInfo="http://10.1.1.34:8080/API/item/$itemId/shape"
        httpResponse=$(curl --location --request GET $urlGetItemShapeInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" != *'<uri>OLY-'* ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - No Shapes Exist - Resetting Item to Placeholder" >> "$logfile"

            # Reset Item to Placeholder
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Resetting Item to Placeholder" >> "$logfile"
            itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")

            urlResetToPlaceholder="http://10.1.1.34/API/v2/items/$itemId/formats/"
            httpResponse=$(curl --location --request DELETE $urlResetToPlaceholder --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CUhJ240QCYOVA1GW8yARnGbTGKlcVxuMWuEabYLspdpzlmjwcaC1J91bABx7f2RW')

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Item Reset to Placeholder Completed" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Updating Item Title {$itemTitle}" >> "$logfile"

            sleep 5

            updateVidispineMetadata $itemId "title" "$itemTitle"

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Prepare for Reload Workflow Completed" >> "$logfile"

        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Shape(s) still exist for Item in Cantemo - Item NOT Reset to Placeholder" >> "$logfile"
        fi

        #---------------------------------------------------------------------------------------
        # Update the reloadLogDetail field in Cantemo with timestamp, user and status
        newReloadLogDetail="$(date +%Y/%m/%d_%H:%M:%S)-Prepare for Reload FAILED-{$userName}-Passcode does NOT match"
        itemReloadLogDetail=$(filterVidispineItemMetadata $itemId "metadata" "oly_reloadLogDetail")
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - itemReloadLogDetail - [$itemReloadLogDetail]" >> "$logfile"
        if [[ "$itemReloadLogDetail" == "" ]];
        then
            #updateVidispineMetadata $itemId oly_reloadLogDetail "$newReloadLogDetail"
            export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
            bodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_reloadLogDetail</name><value>$newReloadLogDetail</value></field><field><name>oly_reloadPasscode</name><value></value></field></timespan></MetadataDocument>"
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - BodyData - [$bodyData]" >> "$logfile"
            httpResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=QNywVlUaFfG0jc0UgFYvbSf0tKWtIeLQMfpUloBlTHMIXz9IJT11Xuqxlb3e5rcZ' --data $bodyData)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - HttpResponse - [$httpResponse]" >> "$logfile"
        else
            export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
            bodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_reloadLogDetail</name><value>$newReloadLogDetail \n $itemReloadLogDetail</value></field><field><name>oly_reloadPasscode</name><value></value></field></timespan></MetadataDocument>"
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - BodyData - [$bodyData]" >> "$logfile"
            httpResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=QNywVlUaFfG0jc0UgFYvbSf0tKWtIeLQMfpUloBlTHMIXz9IJT11Xuqxlb3e5rcZ' --data $bodyData)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - HttpResponse - [$httpResponse]" >> "$logfile"
        fi
    else
        # versionType IS NOT 'originalFile, 'conformFile' nor 'censoredFile'-skip process
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reloadWorkflow) - [$itemId] - Version Type is NOT 'originalFile', 'conformFile' nor 'censoredFile'" >> "$logfile"
    fi
fi

IFS=$saveIFS
