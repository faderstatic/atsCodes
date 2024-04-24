#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will trigger API call to Cantemo to update metadata to clear oly_contentFlags
#::Engineers: Ryan Sims
#::Client: Olympusat
#::Updated: 01/29/2024
#::Rev A: 
#::***************************************************************************************************************************

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be passed from Cantemo to shell script
export itemId=$portal_itemId
export url="http://10.1.1.34/API/v2/items/$itemId/metadata/"

#logfile="/Users/rsims/Documents/OLYMPUSAT Documentation/_olympusatFutureWorkflows/Cinesys/apiCalls/logs/apiCall-$mydate.log"
logfile="/tmp/apiCall-$mydate.log"

echo "++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++" >> $logfile
echo "$datetime - Triggering API to Update Metadata" >> "$logfile"
echo "$datetime - Item ID - $itemId" >> "$logfile"

curl --location --request PUT $url \
--header 'Content-Type: application/json' \
--header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' \
--header 'Cookie: csrftoken=v5vuh2iZJ3JcjaPVqs6ZpAia94FapYa1TqjmUFpleP3nI7mjPLtAA25itLhrFQcV' \
--data '{
    "metadata": {
        "group_name": "Olympusat",
        "fields": [
            {
                "name": "oly_contentFlags",
                "value": ""
            }
        ]
    }
}'

sleep 5

echo "$datetime - Update Metadata Completed" >> "$logfile"

IFS=$saveIFS