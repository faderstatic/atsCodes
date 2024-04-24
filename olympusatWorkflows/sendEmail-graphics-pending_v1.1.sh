#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger an email to be sent via SMTP Server with email body built in shell script
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/02/2024
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
logfile="/opt/olympusat/logs/sendEmail-qcPending-$mydate.log"

#SMTP Server Settings
#export url=smtp://smtp-mail.outlook.com:587
#export user=notify@olympusat.com:560Village

#Recipient email addresses
export recipient1=design@olympusat.com
export recipient2=mamAdmin@olympusat.com
export recipient3=rsims@olympusat.com
export recipient4=kkanjanapitak@olympusat.com
export recipient5=pablo@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export titleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
export titleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
export licensor=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensor")
export contentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
export rightslineContractId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineContractId")
export rightslineItemId=$(filterVidispineItemMetadata $itemId "metadata" "oly_rightslineItemId")
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

#Email Body
subject="MAM - Graphics - Pending - $title"
body="Hi,

A new original title, [$title], is now available in the system and Graphics Status is Pending.

The base Conform Name for this title will be ["$rightslineContractId"_"$rightslineItemId"].

Title: $title
$titleLanguage
Licensor: $licensor
Content Type: $contentType
Full File Path: $fullFilePath2
Link To Item: $linkToClip

Please login to the system and review this item.

Thanks

MAM Notify"

#Email Message
message="Subject: $subject\n\n$body"

echo "$datetime - (graphics) - TitleEs - $titleEs" >> "$logfile"
echo "$datetime - (graphics) - TitleEn - $titleEn" >> "$logfile"
echo "$datetime - (graphics) - Rightsline Contract ID - $rightslineContractId" >> "$logfile"
echo "$datetime - (graphics) - Rightsline Item ID - $rightslineItemId" >> "$logfile"
echo "$datetime - (graphics) - Sending Email" >> "$logfile"
echo "$datetime - (graphics) - To - $recipient1, $recipient2, $recipient3, $recipient4" >> "$logfile"
echo "$datetime - (graphics) - From - $emailFrom" >> "$logfile"
echo "$datetime - (graphics) - Subject - $subject" >> "$logfile"
echo "$datetime - (graphics) - Body - $body" >> "$logfile"

curl --url 'smtp://smtp-mail.outlook.com:587' \
  --ssl-reqd \
  --mail-from $emailFrom \
  --mail-rcpt $recipient1 --mail-rcpt $recipient2 \
  --user 'notify@olympusat.com:560Village' \
  --tlsv1.2 \
  -T <(echo -e "$message")

echo "$datetime - (graphics) - Email Sent" >> "$logfile"

IFS=$saveIFS