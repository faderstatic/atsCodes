#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will check system for matching Conform item or Original Raw item & set metadata
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 09/18/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

saveIFS=$IFS
IFS=$(echo -e "\n\b\015")

# --------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# --------------------------------------------------

# --------------------------------------------------
# Internal funtions
releaseLock ()
{
    rm -f "$lockFile"
}
# --------------------------------------------------

# --------------------------------------------------
# Set some parameters
export itemId="$1"
export lastCheckDate=$(date "+%Y-%m-%dT%H:%M:%S")
export mydate=$(date +%Y-%m-%d)
logfile="/opt/olympusat/logs/mediaManagerWorkflow-$mydate.log"

# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/itemValidationWorkflow/jobQueue.lock"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item Validation Job Initiated" >> "$logfile"
sleep 1

# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 2
done

# Acquire the lock for this job
touch "$lockFile"

# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------

# --------------------------------------------------
# Check item's information
itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Version Type [$itemVersionType]" >> "$logfile"
if [[ "$itemVersionType" == "originalFile" ]];
then
    urlGetItemOriginalFileFlagsInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_originalFileFlags&terse=yes"
    httpResponse=$(curl --location --request GET $urlGetItemOriginalFileFlagsInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Original File Flags [$httpResponse]" >> "$logfile"
    if [[ "$httpResponse" == *originalrawmaster* ]];
    then
        itemRightslineItemId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineItemId")
        itemRightslineContractId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineContractId")
        itemAlternateContractIds=$(filterVidispineItemMetadata $itemId "metadata" "oly_alternateContractIds")
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Rightsline Item ID [$itemRightslineItemId]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Rightsline Contract ID [$itemRightslineContractId]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Alternate Contract IDs [$itemAlternateContractIds]" >> "$logfile"
        if [[ "$itemRightslineItemId" == "" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item's Rightsline Item Id is Empty - skipping process" >> "$logfile"
        else
            if [[ "$itemRightslineContractId" == "" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item's Rightsline Contract Id is Empty - skipping process" >> "$logfile"
            else
                itemTitleSearch=$(echo "$itemRightslineContractId")_$(echo "$itemRightslineItemId")_00
                export searchUrl="http://10.1.1.34/API/v2/search/"
                # API Call to Search if Conform File exists
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Checking if Conform File item exists - [$itemTitleSearch]" >> "$logfile"
                conformCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$itemTitleSearch\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" }]}}"
                conformHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $conformCheckBody)
                if [[ "$conformHttpResponse" != *"<id>OLY-"* ]];
                then
                    # Conform File does not exist
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File does NOT exist - skipping process" >> "$logfile"
                else
                    # Conform File exists
                    conformHitResults=$(echo $conformHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File exists - Number of Items in Results {$conformHitResults}" >> "$logfile"
                    if [ "$conformHitResults" -gt 1 ];
                    then
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
                    else
                        conformItemId=$(echo $conformHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - Original ID - [$itemId] - Conform ID - [$conformItemId]" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Updating Original File Item's 'Item Validation' Flag" >> "$logfile"
                        updateVidispineMetadata $itemId "oly_itemValidation" "matchingconformexists"
                        sleep 1
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$conformItemId] - Updating Conform File Item's 'Item Validation' Flag" >> "$logfile"
                        updateVidispineMetadata $conformItemId "oly_itemValidation" "matchingoriginalexists"
                        sleep 1
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId - $conformItemId] - Updating 'Item Validation' Flag Completed" >> "$logfile"
                    fi
                fi
            fi
        fi
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Original File Flags is NOT 'originalrawmaster' - skipping process" >> "$logfile"
    fi
elif [[ "$itemVersionType" == "conformFile" ]];
then
    itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item Title [$itemTitle]" >> "$logfile"
    itemRightslineContractId=$(echo "$itemTitle" | awk -F "_" '{print $1"_"$2}')
    itemRightslineItemId=$(echo "$itemTitle" | awk -F "_" '{print $3}')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item Rightsline Contract ID [$itemRightslineContractId]" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Item Rightsline Item ID [$itemRightslineItemId]" >> "$logfile"
    export searchUrl="http://10.1.1.34/API/v2/search/"
    # API Call to Search if Original Raw Master File exists
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Checking if Original Raw Master item exists" >> "$logfile"
    originalCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_rightslineContractId\", \"value\": \"$itemRightslineContractId\", \"exact\": true },{ \"name\": \"oly_rightslineItemId\", \"value\": \"$itemRightslineItemId\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" }]}}"
    originalHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $originalCheckBody)
    if [[ "$originalHttpResponse" != *"<id>OLY-"* ]];
    then
        # Original Raw Master does not exist
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Original Raw Master does NOT exist - skipping process" >> "$logfile"
    else
        # Original Raw Master exists
        originalHitResults=$(echo $originalHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Original Raw Master exists - Number of Items in Results {$originalHitResults}" >> "$logfile"
        if [ "$originalHitResults" -gt 1 ];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
        else
            originalItemId=$(echo $originalHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Updating Conform File Item's 'Item Validation' Flag" >> "$logfile"
            updateVidispineMetadata $itemId "oly_itemValidation" "matchingoriginalexists"
            sleep 1
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$originalItemId] - Updating Original Raw Master Item's 'Item Validation' Flag" >> "$logfile"
            updateVidispineMetadata $originalItemId "oly_itemValidation" "matchingconformexists"
            sleep 1
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId - $originalItemId] - Updating 'Item Validation' Flag Completed" >> "$logfile"
        fi
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Version Type is NOT 'originalFile' or 'conformFile' - skipping process" >> "$logfile"
fi
# --------------------------------------------------

IFS=$saveIFS

exit 0