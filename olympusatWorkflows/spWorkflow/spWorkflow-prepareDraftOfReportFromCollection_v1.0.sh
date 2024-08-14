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

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

# Variables to be passed from Cantemo to shell script
export itemId=$1
export user=$2

logfile="/opt/olympusat/logs/spWorkflow-$mydate.log"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Prepare Draft of Report IN PROGRESS - Triggered by [$user]" >> "$logfile"
getCollectionIdUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?null=null&terse=yes"
getCollectionIdHttpResponse=$(curl --location $getCollectionIdUrl --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=TXPkx4KSJvkqcV8CthE8QObxXHgHryV4bRqabWH9QxO3Hr4F3hgzzbcAg7AMVxet')
echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - HTTP Response - [$getCollectionIdHttpResponse]" >> "$logfile"
collectionId=$(echo "$getCollectionIdHttpResponse" | awk -F '</__collection>' '{print $1}' | awk -F '/vidispine">' '{print $5}')
echo "$(date +%Y/%m/%d_%H:%M:%S) - (spWorkflow) - ($itemId) - Collection ID - [$collectionId]" >> "$logfile"

IFS=$saveIFS