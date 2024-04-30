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

contentFlagsValues=""
numberOfValues=$(echo "$httpResponse" | awk -F "$filedName" '{print NF}')
for (( j=1 ; j<=$numberOfValues ; j++ ));
do
    currentValue=$(echo $httpResponse | awk -F "$fieldName" '{print $2}' | awk -F "\">" '{print $2}' | head -c -3)
    echo "currentValue=[$currentValue]"
    if [[ "$contentFlagsValues" = "" ]];
    then
        contentFlagsValues="$currentValue"
        echo "contentFlagsValues=[$contentFlagsValues]"
    else
        contentFlagsValues="$contentFlagsValues","$currentValue"
        echo "contentFlagsValues=[$contentFlagsValues]"
    fi
done
echo "final contentFlagsValues=[$contentFlagsValues]"

: '
#Check Variable
#if [[ ()"$itemContentFlags" != *"legacycontent"*) && ("$user" = "legacyApproval") ]];
if [[ ("$httpResponse" != *"legacycontent"*) && ("$user" = "legacyApproval") ]];
then
    #user is 'legacyApproval' & oly_contentFlags does not contain 'legacycontent'-skip process
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$datetime - (contentProcessingQC) - Item ID - $itemId" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - User - $user" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Content Flags Does NOT Contain 'legacycontent'" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Skipping Marking as Approved" >> "$logfile"
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

    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$datetime - (contentProcessingQC) - Triggering API to Update OriginalQC Metadata" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Item ID - $itemId" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - User - $user" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - New QC Status - $qcStatus" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Item Content Type - $itemContentType" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Item Version Type - $itemVersionType" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Item Current Original Content QC Status - $itemOriginalContentQCStatus" >> "$logfile"
    echo "$datetime - (contentProcessingQC) - Item Current Final QC Status - $itemFinalQCStatus" >> "$logfile"

    case $itemContentType in
        "movie" | "episode")
            case $itemVersionType in
                "originalFile")
                    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
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
        "seasonTrailer" | "movieTrailer" | "promo" | "image" | "audio" | "m-e" | "script" | "subtitle" | "closedCaption" | "project")
            bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>Original Content</name><field><name>oly_originalContentQCStatus</name><value>$qcStatus</value></field><field><name>oly_originalContentQCBy</name><value>$qcBy</value></field><field><name>oly_originalContentQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")
        ;;
    esac

    echo "$datetime - (contentProcessingQC) - Body Data - $bodyData" >> "$logfile"

    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

    sleep 5

    echo "$datetime - (contentProcessingQC) - Update Metadata Completed" >> "$logfile"
fi
'
IFS=$saveIFS
