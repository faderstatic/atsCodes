#!/bin/bash

#::***************************************************************************************************************************
#::This shell script will get the title of an item and deconstuct it for metadata fields
#::Engineers: Ryan Sims & Tang Kanjanapitak
#::Client: Olympusat
#::Updated: 04/02/2024
#::Rev A: 
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

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
logfile="/opt/olympusat/logs/graphicWorkflow-$mydate.log"
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/graphicWorkflow/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Job Initiated" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"

if [[ "$itemContentType" != "image" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Content Type - {$itemContentType}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Item is NOT an Image - skipping & exiting the Script/Workflow" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Deconstructing Title - $title" >> "$logfile"

    if [[ "$title" == *_RAW ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Title ends with _RAW - {$title} - Removing _RAW" >> "$logfile"
        title=$(echo $title | sed 's/.\{4\}$//')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - New Title - {$title}" >> "$logfile"
    fi

    numberOfUnderscores=$(echo $title | awk -F"_" '{print NF-1}')

    echo $numberOfUnderscores
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Number of Underscores - $numberOfUnderscores" >> "$logfile"

    if [[ $numberOfUnderscores == 4 ]];
        then
            blockOne=$(echo $title | awk -F "_" '{print $1}')
            blockTwo=$(echo $title | awk -F "_" '{print $2}')
            blockThree=$(echo $title | awk -F "_" '{print $3}')
            blockFour=$(echo $title | awk -F "_" '{print $4}')
            blockFive=$(echo $title | awk -F "_" '{print $5}')

            blockOneCharCount=$(echo -n $blockOne | wc -c)
            blockTwoCharCount=$(echo -n $blockTwo | wc -c)
            blockThreeCharCount=$(echo -n $blockThree | wc -c)
            blockFourCharCount=$(echo -n $blockFour | wc -c)
            blockFiveCharCount=$(echo -n $blockFive | wc -c)

            if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
            then
                case $blockOneCharCount in
                    "7")
                        titleCode=$(echo $blockOne)
                    ;;
                    "9")
                        titleCode=$(echo $blockOne)
                        seasonCheck=$(echo $blockOne | sed -E 's/.*(..)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockOne)
                        seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        if [[ "$blockOne" == *" "* ]];
                        then
                            titleByLanguage=$(echo $blockOne)
                        else
                            titleByLanguage=$(echo $blockOne | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                        fi
                    ;;
                esac
            else
                if [[ "$blockOne" == *" "* ]];
                then
                    titleByLanguage=$(echo $blockOne)
                else
                    titleByLanguage=$(echo $blockOne | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                fi
            fi

            if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
            then
                language=$(echo $blockTwo)
            else
                blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") || ("$blockTwo" == "poster") ]];
                then
                    imageType=$(echo $blockTwo)
                fi
            fi

            if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
            then
                case $blockThreeCharCount in
                    "7")
                        titleCode=$(echo $blockThree)
                    ;;
                    "9")
                        titleCode=$(echo $blockThree)
                        seasonCheck=$(echo $blockThree | sed -E 's/.*(..)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockThree)
                        seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        titleByLanguage=$(echo $blockThree)
                    ;;
                esac
            else
                if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                then
                    imageSize=$(echo $blockThree)
                else
                    if [[ ("$blockThree" == "EN") || ("$blockThree" == "ES") || ("$blockThree" == "FR") || ("$blockThree" == "OG") ]];
                    then
                        language=$(echo $blockThree)
                    else
                        if [[ "$blockThree" == *" "* ]];
                        then
                            titleByLanguage=$(echo $blockThree)
                        else
                            titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                        fi
                    fi
                fi
            fi
            
            if [[ "$blockFour" =~ ^(M|S).*[0-9]$ ]];
            then
                case $blockFourCharCount in
                    "7")
                        titleCode=$(echo $blockFour)
                    ;;
                    "9")
                        titleCode=$(echo $blockFour)
                        seasonCheck=$(echo $blockFour | sed -E 's/.*(..)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockFour)
                        seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "2")
                        seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "6" | "5" | "4")
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        if [[ "$titleByLanguage" == "" ]];
                        then
                            if [[ "$blockFour" == *" "* ]];
                            then
                                titleByLanguage=$(echo $blockFour)
                            else
                                titleByLanguage=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                            fi
                        fi
                    ;;
                esac
            else
                if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                then
                    imageSize=$(echo $blockFour)
                else
                    blockFourTypeCheck=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                    if [[ ("$blockFourTypeCheck" == "cover") || ("$blockFourTypeCheck" == "feature") || ("$blockFourTypeCheck" == "keyart") || ("$blockFourTypeCheck" == *"still"*) || ("$blockFourTypeCheck" == *"stil"*) || ("$blockFourTypeCheck" == "blank") || ("$blockFourTypeCheck" == "poster") ]];
                    then
                        imageType=$(echo $blockFourTypeCheck)
                    else
                        if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFour" =~ ^(S|s).*[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                        then
                            if [[ "$blockFour" == *"still"* || "$blockFour" == *"Still"* ]];
                            then
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                            else
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - Does NOT contain Still" >> "$logfile"
                                seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                            fi
                        else
                            if [[ ("$blockFour" == "EN") || ("$blockFour" == "en") || ("$blockFour" == "ES") || ("$blockFour" == "es") || ("$blockFour" == "FR") || ("$blockFour" == "fr") || ("$blockFour" == "OG") || ("$blockFour" == "og") ]];
                            then
                                language=$(echo $blockFour)
                            else
                                imageDesc=$(echo $blockFour)
                            fi
                        fi
                    fi
                fi
            fi

            if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
            then
                imageSize=$(echo $blockFive)
            else
                blockFiveTypeCheck=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockFiveTypeCheck" == "cover") || ("$blockFiveTypeCheck" == "feature") || ("$blockFiveTypeCheck" == "keyart") || ("$blockFiveTypeCheck" == *"still"*) || ("$blockFiveTypeCheck" == "blank") || ("$blockFiveTypeCheck" == "poster") ]];
                then
                    imageType=$(echo $blockFiveTypeCheck)
                else
                    if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFive" =~ ^(S|s).*[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                    then
                        if [[ "$blockFive" == *"still"* || "$blockFive" == *"Still"* || "$blockFive" == *"stil"* || "$blockFive" == *"Stil"* ]];
                        then
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Five {$blockFive} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                            imageType="still"
                        else
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Five {$blockFive} - Does NOT contain Still" >> "$logfile"
                            seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                            episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                        fi
                    else
                        if [[ ("$blockFive" == "EN") || ("$blockFive" == "en") || ("$blockFive" == "ES") || ("$blockFive" == "es") || ("$blockFive" == "FR") || ("$blockFive" == "fr") || ("$blockFive" == "OG") || ("$blockFive" == "og") ]];
                        then
                            language=$(echo $blockFive)
                        else
                            imageDesc=$(echo $blockFive)
                        fi
                    fi
                fi
            fi

            if [[ $titleCode == "S"* ]];
            then 
                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
            else
                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value></field>"
            fi
            
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageSize - $imageSize" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
            
        else
            if [[ $numberOfUnderscores == 3 ]];
                then
                    blockOne=$(echo $title | awk -F "_" '{print $1}')
                    blockTwo=$(echo $title | awk -F "_" '{print $2}')
                    blockThree=$(echo $title | awk -F "_" '{print $3}')
                    blockFour=$(echo $title | awk -F "_" '{print $4}')

                    blockOneCharCount=$(echo -n $blockOne | wc -c)
                    blockTwoCharCount=$(echo -n $blockTwo | wc -c)
                    blockThreeCharCount=$(echo -n $blockThree | wc -c)
                    blockFourCharCount=$(echo -n $blockFour | wc -c)

                    if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                    then
                        case $blockOneCharCount in
                            "7")
                                titleCode=$(echo $blockOne)
                            ;;
                            "9")
                                titleCode=$(echo $blockOne)
                                seasonCheck=$(echo $blockOne | sed -E 's/.*(..)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockOne)
                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                titleByLanguage=$(echo $blockOne)
                            ;;
                        esac
                    else
                        titleByLanguage=$(echo $blockOne)
                    fi

                    if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                    then
                        language=$(echo $blockTwo)
                    else
                        blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                        if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") || ("$blockTwo" == "poster") ]];
                        then
                            imageType=$(echo $blockTwo)
                        fi
                    fi

                    if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                    then
                        case $blockThreeCharCount in
                            "7")
                                titleCode=$(echo $blockThree)
                            ;;
                            "9")
                                titleCode=$(echo $blockThree)
                                seasonCheck=$(echo $blockThree | sed -E 's/.*(..)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockThree)
                                seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                titleByLanguage=$(echo $blockThree)
                            ;;
                        esac
                    else
                        if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                        then
                            imageSize=$(echo $blockThree)
                        else
                            if [[ "$blockThree" == *" "* ]];
                            then
                                titleByLanguage=$(echo $blockThree)
                            else
                                titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                            fi
                        fi
                    fi
                    
                    if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                    then
                        imageSize=$(echo $blockFour)
                    else
                        blockFourTypeCheck=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                        if [[ ("$blockFourTypeCheck" == "cover") || ("$blockFourTypeCheck" == "feature") || ("$blockFourTypeCheck" == "keyart") || ("$blockFourTypeCheck" == *"still"*) || ("$blockFourTypeCheck" == "blank") || ("$blockFourTypeCheck" == "poster") ]];
                        then
                            imageType=$(echo $blockFourTypeCheck)
                        else
                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFour" =~ ^(S|s).*[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                            then
                                if [[ "$blockFour" == *"still"* || "$blockFour" == *"Still"* ]];
                                then
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                else
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - Does NOT contain Still" >> "$logfile"
                                    seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                    episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                fi
                            else
                                if [[ ("$blockFour" == "EN") || ("$blockFour" == "en") || ("$blockFour" == "ES") || ("$blockFour" == "es") || ("$blockFour" == "FR") || ("$blockFour" == "fr") || ("$blockFour" == "OG") || ("$blockFour" == "og") ]];
                                then
                                    language=$(echo $blockFour)
                                else
                                    imageDesc=$(echo $blockFour)
                                fi
                            fi
                        fi
                    fi

                    if [[ $titleCode == "S"* ]];
                    then 
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                    else
                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value></field>"
                    fi
                    
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                    
                else
                    if [[ $numberOfUnderscores == 2 ]];
                        then
                            namingConventionCheck=$(echo $title | awk -F "_" '{print $2}')
                            if [[ ("$namingConventionCheck" == "EN") || ("$namingConventionCheck" == "ES") || ("$namingConventionCheck" == "FR") || ("$namingConventionCheck" == "OG") ]];
                                then
                                    titleByLanguage=$(echo $title | awk -F "_" '{print $1}')
                                    #titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                    language=$(echo $title | awk -F "_" '{print $2}')
                                    titleCode=$(echo $title | awk -F "_" '{print $3}')
                                    imageType=$(echo $title | awk -F "_" '{print $4}')

                                    seasonNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                    episodeNumberCheck=$(echo $imageType | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')

                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                else
                                    titleCode=$(echo $title | awk -F "_" '{print $1}')
                                    imageType=$(echo $title | awk -F "_" '{print $2}')
                                    titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                    titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")

                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                fi
                        else
                            if [[ $numberOfUnderscores == 5 ]];
                                then
                                    blockOne=$(echo $title | awk -F "_" '{print $1}')
                                    blockTwo=$(echo $title | awk -F "_" '{print $2}')
                                    blockThree=$(echo $title | awk -F "_" '{print $3}')
                                    blockFour=$(echo $title | awk -F "_" '{print $4}')
                                    blockFive=$(echo $title | awk -F "_" '{print $5}')
                                    blockSix=$(echo $title | awk -F "_" '{print $6}')

                                    blockOneCharCount=$(echo -n $blockOne | wc -c)
                                    blockTwoCharCount=$(echo -n $blockTwo | wc -c)
                                    blockThreeCharCount=$(echo -n $blockThree | wc -c)
                                    blockFourCharCount=$(echo -n $blockFour | wc -c)
                                    blockFiveCharCount=$(echo -n $blockFive | wc -c)
                                    blockSixCharCount=$(echo -n $blockSix | wc -c)

                                    if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                    then
                                        case $blockOneCharCount in
                                            "7")
                                                titleCode=$(echo $blockOne)
                                            ;;
                                            "9")
                                                titleCode=$(echo $blockOne)
                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(..)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockOne)
                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                titleByLanguage=$(echo $blockOne)
                                            ;;
                                        esac
                                    else
                                        titleByLanguage=$(echo $blockOne)
                                    fi

                                    if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                    then
                                        language=$(echo $blockTwo)
                                    else
                                        blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") || ("$blockTwo" == "poster") ]];
                                        then
                                            imageType=$(echo $blockTwo)
                                        fi
                                    fi

                                    if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                    then
                                        case $blockThreeCharCount in
                                            "7")
                                                titleCode=$(echo $blockThree)
                                            ;;
                                            "9")
                                                titleCode=$(echo $blockThree)
                                                seasonCheck=$(echo $blockThree | sed -E 's/.*(..)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockThree)
                                                seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                titleByLanguage=$(echo $blockThree)
                                            ;;
                                        esac
                                    else
                                        if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                        then
                                            imageSize=$(echo $blockThree)
                                        else
                                            if [[ "$blockThree" == *" "* ]];
                                            then
                                                titleByLanguage=$(echo $blockThree)
                                            else
                                                titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                            fi
                                        fi
                                    fi
                                    
                                    if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                    then
                                        imageSize=$(echo $blockFour)
                                    else
                                        blockFourTypeCheck=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockFourTypeCheck" == "cover") || ("$blockFourTypeCheck" == "feature") || ("$blockFourTypeCheck" == "keyart") || ("$blockFourTypeCheck" == *"still"*) || ("$blockFourTypeCheck" == "blank") || ("$blockFourTypeCheck" == "poster") ]];
                                        then
                                            imageType=$(echo $blockFourTypeCheck)
                                        else
                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFour" =~ ^(S|s).*[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                            then
                                                if [[ "$blockFour" == *"still"* || "$blockFour" == *"Still"* ]];
                                                then
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                else
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - Does NOT contain Still" >> "$logfile"
                                                    seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                    episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                fi
                                            else
                                                if [[ ("$blockFour" == "EN") || ("$blockFour" == "en") || ("$blockFour" == "ES") || ("$blockFour" == "es") || ("$blockFour" == "FR") || ("$blockFour" == "fr") || ("$blockFour" == "OG") || ("$blockFour" == "og") ]];
                                                then
                                                    language=$(echo $blockFour)
                                                else
                                                    imageDesc=$(echo $blockFour)
                                                fi
                                            fi
                                        fi
                                    fi

                                    if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                    then
                                        imageSize=$(echo $blockFive)
                                    else
                                        blockFiveTypeCheck=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockFiveTypeCheck" == "cover") || ("$blockFiveTypeCheck" == "feature") || ("$blockFiveTypeCheck" == "keyart") || ("$blockFiveTypeCheck" == *"still"*) || ("$blockFiveTypeCheck" == "blank") || ("$blockFiveTypeCheck" == "poster") ]];
                                        then
                                            imageType=$(echo $blockFiveTypeCheck)
                                        else
                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFive" =~ ^(S|s).*[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                            then
                                                if [[ "$blockFive" == *"still"* || "$blockFive" == *"Still"* ]];
                                                then
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                else
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - Does NOT contain Still" >> "$logfile"
                                                    seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                    episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                fi
                                            else
                                                if [[ ("$blockFive" == "EN") || ("$blockFive" == "en") || ("$blockFive" == "ES") || ("$blockFive" == "es") || ("$blockFive" == "FR") || ("$blockFive" == "fr") || ("$blockFive" == "OG") || ("$blockFive" == "og") ]];
                                                then
                                                    language=$(echo $blockFive)
                                                else
                                                    imageDesc=$(echo $blockFive)
                                                fi
                                            fi
                                        fi
                                    fi

                                    if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                    then
                                        imageSize=$(echo $blockSix)
                                    else
                                        blockSixTypeCheck=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockSixTypeCheck" == "cover") || ("$blockSixTypeCheck" == "feature") || ("$blockSixTypeCheck" == "keyart") || ("$blockSixTypeCheck" == *"still"*) || ("$blockSixTypeCheck" == "blank") || ("$blockSixTypeCheck" == "poster") ]];
                                        then
                                            imageType=$(echo $blockSixTypeCheck)
                                        else
                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockSix" =~ ^(S|s).*[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                            then
                                                if [[ "$blockSix" == *"still"* || "$blockSix" == *"Still"* ]];
                                                then
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                else
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - Does NOT contain Still" >> "$logfile"
                                                    seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                    episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                fi
                                            else
                                                if [[ ("$blockSix" == "EN") || ("$blockSix" == "en") || ("$blockSix" == "ES") || ("$blockSix" == "es") || ("$blockSix" == "FR") || ("$blockSix" == "fr") || ("$blockSix" == "OG") || ("$blockSix" == "og") ]];
                                                then
                                                    language=$(echo $blockSix)
                                                else
                                                    imageDesc=$(echo $blockSix)
                                                fi
                                            fi
                                        fi
                                    fi

                                    if [[ $titleCode == "S"* ]];
                                    then 
                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                    else
                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value></field>"
                                    fi
                                    
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                else
                                    if [[ $numberOfUnderscores == 6 ]];
                                        then
                                            blockOne=$(echo $title | awk -F "_" '{print $1}')
                                            blockTwo=$(echo $title | awk -F "_" '{print $2}')
                                            blockThree=$(echo $title | awk -F "_" '{print $3}')
                                            blockFour=$(echo $title | awk -F "_" '{print $4}')
                                            blockFive=$(echo $title | awk -F "_" '{print $5}')
                                            blockSix=$(echo $title | awk -F "_" '{print $6}')
                                            blockSeven=$(echo $title | awk -F "_" '{print $7}')

                                            blockOneCharCount=$(echo -n $blockOne | wc -c)
                                            blockTwoCharCount=$(echo -n $blockTwo | wc -c)
                                            blockThreeCharCount=$(echo -n $blockThree | wc -c)
                                            blockFourCharCount=$(echo -n $blockFour | wc -c)
                                            blockFiveCharCount=$(echo -n $blockFive | wc -c)
                                            blockSixCharCount=$(echo -n $blockSix | wc -c)
                                            blockSevenCharCount=$(echo -n $blockSeven | wc -c)

                                            if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockOneCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockOne)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockOne)
                                                        seasonCheck=$(echo $blockOne | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockOne)
                                                        seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        titleByLanguage=$(echo $blockOne)
                                                    ;;
                                                esac
                                            else
                                                titleByLanguage=$(echo $blockOne)
                                            fi

                                            if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                            then
                                                language=$(echo $blockTwo)
                                            else
                                                blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") || ("$blockTwo" == "poster") ]];
                                                then
                                                    imageType=$(echo $blockTwo)
                                                fi
                                            fi

                                            if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockThreeCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockThree)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockThree)
                                                        seasonCheck=$(echo $blockThree | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockThree)
                                                        seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        titleByLanguage=$(echo $blockThree)
                                                    ;;
                                                esac
                                            else
                                                if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                then
                                                    imageSize=$(echo $blockThree)
                                                else
                                                    if [[ "$blockThree" == *" "* ]];
                                                    then
                                                        titleByLanguage=$(echo $blockThree)
                                                    else
                                                        titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                    fi
                                                fi
                                            fi
                                            
                                            if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                            then
                                                imageSize=$(echo $blockFour)
                                            else
                                                blockFourTypeCheck=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockFourTypeCheck" == "cover") || ("$blockFourTypeCheck" == "feature") || ("$blockFourTypeCheck" == "keyart") || ("$blockFourTypeCheck" == *"still"*) || ("$blockFourTypeCheck" == "blank") || ("$blockFourTypeCheck" == "poster") ]];
                                                then
                                                    imageType=$(echo $blockFourTypeCheck)
                                                else
                                                    if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFour" =~ ^(S|s).*[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                    then
                                                        if [[ "$blockFour" == *"still"* || "$blockFour" == *"Still"* ]];
                                                        then
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                        else
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - Does NOT contain Still" >> "$logfile"
                                                            seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                            episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        fi
                                                    else
                                                        if [[ ("$blockFour" == "EN") || ("$blockFour" == "en") || ("$blockFour" == "ES") || ("$blockFour" == "es") || ("$blockFour" == "FR") || ("$blockFour" == "fr") || ("$blockFour" == "OG") || ("$blockFour" == "og") ]];
                                                        then
                                                            language=$(echo $blockFour)
                                                        else
                                                            imageDesc=$(echo $blockFour)
                                                        fi
                                                    fi
                                                fi
                                            fi

                                            if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                            then
                                                imageSize=$(echo $blockFive)
                                            else
                                                blockFiveTypeCheck=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockFiveTypeCheck" == "cover") || ("$blockFiveTypeCheck" == "feature") || ("$blockFiveTypeCheck" == "keyart") || ("$blockFiveTypeCheck" == *"still"*) || ("$blockFiveTypeCheck" == "blank") || ("$blockFiveTypeCheck" == "poster") ]];
                                                then
                                                    imageType=$(echo $blockFiveTypeCheck)
                                                else
                                                    if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFive" =~ ^(S|s).*[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                    then
                                                        if [[ "$blockFive" == *"still"* || "$blockFive" == *"Still"* ]];
                                                        then
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                        else
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - Does NOT contain Still" >> "$logfile"
                                                            seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                            episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        fi
                                                    else
                                                        if [[ ("$blockFive" == "EN") || ("$blockFive" == "en") || ("$blockFive" == "ES") || ("$blockFive" == "es") || ("$blockFive" == "FR") || ("$blockFive" == "fr") || ("$blockFive" == "OG") || ("$blockFive" == "og") ]];
                                                        then
                                                            language=$(echo $blockFive)
                                                        else
                                                            imageDesc=$(echo $blockFive)
                                                        fi
                                                    fi
                                                fi
                                            fi

                                            if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                            then
                                                imageSize=$(echo $blockSix)
                                            else
                                                blockSixTypeCheck=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockSixTypeCheck" == "cover") || ("$blockSixTypeCheck" == "feature") || ("$blockSixTypeCheck" == "keyart") || ("$blockSixTypeCheck" == *"still"*) || ("$blockSixTypeCheck" == "blank") || ("$blockSixTypeCheck" == "poster") ]];
                                                then
                                                    imageType=$(echo $blockSixTypeCheck)
                                                else
                                                    if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockSix" =~ ^(S|s).*[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                    then
                                                        if [[ "$blockSix" == *"still"* || "$blockSix" == *"Still"* ]];
                                                        then
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                        else
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - Does NOT contain Still" >> "$logfile"
                                                            seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                            episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        fi
                                                    else
                                                        if [[ ("$blockSix" == "EN") || ("$blockSix" == "en") || ("$blockSix" == "ES") || ("$blockSix" == "es") || ("$blockSix" == "FR") || ("$blockSix" == "fr") || ("$blockSix" == "OG") || ("$blockSix" == "og") ]];
                                                        then
                                                            language=$(echo $blockSix)
                                                        else
                                                            imageDesc=$(echo $blockSix)
                                                        fi
                                                    fi
                                                fi
                                            fi

                                            if [[ "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                            then
                                                imageSize=$(echo $blockSeven)
                                            else
                                                blockSevenTypeCheck=$(echo $blockSeven | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockSevenTypeCheck" == "cover") || ("$blockSevenTypeCheck" == "feature") || ("$blockSevenTypeCheck" == "keyart") || ("$blockSevenTypeCheck" == *"still"*) || ("$blockSevenTypeCheck" == "blank") || ("$blockSevenTypeCheck" == "poster") ]];
                                                then
                                                    imageType=$(echo $blockSevenTypeCheck)
                                                else
                                                    if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockSeven" =~ ^(S|s).*[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockSeven" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                    then
                                                        if [[ "$blockSeven" == *"still"* || "$blockSeven" == *"Still"* ]];
                                                        then
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSeven} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                        else
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSeven} - Does NOT contain Still" >> "$logfile"
                                                            seasonNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                            episodeNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        fi
                                                    else
                                                        if [[ ("$blockSeven" == "EN") || ("$blockSeven" == "en") || ("$blockSeven" == "ES") || ("$blockSeven" == "es") || ("$blockSeven" == "FR") || ("$blockSeven" == "fr") || ("$blockSeven" == "OG") || ("$blockSeven" == "og") ]];
                                                        then
                                                            language=$(echo $blockSeven)
                                                        else
                                                            imageDesc=$(echo $blockSeven)
                                                        fi
                                                    fi
                                                fi
                                            fi

                                            if [[ $titleCode == "S"* ]];
                                            then 
                                                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value><value>$blockSeven</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                            else
                                                graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value><value>$blockSeven</value></field>"
                                            fi
                                            
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                        else
                                            if [[ $numberOfUnderscores == 7 ]];
                                                then
                                                    blockOne=$(echo $title | awk -F "_" '{print $1}')
                                                    blockTwo=$(echo $title | awk -F "_" '{print $2}')
                                                    blockThree=$(echo $title | awk -F "_" '{print $3}')
                                                    blockFour=$(echo $title | awk -F "_" '{print $4}')
                                                    blockFive=$(echo $title | awk -F "_" '{print $5}')
                                                    blockSix=$(echo $title | awk -F "_" '{print $6}')
                                                    blockSeven=$(echo $title | awk -F "_" '{print $7}')
                                                    blockEight=$(echo $title | awk -F "_" '{print $8}')

                                                    blockOneCharCount=$(echo -n $blockOne | wc -c)
                                                    blockTwoCharCount=$(echo -n $blockTwo | wc -c)
                                                    blockThreeCharCount=$(echo -n $blockThree | wc -c)
                                                    blockFourCharCount=$(echo -n $blockFour | wc -c)
                                                    blockFiveCharCount=$(echo -n $blockFive | wc -c)
                                                    blockSixCharCount=$(echo -n $blockSix | wc -c)
                                                    blockSevenCharCount=$(echo -n $blockSeven | wc -c)
                                                    blockEightCharCount=$(echo -n $blockEight | wc -c)

                                                    if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockOneCharCount in
                                                            "7")
                                                                titleCode=$(echo $blockOne)
                                                            ;;
                                                            "9")
                                                                titleCode=$(echo $blockOne)
                                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(..)/\1/')
                                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "10")
                                                                titleCode=$(echo $blockOne)
                                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "11")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "12")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "13")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            *)
                                                                titleByLanguage=$(echo $blockOne)
                                                            ;;
                                                        esac
                                                    else
                                                        titleByLanguage=$(echo $blockOne)
                                                    fi

                                                    if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                                    then
                                                        language=$(echo $blockTwo)
                                                    else
                                                        blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") || ("$blockTwo" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockTwo)
                                                        fi
                                                    fi

                                                    if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockThreeCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockThree)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonCheck=$(echo $blockThree | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    titleByLanguage=$(echo $blockThree)
                                                                ;;
                                                        esac
                                                    else
                                                        if [[ "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockThree" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                        then
                                                            imageSize=$(echo $blockThree)
                                                        else
                                                            if [[ "$blockThree" == *" "* ]];
                                                            then
                                                                titleByLanguage=$(echo $blockThree)
                                                            else
                                                                titleByLanguage=$(echo $blockThree | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                            fi
                                                        fi
                                                    fi
                                                    
                                                    if [[ "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFour" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                    then
                                                        imageSize=$(echo $blockFour)
                                                    else
                                                        blockFourTypeCheck=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockFourTypeCheck" == "cover") || ("$blockFourTypeCheck" == "feature") || ("$blockFourTypeCheck" == "keyart") || ("$blockFourTypeCheck" == *"still"*) || ("$blockFourTypeCheck" == "blank") || ("$blockFourTypeCheck" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockFourTypeCheck)
                                                        else
                                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFour" =~ ^(S|s).*[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFour" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                            then
                                                                if [[ "$blockFour" == *"still"* || "$blockFour" == *"Still"* ]];
                                                                then
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                                else
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFour} - Does NOT contain Still" >> "$logfile"
                                                                    seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                                    episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                                fi
                                                            else
                                                                if [[ ("$blockFour" == "EN") || ("$blockFour" == "en") || ("$blockFour" == "ES") || ("$blockFour" == "es") || ("$blockFour" == "FR") || ("$blockFour" == "fr") || ("$blockFour" == "OG") || ("$blockFour" == "og") ]];
                                                                then
                                                                    language=$(echo $blockFour)
                                                                else
                                                                    imageDesc=$(echo $blockFour)
                                                                fi
                                                            fi
                                                        fi
                                                    fi

                                                    if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                    then
                                                        imageSize=$(echo $blockFive)
                                                    else
                                                        blockFiveTypeCheck=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockFiveTypeCheck" == "cover") || ("$blockFiveTypeCheck" == "feature") || ("$blockFiveTypeCheck" == "keyart") || ("$blockFiveTypeCheck" == *"still"*) || ("$blockFiveTypeCheck" == "blank") || ("$blockFiveTypeCheck" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockFiveTypeCheck)
                                                        else
                                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockFive" =~ ^(S|s).*[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockFive" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                            then
                                                                if [[ "$blockFive" == *"still"* || "$blockFive" == *"Still"* ]];
                                                                then
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                                else
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockFive} - Does NOT contain Still" >> "$logfile"
                                                                    seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                                    episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                                fi
                                                            else
                                                                if [[ ("$blockFive" == "EN") || ("$blockFive" == "en") || ("$blockFive" == "ES") || ("$blockFive" == "es") || ("$blockFive" == "FR") || ("$blockFive" == "fr") || ("$blockFive" == "OG") || ("$blockFive" == "og") ]];
                                                                then
                                                                    language=$(echo $blockFive)
                                                                else
                                                                    imageDesc=$(echo $blockFive)
                                                                fi
                                                            fi
                                                        fi
                                                    fi

                                                    if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                    then
                                                        imageSize=$(echo $blockSix)
                                                    else
                                                        blockSixTypeCheck=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockSixTypeCheck" == "cover") || ("$blockSixTypeCheck" == "feature") || ("$blockSixTypeCheck" == "keyart") || ("$blockSixTypeCheck" == *"still"*) || ("$blockSixTypeCheck" == "blank") || ("$blockSixTypeCheck" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockSixTypeCheck)
                                                        else
                                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockSix" =~ ^(S|s).*[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockSix" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                            then
                                                                if [[ "$blockSix" == *"still"* || "$blockSix" == *"Still"* ]];
                                                                then
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                                else
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSix} - Does NOT contain Still" >> "$logfile"
                                                                    seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                                    episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                                fi
                                                            else
                                                                if [[ ("$blockSix" == "EN") || ("$blockSix" == "en") || ("$blockSix" == "ES") || ("$blockSix" == "es") || ("$blockSix" == "FR") || ("$blockSix" == "fr") || ("$blockSix" == "OG") || ("$blockSix" == "og") ]];
                                                                then
                                                                    language=$(echo $blockSix)
                                                                else
                                                                    imageDesc=$(echo $blockSix)
                                                                fi
                                                            fi
                                                        fi
                                                    fi

                                                    if [[ "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                    then
                                                        imageSize=$(echo $blockSeven)
                                                    else
                                                        blockSevenTypeCheck=$(echo $blockSeven | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockSevenTypeCheck" == "cover") || ("$blockSevenTypeCheck" == "feature") || ("$blockSevenTypeCheck" == "keyart") || ("$blockSevenTypeCheck" == *"still"*) || ("$blockSevenTypeCheck" == "blank") || ("$blockSevenTypeCheck" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockSevenTypeCheck)
                                                        else
                                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockSeven" =~ ^(S|s).*[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockSeven" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockSeven" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                            then
                                                                if [[ "$blockSeven" == *"still"* || "$blockSeven" == *"Still"* ]];
                                                                then
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSeven} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                                else
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockSeven} - Does NOT contain Still" >> "$logfile"
                                                                    seasonNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                                    episodeNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                                fi
                                                            else
                                                                if [[ ("$blockSeven" == "EN") || ("$blockSeven" == "en") || ("$blockSeven" == "ES") || ("$blockSeven" == "es") || ("$blockSeven" == "FR") || ("$blockSeven" == "fr") || ("$blockSeven" == "OG") || ("$blockSeven" == "og") ]];
                                                                then
                                                                    language=$(echo $blockSeven)
                                                                else
                                                                    imageDesc=$(echo $blockSeven)
                                                                fi
                                                            fi
                                                        fi
                                                    fi

                                                    if [[ "$blockEight" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                    then
                                                        imageSize=$(echo $blockEight)
                                                    else
                                                        blockEightTypeCheck=$(echo $blockEight | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockEightTypeCheck" == "cover") || ("$blockEightTypeCheck" == "feature") || ("$blockEightTypeCheck" == "keyart") || ("$blockEightTypeCheck" == *"still"*) || ("$blockEightTypeCheck" == "blank") || ("$blockEightTypeCheck" == "poster") ]];
                                                        then
                                                            imageType=$(echo $blockEightTypeCheck)
                                                        else
                                                            if [[ (-z "$seasonNumberCheck" || -z "$episodeNumberCheck") && ("$blockEight" =~ ^(S|s).*[0-9]$ || "$blockEight" =~ ^(S|s)[0-9].*(E|e)[0-9]$ || "$blockEight" =~ ^(S|s)[0-9].*(E|e)[0-9][0-9]$ || "$blockEight" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9]$ || "$blockEight" =~ ^(S|s)[0-9][0-9].*(E|e)[0-9][0-9]$) ]];
                                                            then
                                                                if [[ "$blockEight" == *"still"* || "$blockEight" == *"Still"* ]];
                                                                then
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockEight} - DOES contain Still - Not extracting Season & Episode Number" >> "$logfile"
                                                                else
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Block Four {$blockEight} - Does NOT contain Still" >> "$logfile"
                                                                    seasonNumberCheck=$(echo $blockEight | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                                    episodeNumberCheck=$(echo $blockEight | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                                fi
                                                            else
                                                                if [[ ("$blockEight" == "EN") || ("$blockEight" == "en") || ("$blockEight" == "ES") || ("$blockEight" == "es") || ("$blockEight" == "FR") || ("$blockEight" == "fr") || ("$blockEight" == "OG") || ("$blockEight" == "og") ]];
                                                                then
                                                                    language=$(echo $blockEight)
                                                                else
                                                                    imageDesc=$(echo $blockEight)
                                                                fi
                                                            fi
                                                        fi
                                                    fi

                                                    if [[ $titleCode == "S"* ]];
                                                    then 
                                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value><value>$blockSeven</value><value>$blockEight</value></field><field><name>oly_seasonNumber</name><value>$seasonNumberCheck</value></field><field><name>oly_episodeNumber</name><value>$episodeNumberCheck</value></field>"
                                                    else
                                                        graphicsTags="<field><name>oly_graphicsTags</name><value>$blockOne</value><value>$blockTwo</value><value>$blockThree</value><value>$blockFour</value><value>$blockFive</value><value>$blockSix</value><value>$blockSeven</value><value>$blockEight</value></field>"
                                                    fi
                                                    
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - language - $language" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                            fi
                                    fi
                            fi
                    fi
            fi
    fi

    if [[ $titleCode == "M"* ]];
    then
        if [[ $language == "es" || $language == "ES" ]];
        then
            fieldNameValue="<field><name>oly_titleEs</name><value>$titleByLanguage</value></field>"
        else
            if [[ $language == "en" || $language == "EN" ]];
            then
                fieldNameValue="<field><name>oly_titleEn</name><value>$titleByLanguage</value></field>"
            else
                fieldNameValue="<field><name>oly_originalTitle</name><value>$titleByLanguage</value></field>"
            fi
        fi
    else
        if [[ $language == "es" || $language == "ES" ]];
        then
            fieldNameValue="<field><name>oly_titleEs</name><value>$titleByLanguage</value></field><field><name>oly_seriesName</name><value>$titleByLanguage</value></field>"
        else
            if [[ $language == "en" || $language == "EN" ]];
            then
                fieldNameValue="<field><name>oly_titleEn</name><value>$titleByLanguage</value></field><field><name>oly_seriesName</name><value>$titleByLanguage</value></field>"
            else
                fieldNameValue="<field><name>oly_originalTitle</name><value>$titleByLanguage</value></field><field><name>oly_seriesName</name><value>$titleByLanguage</value></field>"
            fi
        fi
    fi

    case $language in
        "es")
            graphicsLanguage="spanish"
        ;;
        "en")
            graphicsLanguage="english"
        ;;
        "ES")
            graphicsLanguage="spanish"
        ;;
        "EN")
            graphicsLanguage="english"
        ;;
        "FR")
            graphicsLanguage=""
        ;;
        "OG")
            graphicsLanguage=""
        ;;
        *)
            graphicsLanguage=""
        ;;
    esac

    imageTypeCheck=$(echo $imageType | tr '[:upper:]' '[:lower:]')
    case $imageTypeCheck in
        *"cover"*)
            graphicsType="cover"
        ;;
        *"feature"*)
            graphicsType="feature"
        ;;
        *"keyart"*)
            graphicsType="keyart"
        ;;
        *"still"*)
            graphicsType="still"
        ;;
        *"poster"*)
            graphicsType="poster"
        ;;
        *"blank"*)
            graphicsType="blank"
        ;;
        *)
            graphicsType=""
        ;;
    esac

    if [[ "$imageSize" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$imageSize" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$imageSize" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$imageSize" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
    then
        graphicsResolution=$(echo $imageSize)
    fi

    export itemLicensor=""
    if [[ "$titleCode" =~ ^(M|S).*[0-9]$ ]];
    then
        titleCodeCharCount=$(echo -n $titleCode | wc -c)
        if [[ "$titleCode" == M* ]];
        then
            itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" }]}}"
        else
            case $titleCodeCharCount in
                "7")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
                ;;
                "9")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
                ;;
                "10")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
                ;;
                "11")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" }]}}"
                ;;
                "12")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" }]}}"
                ;;
                "13")
                    itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"originalFile\" },{ \"name\": \"oly_originalFileFlags\", \"value\": \"originalrawmaster\" }]}}"
                ;;
                *)
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Title Code Character Count NOT Supported - [$titleCode]" >> "$logfile"
                ;;
            esac
        fi
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Searching Cantemo for Original Raw Master or Series based on Title Code [$titleCode]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Title Code Character Count - [$titleCodeCharCount]" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Body - [$itemSearchBody]" >> "$logfile"
        export itemSearchUrl="http://10.1.1.34/API/v2/search/"
        itemSearchHttpResponse=$(curl --location --request PUT $itemSearchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $itemSearchBody)
        itemHitResults=$(echo $itemSearchHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Number of Hits - [$itemHitResults]" >> "$logfile"
        if [ "$itemHitResults" -eq 1 ];
        then
            itemSearchItemId=$(echo $itemSearchHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            itemSearchItemLicensor=$(echo $itemSearchHttpResponse | awk -F "<oly_licensor>" '{print $2}' | awk -F "</oly_licensor>" '{print $1}')
            itemSearchItemLicensor=$(echo $itemSearchItemLicensor | awk -F "<list-item>" '{print $2}' | awk -F "</list-item>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item ID - [$itemSearchItemId]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item Licensor - [$itemSearchItemLicensor]" >> "$logfile"
            itemLicensor=$(echo "$itemSearchItemLicensor")
            # Create For Distribution Relationship
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Creating For Distribution Relationship with [$itemSearchItemId]" >> "$logfile"
            sleep 1
            createRelationUrl="http://10.1.1.34:8080/API/relation?allowDuplicate=false"
            createForDistributionRelationBody="{\"relation\": [{\"direction\": {\"source\": \"$itemSearchItemId\",\"target\": \"$itemId\",\"type\": \"U\"},\"value\": [{\"key\": \"type\",\"value\": \"portal_undirectional\"},{\"key\": \"cs_type\",\"value\": \"forDistribution\"}]}]}"
            createForDistributionRelationHttpResponse=$(curl --location $createRelationUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=izsJxc40uxUMKwzH4JavShE11i6wz9rKlTg2pavusNjK0gLTqstgxD8kgRLgSiL4' --data $createForDistributionRelationBody)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Sent API Call to Create Season Item - [$createForDistributionRelationHttpResponse]" >> "$logfile"
            sleep 2            
            reindexItemUrl="http://10.1.1.34/API/v2/reindex/"
            reindexItemBody="{ \"items\": [\"$itemId\", \"$itemSearchItemId\"] }"
            reindexItemHttpResponse=$(curl --location --request PUT $reindexItemUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $reindexItemBody)
            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Sent API Call to ReIndex Item - [$reindexItemHttpResponse]" >> "$logfile"
            sleep 2
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - For Distribution Relationship Created" >> "$logfile"
        elif [ "$itemHitResults" -eq 0 ];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - No Search Results Found - Searching for Conform Item" >> "$logfile"
            if [[ "$titleCode" == M* ]];
            then
                itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" }]}}"
            else
                case $titleCodeCharCount in
                    "7")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"series\" }]}}"
                    ;;
                    "9")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
                    ;;
                    "10")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_contentType\", \"value\": \"season\" }]}}"
                    ;;
                    "11")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" }]}}"
                    ;;
                    "12")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" }]}}"
                    ;;
                    "13")
                        itemSearchBody="{ \"filter\": { \"operator\": \"AND\",\"terms\": [{ \"name\": \"oly_titleCode\", \"value\": \"$titleCode\", \"exact\": true },{ \"name\": \"oly_versionType\", \"value\": \"conformFile\" }]}}"
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Title Code Character Count NOT Supported - [$titleCode]" >> "$logfile"
                    ;;
                esac
            fi
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Body - [$itemSearchBody]" >> "$logfile"
            export itemSearchUrl="http://10.1.1.34/API/v2/search/"
            itemSearchHttpResponse=$(curl --location --request PUT $itemSearchUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $itemSearchBody)
            itemHitResults=$(echo $itemSearchHttpResponse | awk -F "<hits>" '{print $2}' | awk -F "</hits>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Number of Hits - [$itemHitResults]" >> "$logfile"
            if [ "$itemHitResults" -eq 1 ];
            then
                itemSearchItemId=$(echo $itemSearchHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                itemSearchItemLicensor=$(echo $itemSearchHttpResponse | awk -F "<oly_licensor>" '{print $2}' | awk -F "</oly_licensor>" '{print $1}')
                itemSearchItemLicensor=$(echo $itemSearchItemLicensor | awk -F "<list-item>" '{print $2}' | awk -F "</list-item>" '{print $1}')
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item ID - [$itemSearchItemId]" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item Licensor - [$itemSearchItemLicensor]" >> "$logfile"
                itemLicensor=$(echo "$itemSearchItemLicensor")
                # Create For Distribution Relationship
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Creating For Distribution Relationship with [$itemSearchItemId]" >> "$logfile"
                sleep 1
                createRelationUrl="http://10.1.1.34:8080/API/relation?allowDuplicate=false"
                createForDistributionRelationBody="{\"relation\": [{\"direction\": {\"source\": \"$itemSearchItemId\",\"target\": \"$itemId\",\"type\": \"U\"},\"value\": [{\"key\": \"type\",\"value\": \"portal_undirectional\"},{\"key\": \"cs_type\",\"value\": \"forDistribution\"}]}]}"
                createForDistributionRelationHttpResponse=$(curl --location $createRelationUrl --header 'Content-Type: application/json' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=izsJxc40uxUMKwzH4JavShE11i6wz9rKlTg2pavusNjK0gLTqstgxD8kgRLgSiL4' --data $createForDistributionRelationBody)
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Sent API Call to Create Season Item - [$createForDistributionRelationHttpResponse]" >> "$logfile"
                sleep 2            
                reindexItemUrl="http://10.1.1.34/API/v2/reindex/"
                reindexItemBody="{ \"items\": [\"$itemId\", \"$itemSearchItemId\"] }"
                reindexItemHttpResponse=$(curl --location --request PUT $reindexItemUrl --header 'Content-Type: application/json' --header 'Accept: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=VDa9RP3Y9rgomyzNWvRxbu7WdTMetVYBlLg6pGMIJ6oyVABsjJiiEK9JCWVA1HYd' --data $reindexItemBody)
                #echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - Sent API Call to ReIndex Item - [$reindexItemHttpResponse]" >> "$logfile"
                sleep 2
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - [$itemId] - For Distribution Relationship Created" >> "$logfile"
            elif [ "$itemHitResults" -eq 0 ];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - No Search Results Found in Second Search - NOT Setting Licensor Variable" >> "$logfile"
            elif [ "$itemHitResults" -gt 1 ];
            then
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Second Search Results - More than 1 Found - Getting first instance of Licensor" >> "$logfile"
                itemSearchItemId=$(echo $itemSearchHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
                itemSearchItemLicensor=$(echo $itemSearchHttpResponse | awk -F "<oly_licensor>" '{print $2}' | awk -F "</oly_licensor>" '{print $1}')
                itemSearchItemLicensor=$(echo $itemSearchItemLicensor | awk -F "<list-item>" '{print $2}' | awk -F "</list-item>" '{print $1}')
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item ID - [$itemSearchItemId]" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item Licensor - [$itemSearchItemLicensor]" >> "$logfile"
                itemLicensor=$(echo "$itemSearchItemLicensor")
            fi
        elif [ "$itemHitResults" -gt 1 ];
        then
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - More than 1 Found - Getting first instance of Licensor" >> "$logfile"
            itemSearchItemId=$(echo $itemSearchHttpResponse | awk -F "<id>" '{print $2}' | awk -F "</id>" '{print $1}')
            itemSearchItemLicensor=$(echo $itemSearchHttpResponse | awk -F "<oly_licensor>" '{print $2}' | awk -F "</oly_licensor>" '{print $1}')
            itemSearchItemLicensor=$(echo $itemSearchItemLicensor | awk -F "<list-item>" '{print $2}' | awk -F "</list-item>" '{print $1}')
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item ID - [$itemSearchItemId]" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Search Results - Item Licensor - [$itemSearchItemLicensor]" >> "$logfile"
            itemLicensor=$(echo "$itemSearchItemLicensor")
        fi
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Title Code is NOT correct format - NOT Searching API for Item based on Title Code" >> "$logfile"
    fi
    
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Graphics Type - $graphicsType" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Graphics Resolution - $graphicsResolution" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Graphics Language - $graphicsLanguage" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Graphics Tags - $graphicsTags" >> "$logfile"

    bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\">$graphicsTags<field><name>oly_titleCode</name><value>$titleCode</value></field><field><name>oly_licensor</name><value>$itemLicensor</value></field><field><name>oly_primaryMetadataLanguage</name><value>$graphicsLanguage</value></field><field><name>oly_graphicsLanguage</name><value>$graphicsLanguage</value></field><field><name>oly_graphicsResolution</name><value>$graphicsResolution</value></field>$fieldNameValue<field><name>oly_graphicsType</name><value>$graphicsType</value></field></timespan></MetadataDocument>")

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Body Data - $bodyData" >> "$logfile"

    curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

    sleep 5

    echo "$(date +%Y/%m/%d_%H:%M:%S) - (graphicWorkflow) - ($itemId) - Metadata Update Completed" >> "$logfile"
fi

IFS=$saveIFS