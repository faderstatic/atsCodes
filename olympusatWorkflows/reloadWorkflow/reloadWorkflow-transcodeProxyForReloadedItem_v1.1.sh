#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger the Transcode of the lowres proxy for Reloaded Items
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 09/24/2024
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
# Function to Release Lock after item is processed/completed
releaseLock ()
{
    rm -f "$lockFile"
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

# Set some parameters
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M:%S)
export itemId=$1
logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"

# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/transcodeProxyForReloadedItem/jobQueue.lock"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Process Reloaded Item Job INITIATED" >> "$logfile"
sleep 1

# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (prepareFortranscodeProxyForReloadedItemeloadWorkflow) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 5
done

# Acquire the lock for this job
touch "$lockFile"

# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------

newCreationDate=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
itemCreationDate=$(filterVidispineItemMetadata $itemId "metadata" "created")
itemOriginalCreationDate=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalCreationDate")
echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - New Creation Date [$newCreationDate]" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Item Creation Date [$itemCreationDate]" >> "$logfile"
if [[ "$itemOriginalCreationDate" == "" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Item Original Creation Date IS EMPTY [$itemOriginalCreationDate] - Setting with Creation Date [$newCreationDate]" >> "$logfile"
    updateVidispineMetadata $itemId "oly_originalCreationDate" "$itemCreationDate"
    sleep 1
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Item Original Creation Date IS NOT EMPTY [$itemOriginalCreationDate] - Skipping Updating Field" >> "$logfile"
fi
echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Updating Creation Date with New Date [$newCreationDate]" >> "$logfile"
updateVidispineMetadata $itemId "created" "$newCreationDate"
sleep 1
triggerTranscodeUrl="https://cantemo.olympusat.com/vs/items/transcode/"
triggerTranscodeBody="csrfmiddlewaretoken=7lh7lzhsoOv6vgLv3Tf32thK5UbhhgPa55sokrd5vkfxrhzMEEhSufhT84FecpBQ&format=lowres&search_id_selected=&selected_collection=&selected_items=$itemId&ignored_items=&replaceexisting=on&recreatethumbnails=on"
triggerTranscodeReferer="Referer: https://cantemo.olympusat.com/item/$itemId/?index=24&search_id=5279&parentPage=search"
triggerTranscodeHttpResponse=$(curl --location $triggerTranscodeUrl --header 'Accept: application/json, text/javascript, */*; q=0.01' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --header 'Cookie: _ga=GA1.2.900417261.1720610396; search_id=4243; _ga_SRQJQ7CX5M=GS1.2.1721214236.3.0.1721214236.0.0.0; sessionid=mvva8fqc7touots23ji1zg6nggj05ok8; csrftoken=4BVutbV0DzfYIETenjq9NIB9WPZcpnOV2l6Ls3RDK5ZpEFHvY4sYfuBiZZt9kwAB; search_results_viewtype=list' --header 'Origin: https://cantemo.olympusat.com' --header $triggerTranscodeReferer --header 'X-Requested-With: XMLHttpRequest' --data $triggerTranscodeBody)
echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - HTTP Response [$triggerTranscodeHttpResponse]" >> "$logfile"
sleep 1
echo "$(date +%Y/%m/%d_%H:%M:%S) - (transcodeProxyForReloadedItem) - [$itemId] - Process Reloaded Item Job COMPLETED" >> "$logfile"

IFS=$saveIFS
