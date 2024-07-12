#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will copy an item's proxy to Analysis_Ingest folder & then trigger API Call to Vionlabs
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 07/11/2024
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
logfile="/opt/olympusat/logs/olympusatWorkflow-$mydate.log"

# Set Variables to check before continuing with script
export itemId=$1
export analysisType=$2

echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Checking Analysis Type - [$analysisType]" >> "$logfile"

# Check analysisType Variable
if [[ "$analysisType" == "vionlabs" ]];
then
    # analysisType varialbe is set to vionlabs
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Checking & Preparing to Send Item to Vionlabs for Analysis" >> "$logfile"
    
    itemAnalysisStatus=$(filterVidispineItemMetadata $itemId "metadata" "oly_analysisStatus")

    if [[ "$itemAnalysisStuats" == *"in progress"* ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Analysis Status is ALREADY in progress - exiting script/workflow" >> "$logfile"    
    else    
        itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")

        if [[ "$itemContentType" == "movie" ]] || [[ "$itemContentType" == "episode" ]];
        then
            # itemContentType is movie or episode-continue with script/workflow
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Item Content Type is [$itemContentType]" >> "$logfile"
            
            export url="http://10.1.1.34:8080/API/item/$itemId/uri?tag=lowres"
            postResponse=$(curl --location $url --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=q7VRUT9f9VUOd0n4ZqiBmIU6EUxeZYM3886MVW3kGyuG1hODXCyO77DAhEPTOU9c')
            proxySourcePath=$(echo "$postResponse" | awk -F "<uri>" '{print $2}' | awk -F "</uri>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Item Proxy Source Path is [$proxySourcePath]" >> "$logfile"
            proxySourceFilename=$(echo "$proxySourcePath" | awk -F '/' '{print $NF}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Item Proxy Source Filename is [$proxyFilename]" >> "$logfile"

            if [[ ! -e "$proxySourcePath" ]];
            then
                # no proxySourcePath-exiting script/workflow
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - No Proxy Source Path - exiting script/workflow" >> "$logfile"
            else
                # proxySourcePath exists-continuing with script/workflow
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Proxy Source Path exists - continugin with script/workflow" >> "$logfile"
                destinationPath="/Volumes/creative/Content_Processing/Analysis_Ingest/$proxySourceFilename"

                echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Copy Proxy to Destination [$destinationPath] In Progress" >> "$logfile"
                #cp "$proxySourcePath" "$destinationPath"
            fi 
        else
            # itemContentType is not supported-exit script/workflow
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (analysisWorkflow-vionlabs) - ($itemId) - Item Content Type is NOT supported - [$itemContentType]" >> "$logfile"
        fi
    fi
else
    # analysisType variable is not supported
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (emailNotificationWorkflow) - ($itemId) - analysisType variable is not supported" >> "$logfile"
fi

IFS=$saveIFS
