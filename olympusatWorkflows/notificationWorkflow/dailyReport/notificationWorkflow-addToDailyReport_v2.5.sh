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

echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - ($itemId) - Email Workflow - [$emailNotificationWorkflow]" >> "$logfile"

# Check Variable
if [[ "$emailNotificationWorkflow" == "newItem" ]];
then
    # emailNotificationWorkflow varialbe is set to newItem
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - Checking for newItemFileDestination file" >> "$logfile"
    newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"
    if [[ ! -e "$newItemFileDestination" ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - newItemFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

        sleep 2

        echo "ItemId,Title,ContentType,VersionType,FileExtension,ContentFlags" >> "$newItemFileDestination"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - New File created - [$newItemFileDestination]" >> "$logfile"
        
        sleep 5
    fi 

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
    itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
    itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
    itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
    itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')

    urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
    httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

    if [[ "$httpResponse" == *"legacycontent"* ]];
    then
        itemContentFlags="legacyContent"
    else
        itemContentFlags=""
    fi

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - Adding item metadata to newItemWorkflow csv" >> "$logfile"

    echo "$itemId,$itemTitle,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags" >> "$newItemFileDestination"

    sleep 2

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - ($itemId) - Process completed" >> "$logfile"

else
    if [[ "$emailNotificationWorkflow" == "originalContentQCPending" ]];
    then
        # emailNotificationWorkflow varialbe is set to originalContentQCPending
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - Checking for originalContentQCPendingFileDestination file" >> "$logfile"
        originalContentQCPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/originalContentQCPending/originalContentQCPending-$mydate.csv"
        if [[ ! -e "$originalContentQCPendingFileDestination" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - originalContentQCPendingFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

            sleep 2

            echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,OriginalQCStatus" >> "$originalContentQCPendingFileDestination"

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - New File created - [$originalContentQCPendingFileDestination]" >> "$logfile"
            
            sleep 5
        fi 

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
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

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - Adding item metadata to originalContentQCPending csv" >> "$logfile"

        echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemOriginalContentQCStatus" >> "$originalContentQCPendingFileDestination"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - ($itemId) - Process completed" >> "$logfile"

    else
        if [[ "$emailNotificationWorkflow" == "finalQCPending" ]];
        then
            # emailNotificationWorkflow varialbe is set to finalQCPending
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - Checking for finalQCPendingFileDestination file" >> "$logfile"
            finalQCPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/finalQCPending/finalQCPending-$mydate.csv"
            if [[ ! -e "$finalQCPendingFileDestination" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - finalQCPendingFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                sleep 2

                echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,FinalQCStatus" >> "$finalQCPendingFileDestination"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - New File created - [$finalQCPendingFileDestination]" >> "$logfile"
                
                sleep 5
            fi 

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
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

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - Adding item metadata to finalQCPending csv" >> "$logfile"

            echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemFinalQCStatus" >> "$finalQCPendingFileDestination"

            sleep 2

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - ($itemId) - Process completed" >> "$logfile"

        else
            if [[ "$emailNotificationWorkflow" == "markedToBeDeleted" ]];
            then
                # emailNotificationWorkflow varialbe is set to markedToBeDeleted
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - Checking for markedToBeDeletedFileDestination file" >> "$logfile"
                markedToBeDeletedFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/markedToBeDeleted/markedToBeDeleted-$mydate.csv"
                if [[ ! -e "$markedToBeDeletedFileDestination" ]];
                then
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - markedToBeDeletedFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                    sleep 2

                    echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,OriginalContentQCStatus,FinalQCStatus,ArchiveStatus,ArchiveStatusAWS" >> "$markedToBeDeletedFileDestination"

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - New File created - [$markedToBeDeletedFileDestination]" >> "$logfile"
                    
                    sleep 5
                fi

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
                itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
                itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
                itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
                itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
                itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
                itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')
                itemOriginalContentQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")
                itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")
                itemArchiveStatus=$(filterVidispineItemMetadata $itemId "metadata" "portal_archive_status")
                itemArchiveStatusAWS=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveStatusAWS")

                urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
                httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

                if [[ "$httpResponse" == *"legacycontent"* ]];
                then
                    itemContentFlags="legacyContent"
                else
                    itemContentFlags=""
                fi

                sleep 2

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - Adding item metadata to markedToBeDeleted csv" >> "$logfile"

                echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemOriginalContentQCStatus,$itemFinalQCStatus,$itemArchiveStatus,$itemArchiveStatusAWS" >> "$markedToBeDeletedFileDestination"

                sleep 2

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - ($itemId) - Process completed" >> "$logfile"

            else
                if [[ "$emailNotificationWorkflow" == "rtcReviewPending" ]];
                then
                    # emailNotificationWorkflow varialbe is set to rtcReviewPending
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - Checking for rtcReviewPendingFileDestination file" >> "$logfile"
                    rtcReviewPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/rtcReviewPending/rtcReviewPending-$mydate.csv"
                    if [[ ! -e "$rtcReviewPendingFileDestination" ]];
                    then
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - rtcReviewPendingFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                        echo "ItemId,Title,Spanish Title,English Title,Content Type,RTC Review Status" >> "$rtcReviewPendingFileDestination"

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - New File created - [$rtcReviewPendingFileDestination]" >> "$logfile"
                        
                        sleep 2
                    fi

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
                    itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
                    itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
                    itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
                    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
                    itemRtcReviewStatus=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_rtcReviewStatus" "RTC%20Review")

                    sleep 1

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - Adding item metadata to rtcReviewPending csv" >> "$logfile"

                    echo "$itemId,$itemTitle,$itemTitleEs,$itemTitleEn,$itemContentType,$itemRtcReviewStatus" >> "$rtcReviewPendingFileDestination"

                    sleep 1

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - ($itemId) - Process completed" >> "$logfile"

                else
                    if [[ "$emailNotificationWorkflow" == "rtcReviewCompleted" ]];
                    then
                        # emailNotificationWorkflow varialbe is set to rtcReviewCompleted
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - Checking for rtcReviewCompleted file" >> "$logfile"
                        rtcReviewCompletedFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/rtcReviewCompleted/rtcReviewCompleted-$mydate.csv"
                        if [[ ! -e "$rtcReviewCompletedFileDestination" ]];
                        then
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - rtcReviewCompletedFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                            echo "ItemId,Title,Spanish Title,English Title,Content Type,RTC Review Status,RTC Review By,RTC Review Date,RTC Review Notes" >> "$rtcReviewCompletedFileDestination"

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - New File created - [$rtcReviewCompletedFileDestination]" >> "$logfile"
                            
                            sleep 2
                        fi

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
                        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
                        itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
                        itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
                        itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
                        itemRtcReviewStatus=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_rtcReviewStatus" "RTC%20Review")
                        itemRtcReviewBy=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_rtcReviewBy" "RTC%20Review")
                        itemRtcReviewDate=$(filterVidispineItemSubgroupMetadata $itemId "metadata" "oly_rtcReviewDate" "RTC%20Review")
                        itemRtcReviewNotes=$(filterVidispineItemMetadata $itemId "metadata" "oly_rtcReviewNotes")

                        sleep 1

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - Adding item metadata to rtcReviewCompleted csv" >> "$logfile"

                        echo "$itemId,$itemTitle,$itemTitleEs,$itemTitleEn,$itemContentType,$itemRtcReviewStatus,$itemRtcReviewBy,$itemRtcReviewDate,$itemRtcReviewNotes" >> "$rtcReviewCompletedFileDestination"

                        sleep 1

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - ($itemId) - Process completed" >> "$logfile"

                    else
                        if [[ "$emailNotificationWorkflow" == "adComplianceNewItem" ]];
                        then
                            # emailNotificationWorkflow varialbe is set to adComplianceNewItem
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - Checking for adComplianceNewItem file" >> "$logfile"
                            adComplianceNewItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/adComplianceNewItem/adComplianceNewItem-$mydate.csv"
                            if [[ ! -e "$adComplianceNewItemFileDestination" ]];
                            then
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - adComplianceNewItemFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

                                echo "ItemId,Title,Media Type" >> "$adComplianceNewItemFileDestination"

                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - New File created - [$adComplianceNewItemFileDestination]" >> "$logfile"
                                
                                sleep 2
                            fi

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
                            itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
                            itemMediaType=$(filterVidispineItemMetadata $itemId "metadata" "mediaType")

                            sleep 1

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - Adding item metadata to adComplianceNewItem csv" >> "$logfile"

                            echo "$itemId,$itemTitle,$itemMediaType" >> "$adComplianceNewItemFileDestination"

                            sleep 1

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-adComplianceNewItem) - ($itemId) - Process completed" >> "$logfile"

                        else
                            # emailNotificationWorkflow variable is not supported
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - ($itemId) - emailNotificationWorkflow variable is not supported" >> "$logfile"
                        fi
                    fi
                fi
            fi
        fi
    fi
fi

IFS=$saveIFS
