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
notificationType="$1"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Workflow Triggered - Check Notification Type {$notificationType}" >> "$logfile"

# Check notificationType Variable
if [[ "$notificationType" == "newItem" ]];
then
    # notificationType is 'newItem'-continue with workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - New Item Workflow Triggered - Check for List to Send Email" >> "$logfile"

    newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"

    # Check newItemFileDestination Variable
    if [[ -e "$newItemFileDestination" ]];
    then
        # newItemFileDestination file exists - continuing with script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - newItemFileDestination file exists - continuing with script/workflow" >> "$logfile"

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
        export emailFrom=notify@olympusat.com

        # Email Body
        subject="MAM - New Items Ingested - $mydate"
        body="Hi,
    
The following attached list of items have been ingested into Cantemo today.
    
Please login to the system and review these items.
    
Thanks
    
MAM Notify"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - From - $emailFrom" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Subject - $subject" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Body - [$(echo $body)]" >> "$logfile"

        # Setup to send email with attachment
        sesSubject=$(echo $subject) 
        sesMessage=$body
        sesFile=$(echo $newItemFileDestination)
        sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

        curl --url 'smtp://smtp-mail.outlook.com:587' \
        --ssl-reqd  \
        --mail-from $emailFrom \
        --mail-rcpt $recipient1 --mail-rcpt $recipient2 \
        --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
        -F '=(;type=multipart/mixed' \
        -F "=$sesMessage;type=text/plain" \
        -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
        -F '=)' \
        -H "Subject: $sesSubject"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Email Sent Successfully" >> "$logfile"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - Moving newItem csv to zCompleted folder" >> "$logfile"

        mv "$newItemFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - New Item Email Notification Process Completed" >> "$logfile"

    else
        # newItemFileDestination file DOES NOT exist - continuing with script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - newItemFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
    fi
else
    # notificationType is NOT 'newItem'-exiting script
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - notificationType is NOT 'newItem' - exiting script/workflow" >> "$logfile"
fi

IFS=$saveIFS
