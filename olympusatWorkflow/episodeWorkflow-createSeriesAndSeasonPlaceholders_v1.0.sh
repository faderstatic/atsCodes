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

logfile="/opt/olympusat/logs/qcWorkflow-$mydate.log"

#Set Variable to check before continuing with script
export itemId=$1
itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
echo "Content Type - [$itemContentType]"

#Check Variable
if [[ "$itemContentType" != "episode" ]];
then
    echo "contentType is NOT 'episode'-skip process"
    #contentType is NOT 'episode'-skip process
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$datetime - (episodeWorkflow) - Item ID - $itemId" >> "$logfile"
    echo "$datetime - (episodeWorkflow) - Content Type is NOT 'episode'" >> "$logfile"
    echo "$datetime - (episodeWorkflow) - Skipping Episode Workflow" >> "$logfile"
else
    echo "contentType IS episode-continue with process"
    #contentType IS episode-continue with process
    #Variables to be passed from Cantemo to shell script
    itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
    itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
    checkForSeriesItem="$itemSeriesName"
    checkForSeasonItem="$itemSeriesName | Season $itemSeasonNumber"

    echo "Check for Series Item - [$checkForSeriesItem]"
    echo "Check for Season Item - [$checkForSeasonItem]"

    export searchUrl="http://10.1.1.34/API/v2/search/"
    export createUrl="http://10.1.1.34/API/v2/items/"

    #API Call to Search if Series already exists
    #seriesHttpResponse=$(curl --location --request PUT 'http://10.1.1.34/API/v2/search/' --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data '{"filter": {"operator": "AND","terms": [{"name": "title", "value": "Khloe"},{"name": "oly_contentType", "value": "series"}]}}')
    seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\" },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
    seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)
    echo "Series Search httpResponse - [$seriesCheckHttpResponse]"

    if [[ "$seriesCheckHttpResponse" != *""id":"OLY-""* ]];
    then
        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        #seriesCreateHttpResponse=$(curl -X POST "http://10.1.1.34/API/v2/items/" -H "accept: application/json" -H "Content-Type: application/json" -H "X-CSRFToken: u3qcM502KaqTlwp9rDT0dqZw3cePwHN9rLaCojxekvUuYeKgi5ikanKUoe5zziQL" -d "{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"Test Series API\" }, { \"name\": \"oly_contentType\", \"value\": \"series\" }, { \"name\": \"oly_licensor\", \"value\": \"olympusat\" } ] }}")
        seriesCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeriesName\" }, { \"name\": \"oly_contentType\", \"value\": \"series\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" } ] }}"
        seriesCreateHttpResponse=$(curl -X POST $createUrl -H "accept: application/json" -H "Content-Type: application/json" -H "X-CSRFToken: u3qcM502KaqTlwp9rDT0dqZw3cePwHN9rLaCojxekvUuYeKgi5ikanKUoe5zziQL" -d $seriesCreateBody)
        echo "Series Create httpResponse - [$seriesCreateHttpResponse]"
    fi

    sleep 2

    #API Call to Search if Series already exists
    #seasonHttpResponse=$(curl --location --request PUT 'http://10.1.1.34/API/v2/search/' --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data '{"filter": {"operator": "AND","terms": [{"name": "title", "value": "Khloe | Season 1"},{"name": "oly_contentType", "value": "season"}]}}')
    seasonBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeasonItem\" },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
    seasonHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seasonBody)
    echo "Season Search httpResponse - [$seasonHttpResponse]"

    if [[ "$seasonCheckHttpResponse" != *""id":"OLY-""* ]];
    then
        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        #seriesCreateHttpResponse=$(curl -X POST "http://10.1.1.34/API/v2/items/" -H "accept: application/json" -H "Content-Type: application/json" -H "X-CSRFToken: u3qcM502KaqTlwp9rDT0dqZw3cePwHN9rLaCojxekvUuYeKgi5ikanKUoe5zziQL" -d "{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"Test Season API\" }, { \"name\": \"oly_contentType\", \"value\": \"season\" }, { \"name\": \"oly_licensor\", \"value\": \"olympusat\" }, { \"name\": \"oly_seasonNumber\", \"value\": \"1\" } ] }}")
        seasonCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$checkForSeasonName\" }, { \"name\": \"oly_contentType\", \"value\": \"season\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_seasonNumber\", \"value\": \"$itemSeasonNumber\" } ] }}"
        seasonCreateHttpResponse=$(curl -X POST $createUrl -H "accept: application/json" -H "Content-Type: application/json" -H "X-CSRFToken: u3qcM502KaqTlwp9rDT0dqZw3cePwHN9rLaCojxekvUuYeKgi5ikanKUoe5zziQL" -d $seasonCreateBody)
        echo "Season Create httpResponse - [$seasonCreateHttpResponse]"
    fi
fi

IFS=$saveIFS
