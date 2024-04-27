#! /bin/bash

# This application creates archive queue file in a folder determined by the argument
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive item ID as an argument and source file location.
# 	Usage: createQueueFile.sh [Cantemo item] [queue type - archive or restore]
#
# Note:
#   Files in queue folder are named with item ID's from Cantemo - empty file content.
#
# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#                      It calls glacierMultiPartV3.sh and referenced libraries

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#------------------------------
# Set some parameters
export queueType=$2
export cantemoItemId=$1
export myDate=$(date "+%Y-%m-%d")
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
# export awsCustomerId="500844647317"
# export awsVaultName="olympusatMamGlacier"
#------------------------------

#------------------------------
# Get archive ID if available
untrimmedArchiveIdAWS=$(filterVidispineItemMetadata $cantemoItemId "metadata" "oly_archiveIdAWS")
archiveIdAWS=$(echo $untrimmedArchiveIdAWS | awk -F "," '{print $3}')
#------------------------------

case $queueType in
	"Archive")
		cantemoDateField="oly_archiveDateAWS"
		cantemoStatusField="oly_archiveStatusAWS"
		queueFolder="/opt/olympusat/glacierArchive/archiveJobs"
	;;
	"Restore")
		cantemoDateField="oly_restoreDateAWS"
		cantemoStatusField="oly_restoreStatusAWS"
		queueFolder="/opt/olympusat/glacierRestore/restoreJobs"
	;;
esac

#------------------------------
# Let's start with some logging
updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $cantemoItemId $cantemoDateField $updateValue
updateVidispineMetadata $cantemoItemId $cantemoStatusField "in progress - added to queue"
#echo "$(date "+%H:%M:%S") (glacier$queueTypeQueue) - ($itemId) $queueType process is requested in Cantemo" >> "$logFile"
#------------------------------

#------------------------------
# Creating queue file
destinationFile="$queueFolder/$cantemoItemId"
echo $untrimmedArchiveIdAWS > $destinationFile
#------------------------------

exit 0
