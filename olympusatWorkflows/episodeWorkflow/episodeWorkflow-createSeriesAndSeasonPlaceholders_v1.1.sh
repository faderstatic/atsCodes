#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get metadata from Episode & create Series & Season placeholders
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/30/2024
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
itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")

#Check Variable
if [[ "$itemContentType" != "episode" ]];
then
    #echo "contentType is NOT 'episode'-skip process"
    
    #contentType is NOT 'episode'-skip process
    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is NOT 'episode'" >> "$logfile"
    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is [$itemContentType]" >> "$logfile"
    echo "$datetime - (episodeWorkflow) - [$itemId] - Skipping Episode Workflow" >> "$logfile"
else
    #echo "contentType IS episode-continue with process"
    
    #contentType IS episode-continue with process
    #Variables to be passed from Cantemo to shell script

    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is [$itemContentType]" >> "$logfile"

    itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
    itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
    checkForSeriesItem="$itemSeriesName"
    checkForSeasonItem="$itemSeriesName | Season $itemSeasonNumber"

    export searchUrl="http://10.1.1.34/API/v2/search/"
    export createUrl="http://10.1.1.34/API/v2/items/"

    #API Call to Search if Series already exists

    echo "$datetime - (episodeWorkflow) - [$itemId] - Checking if Series item exists - [$checkForSeriesItem]" >> "$logfile"

    seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\" },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
    seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)

    if [[ "$seriesCheckHttpResponse" != *""id":"OLY-""* ]];
    then
        #Series placeholder does not exists, API Call to create new Series placeholder with metadata

        echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Series placeholder - [$checkForSeriesItem]" >> "$logfile"

        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        seriesCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeriesItem\" }, { \"name\": \"oly_contentType\", \"value\": \"series\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" } ] }}"
        seriesCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seriesCreateBody)
    else
        #Series placeholder already exists
        echo "$datetime - (episodeWorkflow) - [$itemId] - Series placeholder already exists - [$checkForSeriesItem]" >> "$logfile"
    fi

    sleep 2

    #API Call to Search if Season already exists

    echo "$datetime - (episodeWorkflow) - [$itemId] - Checking if Season item exists - [$checkForSeasonItem]" >> "$logfile"

    seasonCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeasonItem\" },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
    seasonCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seasonBody)

    if [[ "$seasonCheckHttpResponse" != *""id":"OLY-""* ]];
    then
        #Season placeholder does not exist, API Call to create new Season placeholder with metadata

        echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Season placeholder - [$checkForSeasonItem]" >> "$logfile"

        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        seasonCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeasonItem\" }, { \"name\": \"oly_contentType\", \"value\": \"season\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_seasonNumber\", \"value\": \"$itemSeasonNumber\" }, { \"name\": \"oly_seriesName\", \"value\": \"$checkForSeriesItem\" } ] }}"
        seasonCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seasonCreateBody)
    else
        #Season placeholder already exists
        echo "$datetime - (episodeWorkflow) - [$itemId] - Season placeholder already exists - [$checkForSeriesItem]" >> "$logfile"
    fi

    updateVidispineMetadata $itemId "oly_adminRulesFlags" "episodeprocessed"
fi

IFS=$saveIFS
