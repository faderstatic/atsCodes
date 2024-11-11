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
checkForIngestSubgroupsUrl="http://10.1.1.34:8080/API/item/OLY-55/metadata?field=oly_metadataAssignedTo%2Coly_metadataStatus%2Coly_metadataBy%2Coly_metadataDate&group=Ingest"
checkForIngestSubgroups=$(curl --location $checkForIngestSubgroupsUrl --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=MUjgt5uKtW9KNzBvnj6GtAYhRGX8Q13etYkYdrVTXj9o7Jemi8yPYULPFwtfMO12')
echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - checkForIngestSubgroups [$checkForIngestSubgroups]" >> "$logfile"
numberOfEntries=$(echo "$checkForIngestSubgroups" | grep -o '<group' | wc -l)
echo "$(date +%Y/%m/%d_%H:%M:%S) - (metadataWorkflow) - ($itemId) - numberOfEntries [$numberOfEntries]" >> "$logfile"

IFS=$saveIFS
