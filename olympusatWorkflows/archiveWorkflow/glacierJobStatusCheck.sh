#! /bin/bash

# This script checks for job status
#       customer-id 500844647317
#       vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive upload ID as an argument and source file location.
# It splits source files into 512 MiB chunks then gather SHA256HASH key for each 1 MiB chunk.
#       Usage: glacierJobStatusCheck.sh [folder of files with pending jobs status] [folder of files ready to be queued]

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
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacierRestore-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
#--------------------------------------------------
noProcessExit="false"
#--------------------------------------------------

while [ "$noProcessExit" == "false" ]
do
	for jobPendingFile in $jobPendingFolder/*
	do
		jobIdAWS=$(cat "$jobPendingFile" | awk -F "," '{ print $4 }')
		export cantemoItemId=$(basename "$jobPendingFile")
		echo "$(date "+%H:%M:%S") (glacierJobStatusCheck) - ($cantemoItemId) Checking status for ID: $jobIdAWS" >> "$logFile"
		leadingJobId=$(echo "$jobIdAWS" | cut -c1)
		if [ "$leadingJobId" == "-" ]
		then
			jobIdAWS='\'"$jobIdAWS"
		fi
		glacierApiResponse=$(aws glacier describe-job --vault-name "$awsVaultName" --account-id "$awsCustomerId" --job-id "$jobIdAWS")
		glacierApiResponseTrimmed=$(echo "$glacierApiResponse" | awk -F " " '{print $11}')
		if [ "$glacierApiResponseTrimmed" == "Succeeded" ];
		then
			restoreProcessId=$(ps awx | grep "/opt/olympusat/scriptsActive/glacierQueue" | grep "/opt/olympusat/scriptsActive/glacierRestore" | grep "/bin/bash" | awk '{ print $5 }')
			mv -f "$jobPendingFile" "$jobQueueFolder"
			if [ "$restoreProcessId" == "" ];
			then
				/opt/olympusat/scriptsActive/glacierQueue.sh /opt/olympusat/scriptsActive/glacierRestoreV1.sh "$jobQueueFolder" /opt/olympusat/glacierRestore/restoreActive glacierRestore $concurrentLimit
			fi
			echo "$(date "+%H:%M:%S") (glacierJobStatusCheck) - ($cantemoItemId) Job is ready and added to the queue" >> "$logFile"
			sleep 60
		else
			echo "$(date "+%H:%M:%S") (glacierJobStatusCheck) - ($cantemoItemId) Job is not ready to be downloaded" >> "$logFile"
		fi
	done
	echo "Finished acquiring status on current list of jobs - will check for new jobs in 30 minutes"
	echo "$(date "+%H:%M:%S") (glacierJobStatusCheck) - Finished acquiring status on current list of jobs - will check for new jobs in 30 minutes" >> "$logFile"
	sleep 1800
done

exit 0