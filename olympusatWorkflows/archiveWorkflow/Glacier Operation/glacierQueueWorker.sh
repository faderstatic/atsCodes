#! /bin/bash

# This script maintains archive queue and execute archive jobs for S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: $glacierActionNameQueue.sh [script to execute - full path] [folder location of queue]
#                          [folder location items being worked on] [log file name prefix] [queue limit]
# Note:
#   Files in queue folder are named with item ID's from Cantemo - empty file content.

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#                      It calls glacierMultiPartV3.sh and referenced libraries

#--------------------------------------------------
# External funtions to include
# . /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#------------------------------
# Set some parameters
export scriptToExecute=$1
export queueFolder=$2
export activeFolder=$3
export glacierActionName=$4
export concurrentLimit=$5
export myDate=$(date "+%Y-%m-%d")
export myDateTime=$(date "+%Y%m%d%H%M")
# export awsCustomerId="500844647317"
# export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
export queueListFile="/opt/olympusat/$glacierActionName/Queue$myDateTime-$glacierActionName.txt"
queueListEmpty=false
queueCount=0
#------------------------------

#------------------------------
# Let's start with some logging
echo "$(date "+%H:%M:%S") ($glacierActionName""Queue) - Start processing queue" >> "$logFile"
#------------------------------

#------------------------------
# Let's get the initial list of items
ls -rt $queueFolder > "$queueListFile"
pendingJobCount=$(ls $queueFolder | wc -l)
echo "$(date "+%H:%M:%S") ($glacierActionName""Queue) - There are now $pendingJobCount item(s) in the queue" >> "$logFile"
if [ $pendingJobCount -eq 0 ];
then
    queueListEmpty="true"
else
    queueListEmpty="false"
fi
#------------------------------

#------------------------------
# Initiate action loop
while [ "$queueListEmpty" == "false" ];
do
    #------------------------------
    # Process the current list of queued items
    while read queuedItem;
    do
        #--------------------------------------------------
        # Check to see if we need to start a new log file
        newDate=$(date "+%Y-%m-%d")
        if [ "$myDate" != "$newDate" ];
        then
            logFile="/opt/olympusat/logs/glacier-$newDate.log"
        fi
        #--------------------------------------------------
        
        queueCount=$(ls $activeFolder | wc -l)

        #------------------------------
        # Wait for the queue to become less that allowable limit
        while [ $queueCount -ge $concurrentLimit ];
        do
            echo "$(date "+%H:%M:%S") ($glacierActionName""Queue) - Active jobs for $glacierActionName reaches its limit ($concurrentLimit)" >> "$logFile"
            sleep 300
            queueCount=$(ls $activeFolder | wc -l)
        done
        #------------------------------
        echo "$(date "+%H:%M:%S") ($glacierActionName""Queue) - Start processing $queuedItem" >> "$logFile"
        sourceQueuedItem="$queueFolder/$queuedItem"
        #------------------------------
        # Process item (fire and forget)
        $scriptToExecute $sourceQueuedItem $activeFolder &
        #------------------------------
		sleep 60
    done < $queueListFile

    #------------------------------
    # Update the current queue list incase more items were added
    ls -rt $queueFolder > "$queueListFile"
    #------------------------------
    pendingJobCount=$(ls $queueFolder | wc -l)
    echo "$(date "+%H:%M:%S") ($glacierActionName""Queue) - There are now $pendingJobCount item(s) in the queue" >> "$logFile"

    if [ $pendingJobCount -eq 0 ];
    then
        queueListEmpty="true"
    else
        queueListEmpty="false"
    fi
done
#------------------------------

rm -f $queueListFile

exit 0