#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to mark metadataStatus as completed
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/01/2024
#::Rev A: 
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

#Set Variables to use or check before continuing with script
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"
export itemId=$1
export userName=$2
export metadataStatus=$3
export assignedTo=$4
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/metadataWorkflow/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - [$itemId] - Job Initiated" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Waiting for the previous job to finish..." >> "$logfile"
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
if [[ "$metadataStatus" == "assigned" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - User [$userName] triggered workflow to Assign [$assignedTo] to update metadata on item" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Update appropriate metadata on item IN PROGRESS" >> "$logfile"
    export metadataAssignedDate=$(date "+%Y-%m-%dT%H:%M:%S")
    export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_metadataAssignedTo</name><value>$assignedTo</value></field><field><name>oly_metadataAssignedDate</name><value>$metadataAssignedDate</value></field><field><name>oly_metadataStatus</name><value>pending</value></field><field><name>oly_metadataBy</name><value></value></field><field><name>oly_metadataDate</name><value></value></field></timespan></MetadataDocument>")
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Update appropriate metadata on item COMPLETED" >> "$logfile"
elif [[ "$metadataStatus" == "inProgress" || "$metadataStatus" == "completed" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - User [$userName] triggered workflow to set item as [$metadataStatus]" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Checking current oly_metadataStatus" >> "$logfile"
    itemMetadataStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataStatus")
    #Check Variable
    if [[ "$itemMetadataStatus" == *"completed"* ]];
    then
        # oly_metadataStatus is already 'completed'-skip process
        itemMetadataBy=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataBy")
        itemMetadataDate=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataDate")
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Item is ALREADY marked as Completed - skipping process" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Marked as Completed by {$itemMetadataBy} on {$itemMetadataDate}" >> "$logfile"
    else
        # oly_metadataStatus is NOT completed-continue with process
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Setting variables with appropriate metadata" >> "$logfile"
        export metadataBy=$userName
        export metadataDate=$(date "+%Y-%m-%dT%H:%M:%S")
        case $metadataStatus in
            "inProgress")
                bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_metadataStatus</name><value>$metadataStatus</value></field><field><name>oly_metadataBy</name><value>$metadataBy</value></field></timespan></MetadataDocument>")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Sending API Command to Update Metadata" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Mark as {$metadataStatus}, by {$metadataBy}" >> "$logfile"
            ;;
            "completed")
                bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_metadataStatus</name><value>$metadataStatus</value></field><field><name>oly_metadataBy</name><value>$metadataBy</value></field><field><name>oly_metadataDate</name><value>$metadataDate</value></field></timespan></MetadataDocument>")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Sending API Command to Update Metadata" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Mark as {$metadataStatus}, by {$metadataBy}, on {$metadataDate}" >> "$logfile"
            ;;
        esac
        export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
        curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
        sleep 5
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - Update Metadata Completed" >> "$logfile"
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - metadataStatus NOT Supported - skipping & exiting the Script/Workflow" >> "$logfile"
fi

IFS=$saveIFS
