#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get the Markers from an Item in Cantemo, get the TC and set a metadata field with list of TC's
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 10/23/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

#--------------------------------------------------
# Internal funtions
# Function to Release Lock after item is processed/completed
releaseLock ()
{
    rm -f "$lockFile"
}

# Function to convert to timecode
convertToTimecode() {
  local frame=$1
  local fps=$2
  echo "----------------------------------------------" >> $logfile
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - frame [$frame]" >> "$logfile"
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - fps [$fps]" >> "$logfile"

  # Calculate total seconds as a floating-point number
  local total_seconds=$(echo "scale=4; $frame / $fps" | bc)
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - total_seconds [$total_seconds]" >> "$logfile"
  
  # Extract integer part of seconds
  local int_seconds=$(echo "$total_seconds / 1" | bc)
  # local int_frame=$(echo "$int_seconds * $fps" | bc)
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - int_seconds [$int_seconds]" >> "$logfile"
  
  # Extract fractional part and calculate frames
  local fractional_seconds=$(echo "$total_seconds - $int_seconds" | bc)
  # local frames=$(($frame - $int_frame))
  local frames=$(echo "scale=0; ($fractional_seconds * $fps + 0.5) / 1" | bc)  # Adding 0.5 for rounding
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - fractional_seconds [$fractional_seconds]" >> "$logfile"
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - frames [$frames]" >> "$logfile"
  
  # Calculate hours, minutes, and seconds
  local hours=$(echo "$int_seconds / 3600" | bc)
  local minutes=$(echo "($int_seconds % 3600) / 60" | bc)
  local seconds=$(echo "$int_seconds % 60" | bc)
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - hours [$hours]" >> "$logfile"
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - minutes [$minutes]" >> "$logfile"
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - seconds [$seconds]" >> "$logfile"

  # Format output as HH:MM:SS:FF
  finalTimecode=$(printf "%02d:%02d:%02d:%02d\n" "$hours" "$minutes" "$seconds" "$frames")
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - FINAL [$finalTimecode]" >> "$logfile"

  echo $finalTimecode
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")
# Set global variables
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
# Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2
export adType=$3
logfile="/opt/olympusat/logs/distributionWorkflow-$mydate.log"
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/distributionWorkflow-convertMarkers/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - [$itemId] - Convert Ad Break Markers to Metadata Job Initiated - User ($user) - Ad Type {$adType}" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
if [[ "$adType" == "vod" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Convert Ad Break Markers to Metadata Job IN PROGRESS" >> "$logfile"
    # Get Item's Marker Info
    itemsMarkerInfo="/opt/olympusat/zMisc/convertMarkersToMetadata/$itemId.xml"
    if [[ -e "$itemsMarkerInfo" ]];
    then
        mv -f "$itemsMarkerInfo" "/opt/olympusat/zMisc/convertMarkersToMetadata/zCompleted/"
        sleep 1
    fi
    getItemMarkersURL="http://10.1.1.34/AVAPI/asset/$itemId/?type=AvAdBreak&content=marker"
    getItemMarkersHttpResponse=$(curl --location $getItemMarkersURL --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - HTTP Response [$getItemMarkersHttpResponse]" >> "$logfile"
    itemMarkersFiltered=$(echo "$getItemMarkersHttpResponse" | jq '[.timespans[] | select(.type == "AvAdBreak")]')
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Filtered Item Markers [$itemMarkersFiltered]" >> "$logfile"
    # Loop through each item and extract the required fields using jq
    itemMarkersExtractedInfo=$(echo "$itemMarkersFiltered" | jq -c '
    [
        .[] | 
        select(.metadata[]?.value | startswith("VOD")) |
        {
            type: .type,
            description: (.metadata[] | select(.key == "av_marker_description").value),
            start_frame: .start.frame,
            end_frame: .end.frame
        }
    ]
')
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Extracted Info [$itemMarkersExtractedInfo]" >> "$logfile"
    sleep 1
    # Sort results in ascending order based on start_frame
    itemMarkersSortedInfo=$(echo "$itemMarkersExtractedInfo" | jq 'sort_by(.start_frame)')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Sorted Info [$itemMarkersSortedInfo]" >> "$logfile"
    fps=$(echo "scale=8; 30000 / 1001" | bc)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - fps [$fps]" >> "$logfile"
    # Extract start frames and convert to timecode
    adMarkerTimecodes=$(echo "$itemMarkersSortedInfo" | jq -r '.[] | .start_frame' | while read frame; do
        convertToTimecode "$frame" "$fps"
    done | paste -sd "," -)
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - adMarkerTimecodes [$adMarkerTimecodes]" >> "$logfile"
    if [[ "$adMarkerTimecodes" == "" ]];
    then
        adMarkerTimecodes="NONE"
    fi
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Extracted Marker Info [$adMarkerTimecodes]" >> "$logfile"
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Updating Item's Ad Marker Info in Cantemo" >> "$logfile"
    updateVidispineMetadata $itemId "oly_adMarkers" "$adMarkerTimecodes"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Convert Ad Break Markers to Metadata Job COMPLETED" >> "$logfile"
elif [[ "$adType" == "rtcMexico" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Convert Ad Break Markers to Metadata Job IN PROGRESS" >> "$logfile"
    # Get Item's Marker Info
    itemsMarkerInfo="/opt/olympusat/zMisc/convertMarkersToMetadata/$itemId.xml"
    if [[ -e "$itemsMarkerInfo" ]];
    then
        mv -f "$itemsMarkerInfo" "/opt/olympusat/zMisc/convertMarkersToMetadata/zCompleted/"
        sleep 1
    fi
    getItemMarkersURL="http://10.1.1.34/AVAPI/asset/$itemId/?type=AvAdBreak&content=marker"
    getItemMarkersHttpResponse=$(curl --location $getItemMarkersURL --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - HTTP Response [$getItemMarkersHttpResponse]" >> "$logfile"
    itemMarkersFiltered=$(echo "$getItemMarkersHttpResponse" | jq '[.timespans[] | select(.type == "AvAdBreak")]')
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Filtered Item Markers [$itemMarkersFiltered]" >> "$logfile"
    # Loop through each item and extract the required fields using jq
    itemMarkersExtractedInfo=$(echo "$itemMarkersFiltered" | jq -c '
    [
        .[] | 
        select(.metadata[]?.value | startswith("RTC_MX")) |
        {
            type: .type,
            description: (.metadata[] | select(.key == "av_marker_description").value),
            start_frame: .start.frame,
            end_frame: .end.frame
        }
    ]
')
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Extracted Info [$itemMarkersExtractedInfo]" >> "$logfile"
    sleep 1
    # Sort results in ascending order based on start_frame
    itemMarkersSortedInfo=$(echo "$itemMarkersExtractedInfo" | jq 'sort_by(.start_frame)')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Sorted Info [$itemMarkersSortedInfo]" >> "$logfile"
    fps=$(echo "scale=8; 30000 / 1001" | bc)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - fps [$fps]" >> "$logfile"
    # Extract start frames and convert to timecode
    adMarkerTimecodes=$(echo "$itemMarkersSortedInfo" | jq -r '.[] | .start_frame' | while read frame; do
        convertToTimecode "$frame" "$fps"
    done | paste -sd "," -)
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - adMarkerTimecodes [$adMarkerTimecodes]" >> "$logfile"
    if [[ "$adMarkerTimecodes" == "" ]];
    then
        adMarkerTimecodes="NONE"
    fi
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Extracted Marker Info [$adMarkerTimecodes]" >> "$logfile"
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Updating Item's Ad Marker Info in Cantemo" >> "$logfile"
    updateVidispineMetadata $itemId "oly_adMarkers" "$adMarkerTimecodes"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Convert Ad Break Markers to Metadata Job COMPLETED" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - No Valid Ad Type Set - exiting script" >> "$logfile"
fi
IFS=$saveIFS