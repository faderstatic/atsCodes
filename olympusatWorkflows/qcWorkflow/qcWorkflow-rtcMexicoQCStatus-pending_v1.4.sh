#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to mark metadata as oly_rtcMexicoQCStatus Pending & Send email
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/17/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export titleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
export titleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
export contentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
export fullFilePath=$(filterVidispineFileInfo $itemId  "uri" "tag=original")
export fullFilePath2=$(echo $fullFilePath | sed -e 's/%20/ /g')
export linkToClip=http://cantemo.olympusat.com/item/$itemId/

export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
export qcStatus=pending
#export qcBy=$2
export qcDate=$(date "+%Y-%m-%dT%H:%M:%S")

#logfile="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/apiCalls/logs/apiCall-$mydate.log"
logfile="/opt/olympusat/logs/qcWorkflow-$mydate.log"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcMexicoQC) - ($itemId) - Triggering API to Update rtcMexicoQCStatus Metadata - $qcStatus" >> "$logfile"

bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Mexico QC</name><field><name>oly_rtcMexicoQCStatus</name><value>$qcStatus</value></field><field><name>oly_rtcMexicoQCRequestDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")

curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 1

#Set Permissions on Item to give 'RTC Mexico - Access' group WRITE Access
permissionBodyData=$(echo "[ { \"source_name\": \"RTC Mexico - Access\", \"source\": \"GROUP\", \"permission\": \"WRITE\", \"priority\": \"DEFAULT\" }]")
permissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcMexicoQC) - ($itemId) - Sending API Call to Cantemo to Set ACLs" >> "$logfile"

curl --location $permissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=YWnXd79oejS4KNRwIycf0RuBVs2cgw7wrqotCqrYkvCGFtO6FiROd3XiS9d6RYyt' --data $permissionBodyData

sleep 1

echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcMexicoQC) - ($itemId) - Triggering workflow to add item to daily report" >> "$logfile"

bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.2.sh $itemId rtcMexicoQcPending > /dev/null 2>&1 &"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcMexicoQC) - ($itemId) - Update Metadata Completed" >> "$logfile"

IFS=$saveIFS