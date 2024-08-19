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
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionIdHttpResponse]" >> "$logfile"
    collectionId=$(echo "$getCollectionIdHttpResponse" | awk -F '</__collection>' '{print $1}' | awk -F '/vidispine">' '{print $5}')
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection ID - [$collectionId]" >> "$logfile"
else
    if [[ "$spProcess" == "prepareDraftOfReport" ]];
    then
        echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Prepare Draft of Report IN PROGRESS - Triggered by [$user]" >> "$logfile"
        getCollectionIdUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?null=null&terse=yes"
        getCollectionIdHttpResponse=$(curl --location $getCollectionIdUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=TXPkx4KSJvkqcV8CthE8QObxXHgHryV4bRqabWH9QxO3Hr4F3hgzzbcAg7AMVxet')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionIdHttpResponse]" >> "$logfile"
        collectionId=$(echo "$getCollectionIdHttpResponse" | awk -F '</__collection>' '{print $1}' | awk -F '/vidispine">' '{print $5}')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection ID - [$collectionId]" >> "$logfile"
        getCollectionInfoUrl="http://10.1.1.34/API/v2/collections/$collectionId/"
        getCollectionInfoHttpResponse=$(curl --location $getCollectionInfoUrl --header 'accept: application/xml' --header 'X-CSRFToken: kiSHDG0urLwlI6c6oK6wDSaGF1fw2faui23YCyW7yhgME70nZv8l5EaPIbJtXoWa' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=DCceQb19jageOtbw7oHdoOuwOSFfUeFjhEZxAGiIU7eShnNsrbUvvFcRCrdty5vt')
        getCollectionInfoHttpResponse=$(echo "$getCollectionInfoHttpResponse" | sed ':a;N;$!ba;s/\r/\/r/g;s/\n/\/n/g')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Info - [$getCollectionInfoHttpResponse]" >> "$logfile"
        collectionTitle=$(echo "$getCollectionInfoHttpResponse" | awk -F '<title>|</title>' '{print $2}')
        collectionProject=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_project_str>|</f_sp_project_str>' '{print $2}')
        collectionReportTitle=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportTitle_str>|</f_sp_reportTitle_str>' '{print $2}')
        collectionReportStatus=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportStatus_str_ex>|</f_sp_reportStatus_str_ex>' '{print $2}')
        collectionReportOwner=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportOwner_str_ex>|</f_sp_reportOwner_str_ex>' '{print $2}')
        collectionEpisode=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_episode_str_ex>|</f_sp_episode_str_ex>' '{print $2}')
        collectionSeason=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_season_str_ex>|</f_sp_season_str_ex>' '{print $2}')
        collectionParentalRating=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_parentalRating_str_ex>|</f_sp_parentalRating_str_ex>' '{print $2}')
        collectionContentDescriptors=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_contentDescriptors__values__str>|</f_sp_contentDescriptors__values__str>' '{print $2}')
        collectionReportEmailTo=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_reportEmailTo_str>|</f_sp_reportEmailTo_str>' '{print $2}')
        collectionBodyOfReport=$(echo "$getCollectionInfoHttpResponse" | awk -F '<f_sp_bodyOfReport_str>|</f_sp_bodyOfReport_str>' '{print $2}')
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Title - [$collectionTitle]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Project - [$collectionProject]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Title - [$collectionReportTitle]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Status - [$collectionReportStatus]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Owner - [$collectionReportOwner]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Episode - [$collectionEpisode]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Season - [$collectionSeason]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Parental Rating - [$collectionParentalRating]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Content Descriptors - [$collectionContentDescriptors]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Email To - [$collectionReportEmailTo]" >> "$logfile"
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Body of Report - [$collectionBodyOfReport]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Report Status - [$collectionReportStatus]" >> "$logfile"
        if [[ "$collectionReportStatus" == "draft" ]];
        then
            if [[ "$collectionEpisode" == *list-item* ]];
            then
                collectionEpisodeValues=$(createCommaSeperatedList "$collectionEpisode" "collectionEpisode")
            else
                collectionEpisodeValues=$(echo "$collectionEpisode")
            fi
            if [[ "$collectionSeason" == *list-item* ]];
            then
                collectionSeasonValues=$(createCommaSeperatedList "$collectionSeason" "collectionSeason")
            else
                collectionSeasonValues=$(echo "$collectionSeason")
            fi
            if [[ "$collectionReportOwner" == *list-item* ]];
            then
                collectionReportOwnerValues=$(createCommaSeperatedList "$collectionReportOwner" "collectionReportOwner")
            else
                collectionReportOwnerValues=$(echo "$collectionReportOwner")
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
            getCollectionItemsUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?null=null&terse=yes"
            getCollectionItemsHttpResponse=$(curl --location $getCollectionItemsUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=TXPkx4KSJvkqcV8CthE8QObxXHgHryV4bRqabWH9QxO3Hr4F3hgzzbcAg7AMVxet')
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionItemsHttpResponse]" >> "$logfile"
            #collectionItems=$(echo "$getCollectionItemsHttpResponse" | awk -F '</>' '{print $1}' | awk -F '/vidispine">' '{print $5}')
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection Items - [$collectionItems]" >> "$logfile"
            echo "$getCollectionItemsHttpResponse" | xmllint --xpath '//list-item' - | while read -r line; do
            fromXml_vidispine_id=$(echo "$line" | xmllint --xpath 'string(//vidispine_id)' - 2>/dev/null)
            fromXml_title=$(echo "$line" | xmllint --xpath 'string(//title)' - 2>/dev/null)
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Vidispine ID - [$fromXml_vidispine_id]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Title - [$fromXml_title]" >> "$logfile"
            # Prepare & Send Email with S&P Report
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Preparing & Sending Email with S&P Report" >> "$logfile"
            # Recipient email addresses
            export recipient1="$user@olympusat.com"
            export recipient2=mamAdmin@olympusat.com
            export recipient3=dbassett@olympusat.com
            export recipient4=amorales@olympusat.com
            export recipient5=rsims@olympusat.com
            export recipient6=kkanjanapitak@olympusat.com
            # Sending email address
            export emailFrom=notify@olympusat.com
            # Set variable with timestamp
            collectionTitleCutDate=$(date "+%Y-%m-%dT%H:%M:%S")
            # Email Body
            collectionBodyOfReport=$(echo "$collectionBodyOfReport" | sed 's/\/n/\n/g')
            #collectionBodyOfReport=$(echo "$collectionBodyOfReport" | tr '/n' '\n')
            subject="MAM - S&P Report - $collectionReportTitle"
            body="Hi,

    The following Standards & Practices report has been created with Report Title [$collectionReportTitle]

    Collection Title - $collectionTitle
    Project - $collectionProject
    Report Title - $collectionReportTitle
    Report Status - $collectionReportStatus
    Report Owner - $collectionReportOwnerValues
    Report Email To - $collectionReportEmailToValues

    Season - $collectionSeasonValues
    Episode - $collectionEpisodeValues
    Parental Rating - $collectionParentalRatingValues
    Content Descriptors - $collectionContentDescriptorsValues

    $collectionBodyOfReport

    Legal Language

    It is important to avoid real brand identification on all wardrobe, props and set dressing unless approved in advance by our Sales team.

    As always, please be sure to clear all music/lyrics and stock footage and please discuss with your Legal Department any references to real products, people, places, etc.

    Unless you have otherwise advised us in writing, it is our understanding that, in accordance with Federal Law, no on-air appearances or mention (of products, services, or persons) have been included in this episode in exchange for consideration of any kind to you, performers, or any member of your staff and crew. Please contact us immediately in the event this information is incorrect or if any change is made that causes it to become incorrect.

    Thanks

    MAM Notify"
            # Setup to send email
            #sesSubject=$(echo $subject) 
            #sesMessage=$body
            #curl --url 'smtp://smtp-mail.outlook.com:587' \
            #    --ssl-reqd  \
            #    --mail-from $emailFrom \
            #    --mail-rcpt $recipient1 --mail-rcpt $recipient2 \
            #    --user 'notify@olympusat.com:6bOblVsLg9bPQ8WG7JC7f8Zump' \
            #    -F '=(;type=multipart/mixed' \
            #    -F "=$sesMessage;type=text/plain" \
            #    -F '=)' \
            #    -H "Subject: $sesSubject"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Email with S&P Report Sent Successfully" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Updating Collection Metadata via API" >> "$logfile"
            #updateCollectionMetadataUrl="http://10.1.1.34:8080/API/collection/$collectionId/metadata/"
            #updateCollectionMetadataBody="<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>sp_reportOwner</name><value>$collectionReportOwnerValues</value></field><field><name>sp_reportStatus</name><value>sent</value></field><field><name>sp_titleCutDate</name><value>$collectionTitleCutDate</value></field></timespan></MetadataDocument>"
            #updateCollectionMetadataResponse=$(curl --location --request PUT $updateCollectionMetadataUrl --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=GFMXXpksyiWoOP5GUln9bwwOxTfNLX9XHeNyAPhUF5h0sUWTLKk3FvEdvjsVVziw' --data $updateCollectionMetadataBody)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Response - [$updateCollectionMetadataResponse]" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($collectionId) - Collection Report Status is 'draft' - NOT Sending Email" >> "$logfile"
        fi
    else
        if [[ "$spProcess" == "sendReport" ]];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - Send Report Section" >> "$logfile"
        else
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - No spProcess Set - exiting script" >> "$logfile"
        fi
    fi
IFS=$saveIFS