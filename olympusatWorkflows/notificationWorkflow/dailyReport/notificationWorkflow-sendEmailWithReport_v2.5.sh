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
logfile="/opt/olympusat/logs/notificationWorkflow-$mydate.log"
notificationType="$1"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - Workflow Triggered - Check Notification Type {$notificationType}" >> "$logfile"

# Check notificationType Variable
if [[ "$notificationType" == "newItem" ]];
then
    # notificationType is 'newItem'-continue with workflow
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - New Item Workflow Triggered - Check for List to Send Email" >> "$logfile"

    newItemFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/newItem/newItemWorkflow-$mydate.csv"

    # Check newItemFileDestination Variable
    if [[ -e "$newItemFileDestination" ]];
    then
        # newItemFileDestination file exists - continuing with script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - newItemFileDestination file exists - continuing with script/workflow" >> "$logfile"

        # Recipient email addresses
        export recipient1=mamAdmin@olympusat.com
        export recipient2=amorales@olympusat.com
        export recipient3=srusso@olympusat.com
        export recipient4=hflores@olympusat.com
        export recipient5=echavez@olympusat.com
        export recipient6=rsims@olympusat.com
        export recipient7=kkanjanapitak@olympusat.com

        # Sending email address
        export emailFrom=notify@olympusat.com

        # Email Body
        subject="MAM - New Items Ingested - $mydate"
        body="Hi,

The following attached list of items have been ingested into Cantemo today and may require metadata in order to move to the next stage in the process.

You may find items in one of the following Saved Searches

'New Content Missing Metadata'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-318/?search_id=2232

'Conform Files Missing Metadata'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-317/?search_id=1695

For Legacy Original Raw Master Content, you may need to set with Rightsline Item ID & import Rightsline Legacy Info. You may find those items in the following Saved Search
'Legacy Original-Needs Manual Input-Rightsline IDs
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-347/?search_id=2173

***NOTE***: You must be on the Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
    
Please login to the system and review these items.
    
Thanks
    
MAM Notify"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - From - $emailFrom" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - Subject - $subject" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - Body - [$(echo $body)]" >> "$logfile"

        # Setup to send email with attachment
        sesSubject=$(echo $subject) 
        sesMessage=$body
        sesFile=$(echo $newItemFileDestination)
        sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

        curl --url 'smtp://smtp-mail.outlook.com:587' \
        --ssl-reqd  \
        --mail-from $emailFrom \
        --mail-rcpt $recipient1 --mail-rcpt $recipient3 --mail-rcpt $recipient4 --mail-rcpt $recipient5 \
        --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
        -F '=(;type=multipart/mixed' \
        -F "=$sesMessage;type=text/plain" \
        -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
        -F '=)' \
        -H "Subject: $sesSubject"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - Email Sent Successfully" >> "$logfile"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - Moving newItem csv to zCompleted folder" >> "$logfile"

        mv "$newItemFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

        sleep 2

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-newItem) - New Item Email Notification Process Completed" >> "$logfile"

    else
        # newItemFileDestination file DOES NOT exist-exiting script/workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - newItemFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
    fi
else
    if [[ "$notificationType" == "originalContentQCPending" ]];
    then
        # notificationType is 'originalContentQCPending'-continue with workflow
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Original Content QC Pending Workflow Triggered - Check for List to Send Email" >> "$logfile"

        originalContentQCPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/originalContentQCPending/originalContentQCPending-$mydate.csv"

        # Check originalContentQCPendingFileDestination Variable
        if [[ -e "$originalContentQCPendingFileDestination" ]];
        then
            # originalContentQCPendingFileDestination file exists - continuing with script/workflow
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - originalContentQCPendingFileDestination file exists - continuing with script/workflow" >> "$logfile"

            # Recipient email addresses
            export recipient1=qcmanagement@olympusat.com
            export recipient2=srusso@olympusat.com
            export recipient3=echavez@olympusat.com
            export recipient4=mamAdmin@olympusat.com
            export recipient5=rsims@olympusat.com
            export recipient6=kkanjanapitak@olympusat.com

            # Sending email address
            export emailFrom=notify@olympusat.com

            # Email Body
            subject="MAM - Original Content QC - Pending - $mydate"
            body="Hi,
   
The following attached list of original content items are now Pending Original Content QC.

You can find all of the items in the following Saved Searches

For Legacy Content - 'Original Legacy Content QC-Pending'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-358/?search_id=2434

For New Content - 'Original Content QC-Pending'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-246/?search_id=1503

***NOTE***: You must be on the Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
        
Please login to the system, review & QC these items.

***NOTE***: If the content is 'legacyContent', please check with IT to make sure the files are deleted from the Backup before marking as Approved, as they will be Archived via Cantemo after Approving.
        
Thanks
        
MAM Notify"

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - From - $emailFrom" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Subject - $subject" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Body - [$(echo $body)]" >> "$logfile"

            # Setup to send email with attachment
            sesSubject=$(echo $subject) 
            sesMessage=$body
            sesFile=$(echo $originalContentQCPendingFileDestination)
            sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

            curl --url 'smtp://smtp-mail.outlook.com:587' \
            --ssl-reqd  \
            --mail-from $emailFrom \
            --mail-rcpt $recipient1 --mail-rcpt $recipient2 --mail-rcpt $recipient3 --mail-rcpt $recipient4 \
            --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
            -F '=(;type=multipart/mixed' \
            -F "=$sesMessage;type=text/plain" \
            -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
            -F '=)' \
            -H "Subject: $sesSubject"

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Email Sent Successfully" >> "$logfile"

            sleep 2

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Moving originalContentQCPending csv to zCompleted folder" >> "$logfile"

            mv "$originalContentQCPendingFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

            sleep 2

            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-originalContentQCPending) - Original Content QC Pending Email Notification Process Completed" >> "$logfile"

        else
            # originalContentQCPendingFileDestination file DOES NOT exist-exiting script/workflow
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - originalContentQCPendingFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
        fi
    else
        if [[ "$notificationType" == "finalQCPending" ]];
        then
            # notificationType is 'finalQCPending'-continue with workflow
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Final QC Pending Workflow Triggered - Check for List to Send Email" >> "$logfile"

            finalQCPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/finalQCPending/finalQCPending-$mydate.csv"

            # Check finalQCPendingFileDestination Variable
            if [[ -e "$finalQCPendingFileDestination" ]];
            then
                # finalQCPendingFileDestination file exists - continuing with script/workflow
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - finalQCPendingFileDestination file exists - continuing with script/workflow" >> "$logfile"

                # Recipient email addresses
                export recipient1=qcmanagement@olympusat.com
                export recipient2=srusso@olympusat.com
                export recipient3=echavez@olympusat.com
                export recipient4=mamAdmin@olympusat.com
                export recipient5=rsims@olympusat.com
                export recipient6=kkanjanapitak@olympusat.com

                # Sending email address
                export emailFrom=notify@olympusat.com

                # Email Body
                subject="MAM - Final QC - Pending - $mydate"
                body="Hi,
      
The following attached list of conform content items are now Pending Final QC.

You can find all of the items in the following Saved Searches

'Final QC-Pending'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-224/?search_id=972

***NOTE***: You must be on the Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
            
Please login to the system, review & QC these items.
            
Thanks
            
MAM Notify"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - From - $emailFrom" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Subject - $subject" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Body - [$(echo $body)]" >> "$logfile"

                # Setup to send email with attachment
                sesSubject=$(echo $subject) 
                sesMessage=$body
                sesFile=$(echo $finalQCPendingFileDestination)
                sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

                curl --url 'smtp://smtp-mail.outlook.com:587' \
                --ssl-reqd  \
                --mail-from $emailFrom \
                --mail-rcpt $recipient1 --mail-rcpt $recipient2 --mail-rcpt $recipient3 --mail-rcpt $recipient4 \
                --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
                -F '=(;type=multipart/mixed' \
                -F "=$sesMessage;type=text/plain" \
                -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
                -F '=)' \
                -H "Subject: $sesSubject"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Email Sent Successfully" >> "$logfile"

                sleep 2

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Moving finalQCPending csv to zCompleted folder" >> "$logfile"

                mv "$finalQCPendingFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

                sleep 2

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-finalQCPending) - Final QC Pending Email Notification Process Completed" >> "$logfile"

            else
                # finalQCPendingFileDestination file DOES NOT exist-exiting script/workflow
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - finalQCPendingFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
            fi
        else
            if [[ "$notificationType" == "markedToBeDeleted" ]];
            then
                # notificationType is 'markedToBeDeleted'-continue with workflow
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Marked to be Deleted Workflow Triggered - Check for List to Send Email" >> "$logfile"

                markedToBeDeletedFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/markedToBeDeleted/markedToBeDeleted-$mydate.csv"

                # Check markedToBeDeletedFileDestination Variable
                if [[ -e "$markedToBeDeletedFileDestination" ]];
                then
                    # markedToBeDeletedFileDestination file exists - continuing with script/workflow
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - markedToBeDeletedFileDestination file exists - continuing with script/workflow" >> "$logfile"

                    # Recipient email addresses
                    export recipient1=mamAdmin@olympusat.com
                    export recipient2=rsims@olympusat.com
                    export recipient3=kkanjanapitak@olympusat.com

                    # Sending email address
                    export emailFrom=notify@olympusat.com

                    # Email Body
                    subject="MAM - Content Marked to be Deleted - $mydate"
                    body="Hi,
        
The following attached list of items have been Marked to be Deleted.

You can find all of the items in the following Saved Searches

'Content User Marked as to be Deleted'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-21/?search_id=3126

***NOTE***: You must be on the Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
                
Please login to the system, review & either delete these items or remove metadata marking as to be deleted.
                
Thanks
                
MAM Notify"

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - From - $emailFrom" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Subject - $subject" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Body - [$(echo $body)]" >> "$logfile"

                    # Setup to send email with attachment
                    sesSubject=$(echo $subject) 
                    sesMessage=$body
                    sesFile=$(echo $markedToBeDeletedFileDestination)
                    sesMIMEType=`file --mime-type "$sesFile" | sed 's/.*: //'`

                    curl --url 'smtp://smtp-mail.outlook.com:587' \
                    --ssl-reqd  \
                    --mail-from $emailFrom \
                    --mail-rcpt $recipient1 \
                    --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
                    -F '=(;type=multipart/mixed' \
                    -F "=$sesMessage;type=text/plain" \
                    -F "file=@$sesFile;type=$sesMIMEType;encoder=base64" \
                    -F '=)' \
                    -H "Subject: $sesSubject"

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Email Sent Successfully" >> "$logfile"

                    sleep 2

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Moving markedToBeDeleted csv to zCompleted folder" >> "$logfile"

                    mv "$markedToBeDeletedFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

                    sleep 2

                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-markedToBeDeleted) - Marked to be Deleted Email Notification Process Completed" >> "$logfile"

                else
                    # markedToBeDeletedFileDestination file DOES NOT exist-exiting script/workflow
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - markedToBeDeletedFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
                fi
            else
                if [[ "$notificationType" == "rtcReviewPending" ]];
                then
                    # notificationType is 'rtcReviewPending'-continue with workflow
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - RTC Review Pending Workflow Triggered - Check for List to Send Email" >> "$logfile"

                    rtcReviewPendingFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/rtcReviewPending/rtcReviewPending-$mydate.csv"

                    # Check rtcReviewPendingFileDestination Variable
                    if [[ -e "$rtcReviewPendingFileDestination" ]];
                    then
                        # rtcReviewPendingFileDestination file exists - continuing with script/workflow
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - rtcReviewPendingFileDestination file exists - continuing with script/workflow" >> "$logfile"

                        # Recipient email addresses
                        export recipient1=cmonterrey@olympusat.com
                        export recipient2=mamAdmin@olympusat.com
                        export recipient3=rsims@olympusat.com
                        export recipient4=kkanjanapitak@olympusat.com

                        # Sending email address
                        export emailFrom=notify@olympusat.com

                        # Email Body
                        subject="MAM - RTC Review - Pending - $mydate"
                        body="Hola,

Adjunto se encuentra la lista de elementos de contenido pendientes de revisión para RTC.

Puede encontrar todos los elementos en la siguiente Búsqueda Guardada en el Portal Web de Cantemo

Nombre de la Búsqueda Guardada - 'RTC Review-Pending'
Enlace a la Búsqueda Guardada - https://cantemo.olympusat.com/search/#/savedsearch/OLY-397/?search_id=4936

***NOTA***: Debe estar en la Red de Oficina de Olympusat, ya sea a través de VPN o conectándose de forma remota a una máquina en la Red, para poder acceder al Portal Web de Cantemo.

Inicie sesión en el sistema, verifique y revise estos elementos.

Gracias,

MAM Notify"

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - From - $emailFrom" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - Subject - $subject" >> "$logfile"
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - Body - [$(echo $body)]" >> "$logfile"

                        # Setup to send email with attachment
                        sesSubject=$(echo $subject) 
                        sesMessage=$body
                        sesFile=$(echo $rtcReviewPendingFileDestination)
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

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - Email Sent Successfully" >> "$logfile"

                        sleep 2

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - Moving rtcReviewPending csv to zCompleted folder" >> "$logfile"

                        mv "$rtcReviewPendingFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

                        sleep 2

                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewPending) - RTC Review Pending Email Notification Process Completed" >> "$logfile"

                    else
                        # rtcReviewPendingFileDestination file DOES NOT exist-exiting script/workflow
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - rtcReviewPendingFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
                    fi
                else
                    if [[ "$notificationType" == "rtcReviewCompleted" ]];
                    then
                        # notificationType is 'rtcReviewCompleted'-continue with workflow
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - RTC Review Completed Workflow Triggered - Check for List to Send Email" >> "$logfile"

                        rtcReviewCompletedFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/rtcReviewCompleted/rtcReviewCompleted-$mydate.csv"

                        # Check rtcReviewCompletedFileDestination Variable
                        if [[ -e "$rtcReviewCompletedFileDestination" ]];
                        then
                            # rtcReviewCompletedFileDestination file exists - continuing with script/workflow
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - rtcReviewCompletedFileDestination file exists - continuing with script/workflow" >> "$logfile"

                            # Recipient email addresses
                            export recipient1=dsenderowicz@olympusat.com
                            export recipient2=mamAdmin@olympusat.com
                            export recipient3=rsims@olympusat.com
                            export recipient4=kkanjanapitak@olympusat.com

                            # Sending email address
                            export emailFrom=notify@olympusat.com

                            # Email Body
                            subject="MAM - RTC Review - Completed - $mydate"
                            body="Hi,
                
The following attached list of content items have been reviewed by RTC and they have completed their review.

You can find all of the items in the following Saved Search in Cantemo Web Portal

Saved Search Name - 'RTC Final Review-Completed'
Link to Saved Search - https://cantemo.olympusat.com/search/#/savedsearch/OLY-393/?search_id=4937

***NOTE***: You must be on the Olympusat Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
        
Please login to the system & review these items.
    
Thanks
        
MAM Notify"

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - Sending Email for New Items Ingested into Cantemo Today" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - From - $emailFrom" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - Subject - $subject" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - Body - [$(echo $body)]" >> "$logfile"

                            # Setup to send email with attachment
                            sesSubject=$(echo $subject) 
                            sesMessage=$body
                            sesFile=$(echo $rtcReviewCompletedFileDestination)
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

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - Email Sent Successfully" >> "$logfile"

                            sleep 2

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - Moving rtcReviewCompleted csv to zCompleted folder" >> "$logfile"

                            mv "$rtcReviewCompletedFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

                            sleep 2

                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-rtcReviewCompleted) - RTC Review Completed Email Notification Process Completed" >> "$logfile"

                        else
                            # rtcReviewCompletedFileDestination file DOES NOT exist-exiting script/workflow
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - rtcReviewCompletedFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
                        fi
                    else
                        if [[ "$notificationType" == "prepareForReload" ]];
                        then
                            # notificationType is 'prepareForReload'-continue with workflow
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Prepare For Reload Workflow Triggered - Check for List to Send Email" >> "$logfile"

                            prepareForReloadFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/prepareForReload/prepareForReload-$mydate.csv"

                            # Check prepareForReloadFileDestination Variable
                            if [[ -e "$prepareForReloadFileDestination" ]];
                            then
                                # prepareForReloadFileDestination file exists - continuing with script/workflow
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - prepareForReloadFileDestination file exists - continuing with script/workflow" >> "$logfile"

                                # Recipient email addresses
                                export recipient1=srusso@olympusat.com
                                export recipient2=mamAdmin@olympusat.com
                                export recipient3=rsims@olympusat.com
                                export recipient4=kkanjanapitak@olympusat.com

                                # Sending email address
                                export emailFrom=notify@olympusat.com

                                # Email Body
                                subject="MAM - Prepare For Reload - Initiated - $mydate"
                                body="Hi,
                    
    The following attached list of content items had the 'Prepare For Reload' workflow triggered on them.

    ***NOTE***: You must be on the Olympusat Office Network, either via VPN or remoting into a machine on the Network, in order to access Cantemo Web Portal
        
    Thanks
            
    MAM Notify"

                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Sending Email for Prepare For Reload Items" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - From - $emailFrom" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Subject - $subject" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Body - [$(echo $body)]" >> "$logfile"

                                # Setup to send email with attachment
                                sesSubject=$(echo $subject) 
                                sesMessage=$body
                                sesFile=$(echo $prepareForReloadFileDestination)
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

                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Email Sent Successfully" >> "$logfile"

                                sleep 2

                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Moving prepareForReload csv to zCompleted folder" >> "$logfile"

                                mv "$prepareForReloadFileDestination" "/opt/olympusat/resources/emailNotificationWorkflow/zCompleted/"

                                sleep 2

                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-prepareForReload) - Prepare For Reload Email Notification Process Completed" >> "$logfile"

                            else
                                # prepareForReloadFileDestination file DOES NOT exist-exiting script/workflow
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - prepareForReloadFileDestination file DOES NOT exist - exiting script/workflow" >> "$logfile"
                            fi
                        else
                            # notificationType is NOT supported-exiting script/workflow
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - notificationType is NOT supported - exiting script/workflow" >> "$logfile"
                        fi
                    fi
                fi
            fi
        fi
    fi
fi

IFS=$saveIFS
