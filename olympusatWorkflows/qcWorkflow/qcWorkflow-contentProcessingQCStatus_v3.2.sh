#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to mark metadata as approved
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/01/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
#logfile="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/apiCalls/logs/apiCall-$mydate.log"
logfile="/opt/olympusat/logs/qcWorkflow-$mydate.log"

#Set Variable to check before continuing with script
export itemId=$1
export user=$2
export xmlTag="metadata"
export fieldName="oly_contentFlags"
#itemContentFlags=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentFlags")
urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/$xmlTag?field=$fieldName&terse=yes"
httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')
#echo $httpResponse
#filteredResponse=$(echo $httpResponse | awk -F "$fieldName" '{print $2}' | awk -F "\">" '{print $2}' | head -c -3)
#echo $filteredResponse

#Check Variable
#if [[ "$itemContentFlags" != *"legacycontent"* ]];
if [[ ("$httpResponse" != *"legacycontent"*) && ("$user" = "legacyApproval") ]];
then
    #user is 'legacyApproval' & oly_contentFlags does not contain 'legacycontent'-skip process
    echo "$datetime - (contentProcessingQC) - [$itemId] - User - $user" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - Content Flags Does NOT Contain 'legacycontent'" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - Skipping Marking as Approved" >> "$logfile"
else
    #user is not 'legacyApproval' or user is 'legacyApproval' & oly_contentFlags does contain 'legacycontent'-continue with process
    #Variables to be passed from Cantemo to shell script
    itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
    itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
    itemOriginalContentQCStatus=$(filterVidispineItemQuery $itemId "metadata" "oly_originalContentQCStatus" "group=Original Content")
    itemFinalQCStatus=$(filterVidispineItemQuery $itemId "metadata" "oly_finalQCStatus" "group=Final Content")

    export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    export qcStatus=$3
    export qcBy=$2
    export qcDate=$(date "+%Y-%m-%dT%H:%M:%S")
    skipMetadataUpdate="0"

    echo "$datetime - (contentProcessingQC) - [$itemId] - Triggering API to Update OriginalQC Metadata" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - User - {$user} - New QC Status - {$qcStatus}" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - Content Type - {$itemContentType} - Item Version Type - {$itemVersionType}" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - Current Original Content QC Status - {$itemOriginalContentQCStatus} - Current Final QC Status - {$itemFinalQCStatus}" >> "$logfile"

    case $itemContentType in
        "movie" | "episode")
            case $itemVersionType in
                "originalFile")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                    if [[ "$itemOriginalContentQCStatus" == "approved" ]];
                    then
                        skipMetadataUpdate="1"
                    fi
                    if [[ "$itemContentType" == "episode" ]];
                    then
                        itemSeriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
                        itemSeasonNumber=$(filterVidispineItemMetadata $itemId "metadata" "oly_seasonNumber")
                        echo "$datetime - (contentProcessingQC) - [$itemId] - Item Series Name [$itemSeriesName]" >> "$logfile"
                        echo "$datetime - (contentProcessingQC) - [$itemId] - Item Season Number [$itemSeasonNumber]" >> "$logfile"
                        checkForSeriesItem="$itemSeriesName"
                        checkForSeasonItem="$checkForSeriesItem | Season $itemSeasonNumber"
                        setForSeriesName="$itemSeriesName"
                        setForSeasonName="$itemSeriesName | Season $itemSeasonNumber"
                        if [[ (-z "$itemSeriesName") || (-z "$itemSeasonNumber") ]];
                        then
                            # Metadata is missinging-skip process
                            echo "$datetime - (contentProcessingQC) - [$itemId] - Series Name [$itemSeriesName] - Season Number [$itemSeasonNumber]" >> "$logfile"
                            echo "$datetime - (contentProcessingQC) - [$itemId] - Item is Missing Metadata - Skipping Check for Series-Season" >> "$logfile"
                        else
                            export searchUrl="http://10.1.1.34/API/v2/search/"
                            # API Call to Search if Series exists
                            echo "$datetime - (contentProcessingQC) - [$itemId] - Checking if Series item exists - [$checkForSeriesItem]" >> "$logfile"
                            seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
                            seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)
                            #echo "$datetime - (contentProcessingQC) - [$itemId] - Search for Series Response - [$seriesCheckHttpResponse]" >> "$logfile"
                            if [[ "$seriesCheckHttpResponse" != *"<id>OLY-"* ]];
                            then
                                # Series placeholder does not exists, if Series Name contains : API Call to Search with a modified Series Name
                                if [[ "$checkForSeriesItem" == *:* ]];
                                then
                                    checkForSeriesItem=$(echo $itemSeriesName | sed -e 's/:/\\\\:/g')
                                    echo "$datetime - (contentProcessingQC) - [$itemId] - Checking if Series item exists - [$checkForSeriesItem]" >> "$logfile"
                                    seriesCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeriesItem\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
                                    seriesCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seriesCheckBody)
                                    #echo "$datetime - (contentProcessingQC) - [$itemId] - Search for Series Response - [$seriesCheckHttpResponse]" >> "$logfile"
                                    if [[ "$seriesCheckHttpResponse" != *"<id>OLY-"* ]];
                                    then
                                        # Series placeholder does not exist
                                        echo "$datetime - (contentProcessingQC) - [$itemId] - Series Placeholder Does Not Exists" >> "$logfile"
                                    else
                                        # Series placeholder exists
                                        seriesHitResults=$(echo $seriesCheckHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                                        echo "$datetime - (contentProcessingQC) - [$itemId] - Series placeholder exists - Number of Items in Results {$seriesHitResults}" >> "$logfile"
                                        seriesItemId=$(echo $seriesCheckHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                                        echo "$datetime - (contentProcessingQC) - [$itemId] - Series Item ID - [$seriesItemId]" >> "$logfile"
                                        seriesOriginalContentQCStatus=$(filterVidispineItemQuery $seriesItemId "metadata" "oly_originalContentQCStatus" "group=Original Content")
                                        echo "$datetime - (contentProcessingQC) - [$seriesItemId] - Series Item's QC Status - [$seriesOriginalContentQCStatus]" >> "$logfile"
                                        if [[ "$seriesOriginalContentQCStatus" == "approved" ]];
                                        then
                                            echo "$datetime - (contentProcessingQC) - [$seriesItemId] - Series Item's QC Status is Already Approved - Skipping Update" >> "$logfile"
                                        else
                                            seriesUrl="http://10.1.1.34:8080/API/item/$seriesItemId/metadata/"
                                            seriesBodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                                            curl -s -o /dev/null --location --request PUT $seriesUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $seriesBodyData
                                        fi
                                    fi
                                fi
                            else
                                # Series placeholder exists
                                seriesHitResults=$(echo $seriesCheckHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                                echo "$datetime - (contentProcessingQC) - [$itemId] - Series placeholder exists - Number of Items in Results {$seriesHitResults}" >> "$logfile"
                                seriesItemId=$(echo $seriesCheckHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                                echo "$datetime - (contentProcessingQC) - [$itemId] - Series Item ID - [$seriesItemId]" >> "$logfile"
                                seriesOriginalContentQCStatus=$(filterVidispineItemQuery $seriesItemId "metadata" "oly_originalContentQCStatus" "group=Original Content")
                                echo "$datetime - (contentProcessingQC) - [$seriesItemId] - Series Item's QC Status - [$seriesOriginalContentQCStatus]" >> "$logfile"
                                if [[ "$seriesOriginalContentQCStatus" == "approved" ]];
                                then
                                    echo "$datetime - (contentProcessingQC) - [$seriesItemId] - Series Item's QC Status is Already Approved - Skipping Update" >> "$logfile"
                                else
                                    seriesUrl="http://10.1.1.34:8080/API/item/$seriesItemId/metadata/"
                                    seriesBodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                                    curl -s -o /dev/null --location --request PUT $seriesUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $seriesBodyData
                                    sleep 1
                                fi
                            fi
                            sleep 2
                            # API Call to Search if Season exists
                            echo "$datetime - (contentProcessingQC) - [$itemId] - Checking if Season item exists - [$checkForSeasonItem]" >> "$logfile"
                            seasonCheckBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"title\", \"value\": \"$checkForSeasonItem\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
                            seasonCheckHttpResponse=$(curl --location --request PUT $searchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $seasonCheckBody)
                            #echo "$datetime - (contentProcessingQC) - [$itemId] - Search for Season Response - [$seasonCheckHttpResponse]" >> "$logfile"
                            if [[ "$seasonCheckHttpResponse" != *"<id>OLY-"* ]];
                            then
                                # Season placeholder does not exist
                                echo "$datetime - (contentProcessingQC) - [$itemId] - Season Placeholder Does Not Exists" >> "$logfile"
                            else
                                # Season placeholder exists
                                seasonHitResults=$(echo $seasonCheckHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
                                echo "$datetime - (contentProcessingQC) - [$itemId] - Season placeholder exists - Number of Items in Results {$seasonHitResults}" >> "$logfile"
                                seasonItemId=$(echo $seasonCheckHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                                echo "$datetime - (contentProcessingQC) - [$itemId] - Season Item ID - [$seasonItemId]" >> "$logfile"
                                seasonOriginalContentQCStatus=$(filterVidispineItemQuery $seasonItemId "metadata" "oly_originalContentQCStatus" "group=Original Content")
                                echo "$datetime - (contentProcessingQC) - [$seasonItemId] - Season Item's QC Status - [$seasonOriginalContentQCStatus]" >> "$logfile"
                                if [[ "$seasonOriginalContentQCStatus" == "approved" ]];
                                then
                                    echo "$datetime - (contentProcessingQC) - [$seasonItemId] - Season Item's QC Status is Already Approved - Skipping Update" >> "$logfile"
                                else
                                    seasonUrl="http://10.1.1.34:8080/API/item/$seasonItemId/metadata/"
                                    seasonBodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                                    curl -s -o /dev/null --location --request PUT $seasonUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $seasonBodyData
                                    sleep 1
                                fi
                            fi
                        fi
                    fi
                ;;
                "conformFile")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
                "censoredFile")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
                "conformFile-spanish")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
                "conformFile-english")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
                "censoredFile-spanish")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
                "censoredFile-english")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Final Content</name><field><name>oly_finalQCStatus</name><value>$qcStatus</value></field><field><name>oly_finalQCBy</name><value>$qcBy</value></field><field><name>oly_finalQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
                ;;
            esac
        ;;
        "series" | "season" | "seasonTrailer" | "movieTrailer" | "promo" | "image" | "audio" | "m-e" | "script" | "subtitle" | "closedCaption" | "project" | "marketingContent")
            bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
        ;;
    esac
    #echo "$datetime - (contentProcessingQC) - [$itemId] - Body Data - $bodyData" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - [$itemId] - skipMetadataUpdate Value - [$skipMetadataUpdate]" >> "$logfile"
    if [[ "$skipMetadataUpdate" == 0 ]];
    then
        curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    else
        echo "$datetime - (contentProcessingQC) - [$itemId] - QC Status NOT Updated - Already set to Approved" >> "$logfile"
    fi
    sleep 3
    echo "$datetime - (contentProcessingQC) - [$itemId] - Update Metadata Completed" >> "$logfile"
fi
IFS=$saveIFS
