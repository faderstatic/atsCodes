#!/bin/bash

#::***************************************************************************************************************************
#::This shell script to trigger the actual email to send out list
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/08/2024
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

echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Workflow Triggered - Check for List to Send Email with" >> "$logfile"

newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"

# Check Variable
if [[ -e "$newItemFileDestination" ]];
then
    # newItemFileDestination file exists - continuing with script/workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - newItemFileDestination file exists - continuing with script/workflow" >> "$logfile"
    
    # SMTP Server Settings
    #export url=smtp://smtp-mail.outlook.com:587
    #export user=notify@olympusat.com:560Village

    # Recipient email addresses
    export recipient1name="Ryan Sims"
    export recipient1=rsims@olympusat.com
    export recipient2name="Tang Kanjanapitak"
    export recipient2=kkanjanapitak@olympusat.com
    export recipient3name="MAM Admin"
    export recipient3=mamAdmin@olympusat.com
    #export recipient4=amorales@olympusat.com
    #export recipient5=srusso@olympusat.com

    # Sending email address
    export emailFromName=Notify
    export emailFromAddress=notify@olympusat.com

    # List of Items
    #listOfItems=$(cat $newItemFileDestination)
    attachmentFile="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"
    attachmentType=`file --mime-type "$attachmentFile" | sed 's/.*: //'`

    # Email Body
    subject="MAM - New Items Ingested - $mydate"
    body="Hi,

The following attached list of items have been ingested into Cantemo today.

Please login to the system and view these items.

Thanks

MAM Notify"

    # Email Message
    message="Subject: $subject\n\n$body"

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Sending Email" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - From - $emailFrom" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Subject - $subject" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Body - [$body]" >> "$logfile"

    # Setup to send email with just text-no attachment
    #curl --url 'smtp://smtp-mail.outlook.com:587' \
    #--ssl-reqd \
    #--user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
    #--mail-from $emailFromAddress \
    #--mail-rcpt $recipient1 \
    #--tlsv1.2 \
    #-T <(echo -e "$message")

    # Setup to send email with attachment
    sesFromName=$(echo $emailFromName) 
    sesFromAddress=$(echo $emailFromAddress) 
    sesToName=$(echo $recipient2name)
    sesToAddress=$(echo $recipient2) 
    sesSubject=$(echo $subject) 
    sesMessage=$(echo $body) 
    sesFile=$(echo $newItemFileDestination)
    sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

    curl -v --url 'smtp://smtp-mail.outlook.com:587' --ssl-reqd  --mail-from $sesFromAddress --mail-rcpt $sesToAddress --mail-rcpt $recipient1  --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' -F '=(;type=multipart/mixed' -F "=$sesMessage;type=text/plain" -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" -F '=)' -H "Subject: $sesSubject" -H "From: $sesFromName <$sesFromAddress>" -H "To: $sesToName <$sesToAddress>"

else
    # newItemFileDestination file DOES NOT exist - continuing with script/workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - newItemFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
fi

IFS=$saveIFS
