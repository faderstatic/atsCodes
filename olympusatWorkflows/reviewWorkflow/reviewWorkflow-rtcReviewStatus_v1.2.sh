#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to update rtcReviewStatus & related fields
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 08/09/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

# --------------------------------------------------
# Internal funtions
releaseLock ()
{
    rm -f "$lockFile"
}
# --------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2
export reviewStatus=$3
logfile="/opt/olympusat/logs/rtcReviewWorkflow-$mydate.log"
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/rtcReviewWorkflow/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - [$itemId] - Item Validation Job Initiated" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------

# --------------------------------------------------
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export titleEs=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEs")
export titleEn=$(filterVidispineItemMetadata $itemId "metadata" "oly_titleEn")
export contentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
export fullFilePath=$(filterVidispineFileInfo $itemId  "uri" "tag=original")
export fullFilePath2=$(echo $fullFilePath | sed -e 's/%20/ /g')
export linkToClip=http://cantemo.olympusat.com/item/$itemId/

export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
export reviewDate=$(date "+%Y-%m-%dT%H:%M:%S")

if [[ "$reviewStatus" == "reviewPending" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering API to Update rtcReviewStatus Metadata - [$reviewStatus] - by [$user]" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Review</name><field><name>oly_rtcReviewStatus</name><value>$reviewStatus</value></field><field><name>oly_rtcReviewRequestDate</name><value>$reviewDate</value></field></group></timespan></MetadataDocument>")
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 1
    #Set Permissions on Item to give 'RTC Mexico - Access' group WRITE Access
    permissionBodyData=$(echo "[ { \"source_name\": \"RTC Mexico - Access\", \"source\": \"GROUP\", \"permission\": \"WRITE\", \"priority\": \"DEFAULT\" }]")
    permissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Sending API Call to Cantemo to Set ACLs" >> "$logfile"
    curl --location $permissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=YWnXd79oejS4KNRwIycf0RuBVs2cgw7wrqotCqrYkvCGFtO6FiROd3XiS9d6RYyt' --data $permissionBodyData
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering workflow to add item to daily report" >> "$logfile"
    bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.4.sh $itemId rtcReviewPending > /dev/null 2>&1 &"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Update Metadata Completed" >> "$logfile"
elif [[ "$reviewStatus" == "reviewInProgress" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering API to Update rtcReviewStatus Metadata - [$reviewStatus] - by [$user]" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Review</name><field><name>oly_rtcReviewStatus</name><value>$reviewStatus</value></field></group></timespan></MetadataDocument>")
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Update Metadata Completed" >> "$logfile"
elif [[ "$reviewStatus" == "finalReviewPending" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering API to Update rtcReviewStatus Metadata - [$reviewStatus] - by [$user]" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Review</name><field><name>oly_rtcReviewStatus</name><value>$reviewStatus</value></field><field><name>oly_rtcReviewDate</name><value>$reviewDate</value></field><field><name>oly_rtcReviewBy</name><value>$user</value></field></group></timespan></MetadataDocument>")
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Update Metadata Completed" >> "$logfile"
elif [[ "$reviewStatus" == "finalReviewInProgress" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering API to Update rtcReviewStatus Metadata - [$reviewStatus] - by [$user]" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group><name>RTC Review</name><field><name>oly_rtcReviewStatus</name><value>$reviewStatus</value></field></group></timespan></MetadataDocument>")
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Update Metadata Completed" >> "$logfile"
elif [[ "$reviewStatus" == "finalReviewCompleted" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering API to Update rtcReviewStatus Metadata - [$reviewStatus] - by [$user]" >> "$logfile"
    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
    sleep 1
    #Set Permissions on Item to give 'RTC Mexico - Access' group NONE Access
    getPermissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/?group=RTC%20Mexico%20-%20Access"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Sending API Call to Cantemo to Set ACLs" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - $getPermissionUrl" >> "$logfile"
    httpResponse=$(curl --location --request GET $getPermissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=fHDUyZ7wk6BVS1aMcV7MazrjpRODBxThM3pnmrWGlqw98SbE6g6wt19Dg1Q4GUio' --data '')
    aclId=$(echo "$httpResponse" | awk -F '"id":"' '{print $2}' | awk -F '"' '{print $1}')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - ACL ID - $aclId" >> "$logfile"
    sleep 2
    removePermissionUrl="http://10.1.1.34/API/v2/items/$itemId/acl/$aclId"
    removeAclHttpResponse=$(curl -s -o /dev/null --location --request DELETE $removePermissionUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=zxleguMwvKqz1wS1Q4F9U4vGo54eUXQAQwstEkVB7xokFrQYTFqmtdHxkZf4PW7B' --data '')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Remove ACL HTTP Response - [$removeAclHttpResponse]" >> "$logfile"
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Triggering workflow to add item to daily report" >> "$logfile"
    bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.4.sh $itemId rtcReviewCompleted > /dev/null 2>&1 &"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - Update Metadata Completed" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (rtcReview) - ($itemId) - RTC Review Status NOT Supported" >> "$logfile"
fi

IFS=$saveIFS