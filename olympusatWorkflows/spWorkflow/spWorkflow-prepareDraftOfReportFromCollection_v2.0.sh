#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger automation to prepare draft of report from collection in Cantemo
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 08/14/2024
#::Rev A: 
#::System requirements: This script will only run in LINUX but not MacOS
#::***************************************************************************************************************************

#--------------------------------------------------
# External funtions to include
. /opt/olympusat/scriptsLibrary/olympusatCantemo.lib
#--------------------------------------------------

#--------------------------------------------------
# Internal funtions
createCommaSeperatedList ()
{
    currentFieldValue="$1"
    currentFieldName="$2"
    numberOfValues=$(echo "$currentFieldValue"  | awk -F '<list-item>' '{print NF}')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Values - [$currentFieldValue]" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Number of Values - [$numberOfValues]" >> "$logfile"
    outputVariable=""
    for (( a=2 ; a<=$numberOfValues ; a++ ));
    do
        currentValue=$(echo "$currentFieldValue" | awk -F '<list-item>' '{print $'$a'}' | awk -F '</list-item>' '{print $1}')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Current Value - [$currentValue]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Output Variable - [$outputVariable]" >> "$logfile"
        if [[ "$currentValue" != "" ]];
        then
            if [[ "$outputVariable" == "" ]];
            then
                outputVariable=$(echo "$currentValue")
            else
                outputVariable="$(echo "$outputVariable"), $(echo "$currentValue")"
            fi
        fi
    done
    echo "$outputVariable"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - [$currentFieldName] - Final Output Variable - [$outputVariable]" >> "$logfile"
}

convertToTimecode() {
  local frame=$1
  local fps=$2
  
  # Calculate total seconds as a floating-point number
  local total_seconds=$(echo "scale=4; $frame / $fps" | bc)
  
  # Extract integer part of seconds
  local int_seconds=$(echo "$total_seconds / 1" | bc)
  
  # Extract fractional part and calculate frames
  local fractional_seconds=$(echo "$total_seconds - $int_seconds" | bc)
  local frames=$(echo "scale=0; $fractional_seconds * $fps + 0.5" | bc)  # Adding 0.5 for rounding
  
  # Calculate hours, minutes, and seconds
  local hours=$(echo "$int_seconds / 3600" | bc)
  local minutes=$(echo "($int_seconds % 3600) / 60" | bc)
  local seconds=$(echo "$int_seconds % 60" | bc)

  # Format output as HH:MM:SS:FF
  printf "%02d:%02d:%02d:%02d\n" "$hours" "$minutes" "$seconds" "$frames"
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")
# Set global variables
export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)
# Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2
export spProcess=$3
logfile="/opt/olympusat/logs/spWorkflow-$mydate.log"
if [[ "$spProcess" == "prepareBodyOfReportInfo" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Prepare Body of Report Info IN PROGRESS - Triggered by [$user]" >> "$logfile"
    getCollectionIdUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?null=null&terse=yes"
    getCollectionIdHttpResponse=$(curl --location $getCollectionIdUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=TXPkx4KSJvkqcV8CthE8QObxXHgHryV4bRqabWH9QxO3Hr4F3hgzzbcAg7AMVxet')
    collectionInstanceCount=$(grep -o '<__collection ' <<< "$getCollectionIdHttpResponse" | wc -l)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - __collection Instance Count - [$collectionInstanceCount]" >> "$logfile"
    if [ "$collectionInstanceCount" -gt 1 ];
    then
        collections=""
        for (( d=1 ; d<=$collectionInstanceCount ; d++ )); do
            # Extract the value of the d-th __collection instance
            collection=$(echo "$getCollectionIdHttpResponse" | awk -v n="$d" '{
                count=0
                while (match($0, /<__collection[^>]*>([^<]*)<\/__collection>/, arr)) {
                    count++
                    if (count == n) {
                        print arr[1]
                        exit
                    }
                    $0=substr($0, RSTART+RLENGTH)
                }
            }')
            if [[ "$collections" == "" ]];
            then
                collections="$collection"
            else
                collections="$collections, $collection"
            fi
        done
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collections - [$collections]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - __collection Instance Count is Greater Than 1 - script exiting - NOT processing item" >> "$logfile"
    else
        collectionId=$(echo "$getCollectionIdHttpResponse" | awk -F '</__collection>' '{print $1}' | awk -F '/vidispine">' '{print $5}')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection ID - [$collectionId]" >> "$logfile"
        # Gather Items from Collection & their Metadata
        collectionItemsInfo="/opt/olympusat/zMisc/spReports/$collectionId-prepareBody.xml"
        if [[ -e "$collectionItemsInfo" ]];
        then
            mv -f "$collectionItemsInfo" "/opt/olympusat/zMisc/spReports/zCompleted/"
            sleep 1
        fi
        getCollectionItemsUrl="http://10.1.1.34:8080/API/collection/$collectionId/item/"
        getCollectionItemsHttpResponse=$(curl --location $getCollectionItemsUrl --header 'Content-Type: application/xml' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
        occurrenceCount=$(echo $getCollectionItemsHttpResponse | awk -F '<item id="' '{print NF}')
        occurrenceCount=$(($occurrenceCount - 1))
        for (( b=1 ; b<=$occurrenceCount ; b++ ));
        do
            c=2
            currentValue=$(echo "$getCollectionItemsHttpResponse" | awk -F '"/>' '{print $'$b'}' | awk -F '<item id="' '{print $'$c'}')
            collectionItemTitle=$(filterVidispineItemMetadata $currentValue "metadata" "title")
            # Get Item's Marker Info
            getItemMarkersURL="http://10.1.1.34/AVAPI/asset/$currentValue/?type=AvMarker&content=marker"
            getItemMarkersHttpResponse=$(curl --location $getItemMarkersURL --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
            itemMarkersCleanedUp=$(echo "$getItemMarkersHttpResponse" | jq '[.timespans[] | select(.type == "AvMarker")]')
            itemMarkersExtractedInfo=$(echo "$itemMarkersCleanedUp" | jq -r '[.[] | 
                {
                    title: (.metadata[]? | select(.key == "title") | .value // "N/A"),
                    description: (.metadata[]? | select(.key == "av_marker_description") | .value // "N/A"),
                    start_frame: (.start.frame // "N/A"),
                    end_frame: (.end.frame // "N/A")
                }
                ]')
            fps=$(echo "scale=8; 30000 / 1001" | bc)
            itemMarkersExtractedInfoCleaned=$(echo "$itemMarkersExtractedInfo" | jq -c '.[]' | while read -r line; do
                title=$(echo "$line" | jq -r '.title')
                description=$(echo "$line" | jq -r '.description')
                start_frame=$(echo "$line" | jq -r '.start_frame')
                end_frame=$(echo "$line" | jq -r '.end_frame')
                start_time=$(convertToTimecode "$start_frame" "$fps")
                end_time=$(convertToTimecode "$end_frame" "$fps")
                jq -n --arg title "$title" --arg description "$description" --arg start_time "$start_time" --arg end_time "$end_time" \
                    '{Title: $title, Description: $description, InPoint: $start_time, OutPoint: $end_time}'
                done)
            if [[ "$itemMarkersExtractedInfoCleaned" == "" ]];
            then
                itemMarkersExtractedInfoCleaned="NONE"
            fi
            echo "$currentValue - $collectionItemTitle
Markers:
$itemMarkersExtractedInfoCleaned" >> "$collectionItemsInfo"
        done
        # Set variable with marker info stored in external file
        forBodyOfReport=$(cat $collectionItemsInfo)
        # Check total number of characters in forBodyOfReport
        characterCount=${#forBodyOfReport}
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - forBodyOfReport Character Count [$characterCount]" >> "$logfile"
        if [ "$characterCount" -gt 2000 ];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - forBodyOfReport has more than 2000 characters - NOT updating Cantemo" >> "$logfile"
        else
            forBodyOfReport=$(echo "$forBodyOfReport" | sed -e 's/&/\&amp;/g')
            forBodyOfReport=$(echo "$forBodyOfReport" | sed -e ':a;N;$!ba;s/\n/\&#xA;/g')
            # API Call to Update Collection's bodyOfReport field
            spBodyOfReportUrl="http://10.1.1.34:8080/API/collection/$collectionId/metadata/"
            spBodyOfReportData="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>sp_bodyOfReport</name><value>$forBodyOfReport</value></field></timespan></MetadataDocument>"
            curl --location --request PUT $spBodyOfReportUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx' --data $spBodyOfReportData
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Prepare Body of Report Info COMPLETED" >> "$logfile"
        fi
    fi
elif [[ "$spProcess" == "prepareDraftOfReport" ]];
then
    echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Prepare Draft of Report IN PROGRESS - Triggered by [$user]" >> "$logfile"
    getCollectionIdUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?field=__collection&terse=yes"
    getCollectionIdHttpResponse=$(curl --location $getCollectionIdUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=TXPkx4KSJvkqcV8CthE8QObxXHgHryV4bRqabWH9QxO3Hr4F3hgzzbcAg7AMVxet')
    collectionInstanceCount=$(grep -o '<__collection ' <<< "$getCollectionIdHttpResponse" | wc -l)
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - __collection Instance Count - [$collectionInstanceCount]" >> "$logfile"
    if [[ "$collectionInstanceCount" -eq 0 ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Item NOT Found in Any Collections - Exiting Script" >> "$logfile"
    elif [[ "$collectionInstanceCount" -gt 1 ]];
    then
        collections=""
        for (( d=1 ; d<=$collectionInstanceCount ; d++ )); do
            # Extract the value of the d-th __collection instance
            collection=$(echo "$getCollectionIdHttpResponse" | awk -v n="$d" '{
                count=0
                while (match($0, /<__collection[^>]*>([^<]*)<\/__collection>/, arr)) {
                    count++
                    if (count == n) {
                        print arr[1]
                        exit
                    }
                    $0=substr($0, RSTART+RLENGTH)
                }
            }')
            if [[ "$collections" == "" ]];
            then
                collections="$collection"
            else
                collections="$collections, $collection"
            fi
        done
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collections - [$collections]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Prepare Draft of Report FAILED - __collection Instance Count is Greater Than 1" >> "$logfile"
    else
        collectionId=$(echo "$getCollectionIdHttpResponse" | awk -F '</__collection>' '{print $1}' | awk -F '/vidispine">' '{print $3}')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionIdHttpResponse]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection ID - [$collectionId]" >> "$logfile"
        getCollectionInfoUrl="http://10.1.1.34/API/v2/collections/$collectionId/"
        getCollectionInfoHttpResponse=$(curl --location $getCollectionInfoUrl --header 'accept: application/xml' --header 'X-CSRFToken: kiSHDG0urLwlI6c6oK6wDSaGF1fw2faui23YCyW7yhgME70nZv8l5EaPIbJtXoWa' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=DCceQb19jageOtbw7oHdoOuwOSFfUeFjhEZxAGiIU7eShnNsrbUvvFcRCrdty5vt')
        getCollectionInfoHttpResponse=$(echo "$getCollectionInfoHttpResponse" | sed ':a;N;$!ba;s/\r/\/r/g;s/\n/\/n/g')
        collectionTitle=$(echo "$getCollectionInfoHttpResponse" | awk -F '<title>|</title>' '{print $2}')
        collectionProject=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_project_str>|</f_sp_project_str>' '{print $2}')
        collectionReportTitle=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportTitle_str>|</f_sp_reportTitle_str>' '{print $2}')
        collectionReportStatus=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportStatus__values__str>|</f_sp_reportStatus__values__str>' '{print $2}')
        collectionReportOwner=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportOwner_str_ex>|</f_sp_reportOwner_str_ex>' '{print $2}')
        collectionReportOwnerForEmail=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportOwner__values__str>|</f_sp_reportOwner__values__str>' '{print $2}')
        collectionReportOwnerForEmail=$(echo "$collectionReportOwnerForEmail" | sed 's/&amp;/\&/g')
        collectionEpisode=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_episode_str_ex>|</f_sp_episode_str_ex>' '{print $2}')
        collectionSeason=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_season_str_ex>|</f_sp_season_str_ex>' '{print $2}')
        collectionParentalRating=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_parentalRating__values__str>|</f_sp_parentalRating__values__str>' '{print $2}')
        collectionContentDescriptors=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_contentDescriptors__values__str>|</f_sp_contentDescriptors__values__str>' '{print $2}')
        collectionReportEmailTo=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportEmailTo_str>|</f_sp_reportEmailTo_str>' '{print $2}')
        collectionBodyOfReport=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_bodyOfReport_str>|</f_sp_bodyOfReport_str>' '{print $2}')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Report Status - [$collectionReportStatus]" >> "$logfile"
        if [[ "$collectionReportStatus" == "" || "$collectionReportStatus" == "draft" || "$collectionReportStatus" == "Draft" || "$collectionReportStatus" == "sent" || "$collectionReportStatus" == "Sent" ]];
        then
            if [[ "$collectionEpisode" == *list-item* ]];
            then
                collectionEpisodeValues=$(createCommaSeperatedList "$collectionEpisode" "collectionEpisode")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Episode Values - [$collectionEpisodeValues]" >> "$logfile"
                if [[ "$collectionEpisodeValues" == "" ]];
                then
                    collectionEpisodeValues="N/A"
                fi
            else
                collectionEpisodeValues=$(echo "$collectionEpisode")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Episode Values - [$collectionEpisodeValues]" >> "$logfile"
                if [[ "$collectionEpisodeValues" == "" ]];
                then
                    collectionEpisodeValues="N/A"
                fi
            fi
            if [[ "$collectionSeason" == *list-item* ]];
            then
                collectionSeasonValues=$(createCommaSeperatedList "$collectionSeason" "collectionSeason")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Season Values - [$collectionSeasonValues]" >> "$logfile"
                if [[ "$collectionSeasonValues" == "" ]];
                then
                    collectionSeasonValues="N/A"
                fi
            else
                collectionSeasonValues=$(echo "$collectionSeason")
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Season Values - [$collectionSeasonValues]" >> "$logfile"
                if [[ "$collectionSeasonValues" == "" ]];
                then
                    collectionSeasonValues="N/A"
                fi
            fi
            if [[ "$collectionReportOwner" == *list-item* ]];
            then
                collectionReportOwnerValues=$(createCommaSeperatedList "$collectionReportOwner" "collectionReportOwner")
            else
                collectionReportOwnerValues=$(echo "$collectionReportOwner")
            fi
            if [[ "$collectionReportOwnerForEmail" == *list-item* ]];
            then
                collectionReportOwnerValuesForEmail=$(createCommaSeperatedList "$collectionReportOwnerForEmail" "collectionReportOwner")
            else
                collectionReportOwnerValuesForEmail=$(echo "$collectionReportOwnerForEmail")
            fi
            if [[ "$collectionParentalRating" == *list-item* ]];
            then
                collectionParentalRatingValues=$(createCommaSeperatedList "$collectionParentalRating" "collectionParentalRating")
            else
                collectionParentalRatingValues=$(echo "$collectionParentalRating")
            fi
            if [[ "$collectionContentDescriptors" == *list-item* ]];
            then
                collectionContentDescriptorsValues=$(createCommaSeperatedList "$collectionContentDescriptors" "collectionContentDescriptors")
            else
                collectionContentDescriptorsValues=$(echo "$collectionContentDescriptors")
            fi
            if [[ "$collectionReportEmailTo" == *list-item* ]];
            then
                collectionReportEmailToValues=$(createCommaSeperatedList "$collectionReportEmailTo" "collectionReportEmailTo")
            else
                collectionReportEmailToValues=$(echo "$collectionReportEmailTo")
            fi
            if [[ "$collectionReportOwnerValues" == "" ]];
            then
                collectionReportOwnerValues=$(echo "$user")
            fi
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Title - [$collectionTitle]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Project - [$collectionProject]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Title - [$collectionReportTitle]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Status - [$collectionReportStatus]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Report Owner - [$collectionReportOwnerValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Episode - [$collectionEpisodeValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Season - [$collectionSeasonValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Parental Rating - [$collectionParentalRatingValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Content Descriptors - [$collectionContentDescriptorsValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Final Collection Report Email To - [$collectionReportEmailToValues]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Body of Report - [$collectionBodyOfReport]" >> "$logfile"
            # Gather Items from Collection & their Metadata
            collectionItemsInfo="/opt/olympusat/zMisc/spReports/$collectionId.xml"
            if [[ -e "$collectionItemsInfo" ]];
            then
                mv -f "$collectionItemsInfo" "/opt/olympusat/zMisc/spReports/zCompleted/"
                sleep 1
            fi
            collectionItemRightslineItemId=""
            getCollectionItemsUrl="http://10.1.1.34:8080/API/collection/$collectionId/item/"
            getCollectionItemsHttpResponse=$(curl --location $getCollectionItemsUrl --header 'Content-Type: application/xml' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=ejrWOMvoMPINrazmUw2klDRGMwdXQ5ndB8JzAGf23nKjXD8Ig1r2qxakwAX5OjUx')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionItemsHttpResponse]" >> "$logfile"
            occurrenceCount=$(echo $getCollectionItemsHttpResponse | awk -F '<item id="' '{print NF}')
            occurrenceCount=$(($occurrenceCount - 1))
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Occurrence Count - [$occurrenceCount]" >> "$logfile"
            for (( b=1 ; b<=$occurrenceCount ; b++ ));
            do
                c=2
                currentValue=$(echo "$getCollectionItemsHttpResponse" | awk -F '"/>' '{print $'$b'}' | awk -F '<item id="' '{print $'$c'}') 
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item ID of Item in Collection - [$currentValue]" >> "$logfile"
                collectionItemTitle=$(filterVidispineItemMetadata $currentValue "metadata" "title")
                if [[ "$collectionItemRightslineItemId" == "" ]];
                then
                    collectionItemContentType=$(filterVidispineItemMetadata $currentValue "metadata" "oly_contentType")
                    collectionItemTitleEn=$(filterVidispineItemMetadata $currentValue "metadata" "oly_titleEn")
                    collectionItemTitleEs=$(filterVidispineItemMetadata $currentValue "metadata" "oly_titleEs")
                    collectionItemTitleCode=$(filterVidispineItemMetadata $currentValue "metadata" "oly_titleCode")
                    collectionItemSeasonNumber=$(filterVidispineItemMetadata $currentValue "metadata" "oly_seasonNumber")
                    collectionItemEpisodeNumber=$(filterVidispineItemMetadata $currentValue "metadata" "oly_episodeNumber")
                    collectionItemRightslineItemId=$(filterVidispineItemMetadata $currentValue "metadata" "oly_rightslineItemId")
                fi
                collectionItemDurationSeconds=$(filterVidispineItemMetadata $currentValue "metadata" "durationSeconds")
                # Convert seconds to hours, minutes, and seconds
                hours=$(echo "$collectionItemDurationSeconds / 3600" | bc)
                minutes=$(echo "($collectionItemDurationSeconds % 3600) / 60" | bc)
                seconds=$(echo "$collectionItemDurationSeconds % 60" | bc)
                # Format as HH:MM:SS
                formattedTime=$(printf "%02d:%02d:%02d" $hours $minutes $seconds)
                echo "$currentValue - $collectionItemTitle
    Duration - $formattedTime" >> "$collectionItemsInfo"
            done
            # Check Item's metadata to get proper Title of Content to be used in Email Subject
            if [[ -n "$collectionItemTitleEn" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item Title EN is NOT Empty [$collectionItemTitleEn]" >> "$logfile"
                subTitleOfContent=$(echo "$collectionItemTitleEn")
            elif [[ -n "$collectionItemTitleEs" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item Title ES is NOT Empty [$collectionItemTitleEs]" >> "$logfile"
                subTitleOfContent=$(echo "$collectionItemTitleEs")
            elif [[ -n "$collectionItemTitleCode" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item Title Code is NOT Empty [$collectionItemTitleCode]" >> "$logfile"
                subTitleOfContent=$(echo "$collectionItemTitleCode")
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - No Custom Metadata Set - Using Title [$collectionItemTitle]" >> "$logfile"
                subTitleOfContent=$(echo "$collectionItemTitle")
            fi
            # Check Item's metadata to get proper Rightsline Item ID to be used in Email Subject
            if [[ -n "$collectionItemRightslineItemId" ]];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item Rightsline Item ID is NOT Empty [$collectionItemRightslineItemId]" >> "$logfile"
                subRightslineItemId=$(echo "$collectionItemRightslineItemId")
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Item Rightsline Item ID IS Empty - Setting to 'ID MISSING'" >> "$logfile"
                subRightslineItemId="ID MISSING"
            fi
            # Check Item's metadata to finalize the Email Subject to be used based on if a Movie or Episode
            if [[ "$collectionItemContentType" == "episode" ]];
            then
                # Check Item's metadata to get proper Season Number & Episode Number of Episode Content to be used in Email Subject
                if [[ -n "$collectionItemSeasonNumber" && -n "$collectionItemEpisodeNumber" ]];
                then
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Both Item SeasonNumber & EpisodeNumber are NOT Empty - S [$collectionItemSeasonNumber] - E [$collectionItemEpisodeNumber]" >> "$logfile"
                    subSeasonEpisode="S$(echo "$collectionItemSeasonNumber")E$(echo "$collectionItemEpisodeNumber")"
                else
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Both Item SeasonNumber & EpisodeNumber ARE Empty - Setting to 'S-E MISSING'" >> "$logfile"
                    subSeasonEpisode="S-E MISSING"
                fi
                # Set final variable to be used in Email Subject for Episode
                emailSubjectForContent="MAM - S&P Report - [$subTitleOfContent] - ($subSeasonEpisode) - {$subRightslineItemId}"
            elif [[ "$collectionItemContentType" == "movie" ]];
            then
                # Set final variable to be used in Email Subject for Movie
                emailSubjectForContent="MAM - S&P Report - [$subTitleOfContent] - {$subRightslineItemId}"
            else
                # Set final variable to be used in Email Subject for Other type of Content
                emailSubjectForContent="MAM - S&P Report - [$subTitleOfContent] - {$subRightslineItemId}"
            fi
            # Prepare & Send Email with S&P Report
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Preparing & Sending Email with S&P Report" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Email Subject Line - $emailSubjectForContent" >> "$logfile"
            # Recipient email addresses
            if [[ "$user" == "standardspractices" ]];
            then
                user="censorship"
            fi
            export recipient1="$user@olympusat.com"
            export recipient2=censorship@olympusat.com
            export recipient3=mamAdmin@olympusat.com
            export recipient4=dbassett@olympusat.com
            export recipient5=amorales@olympusat.com
            export recipient6=rsims@olympusat.com
            export recipient7=kkanjanapitak@olympusat.com
            # Sending email address
            export emailFrom=notify@olympusat.com
            # Set variable with timestamp
            collectionTitleCutDate=$(date "+%Y-%m-%dT%H:%M:%S")
            # List of items
            listOfItemsForEmail=$(<"$collectionItemsInfo")
            # Email Body
            collectionBodyOfReport=$(echo "$collectionBodyOfReport" | sed 's/\/n/\n/g')
            collectionBodyOfReport=$(echo "$collectionBodyOfReport" | sed 's/&amp;/\&/g')
            subject=$(echo "$emailSubjectForContent")
            body="Hi,

The following Standards & Practices report has been created with Report Title [$collectionReportTitle]

Collection Title - $collectionTitle
Project - $collectionProject
Report Title - $collectionReportTitle
Report Status - $collectionReportStatus
Report Owner - $collectionReportOwnerValuesForEmail
Report Email To - $collectionReportEmailToValues

Season - $collectionSeasonValues
Episode - $collectionEpisodeValues
Parental Rating - $collectionParentalRatingValues
Content Descriptors - $collectionContentDescriptorsValues

List of items

$listOfItemsForEmail

Body of Report

$collectionBodyOfReport

Legal Language

It is important to avoid real brand identification on all wardrobe, props and set dressing unless approved in advance by our Sales team.

As always, please be sure to clear all music/lyrics and stock footage and please discuss with your Legal Department any references to real products, people, places, etc.

Unless you have otherwise advised us in writing, it is our understanding that, in accordance with Federal Law, no on-air appearances or mention (of products, services, or persons) have been included in this episode in exchange for consideration of any kind to you, performers, or any member of your staff and crew. Please contact us immediately in the event this information is incorrect or if any change is made that causes it to become incorrect.

Thanks

MAM Notify"
            # Setup to send email
            sesSubject=$(echo $subject) 
            sesMessage=$body
            curl --url 'smtp://smtp-mail.outlook.com:587' \
                --ssl-reqd  \
                --mail-from $emailFrom \
                --mail-rcpt $recipient1 --mail-rcpt $recipient2 --mail-rcpt $recipient3 \
                --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
                -F '=(;type=multipart/mixed' \
                -F "=$sesMessage;type=text/plain" \
                -F '=)' \
                -H "Subject: $sesSubject"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Email with S&P Report Sent Successfully" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Updating Collection Metadata via API" >> "$logfile"
            updateCollectionMetadataUrl="http://10.1.1.34:8080/API/collection/$collectionId/metadata/"
            updateCollectionMetadataBody="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>sp_reportOwner</name><value>$collectionReportOwnerValues</value></field><field><name>sp_reportStatus</name><value>sent</value></field><field><name>sp_titleCutDate</name><value>$collectionTitleCutDate</value></field></timespan></MetadataDocument>"
            updateCollectionMetadataResponse=$(curl --location --request PUT $updateCollectionMetadataUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=GFMXXpksyiWoOP5GUln9bwwOxTfNLX9XHeNyAPhUF5h0sUWTLKk3FvEdvjsVVziw' --data $updateCollectionMetadataBody)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Body [$updateCollectionMetadataBody]" >> "$logfile"
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Response [$updateCollectionMetadataResponse]" >> "$logfile"
            if [[ -e "$collectionItemsInfo" ]];
            then
                mv -f "$collectionItemsInfo" "/opt/olympusat/zMisc/spReports/zCompleted/"
                sleep 1
            fi
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Status is 'draft' - NOT Sending Email" >> "$logfile"
        fi
    fi
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - No Valid spProcess Set - exiting script" >> "$logfile"
fi
IFS=$saveIFS