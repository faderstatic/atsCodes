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

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/adComplianceWorkflow-$mydate.log"
# Set Variable before continuing with script
export itemId=$1
export userName=$2
export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
export reviewStatus=$3
export reviewBy=$2
export reviewDate=$(date "+%Y-%m-%dT%H:%M:%S")
itemReviewStatus=$(filterVidispineItemMetadata $itemId "metadata" "ac_reviewStatus")
export newItem=0
if [[ "$reviewStatus" == "newItem-pending" ]];
then
    export reviewStatus="pending"
    export newItem=1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    if [[ "$reviewStatus" == "pending" ]];
    then
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field></timespan></MetadataDocument>")
        if [[ "$newItem" -eq 1 ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Triggering Add to Daily Report on New Item" >> "$logfile"
            bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-addToDailyReport_v2.5.sh $itemId adComplianceNewItem > /dev/null 2>&1 &"
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
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
#elif [[ "$reviewStatus" == "inProgress" && "$itemReviewStatus" == "pending" ]];
elif [[ "$reviewStatus" == "inProgress" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
elif [[ "$reviewStatus" == "needsSupportingDocuments" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
elif [[ "$reviewStatus" == "approved" || "$reviewStatus" == "approvedWithRestrictions" || "$reviewStatus" == "noApparentConcerns" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
elif [[ "$reviewStatus" == "rejected" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
elif [[ "$reviewStatus" == "other" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Initiated" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Current Review Status - {$itemReviewStatus}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - User - {$userName} - New Review Status - {$reviewStatus}" >> "$logfile"
    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>ac_reviewStatus</name><value>$reviewStatus</value></field><field><name>ac_reviewBy</name><value>$reviewBy</value></field><field><name>ac_reviewDate</name><value>$reviewDate</value></field></timespan></MetadataDocument>")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Body Data - [$bodyData]" >> "$logfile"
    sleep 1
    httpResponse=$(curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData)
    sleep 2
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - Update Ad Compliance Review Status Completed" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (reviewStatus) - [$itemId] - New Review Status NOT Supported {$reviewStatus}" >> "$logfile"
fi

IFS=$saveIFS
