#!/bin/bash

#::******************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to mark metadata as oly_rtcMexicoQCStatus Approved/Rejected & Send email
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/17/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS
#::******************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#SMTP Server Settings
#export url=smtp://smtp-mail.outlook.com:587
#export user=notify@olympusat.com:560Village

#Recipient email addresses
export recipient1=dsenderowicz@olympusat.com
export recipient2=mamAdmin@olympusat.com
export recipient3=kkanjanapitak@olympusat.com
export recipient4=rsims@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

#Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")

export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
export qcStatus=$3
export qcBy=$2
export qcDate=$(date "+%Y-%m-%dT%H:%M:%S")
export qcStatusUCase=$(echo $qcStatus | sed 's/.*/\u&/')

#logfile="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/apiCalls/logs/apiCall-$mydate.log"
logfile="/opt/olympusat/logs/qcWorkflow-$mydate.log"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "$datetime - (rtcMexicoQC) - Triggering API to Update rtcMexicoQCStatus Metadata" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Item ID - $itemId" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - New QC Status - $qcStatusUCase" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - QC By - $qcBy" >> "$logfile"

bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Mexico QC</name><field><name>oly_rtcMexicoQCStatus</name><value>$qcStatus</value></field><field><name>oly_rtcMexicoQCBy</name><value>$qcBy</value></field><field><name>oly_rtcMexicoQCDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")

echo "$datetime - (rtcMexicoQC) - Body Data - $bodyData" >> "$logfile"

curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 3

#Set Permissions on Item to give 'RTC Mexico - Access' group NONE Access
getPermissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/?group=RTC%20Mexico%20-%20Access"

echo "$datetime - (rtcMexicoQC) - Sending API Call to Cantemo to Set ACLs" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - URL - $permissionUrl" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Body Data - $permissionBodyData" >> "$logfile"

httpResponse=$(curl --location --request GET $getPermissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=fHDUyZ7wk6BVS1aMcV7MazrjpRODBxThM3pnmrWGlqw98SbE6g6wt19Dg1Q4GUio' --data '')
aclId=$(echo "$httpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')

sleep 3

removePermissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/$aclId"

curl -s -o /dev/null --location --request DELETE $removePermissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=zxleguMwvKqz1wS1Q4F9U4vGo54eUXQAQwstEkVB7xokFrQYTFqmtdHxkZf4PW7B' --data ''

sleep 3

echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcMexicoQC) - ($itemId) - Triggering workflow to add item to daily report" >> "$logfile"

if [[ "$qcStatus" == "approved" ]];
then
  scriptVar="rtcMexicoQcApproved"
elif [[ "$qcStatus" == "rejected" ]];
then
  scriptVar="rtcMexicoQcRejected"
fi

bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.3.sh $itemId $scriptVar > /dev/null 2>&1 &"

sleep 2

echo "$datetime - (rtcMexicoQC) - Update Metadata Completed" >> "$logfile"

IFS=$saveIFS
