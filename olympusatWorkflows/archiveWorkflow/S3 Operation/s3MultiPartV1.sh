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
export activeUploadFolder=$2
export uploadId=$(basename "$tokenFile")
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
# export awsBucketName="olympusatdeeparch"
export logFile="/opt/olympusat/logs/s3-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
# export temporaryFolder="/Volumes/Temp/glacierStage"
export temporaryFolder="/proxies/portal-s3Temp"
# export renameFolder="/proxies/portal-rename"
export chunkSizeExponential=19
#--------------------------------------------------
sourceFile=$(filterVidispineFileInfo $uploadId "uri" "tag=original" | sed -e 's/%20/ /g' | sed -e 's/%23/\#/g')
sourceTitle=$(filterVidispineItemMetadata $uploadId "metadata" "title")
awsBucketName=$(filterVidispineItemMetadata $uploadId "metadata" "oly_uploadBucketAWSS3")
chunksCount=0
chunkByteSize=$((1024*(2**$chunkSizeExponential))
sourceFileName=$(basename "$sourceFile")
sourceFileExtension=$(echo $sourceFileName | awk -F "." '{print $2}')
s3ConstructFile="/proxies/portal-s3Temp/$uploadId.txt"
destinationTempFile="$temporaryFolder/$uploadId/$sourceFileName"
# sourceFilePath=$(dirname "$sourceFile")
# sourceFileSize=$(stat -c%s "$sourceFile")
archiveDescription=$(echo $sourceTitle,,$uploadId )
archiveDescriptionTrunc=$(echo "$archiveDescription" | tr -dc '[:alnum:]-_ ,\n\r')
#--------------------------------------------------

mv -f $tokenFile $activeUploadFolder

#-------------------------------------------------- Copy file into temporary folder
mkdir -p "$temporaryFolder"/"$uploadId"
mkdir -p "$temporaryFolder"/"$uploadId"/Chunk_all
cp -f "$sourceFile" "$destinationTempFile"
sleep 10
sourceFileSize=$(stat -c%s "$destinationTempFile")
#-------------------------------------------------- End copying file to temporary folder

if [ $sourceFileSize -lt $chunkByteSize ];
then
	echo "$(date "+%H:%M:%S") (s3SingleUpload) - ($uploadId) Start processing $sourceFile ($sourceFileSize bytes) as a single upload" >> "$logFile"
	updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
	updateVidispineMetadata $uploadId "oly_uploadDateAWSS3" $updateValue
	updateVidispineMetadata $uploadId "oly_uploadStatusAWSS3" "in progress - processing as a single upload"
	# aws s3api put-object --bucket "$awsBucketName" --body "$destinationTempFile" --key "$sourceFile"
	httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws s3api put-object --bucket "$awsBucketName" --body "$destinationTempFile" --key "$sourceFileName")
	s3UploadId=$(echo "$httpResponse" | awk -F " " '{print $1}')
	echo "$(date "+%H:%M:%S") (s3SingleUpload) - ($uploadId)   Completing single upload process." >> "$logFile"
else
	totalChunkCount=$(( $sourceFileSize/$chunkByteSize ))
	echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId) Start processing $sourceFile ($sourceFileSize bytes) with $chunkByteSize byte chunks" >> "$logFile"

	#-------------------------------------------------- Get Job ID from AWS and set it in Cantemo oly_uploadIdAWSS3
	httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws s3api create-multipart-upload --bucket "$awsBucketName" --key "$sourceFileName")
	# echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   AWS Initiate Response is $httpResponse" >> "$logFile"
	awsJobId=$(echo $httpResponse | awk -F " " '{print $NF}')
	updateVidispineMetadata $uploadId "oly_uploadIdAWSS3" $awsJobId
	echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   Upload session has been created with ID $awsJobId" >> "$logFile"
	updateVidispineMetadata $uploadId "oly_uploadStatusAWSS3" "in progress - copying to temporary folder"
	#-------------------------------------------------- End get Job ID block

	#------------------------------ Log and update Cantemo Metadata
	echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   Finish copying file to $temporaryFolder" >> "$logFile"
	updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
	updateVidispineMetadata $uploadId "oly_uploadDateAWSS3" $updateValue
	#------------------------------ End log

	cd "$temporaryFolder"/"$uploadId"
	chunkList=$(echo "$temporaryFolder"/"$uploadId"/"$uploadId"_list.txt)
	split -d -a 3 --byte=$chunkByteSize --verbose "$destinationTempFile" "$uploadId"_ > "$chunkList"
	iCounter=0
	chunkTreeHash="none"

	#------------------------------ Start a part Entity Tag contruct file
	echo -en '{\n  "Parts": [\n' > $s3ConstructFile
	#------------------------------

	#------------------------------ Process and archive one chunk at a time
	while read chunkByLine;
	do
		#------------------------------ Moving file to the temporary folder
		chunkToProcess=$(echo $chunkByLine | awk -F "'" '{print $2}')
		#------------------------------ Log and update Cantemo Metadata
		echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   Processing $chunkToProcess" >> "$logFile"
		updateValue="in progress - chunk $iCounter of $totalChunkCount"
		updateVidispineMetadata $uploadId "oly_uploadStatusAWSS3" $updateValue
		#------------------------------ End log
		mkdir -p "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"
		mv -f "$temporaryFolder"/"$uploadId"/"$chunkToProcess" "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"/
		cd "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"/
		#------------------------------ End moving file

		#------------------------------ Calculate byte range of chunk to be archived
		chunkTotalByte=$(stat -c%s "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"/"$chunkToProcess")
		byteStartValue=$(($iCounter*$chunkByteSize))
		if [ $chunkTotalByte -lt $chunkByteSize ];
		then
			byteEndValue=$(($byteStartValue+$chunkTotalByte-1))
		else
			byteEndValue=$(($byteStartValue+$chunkByteSize-1))
		fi
		#------------------------------ End calculate byte range

		#------------------------------ Split file, create hash, delete hash
		hashListFile=$(echo "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"/"$uploadId"_"$iCounter"_list.txt)
		split -d -a 3 --byte=1048576 --verbose "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"/"$chunkToProcess" "$uploadId"_"$iCounter"_ > $hashListFile
		hashNumberCount=$(hashDelete "$temporaryFolder" "$uploadId" "$iCounter" "$hashListFile")
		#------------------------------ End split hash delete
	
		#------------------------------ Create tree hash
		chunkTreeHash=$(createTreeHash "$temporaryFolder" "$uploadId" "$iCounter" "$hashNumberCount" "$chunkToProcess")
		#------------------------------ End create tree hash

		#------------------------------ Log and update Cantemo Metadata
		echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   Uploading $chunkToProcess with hash $chunkTreeHash" >> "$logFile"
		echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)     Chunk $iCounter of $totalChunkCount: byte range $byteStartValue-$byteEndValue" >> "$logFile"
		updateValue="in progress - chunk $iCounter"
		updateVidispineMetadata $uploadId "oly_uploadStatusAWSS3" $updateValue
		#------------------------------ End log

		#------------------------------ Uploading using AWS CLI and append construct file
		chunksCount=$((chunksCount+1))
		httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws s3api upload-part --bucket "$awsBucketName" --key "$sourceFileName" --part-number "$chunksCount" --upload-id="$awsJobId" --body "$temporaryFolder/$uploadId/Chunk_$iCounter/$chunkToProcess")
		s3PartEtag=$(echo "$httpResponse" | awk -F " " '{print $1}')
		if [ $chunksCount -eq 1 ];
		then
			echo -en '    {\n      "ETag": '$s3PartEtag',\n      "PartNumber": '$chunksCount'\n    }' >> $s3ConstructFile
		else
			echo -en ',\n    {\n      "ETag": '$s3PartEtag',\n      "PartNumber": '$chunksCount'\n    }' >> $s3ConstructFile
		fi
		#------------------------------ End archiving
		
		cd "$temporaryFolder"/"$uploadId"
		rm -fR "$temporaryFolder"/"$uploadId"/Chunk_"$iCounter"
		iCounter=$((iCounter+1))
	done < $chunkList
	#------------------------------ End process and Archive

	#------------------------------ Process and complete multi-part upload
	echo -en '\n  ]\n}\n' >> $s3ConstructFile
	cd "$temporaryFolder"/"$uploadId"/Chunk_all
	completeTreeHash=$(createTreeHash "$temporaryFolder" "$uploadId" "all" "$chunksCount" "$uploadId")
	httpResponse=$(/usr/local/aws-cli/v2/current/dist/aws s3api complete-multipart-upload --bucket "$awsBucketName" --key "$sourceFileName" --multipart-upload "file://$s3ConstructFile" --upload-id="$awsJobId")
	s3UploadId=$(echo "$httpResponse" | awk -F " " '{print $2}')
	#------------------------------ Log and update Cantemo Metadata
	echo "$(date "+%H:%M:%S") (s3MultiUpload) - ($uploadId)   Completing multi-part upload process with hash $completeTreeHash" >> "$logFile"
fi
cd "$temporaryFolder"
rm -fR "$temporaryFolder"/"$uploadId"

#------------------------------ Update Cantemo Metadata
updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $uploadId "oly_uploadDateAWSS3" $updateValue
if [ "$s3UploadId" == "" ];
then
	updateValue="failed"
	/usr/local/aws-cli/v2/current/dist/aws s3api abort-multipart-upload --bucket "$awsBucketName" --key "$sourceFileName" --upload-id="$awsJobId"
else
	updateValue="completed"
fi
updateVidispineMetadata $uploadId "oly_uploadStatusAWSS3" $updateValue
echo "$(date "+%H:%M:%S") (s3Summary) - ($uploadId)   S3 Upload ID: $s3UploadId" >> "$logFile"
updateValue="$sourceFile,$sourceFileSize,$s3UploadId"
updateVidispineMetadata $uploadId "oly_uploadIdAWSS3" $updateValue
#------------------------------

#------------------------------ Move completed token file to indicate that this archive job is done
rm -f "$activeUploadFolder/$uploadId"
rm -f "$s3ConstructFile"

exit 0
