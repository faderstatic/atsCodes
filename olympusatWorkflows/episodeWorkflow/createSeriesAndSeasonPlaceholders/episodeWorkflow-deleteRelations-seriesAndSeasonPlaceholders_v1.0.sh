#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will delete existing relationships between Episodes and Series & Season placeholders
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 06/12/2024
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

    echo "$datetime - (episodeWorkflow) - [$itemId] - Deleting Existing Relationships" >> "$logfile"

    urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/relation"
    httpResponse=$(curl --location --request DELETE $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
    echo "$datetime - (episodeWorkflow) - [$itemId] - Response [$httpResponse]" >> "$logfile"

    updateVidispineMetadata $itemId "oly_adminRulesFlags" ""

    echo "$datetime - (episodeWorkflow) - [$itemId] - Relationships Deleted" >> "$logfile"
fi

IFS=$saveIFS
