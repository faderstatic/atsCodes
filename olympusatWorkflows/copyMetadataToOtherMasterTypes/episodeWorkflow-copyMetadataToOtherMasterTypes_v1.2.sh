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
        #searchTitle=$(echo $itemTitle | awk -F_ '{NF-=1}1' OFS=_)
        searchTitle1=$(echo $itemTitle | awk -F '_' '{print $1}')
        numberOfUnderscores=$(echo $itemTitle | awk -F"_" '{print NF-1}')
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Number of Underscores - [$numberOfUnderscores]" >> "$logfile"
        
        if [[ $numberOfUnderscores == 5 ]];
        then
            searchTitle2=$(echo $itemTitle | awk -F '_' '{print $5}')
        else
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Number of Underscores NOT Supported - [$numberOfUnderscores]" >> "$logfile"    
        fi

        searchTitle="$searchTitle1 $searchTitle2"

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Search Title - [$searchTitle]" >> "$logfile"

        itemTitleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
        itemTitleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
        itemOriginalTitle=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalTitle")
        itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
        itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
        itemEpisodeNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_episodeNumber")
        itemLicensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
        itemOriginalLanguage=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalLanguage")
        
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
        textlessCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"textlessmaster\" }]}}"
        
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Check Body - [$textlessCheckBody]" >> "$logfile"
        
        textlessCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $textlessCheckBody)

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Check HTTP Response - [$textlessCheckHttpResponse]" >> "$logfile"

        if [[ "$textlessCheckHttpResponse" == *'"id":"OLY-'* ]];
        then
            #Textless Master does exist, updating metadata
            textlessItemId=$(echo "$textlessCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Master Item ID - [$textlessItemId]" >> "$logfile"

            #Updating metadata on Textless Master Item
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Textless Master Item - [$textlessItemId]" >> "$logfile"

            updateVidispineMetadata $textlessItemId "oly_titleEs" "$itemTitleEs"
            updateVidispineMetadata $textlessItemId "oly_titleEn" "$itemTitleEn"
            updateVidispineMetadata $textlessItemId "oly_originalTitle" "$itemOriginalTitle"
            updateVidispineMetadata $textlessItemId "oly_seriesName" "$itemSeriesName"
            updateVidispineMetadata $textlessItemId "oly_seasonNumber" "$itemSeasonNumber"
            updateVidispineMetadata $textlessItemId "oly_episodeNumber" "$itemEpisodeNumber"
            updateVidispineMetadata $textlessItemId "oly_licensor" "$itemLicensor"
            updateVidispineMetadata $textlessItemId "oly_originalLanguage" "$itemOriginalLanguage"
           
        else
            #Textless Master does not exist - trying different search
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Master does not exist - Trying different search" >> "$logfile"

            #searchTitle="$searchTitle1 S'$itemSeasonNumber'E'$itemEpisodeNumber'"
            searchTitle=$(echo $searchTitle1 "S"$itemSeasonNumber"E"$itemEpisodeNumber)
            export searchUrl="http://10.1.1.34/API/v2/search/"
            textlessCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"textlessmaster\" }]}}"
            
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Textless Check Body - [$textlessCheckBody]" >> "$logfile"
            
            textlessCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $textlessCheckBody)

            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Textless Check HTTP Response - [$textlessCheckHttpResponse]" >> "$logfile"

            if [[ "$textlessCheckHttpResponse" == *'"id":"OLY-'* ]];
            then
                #Textless Master does exist, updating metadata
                textlessItemId=$(echo "$textlessCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Master Item ID - [$textlessItemId]" >> "$logfile"

                #Updating metadata on Textless Master Item
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Textless Master Item - [$textlessItemId]" >> "$logfile"

                updateVidispineMetadata $textlessItemId "oly_titleEs" "$itemTitleEs"
                updateVidispineMetadata $textlessItemId "oly_titleEn" "$itemTitleEn"
                updateVidispineMetadata $textlessItemId "oly_originalTitle" "$itemOriginalTitle"
                updateVidispineMetadata $textlessItemId "oly_seriesName" "$itemSeriesName"
                updateVidispineMetadata $textlessItemId "oly_seasonNumber" "$itemSeasonNumber"
                updateVidispineMetadata $textlessItemId "oly_episodeNumber" "$itemEpisodeNumber"
                updateVidispineMetadata $textlessItemId "oly_licensor" "$itemLicensor"
                updateVidispineMetadata $textlessItemId "oly_originalLanguage" "$itemOriginalLanguage"
            
            else
                #Textless Master does not exist
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Textless Master does not exist" >> "$logfile"
            fi
        fi

        sleep 2

        #API Call to Search for Dubbed Master

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Searching for Dubbed Master - [$searchTitle]" >> "$logfile"

        export searchUrl="http://10.1.1.34/API/v2/search/"
        dubbedCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"dubbedmaster*\" }]}}"
        
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master Check Body - [$dubbedCheckBody]" >> "$logfile"
        
        dubbedCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $dubbedCheckBody)

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master Check HTTP Response - [$dubbedCheckHttpResponse]" >> "$logfile"

        if [[ "$dubbedCheckHttpResponse" == *'"id":"OLY-'* ]];
        then
            #Dubbed Master does exist, updating metadata
            dubbedItemId=$(echo "$dubbedCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master Item ID - [$dubbedItemId]" >> "$logfile"

            #Updating metadata on Dubbed Master Item
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Dubbed Master Item - [$dubbedItemId]" >> "$logfile"

            updateVidispineMetadata $dubbedItemId "oly_titleEs" "$itemTitleEs"
            updateVidispineMetadata $dubbedItemId "oly_titleEn" "$itemTitleEn"
            updateVidispineMetadata $dubbedItemId "oly_originalTitle" "$itemOriginalTitle"
            updateVidispineMetadata $dubbedItemId "oly_seriesName" "$itemSeriesName"
            updateVidispineMetadata $dubbedItemId "oly_seasonNumber" "$itemSeasonNumber"
            updateVidispineMetadata $dubbedItemId "oly_episodeNumber" "$itemEpisodeNumber"
            updateVidispineMetadata $dubbedItemId "oly_licensor" "$itemLicensor"
            updateVidispineMetadata $dubbedItemId "oly_originalLanguage" "$itemOriginalLanguage"

        else
            #Dubbed Master does not exist - trying different search
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master does not exist - Trying different search" >> "$logfile"

            #searchTitle="$searchTitle1 S'$itemSeasonNumber'E'$itemEpisodeNumber'"
            searchTitle=$(echo $searchTitle1 "S"$itemSeasonNumber"E"$itemEpisodeNumber)
            export searchUrl="http://10.1.1.34/API/v2/search/"
            dubbedCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"dubbedmaster*\" }]}}"
            
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Dubbed Master Check Body - [$dubbedCheckBody]" >> "$logfile"
            
            dubbedCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $dubbedCheckBody)

            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Dubbed Master Check HTTP Response - [$dubbedCheckHttpResponse]" >> "$logfile"

            if [[ "$dubbedCheckHttpResponse" == *'"id":"OLY-'* ]];
            then
                #Dubbed Master does exist, updating metadata
                dubbedItemId=$(echo "$dubbedCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master Item ID - [$dubbedItemId]" >> "$logfile"

                #Updating metadata on Dubbed Master Item
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Dubbed Master Item - [$dubbedItemId]" >> "$logfile"

                updateVidispineMetadata $dubbedItemId "oly_titleEs" "$itemTitleEs"
                updateVidispineMetadata $dubbedItemId "oly_titleEn" "$itemTitleEn"
                updateVidispineMetadata $dubbedItemId "oly_originalTitle" "$itemOriginalTitle"
                updateVidispineMetadata $dubbedItemId "oly_seriesName" "$itemSeriesName"
                updateVidispineMetadata $dubbedItemId "oly_seasonNumber" "$itemSeasonNumber"
                updateVidispineMetadata $dubbedItemId "oly_episodeNumber" "$itemEpisodeNumber"
                updateVidispineMetadata $dubbedItemId "oly_licensor" "$itemLicensor"
                updateVidispineMetadata $dubbedItemId "oly_originalLanguage" "$itemOriginalLanguage"
            
            else
                #Dubbed Master does not exist
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Dubbed Master does not exist" >> "$logfile"
            fi
        fi

        sleep 2

        #API Call to Search for Spanish Master

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Searching for Spanish Master - [$searchTitle]" >> "$logfile"

        export searchUrl="http://10.1.1.34/API/v2/search/"
        spanishCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"spanishmaster\" }]}}"
        
        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master Check Body - [$spanishCheckBody]" >> "$logfile"
        
        spanishCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $spanishCheckBody)

        echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master Check HTTP Response - [$spanishCheckHttpResponse]" >> "$logfile"

        if [[ "$spanishCheckHttpResponse" == *'"id":"OLY-'* ]];
        then
            #Spanish Master does exist, updating metadata
            spanishItemId=$(echo "$spanishCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master Item ID - [$spanishItemId]" >> "$logfile"

            #Updating metadata on Spanish Master Item
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Spanish Master Item - [$spanishItemId]" >> "$logfile"

            updateVidispineMetadata $spanishItemId "oly_titleEs" "$itemTitleEs"
            updateVidispineMetadata $spanishItemId "oly_titleEn" "$itemTitleEn"
            updateVidispineMetadata $spanishItemId "oly_originalTitle" "$itemOriginalTitle"
            updateVidispineMetadata $spanishItemId "oly_seriesName" "$itemSeriesName"
            updateVidispineMetadata $spanishItemId "oly_seasonNumber" "$itemSeasonNumber"
            updateVidispineMetadata $spanishItemId "oly_episodeNumber" "$itemEpisodeNumber"
            updateVidispineMetadata $spanishItemId "oly_licensor" "$itemLicensor"
            updateVidispineMetadata $spanishItemId "oly_originalLanguage" "$itemOriginalLanguage"

        else
            #Spanish Master does not exist - trying different search
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master does not exist - Trying different search" >> "$logfile"

            #searchTitle="$searchTitle1 S'$itemSeasonNumber'E'$itemEpisodeNumber'"
            searchTitle=$(echo $searchTitle1 "S"$itemSeasonNumber"E"$itemEpisodeNumber)
            export searchUrl="http://10.1.1.34/API/v2/search/"
            spanishCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$searchTitle\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"spanishmaster\" }]}}"
            
            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Spanish Master Check Body - [$spanishCheckBody]" >> "$logfile"
            
            spanishCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $spanishCheckBody)

            echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Second Spanish Master Check HTTP Response - [$spanishCheckHttpResponse]" >> "$logfile"

            if [[ "$spanishCheckHttpResponse" == *'"id":"OLY-'* ]];
            then
                #Spanish Master does exist, updating metadata
                spanishItemId=$(echo "$spanishCheckHttpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master Item ID - [$spanishItemId]" >> "$logfile"

                #Updating metadata on Spanish Master Item
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Updating Metadata on Spanish Master Item - [$spanishItemId]" >> "$logfile"

                updateVidispineMetadata $spanishItemId "oly_titleEs" "$itemTitleEs"
                updateVidispineMetadata $spanishItemId "oly_titleEn" "$itemTitleEn"
                updateVidispineMetadata $spanishItemId "oly_originalTitle" "$itemOriginalTitle"
                updateVidispineMetadata $spanishItemId "oly_seriesName" "$itemSeriesName"
                updateVidispineMetadata $spanishItemId "oly_seasonNumber" "$itemSeasonNumber"
                updateVidispineMetadata $spanishItemId "oly_episodeNumber" "$itemEpisodeNumber"
                updateVidispineMetadata $spanishItemId "oly_licensor" "$itemLicensor"
                updateVidispineMetadata $spanishItemId "oly_originalLanguage" "$itemOriginalLanguage"
            
            else
                #Spanish Master does not exist
                echo "$datetime - (copyMetadataToOtherMasters) - [$itemId] - Spanish Master does not exist" >> "$logfile"
            fi
        fi
    fi
fi

IFS=$saveIFS
