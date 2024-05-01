#! /bin/bash

# This script performs archive-retrieval request to S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: glacierRequestRestore.sh [Item ID]

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
export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
export restorePendingStatus="/opt/olympusat/glacierRestore/restorePendingStatus/"
untrimmedArchiveIdAWS=$(filterVidispineItemMetadata $itemId "metadata" "oly_archiveIdAWS")
archiveIdAWS=$(echo $untrimmedArchiveIdAWS | awk -F "," '{print $3}')
#--------------------------------------------------

#------------------------------ Initiate archive-retrieval job
#echo "$(date "+%H:%M:%S") (glacierRestore) - ($itemId) Restore process is requested in Cantemo" >> "$logFile"
httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier initiate-job --account-id "$awsCustomerId" --vault-name "$awsVaultName" --job-parameters="{\"Type\":\"archive-retrieval\",\"Tier\":\"Bulk\",\"ArchiveId\":\"$archiveIdAWS\"}")
jobRestoreId=$(echo "$httpResponse" | awk -F " " '{print $1}')
#echo "$(date "+%H:%M:%S") (glacierRestore) - ($itemId) Restore job initiate with $jobRestoreId" >> "$logFile"
echo "$untrimmedArchiveIdAWS,$jobRestoreId" > "$restorePendingStatus$itemId"
#------------------------------ End initiate

#------------------------------ Log and update Cantemo Metadata
updateVidispineMetadata $itemId "oly_restoreStatusAWS" "in progress - restore job initiated"
updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $itemId "oly_restoreDateAWS" $updateValue
#------------------------------ End log

exit 0
