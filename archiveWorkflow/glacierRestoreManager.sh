#! /bin/bash

# This script checks for job status and execute restore queue
#       customer-id 500844647317
#       vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive upload ID as an argument and source file location.
# It splits source files into 512 MiB chunks then gather SHA256HASH key for each 1 MiB chunk.
#       Usage: glacierRestoreQueue.sh [folder of files with pending jobs status] [folder of files ready to be queued]

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export jobPendingFolder=$1
export jobQueueFolder=$2
export concurrentLimit=2
export checkInterval=1800
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
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
	if [ ! -z "$(ls -A $jobPendingFolder)" ];
	then
		for jobPendingFile in $jobPendingFolder/*
		do
			jobIdAWS=$(cat "$jobPendingFile" | awk -F "," '{ print $4 }')
			cantemoItemId=$(basename "$jobPendingFile")
			echo "$(date "+%H:%M:%S") (glacierRestoreQueue) - ($cantemoItemId) Checking status for job ID: $jobIdAWS" >> "$logFile"
			leadingJobId=$(echo "$jobIdAWS" | cut -c1)
			if [ "$leadingJobId" == "-" ]
			then
				jobIdAWS='\'"$jobIdAWS"
			fi
			
			#--------------------------------------------------
			# Check retrieval job status in AWS to make sure its output is ready to be downloaded (restore)
			glacierApiResponse=$(aws glacier describe-job --vault-name "$awsVaultName" --account-id "$awsCustomerId" --job-id "$jobIdAWS")
			glacierApiResponseTrimmed=$(echo "$glacierApiResponse" | awk -F " " '{print $11}')
			if [ "$glacierApiResponseTrimmed" == "Succeeded" ];
			then
				restoreProcessId=$(ps awx | grep "/opt/olympusat/scriptsActive/glacierQueue" | grep "/opt/olympusat/scriptsActive/glacierRestore" | grep "/bin/bash" | awk '{ print $5 }')
				mv -f "$jobPendingFile" "$jobQueueFolder"
				echo "$(date "+%H:%M:%S") (glacierRestoreQueue) - ($cantemoItemId) Job is ready and added to the queue" >> "$logFile"
				if [ "$restoreProcessId" == "" ];
				then
					/opt/olympusat/scriptsActive/glacierQueueWorker.sh /opt/olympusat/scriptsActive/glacierRestoreV1.sh "$jobQueueFolder" /opt/olympusat/glacierRestore/restoreActive glacierRestore $concurrentLimit
				fi
				sleep 60
			else
				echo "$(date "+%H:%M:%S") (glacierRestoreQueue) - ($cantemoItemId) Job is not ready to be downloaded" >> "$logFile"
			fi
			#--------------------------------------------------
		done
		# echo "Finished acquiring status on current list of jobs - will check for new jobs in $checkInterval seconds"
		echo "$(date "+%H:%M:%S") (glacierRestoreQueue) - Finished acquiring status on current list of jobs - will check for new jobs in $checkInterval seconds" >> "$logFile"
		sleep $checkInterval
	else
		# echo "There are no new job pending status retrieval - will check for new jobs in $checkInterval seconds"
		echo "$(date "+%H:%M:%S") (glacierRestoreQueue) - There are no new job pending status retrieval - will check for new jobs in $checkInterval seconds" >> "$logFile"
		sleep $checkInterval
	fi
	#--------------------------------------------------
done

exit 0