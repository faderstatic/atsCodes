#! /bin/bash

# This script deletes an archive from S3 Glacier for the following account
#	customer-id 500844647317
#	vault-name olympusatMamGlacier
#
# 	Usage: glacierDeleteV1.sh [item ID] [user]

# System requirements: This script will run on LINUX and MACOS X

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
# . /opt/olympusat/scriptsLibrary/olympusatGlacier.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

#--------------------------------------------------
# Set some parameters
export cantemoItemId=$1
export cantemoUser=$2
export title=$(filterVidispineItemMetadata $cantemoItemId "metadata" "title")
export myDate=$(date "+%Y-%m-%d")
export awsCustomerId="500844647317"
export awsVaultName="olympusatMamGlacier"
export logFile="/opt/olympusat/logs/glacier-$myDate.log"
export urlMetadata=$(echo "http://10.1.1.34:8080/API/item/$uploadId/metadata/")
#--------------------------------------------------
untrimmedArchiveIdAWS=$(filterVidispineItemMetadata $cantemoItemId "metadata" "oly_archiveIdAWS")
archiveIdAWS=$(echo $untrimmedArchiveIdAWS | awk -F "," '{print $3}')
echo "$(date "+%H:%M:%S") (glacierDelete) - ($cantemoItemId) $archiveIdAWS" >> "$logFile"
#--------------------------------------------------

updateValue=$(date "+%Y-%m-%dT%H:%M:%S")
updateVidispineMetadata $cantemoItemId "oly_deleteDateAWS" $updateValue
urlUpdateMetadata="http://10.1.1.34:8080/API/item/$cantemoItemId/metadata/"
bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_archiveStatusAWS</name><value></value></field><field><name>oly_archiveDateAWS</name><value></value></field><field><name>oly_restoreStatusAWS</name><value></value></field><field><name>oly_restoreDateAWS</name><value></value></field><field><name>oly_archiveIdAWS</name><value></value></field></timespan></MetadataDocument>")
curl -s -o /dev/null --location --request PUT $urlUpdateMetadata --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
glacierApiResponse=$(/usr/local/bin/aws glacier delete-archive --account-id "$awsCustomerId" --vault-name "$awsVaultName" --archive-id "$archiveIdAWS")
echo "$(date "+%H:%M:%S") (glacierDelete) - ($cantemoItemId) Item has been deleted" >> "$logFile"
updateVidispineMetadata $cantemoItemId "oly_deleteStatusAWS" "completed"
updateVidispineMetadata $cantemoItemId "oly_deleteByAWS" "$cantemoUser"

#Recipient email addresses
export recipient1=mamAdmin@olympusat.com
export recipient2=kkanjanapitak@olympusat.com
export recipient3=rsims@olympusat.com

#Sending email address
export emailFrom=notify@olympusat.com

#Email Body
subject="MAM - Deleted from Glacier - $title"
body="Hi,

[$title] has been deleted from Glacier Archive by [$cantemoUser].

Item ID: $cantemoItemId
Title: $title
Archive ID: $archiveIdAWS

Thanks

MAM Notify"

#Email Message
message="Subject: $subject\n\n$body"

#echo "$(date "+%H:%M:%S") (glacierDelete) - Sending Email" >> "$logFile"
#echo "$(date "+%H:%M:%S") (glacierDelete) - To - $recipient1, $recipient2, $recipient3, $recipient4, $recipient5" >> "$logFile"
#echo "$(date "+%H:%M:%S") (glacierDelete) - From - $emailFrom" >> "$logFile"
#echo "$(date "+%H:%M:%S") (glacierDelete) - Subject - $subject" >> "$logFile"
#echo "$(date "+%H:%M:%S") (glacierDelete) - Body - [$body]" >> "$logFile"

curl --url 'smtp://smtp-mail.outlook.com:587' \
  --ssl-reqd \
  --mail-from $emailFrom \
  --mail-rcpt $recipient2 --mail-rcpt $recipient3 \
  --user 'notify@olympusat.com:560Village' \
  --tlsv1.2 \
  -T <(echo -e "$message")

#echo "$(date "+%H:%M:%S") (glacierDelete) - Email Sent" >> "$logFile"

exit 0
