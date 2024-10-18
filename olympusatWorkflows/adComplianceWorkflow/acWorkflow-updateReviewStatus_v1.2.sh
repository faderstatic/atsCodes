#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to Update Ad Compliance Content's Review Status
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 10/02/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS (because hash openssl)
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

#--------------------------------------------------
# Internal funtions to include
# Function to Release Lock after item is processed/completed
releaseLock ()
{
    rm -f "$lockFile"
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/adComplianceWorkflow-$mydate.log"
# Set Variable before continuing with script
export itemId=$1
export userName=$2
export reviewStatus=$3
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/adComplianceReviewStatus/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated - User ($userName) - New Review Status - {$reviewStatus}" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 5
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
# API call to get metadata_main_group
getMetadataMainGroupUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?group=null"
getMetadataMainGroupHttpResponse=$(curl --location $getMetadataMainGroupUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=KPo8XvLM97mfZdNhFOicHLu2WgZsZWT9z0xMBG5cTV1jbmao22hTEekmK845PRhq')
itemMetadataMainGroup=$(echo "$getMetadataMainGroupHttpResponse" | awk -F '</group>' '{print $1}' | awk -F '<group>' '{print $2}')
#echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Main Metadata Group {$itemMetadataMainGroup}" >> "$logfile"
if [[ "$itemMetadataMainGroup" == "Ad Compliance" ]];
then
    export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    export reviewBy=$2
    export reviewDate=$(date "+%Y-%m-%dT%H:%M:%S")
    itemReviewStatus=$(filterVidispineItemMetadata $itemId "metadata" "ac_reviewStatus")
    export newItem=0
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Metadata Main Group - [$itemMetadataMainGroup] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    if [[ "$reviewStatus" == "newItem-pending" ]];
    then
        export reviewStatus="pending"
        export newItem=1
        if [[ "$reviewStatus" == "pending" ]];
        then
            bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field></timespan></MetadataDocument>")
            if [[ "$newItem" -eq 1 ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Triggering Add to Daily Report on New Item" >> "$logfile"
                bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.7.sh $itemId adComplianceNewItem > /dev/null 2>&1 &"
                sleep 1
                itemAdvertiser=$(filterVidispineItemMetadata $itemId "metadata" "ac_advertiser")
                itemContactEmail=$(filterVidispineItemMetadata $itemId "metadata" "ac_contactEmail")
                if [[ "$itemAdvertiser" == "" || "$itemContactEmail" == "" ]];
                then
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Advertiser or Contact Email Info MISSING - NOT Sending Email to Advertiser" >> "$logfile"
                else
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Triggering Add to Advertiser Contact Report on New Item" >> "$logfile"
                    bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.7.sh $itemId adComplianceForLicensor $itemAdvertiser $itemContactEmail > /dev/null 2>&1 &"
                fi
            fi
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - New Review Status NOT Supported {$reviewStatus}" >> "$logfile"
        fi
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    #elif [[ "$reviewStatus" == "pending" && "$itemReviewStatus" == "" ]];
    elif [[ "$reviewStatus" == "pending" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    #elif [[ "$reviewStatus" == "inProgress" && "$itemReviewStatus" == "pending" ]];
    elif [[ "$reviewStatus" == "inProgress" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    elif [[ "$reviewStatus" == "needsSupportingDocuments" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    elif [[ "$reviewStatus" == "approved" || "$reviewStatus" == "approvedWithRestrictions" || "$reviewStatus" == "noApparentConcerns" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    elif [[ "$reviewStatus" == "rejected" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    elif [[ "$reviewStatus" == "other" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
        sleep 1
        httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
        sleep 2
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - New Review Status NOT Supported {$reviewStatus}" >> "$logfile"
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Item's Metadata Main Group NOT Supported {$itemMetadataMainGroup}" >> "$logfile"
fi

IFS=$saveIFS
