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

# Function to create comma seperated list
createCommaSeperatedList ()
{
    currentFieldValue="$1"
    currentFieldName="$2"
    numberOfValues=$(echo "$currentFieldValue"  | awk -F '<list-item>' '{print NF}')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Values - [$currentFieldValue]" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Number of Values - [$numberOfValues]" >> "$logfile"
    outputVariable=""
    for (( a=2 ; a<=$numberOfValues ; a++ ));
    do
        currentValue=$(echo "$currentFieldValue" | awk -F '<list-item>' '{print $'$a'}' | awk -F '</list-item>' '{print $1}')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Current Value - [$currentValue]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Output Variable - [$outputVariable]" >> "$logfile"
        if [[ "$currentValue" != "" ]];
        then
            if [[ "$outputVariable" == "" ]];
            then
                outputVariable=$(echo "$currentValue")
            else
                outputVariable="$(echo "$outputVariable"), $(echo "$currentValue")"
            fi
        fi
    done
    echo "$outputVariable"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Final Output Variable - [$outputVariable]" >> "$logfile"
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
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - int_seconds [$int_seconds]" >> "$logfile"
  
  # Extract fractional part and calculate frames
  local fractional_seconds=$(echo "$total_seconds - $int_seconds" | bc)
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
  
  # Add timecode to array to be sorted later
  adMarkerTimecodeArray+=("$finalTimecode")

  echo $finalTimecode
}

# Function to sort timecodes and store them in a variable
sort_timecodes() {
    local fps=29.97
    local timecodes=("$@")
    echo "----------------------------------------------" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - timecodes [$timecodes]" >> "$logfile"
    
    # Create an associative array to map total frames back to timecodes
    declare -A frame_map
    
    # Convert timecodes to total frames and store in an array
    for timecode in "${timecodes[@]}"; do
        total_frames=$(timecode_to_frames "$timecode" "$fps")
        frame_map["$total_frames"]=$timecode
    done
    
    # Sort the timecodes numerically based on total frames
    sorted_frames=($(echo "${!frame_map[@]}" | tr ' ' '\n' | sort -n))
    
    # Initialize an empty string to store the sorted timecodes
    local sorted_timecodes=""
    
    # Concatenate the sorted timecodes into a single string, separated by commas
    for frame in "${sorted_frames[@]}"; do
        if [[ -z "$sorted_timecodes" ]]; then
            sorted_timecodes="${frame_map[$frame]}"
        else
            sorted_timecodes="$sorted_timecodes,${frame_map[$frame]}"
        fi
    done
    
    # Output the sorted timecodes as a variable
    echo "$sorted_timecodes"
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
    fps=$(echo "scale=8; 30000 / 1001" | bc)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - fps [$fps]" >> "$logfile"
    # Extract start frames and convert to timecode
    adMarkerTimecodes=$(echo "$itemMarkersExtractedInfo" | jq -r '.[] | .start_frame' | while read frame; do
        convertToTimecode "$frame" "$fps"
    done | paste -sd "," -)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - adMarkerTimecodes [$adMarkerTimecodes]" >> "$logfile"
    # Call the function with the list of timecodes
    sortedAdMarkerTimecodes=$(sort_timecodes "${adMarkerTimecodes[@]}")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - sortedAdMarkerTimecodes [$sortedAdMarkerTimecodes]" >> "$logfile"
    if [[ "$sortedAdMarkerTimecodes" == "" ]];
    then
        sortedAdMarkerTimecodes="NONE"
    fi
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - Extracted Marker Info [$sortedAdMarkerTimecodes]" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - No Valid Ad Type Set - exiting script" >> "$logfile"
fi
IFS=$saveIFS