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
# Function to Release Lock after item is processed/completed
releaseLock ()
{
    rm -f "$lockFile"
}

# Function to hash input passcode
hashPasscode() {
    echo -n "$1" | openssl dgst -sha256 -binary | base64
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

# Set some parameters
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M:%S)
export itemId=$1
logfile="/opt/olympusat/logs/ingestMetadataWorkflow-$mydate.log"

# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/convertDurationToMinutes/jobQueue.lock"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item Convert DurationSeconds to Minutes Job Initiated" >> "$logfile"
sleep 1

# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 2
done

# Acquire the lock for this job
touch "$lockFile"

# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------

itemDurationSeconds=$(filterVidispineItemMetadata $itemId "metadata" "durationSeconds")
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item DurationSeconds [$itemDurationSeconds]" >> "$logfile"
sleep 1
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Converting to Minutes" >> "$logfile"
sleep 1
itemDurationInMinutesTemp=$(echo "scale=2; $itemDurationSeconds / 60" | bc)
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Temp Item Duration in Minutes [$itemDurationInMinutesTemp]" >> "$logfile"
itemDurationInMinutes=$(echo "$itemDurationInMinutesTemp" | awk '{print ($1 - int($1) >= 0.50) ? int($1) + 1 : int($1)}')
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item Duration in Minutes [$itemDurationInMinutes]" >> "$logfile"
if (( itemDurationInMinutes < 29 ));
then
    itemTrtMinutes=30
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
elif (( itemDurationInMinutes >= 30 && itemDurationInMinutes <= 39 ));
then
    itemTrtMinutes=45
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
elif (( itemDurationInMinutes >= 40 && itemDurationInMinutes <= 59 ));
then
    itemTrtMinutes=60
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
elif (( itemDurationInMinutes >= 60 && itemDurationInMinutes <= 89 ));
then
    itemTrtMinutes=90
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
elif (( itemDurationInMinutes >= 90 && itemDurationInMinutes <= 119 ));
then
    itemTrtMinutes=120
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
elif (( itemDurationInMinutes >= 120 && itemDurationInMinutes <= 149 ));
then
    itemTrtMinutes=150
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item TRT Minutes [$itemTrtMinutes]" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item Duration in Minutes NOT Supported" >> "$logfile"
fi
sleep 1
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Update Item's Metadata in Cantemo" >> "$logfile"
updateVidispineMetadata $itemId "oly_trtMinutes" "$itemTrtMinutes"
sleep 1
echo "$(date +%Y/%m/%d_%H:%M:%S) - (convertDurationSecondsToMinutes) - [$itemId] - Item Convert DurationSeconds to Minutes Job Completed" >> "$logfile"

IFS=$saveIFS
