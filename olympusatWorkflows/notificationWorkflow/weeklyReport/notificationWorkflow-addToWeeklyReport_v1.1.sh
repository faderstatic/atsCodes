#!/bin/bash

#::***************************************************************************************************************************
#::This shell script is the initial trigger to create list of items to send email notification
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/08/2024
#::Rev A: 
#::System requirements: This script will run in LINUX & MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
logfile="/opt/olympusat/logs/notificationWorkflow-$mydate.log"

# Set Variables to check before continuing with script
export emailNotificationWorkflow=$1

echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - Email Workflow - [$emailNotificationWorkflow]" >> "$logfile"

# Check Variable
if [[ "$emailNotificationWorkflow" == "contentMissingMetadata" ]];
then
    # emailNotificationWorkflow varialbe is set to contentMissingMetadata
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Checking for contentMissingMetadataFileDestination file" >> "$logfile"
    contentMissingMetadataFileDestination="/opt/olympusat/resources/emailNotificationWorkflow/contentMissingMetadata/contentMissingMetadata-$mydate.csv"
    if [[ ! -e "$contentMissingMetadataFileDestination" ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - contentMissingMetadataFileDestination file NOT FOUND - creating new file with headers" >> "$logfile"

        sleep 2

        echo "ItemId,Title,Licensor,ContentType,VersionType,FileExtension,ContentFlags,OriginalQCStatus,FinalQCStatus" >> "$contentMissingMetadataFileDestination"

        echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - New File created - [$contentMissingMetadataFileDestination]" >> "$logfile"
        
        sleep 5
    fi 

    # API Call to Search for items in the 'New Content Missing Metadata' Saved Search
    newContentSearchResponse=$(curl --location --request PUT 'http://10.1.1.34/API/v2/search/?page_size=1000' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' \
    --header 'Cookie: csrftoken=ANvypnJfTcCzim0jlTSRyBwxRhl6iyiySztiJ3lMsH9LQHpxQ4l6LbvEJxqer3Y8' \
    --data '{
        "filter": {
            "operator": "AND",
            "terms": [
                {
                    "name": "portal_deleted",
                    "missing": true
                }
            ]
        },
        "query": "((metadata_main_group:\"Olympusat\" AND \u0021f_oly_tags_str:\"to be deleted\" AND is_online:true AND placeholder_shape_size:0 AND id:*OLY-* AND (\u0021f_oly_contentType_str_ex:*Trailer* OR \u0021f_oly_contentType_str_ex:\"promo\" OR \u0021f_oly_contentType_str_ex:\"teaser\") AND (\u0021f_oly_versionType_str_ex:\"conformFile\" OR \u0021f_oly_versionType_str_ex:\"censoredFile\" OR \u0021f_oly_versionType_str_ex:\"conformFile-spanish\" OR \u0021f_oly_versionType_str_ex:\"conformFile-english\" OR \u0021f_oly_versionType_str_ex:\"censoredFile-spanish\" OR \u0021f_oly_versionType_str_ex:\"censoredFile-english\")) AND (storage_original:OLY-8 OR storage_original:OLY-9 OR storage_original:OLY-10 OR storage_original:OLY-16) AND ((\u0021_exists_:\"f_oly_seriesName_str\" AND f_oly_contentType_str_ex:\"episode\") OR (\u0021_exists_:\"f_oly_seasonNumber_str_ex\" AND f_oly_contentType_str_ex:\"episode\") OR (\u0021_exists_:\"f_oly_episodeNumber_str_ex\" AND f_oly_contentType_str_ex:\"episode\") OR (\u0021_exists_:f_oly_licensor_str_ex) OR (\u0021_exists_:f_oly_rightslineContractId_str AND (\u0021f_oly_contentFlags_str_ex:*unlicensedcontent* OR \u0021f_oly_originalFileFlags_str_ex:*textless* OR \u0021f_oly_originalFileFlags_str_ex:*dubbedmaster* OR \u0021f_oly_originalFileFlags_str_ex:*spanishmaster* OR \u0021f_oly_originalFileFlags_str_ex:*originalrawmaster*)) OR (\u0021_exists_:f_oly_rightslineItemId_str AND (\u0021f_oly_originalFileFlags_str_ex:*textless* OR \u0021f_oly_originalFileFlags_str_ex:*dubbedmaster* OR \u0021f_oly_originalFileFlags_str_ex:*spanishmaster* OR \u0021f_oly_originalFileFlags_str_ex:*originalrawmaster*)) OR (\u0021_exists_:f_oly_contentType_str_ex) OR (\u0021_exists_:f_oly_versionType_str_ex) OR (\u0021_exists_:f_oly_titleEn_str OR \u0021_exists_:f_oly_titleEs_str))) OR (metadata_main_group:\"Olympusat\" AND \u0021f_oly_tags_str:\"to be deleted\" AND is_online:true AND placeholder_shape_size:0 id:*OLY-* AND storage_original:OLY-65 AND ((\u0021_exists_:f_oly_licensor_str_ex) OR (\u0021_exists_:f_oly_titleEn_str OR \u0021_exists_:f_oly_titleEs_str OR \u0021_exists_:f_oly_seriesName_str))) OR (metadata_main_group:\"Olympusat\" AND \u0021f_oly_tags_str:\"to be deleted\" AND is_online:true AND placeholder_shape_size:0 id:*OLY-* AND (storage_original:OLY-8 OR storage_original:OLY-9 OR storage_original:OLY-10 OR storage_original:OLY-16) AND (f_oly_contentType_str_ex:*Trailer* OR f_oly_contentType_str_ex:\"promo\" OR f_oly_contentType_str_ex:\"teaser\") AND ((\u0021_exists_:f_oly_licensor_str_ex) OR (\u0021_exists_:f_oly_titleEn_str OR \u0021_exists_:f_oly_titleEs_str OR \u0021_exists_:f_oly_seriesName_str)))",
        "search_interval": "all",
        "category": "Olympusat",
        "sort": [
            {
                "name": "created",
                "order": "desc"
            }
        ],
        "aggregations": {
            "portal_itemtype": {
                "terms": {
                    "name": "portal_itemtype"
                }
            },
            "type": {
                "terms": {
                    "name": "type",
                    "includes": [
                        "item"
                    ]
                }
            },
            "is_archived": {
                "terms": {
                    "name": "is_archived"
                }
            },
            "is_online": {
                "terms": {
                    "name": "is_online"
                }
            },
            "user": {
                "terms": {
                    "name": "user"
                }
            }
        },
        "fields": [
            "vidispine_id",
            "parent_id",
            "uuid",
            "title",
            "representative_fields",
            "created",
            "type",
            "portal_itemtype",
            "lock_exists",
            "is_online",
            "durationSeconds",
            "f_portal_archive_action_status_str_ex",
            "portal_archive_status",
            "has_annotations",
            "plugins",
            "lock_by_user",
            "parent_collection"
        ]
    }')

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - New Content Search Response {$newContentSearchResponse}" >> "$logfile"

    #-------------------------------------------------------------------------
    # Iterate through newContentSearchResponse and extract out each vidispine_id
    items=$(echo "$newContentSearchResponse" | jq -r '.results' | jq '.[]' | jq -r '.vidispine_id')
    for itemId in ${items[@]}; do
        # Gather item's metadata
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
        itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
        itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
        itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
        itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')
        itemOriginalContentQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")
        itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")

        urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
        httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *"legacycontent"* ]];
        then
            itemContentFlags="legacyContent"
        else
            itemContentFlags=""
        fi

        sleep 2

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Adding item metadata to csv" >> "$logfile"

        echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemOriginalContentQCStatus,$itemFinalQCStatus" >> "$contentMissingMetadataFileDestination"

        sleep 1
    done
    #-------------------------------------------------------------------------

    # API Call to Search for items in the 'Conform Files Missing Metadata' Saved Search
    conformFilesSearchResponse=$(curl --location --request PUT 'http://10.1.1.34/API/v2/search/?page_size=1000' \
    --header 'Content-Type: application/json' \
    --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' \
    --header 'Cookie: csrftoken=ANvypnJfTcCzim0jlTSRyBwxRhl6iyiySztiJ3lMsH9LQHpxQ4l6LbvEJxqer3Y8' \
    --data '{
        "filter": {
            "operator": "AND",
            "terms": [
                {
                    "name": "portal_deleted",
                    "missing": true
                }
            ]
        },
        "query": "(metadata_main_group:\"Olympusat\" AND \u0021f_oly_tags_str:\"to be deleted\" AND is_online:true AND placeholder_shape_size:0 id:*OLY-* AND (f_oly_versionType_str_ex:\"conformFile\" OR f_oly_versionType_str_ex:\"censoredFile\" OR f_oly_versionType_str_ex:\"conformFile-spanish\" OR f_oly_versionType_str_ex:\"conformFile-english\" OR f_oly_versionType_str_ex:\"censoredFile-spanish\" OR f_oly_versionType_str_ex:\"censoredFile-english\")) AND (storage_original:OLY-8 OR storage_original:OLY-9 OR storage_original:OLY-10 OR storage_original:OLY-16) AND ((\u0021_exists_:f_oly_licensor_str_ex) OR (\u0021_exists_:f_oly_contentType_str_ex) OR (\u0021_exists_:f_oly_titleEn_str OR \u0021_exists_:f_oly_titleEs_str))",
        "search_interval": "all",
        "category": "Olympusat",
        "sort": [
            {
                "name": "created",
                "order": "desc"
            }
        ],
        "fields": [
            "vidispine_id",
            "parent_id",
            "uuid",
            "title",
            "representative_fields",
            "created",
            "type",
            "portal_itemtype",
            "lock_exists",
            "is_online",
            "durationSeconds",
            "f_portal_archive_action_status_str_ex",
            "portal_archive_status",
            "has_annotations",
            "plugins",
            "lock_by_user",
            "parent_collection"
        ],
        "aggregations": {
            "portal_itemtype": {
                "terms": {
                    "name": "portal_itemtype"
                }
            },
            "type": {
                "terms": {
                    "name": "type",
                    "includes": [
                        "item"
                    ]
                }
            },
            "is_archived": {
                "terms": {
                    "name": "is_archived"
                }
            },
            "is_online": {
                "terms": {
                    "name": "is_online"
                }
            },
            "user": {
                "terms": {
                    "name": "user"
                }
            }
        }
    }')

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - Conform Files Search Response {$conformFilesSearchResponse}" >> "$logfile"

    #-------------------------------------------------------------------------
    # Iterate through conformFilesSearchResponse and extract out each vidispine_id
    items=$(echo "$conformFilesSearchResponse" | jq -r '.results' | jq '.[]' | jq -r '.vidispine_id')
    for itemId in ${items[@]}; do
        # Gather item's metadata
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Gathering item metadata from Cantemo" >> "$logfile"
        itemTitle=$(filterVidispineItemMetadata $itemId "metadata" "title")
        itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
        itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
        itemOriginalFilename=$(filterVidispineItemMetadata $itemId "metadata" "originalFilename")
        itemOriginalExtension=$(echo "$itemOriginalFilename" | awk -F "." '{print $2}')
        itemOriginalContentQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_originalContentQCStatus")
        itemFinalQCStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_finalQCStatus")

        urlGetItemInfo="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_contentFlags&terse=yes"
        httpResponse=$(curl --location --request GET $urlGetItemInfo --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=Tkb9vkSC8v4SceB8CHUyB3iaMPjvgoHrzhLrvo36agG3wqv0jHc7nsOtdTo9JEyM')

        if [[ "$httpResponse" == *"legacycontent"* ]];
        then
            itemContentFlags="legacyContent"
        else
            itemContentFlags=""
        fi

        sleep 2

        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Adding item metadata to csv" >> "$logfile"

        echo "$itemId,$itemTitle,$itemLicensor,$itemContentType,$itemVersionType,$itemOriginalExtension,$itemContentFlags,$itemOriginalContentQCStatus,$itemFinalQCStatus" >> "$contentMissingMetadataFileDestination"

        sleep 1
    done
    #-------------------------------------------------------------------------

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Triggering Script to Send Email with Attachment" >> "$logfile"

    sleep 5

    bash -c "sudo /opt/olympusat/scriptsActive/notificationWorkflow-sendEmailWithWeeklyReport_v1.0-.sh contentMissingMetadata > /dev/null 2>&1 &"

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow-contentMissingMetadata) - ($itemId) - Process completed" >> "$logfile"
else
    # emailNotificationWorkflow variable is not supported
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (notificationWorkflow) - emailNotificationWorkflow variable is not supported" >> "$logfile"
fi

IFS=$saveIFS
