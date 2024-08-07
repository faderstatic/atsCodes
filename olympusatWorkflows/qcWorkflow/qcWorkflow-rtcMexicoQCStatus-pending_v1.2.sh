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

#SMTP Server Settings
#export url=smtp://smtp-mail.outlook.com:587
#export user=notify@olympusat.com:560Village

#Recipient email addresses
export recipient1=cmonterrey@olympusat.com
export recipient2=mamAdmin@olympusat.com
export recipient3=kkanjanapitak@olympusat.com
export recipient4=rsims@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

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
echo "$datetime - (rtcMexicoQC) - Triggering API to Update rtcMexicoQCStatus Metadata" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Item ID - $itemId" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - New QC Status - $qcStatus" >> "$logfile"

bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Mexico QC</name><field><name>oly_rtcMexicoQCStatus</name><value>$qcStatus</value></field><field><name>oly_rtcMexicoQCRequestDate</name><value>$qcDate</value></field></group></timespan></MetadataDocument>")

echo "$datetime - (rtcMexicoQC) - Body Data - $bodyData" >> "$logfile"

curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 3

#Set Permissions on Item to give 'RTC Mexico - Access' group READ Access
permissionBodyData=$(echo "[ { \"source_name\": \"RTC Mexico - Access\", \"source\": \"GROUP\", \"permission\": \"READ\", \"priority\": \"DEFAULT\" }]")
permissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/"

echo "$datetime - (rtcMexicoQC) - Sending API Call to Cantemo to Set ACLs" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - URL - $permissionUrl" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Body Data - $permissionBodyData" >> "$logfile"

curl --location $permissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=YWnXd79oejS4KNRwIycf0RuBVs2cgw7wrqotCqrYkvCGFtO6FiROd3XiS9d6RYyt' --data $permissionBodyData

sleep 3

if [[ $titleEs != "" && $titleEn != "" ]];
  then
    titleLanguage="Title-English: $titleEn
Title-Spanish: $titleEs"
  else
    if [[ $titleEs != "" && $titleEn == "" ]];
      then
        titleLanguage="Title-Spanish: $titleEs"
      else
        if [[ $titleEs == "" && $titleEn != "" ]];
          then
            titleLanguage="Title-English: $titleEn"
          else
            if [[ $titleEs == "" && $titleEn == "" ]];
              then
                titleLanguage=""
              else
                titleLanguage=""
            fi
        fi
    fi
fi

#Email Body
subject="MAM - RTC Mexico QC - Pending - $title"
body="Hi,

A new title, [$title], is now Pending RTC Mexico QC.

Title: $title
$titleLanguage
Content Type: $contentType
Link To Clip: $linkToClip

Please login to the system and QC this item.

Thanks

MAM Notify"

#Email Message
message="Subject: $subject\n\n$body"

echo "$datetime - (rtcMexicoQC) - Sending Email" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - From - $emailFrom" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Subject - $subject" >> "$logfile"
echo "$datetime - (rtcMexicoQC) - Body - [$body]" >> "$logfile"

curl --url 'smtp://smtp-mail.outlook.com:587' \
  --ssl-reqd \
  --mail-from $emailFrom \
  --mail-rcpt $recipient2 \
  --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
  --tlsv1.2 \
  -T <(echo -e "$message")

echo "$datetime - (rtcMexicoQC) - Email Sent" >> "$logfile"

IFS=$saveIFS

echo "$datetime - (rtcMexicoQC) - Update Metadata Completed" >> "$logfile"

IFS=$saveIFS
