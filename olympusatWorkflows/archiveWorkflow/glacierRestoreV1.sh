#! /bin/bash

# This script performs multiplart upload to S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive upload ID as an argument and source file location.
# It splits source files into 512 MiB chunks then gather SHA256HASH key for each 1 MiB chunk.
# 	Usage: glacierRestore.sh [filepath with the filename being item ID] [folder of actively working file "token"]

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# . /opt/olympusat/scriptsLibrary/olympusatGlacier.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export tokenFile=$1
export activeRestoreFolder=$2
export cantemoItemId=$(basename "$tokenFile")
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
#--------------------------------------------------
destinationFile=$(cat "$tokenFile" | awk -F "," '{ print $1 }')
destinationFileName=$(basename "$destinationFile")
stagingFile="/Volumes/creative/MAM/zSoftware/stagingRestore/$destinationFileName"
completeFileSize=$(cat "$tokenFile" | awk -F "," '{ print $2 }')
jobIdAWS=$(cat "$tokenFile" | awk -F "," '{ print $4 }')
#--------------------------------------------------

updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $cantemoItemId "oly_restoreDateAWS" $updateValue

mv -f $tokenFile $activeRestoreFolder

if [ -f "$destinationFile" ];
then
	updateVidispineMetadata $cantemoItemId "oly_restoreStatusAWS" "completed - no restore needed - file exists"
	echo "$(date "+%H:%M:%S") (glacierRestore) - ($cantemoItemId) Destination file exists ($destinationFile) - restore process skipped" >> "$logFile"
	sleep 60
else
	updateVidispineMetadata $cantemoItemId "oly_restoreStatusAWS" "Start restoring process"
	echo "$(date "+%H:%M:%S") (glacierRestore) - ($cantemoItemId) Start restoring $jobIdAWS" >> "$logFile"
	# leadingJobId=$(echo "$jobIdAWS" | cut -c1)
	# if [ "$leadingJobId" == "-" ];
	# then
	# 	jobIdAWS='\'"$jobIdAWS"
	# fi
	glacierApiResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier get-job-output --vault-name "$awsVaultName" --account-id "$awsCustomerId" --job-id "$jobIdAWS" "$stagingFile")
	glacierApiResponseTrimmed=$(echo "$glacierApiResponse" | awk -F " " '{print $1}')
	echo "$(date "+%H:%M:%S") (glacierRestore) - ($cantemoItemId) $glacierApiResponse" >> "$logFile"
	echo "$(date "+%H:%M:%S") (glacierRestore) - ($cantemoItemId) Restoring $destinationFile successfully" >> "$logFile"
	echo "$(date "+%H:%M:%S") (glacierRestore) - ($cantemoItemId) Verifying $destinationFile has the correct file size" >> "$logFile"
	sleep 240
	downloadedFileSize=$(stat -c%s "$stagingFile")
	updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
	updateVidispineMetadata $cantemoItemId "oly_restoreDateAWS" $updateValue
	if [[ $downloadedFileSize -eq $completeFileSize ]];
	then
	    mv -f $stagingFile $destinationFile
	    updateVidispineMetadata $cantemoItemId "oly_restoreStatusAWS" "completed - file successfully restored from Glacier"
	else
	    updateVidispineMetadata $cantemoItemId "oly_restoreStatusAWS" "failed - file restored does not match the original file"
fi

rm -f $activeRestoreFolder/$cantemoItemId

exit 0