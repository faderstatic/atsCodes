#! /bin/bash

# This script performs archive-retrieval request to S3 Glacier for the following account
#	customer-id 500844647317
#	s3-bucket olympusatdeeparch
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: s3DownloadRequest.sh [Item ID]

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export itemId=$1
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsBucketName="olympusatdeeparch"
export logFile="/opt/olympusat/logs/s3-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$itemId/metadata/")
export downloadPendingStatus="/opt/olympusat/s3Download/downloadPendingStatus/"
untrimmedUploadIdAWS=$(filterVidispineItemMetadata $itemId "metadata" "oly_uploadIdAWS")
uploadIdAWS=$(echo $untrimmedUploadIdAWS | awk -F "," '{print $3}')
#--------------------------------------------------

#------------------------------ Initiate archive-retrieval job
echo "$(date "+%H:%M:%S") (s3Download) - ($itemId) Download process is requested in Cantemo" >> "$logFile"
httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws s3api restore-object --bucket "$awsBucketName" --restore-request --job-parameters="{\"Type\":\"archive-retrieval\",\"Tier\":\"Bulk\",\"ArchiveId\":\"$archiveIdAWS\"}")
jobDownloadId=$(echo "$httpResponse" | awk -F " " '{print $1}')
echo "$(date "+%H:%M:%S") (s3Download) - ($itemId) Download job initiate with $jobDownloadId" >> "$logFile"
echo "$untrimmedUploadIdAWS,$jobUploadId" > "$downloadPendingStatus$itemId"
#------------------------------ End initiate

#------------------------------ Log and update Cantemo Metadata
updateVidispineMetadata $itemId "oly_downloadStatusAWS" "in progress - download job initiated"
updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $itemId "oly_downloadDateAWS" $updateValue
#------------------------------ End log

exit 0
