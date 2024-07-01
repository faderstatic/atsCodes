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

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"

#Set Variable to check before continuing with script
export itemId=$1
export userName=$2
export metadataStatus=$3

echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - User [$userName] triggered workflow to set item as [$metadataStatus]" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Checking current oly_metadataStatus" >> "$logfile"
itemMetadataStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataStatus")

#Check Variable
if [[ "$itemMetadataStatus" == *"completed"* ]];
then
    # oly_metadataStatus is already 'completed'-skip process
    itemMetadataBy=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataBy")
    itemMetadataDate=$(filterVidispineItemMetadata $itemId "metadata" "oly_metadataDate")
    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Item is ALREADY marked as Completed - skipping process" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Marked as Completed by {$itemMetadataBy} on {$itemMetadataDate}" >> "$logfile"
else
    # oly_metadataStatus is NOT completed-continue with process
    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Setting variables with appropriate metadata" >> "$logfile"
    export metadataBy=$userName
    export metadataDate=$(date "+%Y-%m-%dT%H:%M:%S")

    case $metadataStatus in
        "inProgress")
            bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_metadataStatus</name><value>$metadataStatus</value></field><field><name>oly_metadataBy</name><value>$metadataBy</value></field><field><name>oly_metadataDate</name><value>$metadataDate</value></field></timespan></MetadataDocument>")
        ;;
        "completed")
            bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_metadataStatus</name><value>$metadataStatus</value></field><field><name>oly_metadataBy</name><value>$metadataBy</value></field><field><name>oly_metadataDate</name><value>$metadataDate</value></field></timespan></MetadataDocument>")
        ;;
    esac

    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Sending API Command to Update Metadata" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Mark as {$metadataStatus}, by {$metadataBy}, on {$metadataDate}" >> "$logfile"

    export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

    sleep 5

    echo "$(date +%Y/%m/%d_%H:%M) - (metadataWorkflow) - ($itemId) - Update Metadata Completed" >> "$logfile"
fi

IFS=$saveIFS
