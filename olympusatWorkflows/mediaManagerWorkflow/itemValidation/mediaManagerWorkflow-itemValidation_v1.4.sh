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
                conformCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$itemTitleSearch\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" },{ \"name\": \"type\", \"value\": \"item\" }]}}"
                conformHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $conformCheckBody)
                if [[ "$conformHttpResponse" != *"<id>OLY-"* ]];
                then
                    # Checking Alternate Contract IDs
                    if [[ "$itemAlternateContractIds" == "" ]];
                    then
                        # Conform File does not exist
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File does NOT exist - skipping process" >> "$logfile"
                    else
                        # Checking if Conform File exists with Alternate Contract Id
                        itemTitleSearch2=$(echo "$itemAlternateContractIds")_$(echo "$itemRightslineItemId")_00
                        export searchUrl="http://10.1.1.34/API/v2/search/"
                        # API Call to Search if Conform File exists
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Checking if Conform File item exists - [$itemTitleSearch2]" >> "$logfile"
                        conformCheckBody2="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$itemTitleSearch2\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" },{ \"name\": \"type\", \"value\": \"item\" }]}}"
                        conformHttpResponse2=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $conformCheckBody2)
                        if [[ "$conformHttpResponse2" != *"<id>OLY-"* ]];
                        then
                            # Check Rightsline Contract ID and replace CA_000 with CA_999
                            if [[ "$itemRightslineContractId" =~ ^CA_000 ]];
                            then
                                itemRightslineContractIdNew="${itemRightslineContractId/000/999}"
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - New Rightsline Contract ID [$itemRightslineContractIdNew]" >> "$logfile"
                                # Checking if Conform File exists with New Rightsline Contract ID
                                itemTitleSearch3=$(echo "$itemRightslineContractIdNew")_$(echo "$itemRightslineItemId")_00
                                export searchUrl="http://10.1.1.34/API/v2/search/"
                                # API Call to Search if Conform File exists
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Checking if Conform File item exists - [$itemTitleSearch3]" >> "$logfile"
                                conformCheckBody3="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$itemTitleSearch3\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" },{ \"name\": \"type\", \"value\": \"item\" }]}}"
                                conformHttpResponse3=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $conformCheckBody3)
                                if [[ "$conformHttpResponse3" != *"<id>OLY-"* ]];
                                then
                                    # Check Rightsline Contract ID and replace CA_000 with CA_999
                                    if [[ "$itemAlternateContractIds" =~ ^CA_000 ]];
                                    then
                                        itemAlternateContractIdsNew="${itemAlternateContractIds/000/999}"
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - New Alternate Contract IDs [$itemAlternateContractIdsNew]" >> "$logfile"
                                        # Checking if Conform File exists with New Alternate Contract IDs
                                        itemTitleSearch4=$(echo "$itemAlternateContractIdsNew")_$(echo "$itemRightslineItemId")_00
                                        export searchUrl="http://10.1.1.34/API/v2/search/"
                                        # API Call to Search if Conform File exists
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Checking if Conform File item exists - [$itemTitleSearch4]" >> "$logfile"
                                        conformCheckBody4="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$itemTitleSearch4\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" },{ \"name\": \"type\", \"value\": \"item\" }]}}"
                                        conformHttpResponse4=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $conformCheckBody4)
                                        if [[ "$conformHttpResponse4" != *"<id>OLY-"* ]];
                                        then
                                            # Conform File does not exist
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File does NOT exist - skipping process" >> "$logfile"
                                        else
                                            # Conform File exists
                                            conformHitResults4=$(echo $conformHttpResponse4 | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File exists - Number of Items in Results {$conformHitResults4}" >> "$logfile"
                                            if [ "$conformHitResults4" -gt 1 ];
                                            then
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
                                            else
                                                # Command to trigger 'Copy Conform Metadata' script
                                                copyConformUrl="https://cantemo.olympusat.com/cs_api/cs_script_actions/execute"
                                                copyConformBody="{\"actionId\":\"copy_conform_metadata\",\"queryString\":\"selected_objects=$itemId\"}"
                                                copyConformHttpResponse=$(curl --location $copyConformUrl --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/json' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header 'Referer: https://cantemo.olympusat.com/item/OLY-251/?index=24&search_id=5279&parentPage=search' --header 'X-Csrftoken: 4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB' --data $copyConformBody)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Copy Conform HTTP Response [$copyConformHttpResponse]" >> "$logfile"
                                                # Update Rightsline Contract ID with updated Contract ID Info
                                                updateVidispineMetadata $itemId "oly_rightslineContractId" "$itemAlternateContractIdsNew"
                                                sleep 1
                                                updateItemsAlternateContractIds="$(echo "$itemRightslineContractId") - $(echo "$itemAlternateContractIds")"
                                                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - New Alternate Contract Ids [$updateItemsAlternateContractIds]" >> "$logfile"
                                                updateVidispineMetadata $itemId "oly_alternateContractIds" "$updateItemsAlternateContractIds"
                                                sleep 1
                                                # Extract out Item ID for Conform Item
                                                conformItemId=$(echo $conformHttpResponse4 | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
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
                                    else
                                        # Conform File does not exist
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File does NOT exist - skipping process" >> "$logfile"
                                    fi
                                else
                                    # Conform File exists
                                    conformHitResults3=$(echo $conformHttpResponse3 | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File exists - Number of Items in Results {$conformHitResults3}" >> "$logfile"
                                    if [ "$conformHitResults3" -gt 1 ];
                                    then
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
                                    else
                                        # Command to trigger 'Copy Conform Metadata' script
                                        copyConformUrl="https://cantemo.olympusat.com/cs_api/cs_script_actions/execute"
                                        copyConformBody="{\"actionId\":\"copy_conform_metadata\",\"queryString\":\"selected_objects=$itemId\"}"
                                        copyConformHttpResponse=$(curl --location $copyConformUrl --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/json' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header 'Referer: https://cantemo.olympusat.com/item/OLY-251/?index=24&search_id=5279&parentPage=search' --header 'X-Csrftoken: 4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB' --data $copyConformBody)
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Copy Conform HTTP Response [$copyConformHttpResponse]" >> "$logfile"
                                        # Update Rightsline Contract ID with Updated Contract ID Info
                                        updateVidispineMetadata $itemId "oly_rightslineContractId" "$itemRightslineContractIdNew"
                                        sleep 1
                                        updateItemsAlternateContractIds="$(echo "$itemRightslineContractId") - $(echo "$itemAlternateContractIds")"
                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - New Alternate Contract Ids [$updateItemsAlternateContractIds]" >> "$logfile"
                                        updateVidispineMetadata $itemId "oly_alternateContractIds" "$updateItemsAlternateContractIds"
                                        sleep 1
                                        # Extract out Item ID for Conform Item
                                        conformItemId=$(echo $conformHttpResponse3 | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
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
                            else
                                # Conform File does not exist
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File does NOT exist - skipping process" >> "$logfile"
                            fi
                        else
                            # Conform File exists with Alternate Contract ID
                            conformHitResults2=$(echo $conformHttpResponse2 | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File exists - Number of Items in Results {$conformHitResults2}" >> "$logfile"
                            if [ "$conformHitResults2" -gt 1 ];
                            then
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
                            else
                                # Command to trigger 'Copy Conform Metadata' script
                                copyConformUrl="https://cantemo.olympusat.com/cs_api/cs_script_actions/execute"
                                copyConformBody="{\"actionId\":\"copy_conform_metadata\",\"queryString\":\"selected_objects=$itemId\"}"
                                copyConformHttpResponse=$(curl --location $copyConformUrl --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/json' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header 'Referer: https://cantemo.olympusat.com/item/OLY-251/?index=24&search_id=5279&parentPage=search' --header 'X-Csrftoken: 4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB' --data $copyConformBody)
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Copy Conform HTTP Response [$copyConformHttpResponse]" >> "$logfile"
                                # Update Rightsline Contract ID with Updated Contract ID Info
                                updateVidispineMetadata $itemId "oly_rightslineContractId" "$itemAlternateContractIds"
                                sleep 1
                                updateVidispineMetadata $itemId "oly_alternateContractIds" "$itemRightslineContractId"
                                sleep 1
                                # Extract out Item ID for Conform Item
                                conformItemId=$(echo $conformHttpResponse2 | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
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
                else
                    # Conform File exists
                    conformHitResults=$(echo $conformHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Conform File exists - Number of Items in Results {$conformHitResults}" >> "$logfile"
                    if [ "$conformHitResults" -gt 1 ];
                    then
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Search Results with MORE THAN 1 Hit - skipping process" >> "$logfile"
                    else
                        # Command to trigger 'Copy Conform Metadata' script
                        copyConformUrl="https://cantemo.olympusat.com/cs_api/cs_script_actions/execute"
                        copyConformBody="{\"actionId\":\"copy_conform_metadata\",\"queryString\":\"selected_objects=$itemId\"}"
                        copyConformHttpResponse=$(curl --location $copyConformUrl --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/json' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header 'Referer: https://cantemo.olympusat.com/item/OLY-251/?index=24&search_id=5279&parentPage=search' --header 'X-Csrftoken: 4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB' --data $copyConformBody)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Copy Conform HTTP Response [$copyConformHttpResponse]" >> "$logfile"
                        # Extract out Item ID for Conform Item
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
    originalCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_rightslineContractId\", \"value\": \"$itemRightslineContractId\", \"exact\": true },{ \"name\": \"oly_rightslineItemId\", \"value\": \"$itemRightslineItemId\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" },{ \"name\": \"type\", \"value\": \"item\" }]}}"
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
            idForConformItem=$(echo "$itemId")
            idForOriginalItem=$(echo $originalHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - Conform Item ID - [$idForConformItem] - Original Item ID [$idForOriginalItem]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$idForConformItem] - Updating Conform File Item's 'Item Validation' Flag" >> "$logfile"
            updateVidispineMetadata $idForConformItem "oly_itemValidation" "matchingoriginalexists"
            sleep 1
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$idForOriginalItem] - Updating Original Raw Master Item's 'Item Validation' Flag" >> "$logfile"
            updateVidispineMetadata $idForOriginalItem "oly_itemValidation" "matchingconformexists"
            sleep 1
            # Command to trigger 'Copy Conform Metadata' script
            copyConformUrl="https://cantemo.olympusat.com/cs_api/cs_script_actions/execute"
            copyConformBody="{\"actionId\":\"copy_conform_metadata\",\"queryString\":\"selected_objects=$idForOriginalItem\"}"
            copyConformHttpResponse=$(curl --location $copyConformUrl --header 'Accept: */*' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/json' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header 'Referer: https://cantemo.olympusat.com/item/OLY-251/?index=24&search_id=5279&parentPage=search' --header 'X-Csrftoken: 4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB' --data $copyConformBody)
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$idForOriginalItem] - Copy Conform HTTP Response [$copyConformHttpResponse]" >> "$logfile"
            sleep 1
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$idForConformItem - $idForOriginalItem] - Updating 'Item Validation' Flag Completed" >> "$logfile"
        fi
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (itemValidation) - [$itemId] - Version Type is NOT 'originalFile' or 'conformFile' - skipping process" >> "$logfile"
fi
# --------------------------------------------------

IFS=$saveIFS

exit 0