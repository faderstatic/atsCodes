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

  # --------Drop Frame Calculation---------
  # Drop-frame constants for 29.97 fps
  local frames_per_hour=107892       # 29.97 fps, drop-frame
  local frames_per_10_minutes=17982  # Frames in 10 minutes (with drop-frame)
  local frames_per_minute=1798       # Frames in 1 minute (with drop-frame)
  local frame_per_seconds=28         # Frames in 1 second within 10 minutes

  # Calculate drop-frame adjusted timecode
  local total_hours=$(( frame / frame_per_hour ))
  local frame_remainder=$(( frame % frame_per_hour))
  local total_10minutes=$(( frame_remainder / frame_per_10_minutes ))
  frame_remainder=$(( frame_remainder % frame_per_10_minutes ))
  local total_minutes=$(( total_10minutes * 10 ))
  local total_seconds=$(( frame_remainder / frame_per_seconds ))
  frame_remainder=$(( frame_remainder % frame_per_seconds ))

  # --------Final Output---------
  # Format output as HH:MM:SS:FF
  finalTimecode=$(printf "%02d:%02d:%02d:%02d\n" "$total_hours" "$total_minutes" "$total_seconds" "$frame_remainder")
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - FINAL [$finalTimecode]"

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
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
if [[ "$adType" == "vod" ]];
then
    # Get Item's Marker Info
    itemsMarkerInfo="/opt/olympusat/zMisc/convertMarkersToMetadata/$itemId.xml"
    if [[ -e "$itemsMarkerInfo" ]];
    then
        mv -f "$itemsMarkerInfo" "/opt/olympusat/zMisc/convertMarkersToMetadata/zCompleted/"
        sleep 1
    fi
    getItemMarkersURL="http://10.1.1.34/AVAPI/asset/$itemId/?type=AvAdBreak&content=marker"
    getItemMarkersHttpResponse=$(curl --location $getItemMarkersURL --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
    itemMarkersFiltered=$(echo "$getItemMarkersHttpResponse" | jq '[.timespans[] | select(.type == "AvAdBreak")]')
    sleep 1
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
    sleep 2
    # Sort results in ascending order based on start_frame
    itemMarkersSortedInfo=$(echo "$itemMarkersExtractedInfo" | jq 'sort_by(.start_frame)')
    fps=$(echo "scale=8; 30000 / 1001" | bc)
    # Extract start frames and convert to timecode
    adMarkerTimecodes=$(echo "$itemMarkersSortedInfo" | jq -r '.[] | .start_frame' | while read frame; do
        convertToTimecode "$frame" "$fps"
    done | paste -sd "," -)
    if [[ "$adMarkerTimecodes" == "" ]];
    then
        adMarkerTimecodes="NONE"
    fi
    sleep 1
    updateVidispineMetadata $itemId "oly_adMarkers" "$adMarkerTimecodes"
elif [[ "$adType" == "rtcMexico" ]];
then
    # Get Item's Marker Info
    itemsMarkerInfo="/opt/olympusat/zMisc/convertMarkersToMetadata/$itemId.xml"
    if [[ -e "$itemsMarkerInfo" ]];
    then
        mv -f "$itemsMarkerInfo" "/opt/olympusat/zMisc/convertMarkersToMetadata/zCompleted/"
        sleep 1
    fi
    getItemMarkersURL="http://10.1.1.34/AVAPI/asset/$itemId/?type=AvAdBreak&content=marker"
    getItemMarkersHttpResponse=$(curl --location $getItemMarkersURL --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
    itemMarkersFiltered=$(echo "$getItemMarkersHttpResponse" | jq '[.timespans[] | select(.type == "AvAdBreak")]')
    sleep 1
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
    sleep 2
    # Sort results in ascending order based on start_frame
    itemMarkersSortedInfo=$(echo "$itemMarkersExtractedInfo" | jq 'sort_by(.start_frame)')
    fps=$(echo "scale=8; 30000 / 1001" | bc)
    # Extract start frames and convert to timecode
    adMarkerTimecodes=$(echo "$itemMarkersSortedInfo" | jq -r '.[] | .start_frame' | while read frame; do
        convertToTimecode "$frame" "$fps"
    done | paste -sd "," -)
    if [[ "$adMarkerTimecodes" == "" ]];
    then
        adMarkerTimecodes="NONE"
    fi
    sleep 1
    updateVidispineMetadata $itemId "oly_adMarkers" "$adMarkerTimecodes"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - No Valid Ad Type Set - exiting script"
fi
IFS=$saveIFS