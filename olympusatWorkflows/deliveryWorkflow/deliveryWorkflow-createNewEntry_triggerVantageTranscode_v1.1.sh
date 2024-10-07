#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to Add new entry in Delivery subgroup & trigger Vantage Transcode
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 10/03/2024
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
logfile="/opt/olympusat/logs/deliveryWorkflow-$mydate.log"
# Set Variable before continuing with script
export itemId=$1
export userName=$2
export transcodeProfile=$3
export deliveryDate=$(date "+%Y-%m-%dT%H:%M:%S")
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/deliveryWorkflow/jobQueue.lock"

echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Delivery Job Initiated - User ($userName) - Transcode Profile {$transcodeProfile}" >> "$logfile"
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
# Check if transcodeProfile is Vantage_Submit
echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Check Transcode Profile" >> "$logfile"
if [[ "$transcodeProfile" == "Vantage_Submit" ]];
then
    sleep 1
    # Gathering metadata from item in Cantemo
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Gathering Delivery Job Metadata" >> "$logfile"
    itemStudioName=$(filterVidispineItemMetadata $itemId "metadata" "oly_studioName")
    itemVantageWorkflowName=$(filterVidispineItemMetadata $itemId "metadata" "oly_vantageWorkflowName")
    itemLicensorOutputFolder=$(filterVidispineItemMetadata $itemId "metadata" "oly_licensorOutputFolder")
    itemVantageCustomFolderName=$(filterVidispineItemMetadata $itemId "metadata" "oly_vantageCustomFolderName")
    itemFileNameOutput=$(filterVidispineItemMetadata $itemId "metadata" "oly_fileNameOutput")
    itemIdDistribution=$(filterVidispineItemMetadata $itemId "metadata" "oly_van_idDistribution")
    itemVantagePriority=$(filterVidispineItemMetadata $itemId "metadata" "oly_vantagePriority")
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Studio Name {$itemStudioName}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Vantage Workflow Name {$itemVantageWorkflowName}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Licensor Output Folder {$itemLicensorOutputFolder}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Vantage Custom Folder Name {$itemVantageCustomFolderName}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - File Name Output {$itemFileNameOutput}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - ID Distribution {$itemIdDistribution}" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Vantage Priority {$itemVantagePriority}" >> "$logfile"
    sleep 1
    # Look into adding a check if there is already a subgroup entry matching the metadata gathered, that delivery status is inProgress

    # API Call to create new entry in Delivery subgroup
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Sending API Call to Create New Entry in Delivery Subgroup" >> "$logfile"
    export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    export bodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><group mode=\"add\"><name>Delivery</name><field><name>oly_deliveryStatus</name><value>inProgress</value></field><field><name>oly_deliveryBy</name><value>$userName</value></field><field><name>oly_deliveryDate</name><value>$deliveryDate</value></field><field><name>oly_studioName</name><value>$itemStudioName</value></field><field><name>oly_vantageWorkflowName</name><value>$itemVantageWorkflowName</value></field><field><name>oly_licensorOutputFolder</name><value>$itemLicensorOutputFolder</value></field><field><name>oly_vantageCustomFolderName</name><value>$itemVantageCustomFolderName</value></field><field><name>oly_fileNameOutput</name><value>$itemFileNameOutput</value></field><field><name>oly_van_idDistribution</name><value>$itemIdDistribution</value></field><field><name>oly_vantagePriority</name><value>$itemVantagePriority</value></field></group></timespan></MetadataDocument>"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Body Data [$bodyData]" >> "$logfile"
    createEntryHttpResponse=$(curl --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=KeXafYLa3CfIcRzC34r4QBx3cJStwuAC2asS2qj2miHGvBH2r2CMvIxVUQ8wuCVU' --data $bodyData)
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Create Entry HTTP Response [$createEntryHttpResponse]" >> "$logfile"
    sleep 3
    # API Call to Get the Delivery subgroup metadata for item to get group uuid to send to Vantage to update with job status
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Sending API Call to Get Subgroup Metadata" >> "$logfile"
    export getMetadataUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_deliveryStatus%2Coly_deliveryBy%2Coly_deliveryDate&group=Delivery"
    getMetadataHttpResponse=$(curl --location $getMetadataUrl --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=KeXafYLa3CfIcRzC34r4QBx3cJStwuAC2asS2qj2miHGvBH2r2CMvIxVUQ8wuCVU')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Get Metadata HTTP Response [$getMetadataHttpResponse]" >> "$logfile"
    sleep 1
    # Extract out group uuid for new subgroup entry
    entryGroupUUID=$(echo "$getMetadataHttpResponse" | awk -F 'uuid="' '/<group / {print $2}' | cut -d '"' -f1)
    #entryGroupUUID=$(echo "$getMetadataHttpResponse" | grep -oP '(?<=<group uuid=").*?(?=")')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Group UUID [$entryGroupUUID]" >> "$logfile"
    sleep 1
    # Update item metadata in Cantemo with Group UUID value
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Updating Item in Cantemo with Group UUID" >> "$logfile"
    updateVidispineMetadata $itemId "oly_van_groupUuid" "$entryGroupUUID"
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Triggering Vantage_Submit Transcode Job" >> "$logfile"
    triggerTranscodeUrl="http://10.1.1.34:8080/API/item/$itemId/transcode?tag=Vantage_Submit"
    #triggerTranscodeBody="csrfmiddlewaretoken=mJ44H4eZ0QxMh9GrnVN5tRGYCn263XidhundnIxKicVIp9fWEMvcM1FnWesWSsv6&format=Vantage_Submit&search_id_selected=&selected_collection=&selected_items=$itemId&ignored_items="
    #triggerTranscodeReferer="Referer: https://cantemo.olympusat.com/item/$itemId/"
    #triggerTranscodeHttpResponse=$(curl --location $triggerTranscodeUrl --header 'Accept: application/json, text/javascript, */*; q=0.01' --header 'Accept-Language: en-US,en;q=0.9' --header 'Connection: keep-alive' --header 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' --header 'Cookie: sessionid=86dng5gldl4mgzmnrulciz688acn7hgr; csrftoken=uwWfUZF9yDspIiHJoEOvM9phLFIsjzKGphfoADYUQZQlQigeFvwC5joG5w8i84Xz' --header 'Origin: https://cantemo.olympusat.com' --header $triggerTranscodeReferer --header 'X-Requested-With: XMLHttpRequest' --data $triggerTranscodeBody)
    triggerTranscodeHttpResponse=$(curl --location --request POST $triggerTranscodeUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=K2ujG3xyN97sp4ieVchjaSyxLFUppsYHArZra7Z5yLCtbhzlRFrXxZGYIToBpOIy' --data '')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Trigger Transcode HTTP Response [$triggerTranscodeHttpResponse]" >> "$logfile"
    sleep 5
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Cleanup/Clear Original Metadata Fields" >> "$logfile"
    clearMetadataUrl="http://10.1.1.34:8080/API/item/$itemId/metadata/"
    clearMetadataBodyData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_studioName</name><value></value></field><field><name>oly_vantageWorkflowName</name><value></value></field><field><name>oly_licensorOutputFolder</name><value></value></field><field><name>oly_vantageCustomFolderName</name><value></value></field><field><name>oly_fileNameOutput</name><value></value></field><field><name>oly_van_idDistribution</name><value></value></field><field><name>oly_vantagePriority</name><value></value></field></timespan></MetadataDocument>"
    clearMetadataHttpResponse=$(curl --location --request PUT $clearMetadataUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=KeXafYLa3CfIcRzC34r4QBx3cJStwuAC2asS2qj2miHGvBH2r2CMvIxVUQ8wuCVU' --data $clearMetadataBodyData)
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Metadata Subgroup Entry Set & Delivery Job Sent to Vantage" >> "$logfile"
else
    sleep 1
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (deliveryWorkflow) - [$itemId] - Delivery Job SKIPPED - Transcode Profile NOT Supported" >> "$logfile"
fi
IFS=$saveIFS
