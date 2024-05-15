#! /bin/bash

# This script checks for archive token files and execute archive queue
#       customer-id 500844647317
#       vault-name olympusatMamGlacier
# 
#       Usage: glacierArchiveQueue.sh [folder of token files in the queue] [folder of active token files]

# System requirements: This script will only run in LINUX and MacOS)

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export jobQueueFolder=$1
export jobActiveFolder=$2
export concurrentLimit=2
export checkInterval=1800
export myDate=$(date "+%Y-%m-%d")
export logArchiveDate=$(date "+%Y-%m-%d" -d "14 day ago")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
# export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
#--------------------------------------------------
noProcessExit="false"
logFile="/opt/olympusat/logs/glacier-$myDate.log"
#--------------------------------------------------

while [ "$noProcessExit" == "false" ]
do
	#--------------------------------------------------
	# Check to see if we need to start a new log file
	newDate=$(date "+%Y-%m-%d")
	if [ "$myDate" != "$newDate" ];
	then
		logFile="/opt/olympusat/logs/glacier-$newDate.log"
	fi
	#--------------------------------------------------
	
	#--------------------------------------------------
	# Only run the actions if the folder is NOT empty
	if [ ! -z "$(ls -A $jobQueueFolder)" ];
	then
		for jobQueueFile in $jobQueueFolder/*
		do
			cantemoItemId=$(basename "$jobQueueFile")
			echo "$(date "+%H:%M:%S") (glacierArchiveQueue) - ($cantemoItemId) New item in archive queue" >> "$logFile"
			archiveProcessId=$(ps awx | grep "/opt/olympusat/scriptsActive/glacierQueue" | grep "/opt/olympusat/scriptsActive/glacierMultiPart" | grep "/bin/bash" | awk '{ print $5 }')
			if [ "$archiveProcessId" == "" ];
			then
				/opt/olympusat/scriptsActive/glacierQueueWorker.sh /opt/olympusat/scriptsActive/glacierMultiPartV4.sh "$jobQueueFolder" "$jobActiveFolder" glacierArchive $concurrentLimit
				sleep 60
			fi
		done
		# echo "Finished adding new item to archive queue - will check for new items in $checkInterval seconds"
		echo "$(date "+%H:%M:%S") (glacierArchiveQueue) - Finished adding new item to archive queue - will check for new items in $checkInterval seconds" >> "$logFile"
		sleep $checkInterval
	else
		# echo "There are no new job in archive queue - will check for new jobs in $checkInterval seconds"
		echo "$(date "+%H:%M:%S") (glacierArchiveQueue) - There are no new job in archive queue - will check for new jobs in $checkInterval seconds" >> "$logFile"
		sleep $checkInterval
	fi
	#--------------------------------------------------
done

exit 0