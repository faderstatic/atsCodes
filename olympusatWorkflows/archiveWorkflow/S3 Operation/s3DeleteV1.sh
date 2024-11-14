#! /bin/bash

# This script deletes an archive from S3 Glacier for the following account
#	customer-id 500844647317
#	bucket-name olympusatdeeparch
#
# 	Usage: S3DeleteV1.sh [item ID] [user]

# System requirements: This script will run on LINUX and MACOS X

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export cantemoItemId=$1
export cantemoUser=$2
# export title=$(filterVidispineItemMetadata $cantemoItemId "metadata" "title")
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsBucketName="olympusatdeeparch"
export logFile="/opt/olympusat/logs/S3-$myDate.log"
export urlUpdateMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata/"
#--------------------------------------------------
sourceFile=$(filterVidispineFileInfo $cantemoItemId "uri" "tag=original" | sed -e 's/%20/ /g' | sed -e 's/%23/\#/g')
sourceFileName=$(basename "$sourceFile")
echo "$(date "+%H:%M:%S") (S3Delete) - ($cantemoItemId) $sourceFileName" >> "$logFile"
#--------------------------------------------------

updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $cantemoItemId "oly_deleteDateAWS" $updateValue
bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_uploadStatusAWSS3</name><value><field><name>oly_uploadBucketAWSS3</name><value></value></field><field></value></field><field><name>oly_uploadDateAWSS3</name><value></value></field><field><name>oly_uploadIdAWSS3</name><value></value></field></timespan></MetadataDocument>")
curl -s -o /dev/null --location --request PUT $urlUpdateMetadata --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
glacierApiResponse=$(/usr/local/bin/aws s3api delete-object --bucket "$awsBucketName" --key "$sourceFileName")
echo "$(date "+%H:%M:%S") (S3Delete) - ($cantemoItemId) Item has been deleted" >> "$logFile"
updateVidispineMetadata $cantemoItemId "oly_deleteStatusAWS" "completed"
updateVidispineMetadata $cantemoItemId "oly_deleteByAWS" "$cantemoUser"

#Recipient email addresses
export recipient1=mamAdmin@olympusat.com
# export recipient2=kkanjanapitak@olympusat.com
# export recipient3=rsims@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

#Email Body
subject="MAM - Deleted from s3 - $title"
body="Hi,

[$sourceFileName] has been deleted from S3 Glacier Deep Archive by [$cantemoUser].

Item ID: $cantemoItemId
File Name: $sourceFileName
AWS Bucket: $awsBucketName

Thanks

MAM Notify"

#Email Message
message="Subject: $subject\n\n$body"

#echo "$(date "+%H:%M:%S") (S3Delete) - Sending Email" >> "$logFile"
#echo "$(date "+%H:%M:%S") (S3Delete) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logFile"
#echo "$(date "+%H:%M:%S") (S3Delete) - From - $emailFrom" >> "$logFile"
#echo "$(date "+%H:%M:%S") (S3Delete) - Subject - $subject" >> "$logFile"
#echo "$(date "+%H:%M:%S") (S3Delete) - Body - [$body]" >> "$logFile"

curl --url 'smtp://smtp-mail.outlook.com:587' \
  --ssl-reqd \
  --mail-from $emailFrom \
  --user 'notify@olympusat.com:560Village' \
  --tlsv1.2 \
  -T <(echo -e "$message")

# curl --url 'smtp://smtp-mail.outlook.com:587' \
#   --ssl-reqd \
#   --mail-from $emailFrom \
#   --mail-rcpt $recipient2 --mail-rcpt $recipient3 \
#   --user 'notify@olympusat.com:560Village' \
#   --tlsv1.2 \
#   -T <(echo -e "$message")

echo "$(date "+%H:%M:%S") (S3Delete) - Email Sent" >> "$logFile"

exit 0