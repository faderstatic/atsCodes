#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger an email to be sent via SMTP Server with email body built in shell script
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/05/2024
#::Rev A: 
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#fileEmail="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/sendEmailTests/$emailFileName"
#logfile="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/sendEmailTests/logs/sendEmailLog-$mydate.log"
logfile="/opt/olympusat/logs/sendEmail-workflowPending-$mydate.log"

#SMTP Server Settings
#export url=smtp://smtp-mail.outlook.com:587
#export user=notify@olympusat.com:560Village

#Recipient email addresses
export recipient1=testDubbingEnglish@olympusat.com
export recipient2=mamAdmin@olympusat.com
export recipient3=kkanjanapitak@olympusat.com
export recipient4=rsims@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export titleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
export titleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
export seriesName=$(filterVidispineItemMetadata $itemId "metadata" "oly_seriesName")
export licensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
export contentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
export rightslineContractId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineContractId")
export rightslineItemId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineItemId")
export qcNotes=$(filterVidispineItemQuery $itemId "metadata" "oly_originalContentQCNotes" "group=Original Content")
export fullFilePath=$(filterVidispineFileInfo $itemId  "uri" "tag=original")
export fullFilePath2=$(echo $fullFilePath | sed -e 's/%20/ /g')
export linkToClip=http://cantemo.olympusat.com/item/$itemId/

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

if [[ $seriesName != "" ]];
  then
    emailSeriesName="Series Name: $seriesName"
  else
    emailSeriesName=""
fi

if [[ $qcNotes != "" ]];
  then
    emailQcNotes="QC Notes: $qcNotes"
  else
    emailQcNotes=""
fi

#Email Body
subject="MAM - English Dubbing - Pending - $title"
body="Hi,

A new original title, [$title], is now Pending English Dubbing.

The base Conform Name for this title will be ["$rightslineContractId"_"$rightslineItemId"].

Title: $title
$titleLanguage
$emailSeriesName
Licensor: $licensor
Content Type: $contentType
$emailQcNotes
Full File Path: $fullFilePath2
Link To Clip: $linkToClip

Please login to the system and review this item.

Thanks

MAM Notify"

#Email Message
message="Subject: $subject\n\n$body"

echo "$datetime - (dubbingEnglish) - Sending Email" >> "$logfile"
echo "$datetime - (dubbingEnglish) - To - $recipient1, $recipient2, $recipient3, $recipient4" >> "$logfile"
echo "$datetime - (dubbingEnglish) - From - $emailFrom" >> "$logfile"
echo "$datetime - (dubbingEnglish) - Subject - $subject" >> "$logfile"
echo "$datetime - (dubbingEnglish) - Body - $body" >> "$logfile"

curl --url 'smtp://smtp-mail.outlook.com:587' \
  --ssl-reqd \
  --mail-from $emailFrom \
  --mail-rcpt $recipient3 --mail-rcpt $recipient4 \
  --user 'notify@olympusat.com:560Village' \
  --tlsv1.2 \
  -T <(echo -e "$message")

echo "$datetime - (dubbingEnglish) - Email Sent" >> "$logfile"

IFS=$saveIFS