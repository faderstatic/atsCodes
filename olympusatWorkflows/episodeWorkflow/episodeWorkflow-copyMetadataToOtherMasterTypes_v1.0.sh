#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get metadata from Original Master Episode & copy to other Master Types (textless, dubbed, etc)
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 05/14/2024
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
    #contentType is NOT 'episode'-skip process

    echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Content Type is NOT 'episode'" >> "$logfile"
    echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Content Type is [$itemContentType] - Skipping Episode Workflow" >> "$logfile"
else
    #contentType IS episode-continue with process
    #Variables to be passed from Cantemo to shell script

    echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Content Type is [$itemContentType]" >> "$logfile"

    urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_originalFileFlags&terse=yes"
    httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

    echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Original File Flags are [$httpResponse]" >> "$logfile"

    if [[ "$httpResponse" != *"originalrawmaster"* ]];
    then
        #Item is not Original Master-skip process
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Item is Not Original Master - Skipping Episode Workflow" >> "$logfile"
    else
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
        searchTitle=$(echo $itemTitle | awk -F_ '{NF-=1}1' OFS=_)

        echo "searchTitle = [$searchTitle]"
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Search Title - [$searchTitle]" >> "$logfile"

        itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
        itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
        itemEpisodeNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_episodeNumber")
        
        urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
        httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *"legacycontent"* ]];
        then
            contentFlagsValue="legacycontent"
        else
            contentFlagsValue=""
        fi

        #API Call to Search for Textless Master

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Searching for Textless Master - [$searchTitle]" >> "$logfile"

        export searchUrl="http://10.1.1.34/API/v2/search/"
        #seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\" },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
        #seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)

        #if [[ "$seriesCheckHttpResponse" != *'"id":"OLY-'* ]];
        #then
            #Series placeholder does not exists, API Call to create new Series placeholder with metadata

            #echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Series placeholder - [$checkForSeriesItem]" >> "$logfile"

            #itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
            #seriesCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeriesItem\" }, { \"name\": \"oly_titleEn\", \"value\": \"$checkForSeriesItem\" }, { \"name\": \"oly_contentType\", \"value\": \"series\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_contentFlags\", \"value\": \"$contentFlagsValue\" } ] }}"
            #seriesCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seriesCreateBody)
        #else
            #Series placeholder already exists
            #echo "$datetime - (episodeWorkflow) - [$itemId] - Series placeholder already exists - [$checkForSeriesItem]" >> "$logfile"
        #fi

        #sleep 2

        #API Call to Search if Season already exists

        #echo "$datetime - (episodeWorkflow) - [$itemId] - Checking if Season item exists - [$checkForSeasonItem]" >> "$logfile"

        #seasonCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeasonItem\" },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
        #seasonCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seasonCheckBody)

        #if [[ "$seasonCheckHttpResponse" != *'"id":"OLY-'* ]];
        #then
            #Season placeholder does not exist, API Call to create new Season placeholder with metadata

            #echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Season placeholder - [$checkForSeasonItem]" >> "$logfile"

            #itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
            #seasonCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeasonItem\" }, { \"name\": \"oly_titleEn\", \"value\": \"$checkForSeriesItem\" }, { \"name\": \"oly_contentType\", \"value\": \"season\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_seasonNumber\", \"value\": \"$itemSeasonNumber\" }, { \"name\": \"oly_seriesName\", \"value\": \"$checkForSeriesItem\" }, { \"name\": \"oly_contentFlags\", \"value\": \"$contentFlagsValue\" } ] }}"
            #seasonCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seasonCreateBody)
        #else
            #Season placeholder already exists
            #echo "$datetime - (episodeWorkflow) - [$itemId] - Season placeholder already exists - [$checkForSeasonItem]" >> "$logfile"
        #fi

        #updateVidispineMetadata $itemId "oly_adminRulesFlags" "episodeprocessed"
    fi
fi

IFS=$saveIFS
