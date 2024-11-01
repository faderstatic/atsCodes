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
# . /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

#--------------------------------------------------
# Internal funtions
# Function to Release Lock after item is processed/completed

# Function to convert to timecode
convertToTimecode() {
  local frame=$1
  local droppedFrame=$2

  # --------Drop Frame Calculation---------
  # Drop-frame constants for 29.97 fps
  if [[ $droppedFrame -eq 1 ]];
  then
    local frames_per_hour=107892       # 29.97 fps, drop-frame
    local frames_per_10_minutes=17982  # Frames in 10 minutes (with drop-frame)
    local frames_per_minute=1798       # Frames in 1 minute (with drop-frame)
    local frames_per_seconds=28         # Frames in 1 second within 10 minutes
  else
    local frames_per_hour=108000
    local frames_per_10_minutes=18000
    local frames_per_minute=1800
    local frames_per_seconds=30
  fi

  # Calculate drop-frame adjusted timecode
  local total_hours=$(( frame / frames_per_hour ))
  local frame_remainder=$(( frame % frames_per_hour))
  local total_10minutes=$(( frame_remainder / frames_per_10_minutes ))
  frame_remainder=$(( frame_remainder % frames_per_10_minutes ))
  total_10minutes=$(( total_10minutes * 10 ))
  local total_minutes=$(( (frame_remainder / frames_per_minute) + total_10minutes ))
  frame_remainder=$(( frame_remainder % frames_per_minute ))
  local total_seconds=$(( frame_remainder / frames_per_seconds ))
  frame_remainder=$(( frame_remainder % frames_per_seconds ))

  # --------Final Output---------
  # Format output as HH:MM:SS:FF
  finalTimecode=$(printf "%02d:%02d:%02d:%02d\n" "$total_hours" "$total_minutes" "$total_seconds" "$frame_remainder")
  echo "$(date +%Y/%m/%d_%H:%M:%S) - (distributionWorkflow-convertAdBreakMarkers) - ($itemId) - INTERNAL FUNCTION - FINAL [$finalTimecode]"

  echo $finalTimecode
}

#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export frame=$1
export droppedFrame=$2

convertToTimecode $frame $droppedFrame

IFS=$saveIFS