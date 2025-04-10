#! /bin/bash

# This script performs multiplart upload to S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
# PREREQUISITE: This script must receive upload ID as an argument and source file location.
# It splits source files into 512 MiB chunks then gather SHA256HASH key for each 1 MiB chunk.
# 	Usage: glacierMultiArch.sh [filepath with the filename being item ID] [folder of actively working file "token"] [path to temporary folder]

# System requirements: This script will only run in LINUX but not MacOS (because hash openssl)

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
. /opt/olympusat/scriptsLibrary/olympusatChunkHash.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export tokenFile=$1
export activeArchiveFolder=$2
export uploadId=$(basename "$tokenFile")
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
# export temporaryFolder="/Volumes/Temp/glacierStage"
export temporaryFolder=$3
# export renameFolder="/proxies/portal-rename"
export chunkSizeExponential=19
#--------------------------------------------------
sourceFile=$(filterVidispineFileInfo $uploadId "uri" "tag=original" | sed -e 's/%20/ /g' | sed -e 's/%23/\#/g')
sourceTitle=$(filterVidispineItemMetadata $uploadId "metadata" "title")
chunksCount=0
chunkByteSize=$((1024*(2**$chunkSizeExponential)))
sourceFileName=$(basename "$sourceFile")
sourceFileExtension=$(echo $sourceFileName | awk -F "." '{print $2}')
destinationTempFile="$temporaryFolder/$uploadId/$uploadId.$sourceFileExtension"
# sourceFilePath=$(dirname "$sourceFile")
# sourceFileSize=$(stat -c%s "$sourceFile")
archiveDescription=$(echo $sourceTitle,,$uploadId)
#--------------------------------------------------

mv -f $tokenFile $activeArchiveFolder

#-------------------------------------------------- Copy file into temporary folder
mkdir -p "$temporaryFolder"/"$uploadId"
mkdir -p "$temporaryFolder"/"$uploadId"/Chunk_all
cp -f "$sourceFile" "$destinationTempFile"
sleep 10
sourceFileSize=$(stat -c%s "$destinationTempFile")
echo "Source file - $destinationTempFile"
echo "File size - $sourceFileSize"
#-------------------------------------------------- End copying file to temporary folder

if [ $sourceFileSize -lt $chunkByteSize ];
then
	# echo "$(date "+%H:%M:%S") (glacierSingleArch) - ($uploadId) Start processing $sourceFile ($sourceFileSize bytes) as a single upload" >> "$logFile"
	# updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
	# updateVidispineMetadata $uploadId "oly_archiveDateAWS" $updateValue
	# updateVidispineMetadata $uploadId "oly_archiveStatusAWS" "in progress - archiving as a single upload"
	# httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier upload-archive --account-id "$awsCustomerId" --vault-name "$awsVaultName" --body "$destinationTempFile" --archive-description "$archiveDescription")
	echo "/usr/local/aws-cli/v2/current/dist/aws glacier upload-archive --account-id "$awsCustomerId" --vault-name "$awsVaultName" --body "$destinationTempFile" --archive-description "$archiveDescription
	# awsArchiveId=$(echo "$httpResponse" | awk -F " " '{print $1}')
	# echo "$(date "+%H:%M:%S") (glacierSingleArch) - ($uploadId)   Completing single upload process." >> "$logFile"
else
	totalChunkCount=$(( $sourceFileSize/$chunkByteSize ))
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId) Start processing $sourceFile ($sourceFileSize bytes) with $chunkByteSize byte chunks" >> "$logFile"

	#-------------------------------------------------- Get Job ID from AWS and set it in Cantemo oly_archiveIdAWS
	# httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier initiate-multipart-upload --account-id "$awsCustomerId" --archive-description "$archiveDescription" --part-size $chunkByteSize --vault-name "$awsVaultName")
	archiveDescriptionTrunc=$(echo "$archiveDescription" | tr -dc '[:alnum:]_ ,\n\r')
	echo "/usr/local/aws-cli/v2/current/dist/aws glacier initiate-multipart-upload --account-id "$awsCustomerId" --archive-description \""$archiveDescriptionTrunc"\" --part-size "$chunkByteSize" --vault-name "$awsVaultName
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId)   AWS Initiate Response is $httpResponse" >> "$logFile"
	# awsJobId=$(echo $httpResponse | awk -F " " '{print $2}')
	# awsJobId="Z0vF67TUjlqj9D5bhhF7U3UMEhZmm8ymWZ_EXj7iMGZqKTRkvLc9ab9Z-5xKOA1W-pvcl1whXvtsvrqcs-KNiWBUstni"
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId)   /usr/local/aws-cli/v2/current/dist/aws glacier initiate-multipart-upload --account-id $awsCustomerId --archive-description $uploadId --part-size $chunkByteSize --vault-name $awsVaultName" >> "$logFile"
	# updateVidispineMetadata $uploadId "oly_archiveIdAWS" $awsJobId
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId)   Archive session has been created with ID $awsJobId" >> "$logFile"
	# updateVidispineMetadata $uploadId "oly_archiveStatusAWS" "in progress - copying to temporary folder"
	#-------------------------------------------------- End get Job ID block

	#------------------------------ Log and update Cantemo Metadata
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId)   Finish copying file to $temporaryFolder" >> "$logFile"
	# updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
	# updateVidispineMetadata $uploadId "oly_archiveDateAWS" $updateValue
	#------------------------------ End log

	# cd "$temporaryFolder"/"$uploadId"
	# chunkList=$(echo "$temporaryFolder"/"$uploadId"/"$uploadId"_list.txt)
	# split -d -a 3 --byte=$chunkByteSize --verbose "$destinationTempFile" "$uploadId"_ > "$chunkList"
	# iCounter=0
	# chunkTreeHash="none"
	
	#------------------------------ Process and complete multi-part upload
	# cd "$temporaryFolder"/"$uploadId"/Chunk_all
	# completeTreeHash=$(createTreeHash "$temporaryFolder" "$uploadId" "all" "$chunksCount" "$uploadId")
	# if [ "$leadingAwsJobId" == "-" ];
	# then
	# 	httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier complete-multipart-upload --upload-id "\\$awsJobId" --checksum $completeTreeHash --archive-size $sourceFileSize --account-id "$awsCustomerId" --vault-name "$awsVaultName")
	# else
	# httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws glacier complete-multipart-upload --upload-id="$awsJobId" --checksum $completeTreeHash --archive-size $sourceFileSize --account-id "$awsCustomerId" --vault-name "$awsVaultName")
	# fi
	# awsArchiveId=$(echo "$httpResponse" | awk -F " " '{print $1}')
	#------------------------------ Log and update Cantemo Metadata
	# echo "$(date "+%H:%M:%S") (glacierMultiArch) - ($uploadId)   Completing multi-part upload process with hash $completeTreeHash" >> "$logFile"
	# cd "$temporaryFolder"
	# rm -fR "$temporaryFolder"/"$uploadId"
fi

#------------------------------ Update Cantemo Metadata
# updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
# updateVidispineMetadata $uploadId "oly_archiveDateAWS" $updateValue
# if [ "$awsArchiveId" == "" ];
# then
# 	updateValue="failed"
# else
# 	updateValue="completed"
# fi
# updateVidispineMetadata $uploadId "oly_archiveStatusAWS" $updateValue
# echo "$(date "+%H:%M:%S") (glacierSummary) - ($uploadId)   AWS Archive ID: $awsArchiveId" >> "$logFile"
# updateValue="$sourceFile,$sourceFileSize,$awsArchiveId"
# updateVidispineMetadata $uploadId "oly_archiveIdAWS" $updateValue
#------------------------------

#------------------------------ Move completed token file to indicate that this archive job is done
# rm -f "$activeArchiveFolder/$uploadId"

exit 0
