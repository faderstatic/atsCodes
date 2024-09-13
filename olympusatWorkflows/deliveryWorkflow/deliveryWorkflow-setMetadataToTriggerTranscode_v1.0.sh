#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will set metadata on item in Cantemo to trigger Transcode workflow
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 09/12/2024
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
export distributionBy="$2"
export distributionTo="$3"
export distributionDate=$(date "+%Y-%m-%dT%H:%M:%S")
export mydate=$(date +%Y-%m-%d)
logfile="/opt/olympusat/logs/deliveryWorkflow-$mydate.log"

# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/deliveryWorkflow/jobQueue.lock"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Delivery Job Initiated" >> "$logfile"
sleep 1

# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 2
done

# Acquire the lock for this job
touch "$lockFile"

# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------

# --------------------------------------------------
# Check item's existing Distribution Metadata
urlGetItemDistributionMetadata="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_distributionStatus%2Coly_distributionTo%2Coly_distributionDate&group=Distribution&terse=yes"
distributionMetadataHttpResponse=$(curl --location --request GET $urlGetItemDistributionMetadata --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Current Distribution Metadata [$distributionMetadataHttpResponse]" >> "$logfile"
# --------------------------------------------------

# --------------------------------------------------
# Set Metadata on item to populate in Saved Search to trigger Rules Engine Job
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Item ID [$itemId]" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Distribution To [$distributionTo]" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Distribution By [$distributionBy]" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Distribution Date [$distributionDate]" >> "$logfile"
export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Distribution</name><field><name>oly_distributionTo</name><value>$distributionTo</value></field><field><name>oly_distributionStatus</name><value>inProgress</value></field><field><name>oly_distributionBy</name><value>$distributionBy</value></field><field><name>oly_distributionDate</name><value>$distributionDate</value></field></group></timespan></MetadataDocument>")
httpPostResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Update Metadata HTTP Response [$httpPostResponse]" >> "$logfile"
sleep 1
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Initiate Delivery Job Completed" >> "$logfile"
# --------------------------------------------------

IFS=$saveIFS

exit 0