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
    export recipient1=rsims@olympusat.com
    export recipient2=kkanjanapitak@olympusat.com
    export recipient3=mamAdmin@olympusat.com
    export recipient4=amorales@olympusat.com
    export recipient5=srusso@olympusat.com

    # Sending email address
    export emailFrom=notify@olympusat.com

    # List of Items
    listOfItems=cat $newItemFileDestination

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - List of Items {$listOfItems}" >> "$logfile"

    # Email Body
    subject="MAM - New Items Ingested - $mydate"
    body="Hi,

    The following list of items have been ingested into Cantemo today.

    $listOfItems

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

    #curl --url 'smtp://smtp-mail.outlook.com:587' \
    #--ssl-reqd \
    #--mail-from $emailFrom \
    #--mail-rcpt $recipient3 --mail-rcpt $recipient4 \
    #--user 'notify@olympusat.com:560Village' \
    #--tlsv1.2 \
    #-T <(echo -e "$message")

else
    # newItemFileDestination file DOES NOT exist - continuing with script/workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - newItemFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
fi

IFS=$saveIFS
