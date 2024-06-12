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
    #contentType is NOT 'episode'-skip process

    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is NOT 'episode'" >> "$logfile"
    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is [$itemContentType] - Skipping Episode Workflow" >> "$logfile"
else
    #contentType IS episode-continue with process
    #Variables to be passed from Cantemo to shell script

    echo "$datetime - (episodeWorkflow) - [$itemId] - Content Type is [$itemContentType]" >> "$logfile"

    itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
    itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
    checkForSeriesItem="$itemSeriesName"
    if [[ "$checkForSeriesItem" == *:* ]];
    then
        checkForSeriesItem=$(echo $itemSeriesName | sed -e 's/:/\\\\:/g')
    fi
    checkForSeasonItem="$checkForSeriesItem | Season $itemSeasonNumber"
    setForSeriesName="$itemSeriesName"
    setForSeasonName="$itemSeriesName | Season $itemSeasonNumber"

    if [[ (-z "$itemSeriesName") || (-z "$itemSeasonNumber") ]];
    then
        #Metadaata is missinging-skip process
        echo "$datetime - (episodeWorkflow) - [$itemId] - Series Name [$itemSeriesName] - Season Number [$itemSeasonNumber]" >> "$logfile"
        echo "$datetime - (episodeWorkflow) - [$itemId] - Item is Missing Metadata - Skipping Episode Workflow" >> "$logfile"
    else
        export searchUrl="http://10.1.1.34/API/v2/search/"
        export createUrl="http://10.1.1.34/API/v2/items/"

        urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
        httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *"legacycontent"* ]];
        then
            contentFlagsValue="legacycontent"
        else
            contentFlagsValue=""
        fi

        #API Call to Search if Series already exists

        echo "$datetime - (episodeWorkflow) - [$itemId] - Checking if Series item exists - [$checkForSeriesItem]" >> "$logfile"

        seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\" },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
        seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)

        if [[ "$seriesCheckHttpResponse" != *"<id>OLY-"* ]];
        then
            #Series placeholder does not exists, API Call to create new Series placeholder with metadata

            echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Series placeholder - [$setForSeriesName]" >> "$logfile"

            #itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
            #seriesCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$setForSeriesName\" }, { \"name\": \"oly_titleEn\", \"value\": \"$setForSeriesName\" }, { \"name\": \"oly_contentType\", \"value\": \"series\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_contentFlags\", \"value\": \"$contentFlagsValue\" } ] }}"
            #seriesCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seriesCreateBody)
            #seriesItemId=$(echo $seriesCreateHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            #echo "$datetime - (episodeWorkflow) - [$itemId] - Series Item ID - [$seriesItemId]" >> "$logfile"
        else
            #Series placeholder already exists
            echo "$datetime - (episodeWorkflow) - [$itemId] - Series placeholder already exists - [$setForSeriesName]" >> "$logfile"
            seriesItemId=$(echo $seriesCheckHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            echo "$datetime - (episodeWorkflow) - [$itemId] - Series Item ID - [$seriesItemId]" >> "$logfile"

            echo "$datetime - (episodeWorkflow) - [$itemId] - Adding Relationship for Series - [$seriesItemId]" >> "$logfile"
            
            sleep 1
            
            createRelationUrl="http://10.1.1.34:8080/API/relation?allowDuplicate=false"
            createSeriesRelationBody="{\"relation\": [{\"direction\": {\"source\": \"$itemId\",\"target\": \"$seriesItemId\",\"type\": \"U\"},\"value\": [{\"key\": \"type\",\"value\": \"portal_undirectional\"},{\"key\": \"cs_type\",\"value\": \"series\"}]}]}"
            createSeriesRelationHttpResponse=$(curl --location $createRelationUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=izsJxc40uxUMKwzH4JavShE11i6wz9rKlTg2pavusNjK0gLTqstgxD8kgRLgSiL4' --data $createSeriesRelationBody)
            
            #curl --location 'http://10.1.1.34:8080/API/relation?allowDuplicate=false' --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=izsJxc40uxUMKwzH4JavShE11i6wz9rKlTg2pavusNjK0gLTqstgxD8kgRLgSiL4' --data '{"relation": [{"direction": {"source": "'$itemId'","target": "'$seriesItemId'","type": "U"},"value": [{"key": "type","value": "portal_undirectional"},{"key": "cs_type","value": "series"}]}]}'

            echo "$datetime - (episodeWorkflow) - [$itemId] - Sent API Call to Create Series Item - [$createSeriesRelationHttpResponse]" >> "$logfile"
            
            sleep 2
            
            reindexItemUrl="http://10.1.1.34/API/v2/reindex/"
            reindexItemBody="{ \"items\": [\"$itemId\", \"$seriesItemId\"] }"
            reindexItemHttpResponse=$(curl --location --request PUT $reindexItemUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $reindexItemBody)

            echo "$datetime - (episodeWorkflow) - [$itemId] - Sent API Call to ReIndex Item - [$reindexItemHttpResponse]" >> "$logfile"

        fi

        sleep 2

        #API Call to Search if Season already exists

        echo "$datetime - (episodeWorkflow) - [$itemId] - Checking if Season item exists - [$checkForSeasonItem]" >> "$logfile"

        seasonCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeasonItem\" },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
        seasonCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seasonCheckBody)

        if [[ "$seasonCheckHttpResponse" != *"<id>OLY-"* ]];
        then
            #Season placeholder does not exist, API Call to create new Season placeholder with metadata

            echo "$datetime - (episodeWorkflow) - [$itemId] - Creating new Season placeholder - [$setForSeasonName]" >> "$logfile"

            #itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
            #seasonCreateBody="{ \"metadata\": { \"group_name\": \"Olympusat\", \"fields\": [ { \"name\": \"title\", \"value\": \"$setForSeasonName\" }, { \"name\": \"oly_titleEn\", \"value\": \"$setForSeriesName\" }, { \"name\": \"oly_contentType\", \"value\": \"season\" }, { \"name\": \"oly_licensor\", \"value\": \"$itemLicensor\" }, { \"name\": \"oly_seasonNumber\", \"value\": \"$itemSeasonNumber\" }, { \"name\": \"oly_seriesName\", \"value\": \"$setForSeriesName\" }, { \"name\": \"oly_contentFlags\", \"value\": \"$contentFlagsValue\" } ] }}"
            #seasonCreateHttpResponse=$(curl --location --request POST $createUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=CRbBvVEFSfR5lHoQebsbQemRRas2MUyo53CsO5ixtkSrzvC9H7NffcuaXkIJvr1V' --data $seasonCreateBody)
            #seasonItemId=$(echo $seasonCreateHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            #echo "$datetime - (episodeWorkflow) - [$itemId] - Season Item ID - [$seasonItemId]" >> "$logfile"
        else
            #Season placeholder already exists
            echo "$datetime - (episodeWorkflow) - [$itemId] - Season placeholder already exists - [$setForSeasonName]" >> "$logfile"
            seasonItemId=$(echo $seasonCheckHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            echo "$datetime - (episodeWorkflow) - [$itemId] - Season Item ID - [$seasonItemId]" >> "$logfile"

            echo "$datetime - (episodeWorkflow) - [$itemId] - Adding Relationship for Season - [$seasonItemId]" >> "$logfile"
            
            sleep 1
            
            createRelationUrl="http://10.1.1.34:8080/API/relation?allowDuplicate=false"
            createSeasonRelationBody="{\"relation\": [{\"direction\": {\"source\": \"$itemId\",\"target\": \"$seasonItemId\",\"type\": \"U\"},\"value\": [{\"key\": \"type\",\"value\": \"portal_undirectional\"},{\"key\": \"cs_type\",\"value\": \"season\"}]}]}"
            createSeasonRelationHttpResponse=$(curl --location $createRelationUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=izsJxc40uxUMKwzH4JavShE11i6wz9rKlTg2pavusNjK0gLTqstgxD8kgRLgSiL4' --data $createSeasonRelationBody)
            
            echo "$datetime - (episodeWorkflow) - [$itemId] - Sent API Call to Create Season Item - [$createSeasonRelationHttpResponse]" >> "$logfile"
            
            sleep 2
            
            reindexItemUrl="http://10.1.1.34/API/v2/reindex/"
            reindexItemBody="{ \"items\": [\"$itemId\", \"$seasonItemId\"] }"
            reindexItemHttpResponse=$(curl --location --request PUT $reindexItemUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $reindexItemBody)

            echo "$datetime - (episodeWorkflow) - [$itemId] - Sent API Call to ReIndex Item - [$reindexItemHttpResponse]" >> "$logfile"
            echo "$datetime - (episodeWorkflow) - [$itemId] - Create Series, Season & Add Relationship Workflow Completed!!" >> "$logfile"

        fi

        #updateVidispineMetadata $itemId "oly_adminRulesFlags" "episodeprocessed"
    fi
fi

IFS=$saveIFS
