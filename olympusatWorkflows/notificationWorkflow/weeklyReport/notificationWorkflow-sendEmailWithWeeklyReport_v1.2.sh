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
export mydate2=$(date -d "$mydate - 1 day" +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/notificationWorkflow-$mydate.log"
notificationType="$1"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - Workflow Triggered - Check Notification Type {$notificationType}" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - mydate [$mydate] - mydate2 [$mydate2]" >> "$logfile"

# Check notificationType Variable
if [[ "$notificationType" == "contentMissingMetadata" ]];
then
    # notificationType is 'contentMissingMetadata'-continue with workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - New Content Missing Metadata Workflow Triggered - Check for List to Send Email" >> "$logfile"

    contentMissingMetadataFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/contentMissingMetadata/contentMissingMetadata-$mydate.csv"
    contentMissingMetadataFileDestination2="/opt/olympusat/resources/emailNotificationWorkflow/contentMissingMetadata/contentMissingMetadata-$mydate2.csv"

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - fileDestination [$contentMissingMetadataFileDestination]" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - fileDestination2 [$contentMissingMetadataFileDestination2]" >> "$logfile"

    # Check contentMissingMetadataFileDestination Variable
    if [[ -e "$contentMissingMetadataFileDestination" || -e "$contentMissingMetadataFileDestination2" ]];
    then
        # contentMissingMetadataFileDestination file exists - continuing with script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - contentMissingMetadataFileDestination file exists - continuing with script/workflow" >> "$logfile"

        if [[ -e "$contentMissingMetadataFileDestination" ]];
        then
            contentMissingMetadataFileDestination=$(echo $contentMissingMetadataFileDestination)
        else
            if [[ -e "$contentMissingMetadataFileDestination2" ]];
            then
                contentMissingMetadataFileDestination=$(echo $contentMissingMetadataFileDestination2)
            fi
        fi

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - Final fileDestination [$contentMissingMetadataFileDestination]" >> "$logfile"

        # Recipient email addresses
        export recipient1=mamAdmin@olympusat.com
        export recipient2=srusso@olympusat.com
        export recipient3=echavez@olympusat.com
        export recipient4=hflores@olympusat.com
        export recipient5=bgross@olympusat.com
        export recipient6=rvanerven@olympusat.com
        export recipient7=rsims@olympusat.com
        export recipient8=kkanjanapitak@olympusat.com
        export recipient9=amorales@olympusat.com

        # Sending email address
        export emailFrom=notify@olympusat.com

        # Email Body
        subject="MAM - Content Missing Metadata - Weekly Report - $mydate"
        body="Hi,

This is a Weekly Report that checks if there are any items in the 'New Content Missing Metadata' or 'Conform Files Missing Metadata' Saved Searches for any items still missing metadata.

The following attached list of items in Cantemo require metadata in order to move to the next stage in the process.

You may find items in one of the following Saved Searches

'New Content Missing Metadata'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-318/?search_id=2232

'Conform Files Missing Metadata'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-317/?search_id=1695

For Legacy Original Raw Master Content, you may need to set with Rightsline Item ID & import Rightsline Legacy Info. You may find those items in the following Saved Search
'Legacy Original-Needs Manual Input-Rightsline IDs
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-347/?search_id=2173

***NOTE***: You must be on the Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
    
Please login to the system and review these items as soon as possible.
    
Thanks
    
MAM Notify"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - From - $emailFrom" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Subject - $subject" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Body - [$(echo $body)]" >> "$logfile"
        
        # Setup to send email with attachment
        sesSubject=$(echo $subject) 
        sesMessage=$body
        sesFile=$(echo $contentMissingMetadataFileDestination)
        sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

        curl --url 'smtp://smtp-mail.outlook.com:587' \
        --ssl-reqd  \
        --mail-from $emailFrom \
        --mail-rcpt $recipient1 --mail-rcpt $recipient2 --mail-rcpt $recipient3 --mail-rcpt $recipient4 --mail-rcpt $recipient5 --mail-rcpt $recipient6 \
        --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
        -F '=(;type=multipart/mixed' \
        -F "=$sesMessage;type=text/plain" \
        -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
        -F '=)' \
        -H "Subject: $sesSubject"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Email Sent Successfully" >> "$logfile"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Moving contentMissingMetadata csv to zCompleted folder" >> "$logfile"

        mv "$contentMissingMetadataFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - New Content Missing Metadata Email Notification Process Completed" >> "$logfile"

    else
        # contentMissingMetadataFileDestination file DOES NOT exist-exiting script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - contentMissingMetadataFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
    fi
else
    # notificationType is NOT supported-exiting script/workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - notificationType is NOT supported - exiting script/workflow" >> "$logfile"    
fi

IFS=$saveIFS
