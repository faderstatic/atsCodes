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

# Function for processing Original Raw Master or Conform File Items
processContent() {
    export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Deconstructing Title - $title" >> "$logfile"
    sleep 2
    if [[ "$title" == *_RAW ]];
    then
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Title ends with _RAW - {$title} - Removing _RAW" >> "$logfile"
        title=$(echo $title | sed 's/.\{4\}$//')
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - New Title - {$title}" >> "$logfile"
    fi
    numberOfUnderscores=$(echo $title | awk -F"_" '{print NF-1}')
    echo $numberOfUnderscores
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Number of Underscores - $numberOfUnderscores" >> "$logfile"
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
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockOne)
                        seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockOne)
                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                    ;;
                esac
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
            fi
            if [[ "$blockTwo" =~ ^(M|S).*[0-9]$ ]];
            then
                case $blockTwoCharCount in
                    "7")
                        titleCode=$(echo $blockTwo)
                    ;;
                    "9")
                        titleCode=$(echo $blockTwo)
                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(..)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockTwo)
                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockTwo)
                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockTwo)
                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockTwo)
                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "2")
                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "6" | "5" | "4")
                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                    ;;
                esac
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockThree)
                        seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockThree)
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "2")
                        seasonCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "6" | "5" | "4")
                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                    ;;
                esac
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockFour)
                        seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockFour)
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "2")
                        seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "6" | "5" | "4")
                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                    ;;
                esac
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
            fi
            if [[ "$blockFive" =~ ^(M|S).*[0-9]$ ]];
            then
                case $blockFiveCharCount in
                    "7")
                        titleCode=$(echo $blockFive)
                    ;;
                    "9")
                        titleCode=$(echo $blockFive)
                        seasonCheck=$(echo $blockFive | sed -E 's/.*(..)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "10")
                        titleCode=$(echo $blockFive)
                        seasonCheck=$(echo $blockFive | sed -E 's/.*(...)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "11")
                        titleCode=$(echo $blockFive)
                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "12")
                        titleCode=$(echo $blockFive)
                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "13")
                        titleCode=$(echo $blockFive)
                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(......)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "2")
                        seasonCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                        fi
                    ;;
                    "6" | "5" | "4")
                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                        then
                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                        fi
                    ;;
                    *)
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                    ;;
                esac
            else
                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
            fi
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - +++++++++++++++++++++++++++++++++" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - titleCode - $titleCode" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumber - $seasonNumberCheck" >> "$logfile"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumber - $episodeNumberCheck" >> "$logfile"
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
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockOne)
                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockOne)
                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                            ;;
                        esac
                    else
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                    fi
                    if [[ "$blockTwo" =~ ^(M|S).*[0-9]$ ]];
                    then
                        case $blockTwoCharCount in
                            "7")
                                titleCode=$(echo $blockTwo)
                            ;;
                            "9")
                                titleCode=$(echo $blockTwo)
                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(..)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockTwo)
                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockTwo)
                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockTwo)
                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockTwo)
                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "2")
                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "6" | "5" | "4")
                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
                            ;;
                        esac
                    else
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
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
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockThree)
                                seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockThree)
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "2")
                                seasonCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "6" | "5" | "4")
                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                            ;;
                        esac
                    else
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "10")
                                titleCode=$(echo $blockFour)
                                seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "11")
                                titleCode=$(echo $blockFour)
                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "12")
                                titleCode=$(echo $blockFour)
                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "13")
                                titleCode=$(echo $blockFour)
                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "2")
                                seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                fi
                            ;;
                            "6" | "5" | "4")
                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                then
                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                fi
                            ;;
                            *)
                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                            ;;
                        esac
                    else
                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                    fi
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - +++++++++++++++++++++++++++++++++" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - titleCode - $titleCode" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumber - $seasonNumberCheck" >> "$logfile"
                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumber - $episodeNumberCheck" >> "$logfile"
                else
                    if [[ $numberOfUnderscores == 2 ]];
                        then
                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Number of Underscores NOT Supported {$numberOfUnderscores}" >> "$logfile"
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
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockOne)
                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockOne)
                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                    fi
                                    if [[ "$blockTwo" =~ ^(M|S).*[0-9]$ ]];
                                    then
                                        case $blockTwoCharCount in
                                            "7")
                                                titleCode=$(echo $blockTwo)
                                            ;;
                                            "9")
                                                titleCode=$(echo $blockTwo)
                                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(..)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockTwo)
                                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockTwo)
                                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockTwo)
                                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockTwo)
                                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "2")
                                                seasonCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "6" | "5" | "4")
                                                seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
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
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockThree)
                                                seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockThree)
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "2")
                                                seasonCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "6" | "5" | "4")
                                                seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockFour)
                                                seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockFour)
                                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockFour)
                                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockFour)
                                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "2")
                                                seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "6" | "5" | "4")
                                                seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                    fi
                                    if [[ "$blockFive" =~ ^(M|S).*[0-9]$ ]];
                                    then
                                        case $blockFiveCharCount in
                                            "7")
                                                titleCode=$(echo $blockFive)
                                            ;;
                                            "9")
                                                titleCode=$(echo $blockFive)
                                                seasonCheck=$(echo $blockFive | sed -E 's/.*(..)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockFive)
                                                seasonCheck=$(echo $blockFive | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockFive)
                                                seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockFive)
                                                seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockFive)
                                                seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "2")
                                                seasonCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "6" | "5" | "4")
                                                seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                    fi
                                    if [[ "$blockSix" =~ ^(M|S).*[0-9]$ ]];
                                    then
                                        case $blockSixCharCount in
                                            "7")
                                                titleCode=$(echo $blockSix)
                                            ;;
                                            "9")
                                                titleCode=$(echo $blockSix)
                                                seasonCheck=$(echo $blockSix | sed -E 's/.*(..)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "10")
                                                titleCode=$(echo $blockSix)
                                                seasonCheck=$(echo $blockSix | sed -E 's/.*(...)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "11")
                                                titleCode=$(echo $blockSix)
                                                seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "12")
                                                titleCode=$(echo $blockSix)
                                                seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "13")
                                                titleCode=$(echo $blockSix)
                                                seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(......)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "2")
                                                seasonCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            "6" | "5" | "4")
                                                seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                then
                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                fi
                                            ;;
                                            *)
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                            ;;
                                        esac
                                    else
                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                    fi
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - titleCode - $titleCode" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumber - $episodeNumberCheck" >> "$logfile"
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
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockOne)
                                                        seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockOne)
                                                        seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                            fi
                                            if [[ "$blockTwo" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockTwoCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockTwo)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockTwo)
                                                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockTwo)
                                                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockTwo)
                                                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockTwo)
                                                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockTwo)
                                                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
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
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockThree)
                                                        seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockThree)
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockFour)
                                                        seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockFour)
                                                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockFour)
                                                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockFour)
                                                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                            fi
                                            if [[ "$blockFive" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockFiveCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockFive)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockFive)
                                                        seasonCheck=$(echo $blockFive | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockFive)
                                                        seasonCheck=$(echo $blockFive | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockFive)
                                                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockFive)
                                                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockFive)
                                                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                            fi
                                            if [[ "$blockSix" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockSixCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockSix)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockSix)
                                                        seasonCheck=$(echo $blockSix | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockSix)
                                                        seasonCheck=$(echo $blockSix | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockSix)
                                                        seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockSix)
                                                        seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockSix)
                                                        seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                            fi
                                            if [[ "$blockSeven" =~ ^(M|S).*[0-9]$ ]];
                                            then
                                                case $blockSevenCharCount in
                                                    "7")
                                                        titleCode=$(echo $blockSeven)
                                                    ;;
                                                    "9")
                                                        titleCode=$(echo $blockSeven)
                                                        seasonCheck=$(echo $blockSeven | sed -E 's/.*(..)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "10")
                                                        titleCode=$(echo $blockSeven)
                                                        seasonCheck=$(echo $blockSeven | sed -E 's/.*(...)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "11")
                                                        titleCode=$(echo $blockSeven)
                                                        seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "12")
                                                        titleCode=$(echo $blockSeven)
                                                        seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "13")
                                                        titleCode=$(echo $blockSeven)
                                                        seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(......)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "2")
                                                        seasonCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    "6" | "5" | "4")
                                                        seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                        if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                        then
                                                            seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                            episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                            #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                        fi
                                                    ;;
                                                    *)
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Seven Does NOT Contain Title Code" >> "$logfile"
                                                    ;;
                                                esac
                                            else
                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Seven Does NOT Contain Title Code" >> "$logfile"
                                            fi
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - titleCode - $titleCode" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumber - $episodeNumberCheck" >> "$logfile"
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
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "10")
                                                                titleCode=$(echo $blockOne)
                                                                seasonCheck=$(echo $blockOne | sed -E 's/.*(...)/\1/')
                                                                if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "11")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(....)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "12")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(.....)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            "13")
                                                                titleCode=$(echo $blockOne)
                                                                seasonEpisodeCheck=$(echo $blockOne | sed -E 's/.*(......)/\1/')
                                                                if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                then
                                                                    seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                    episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                fi
                                                            ;;
                                                            *)
                                                                echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                                            ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block One Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    if [[ "$blockTwo" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockTwoCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockTwo)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockTwo)
                                                                    seasonCheck=$(echo $blockTwo | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockTwo)
                                                                    seasonCheck=$(echo $blockTwo | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockTwo)
                                                                    seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockTwo)
                                                                    seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockTwo)
                                                                    seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockTwo | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Two Does NOT Contain Title Code" >> "$logfile"
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
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonCheck=$(echo $blockThree | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockThree)
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockThree | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Three Does NOT Contain Title Code" >> "$logfile"
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
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockFour)
                                                                    seasonCheck=$(echo $blockFour | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockFour)
                                                                    seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockFour)
                                                                    seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockFour)
                                                                    seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockFour | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Four Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    if [[ "$blockFive" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockFiveCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockFive)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockFive)
                                                                    seasonCheck=$(echo $blockFive | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockFive)
                                                                    seasonCheck=$(echo $blockFive | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockFive)
                                                                    seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockFive)
                                                                    seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockFive)
                                                                    seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockFive | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Five Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    if [[ "$blockSix" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockSixCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockSix)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockSix)
                                                                    seasonCheck=$(echo $blockSix | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockSix)
                                                                    seasonCheck=$(echo $blockSix | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockSix)
                                                                    seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockSix)
                                                                    seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockSix)
                                                                    seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockSix | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Six Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    if [[ "$blockSeven" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockSevenCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockSeven)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockSeven)
                                                                    seasonCheck=$(echo $blockSeven | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockSeven)
                                                                    seasonCheck=$(echo $blockSeven | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockSeven)
                                                                    seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockSeven)
                                                                    seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockSeven)
                                                                    seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockSeven | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Seven Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Seven Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    if [[ "$blockEight" =~ ^(M|S).*[0-9]$ ]];
                                                    then
                                                        case $blockEightCharCount in
                                                            "7")
                                                                    titleCode=$(echo $blockEight)
                                                                ;;
                                                                "9")
                                                                    titleCode=$(echo $blockEight)
                                                                    seasonCheck=$(echo $blockEight | sed -E 's/.*(..)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "10")
                                                                    titleCode=$(echo $blockEight)
                                                                    seasonCheck=$(echo $blockEight | sed -E 's/.*(...)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "11")
                                                                    titleCode=$(echo $blockEight)
                                                                    seasonEpisodeCheck=$(echo $blockEight | sed -E 's/.*(....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "12")
                                                                    titleCode=$(echo $blockEight)
                                                                    seasonEpisodeCheck=$(echo $blockEight | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "13")
                                                                    titleCode=$(echo $blockEight)
                                                                    seasonEpisodeCheck=$(echo $blockEight | sed -E 's/.*(......)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "2")
                                                                    seasonCheck=$(echo $blockEight | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonCheck" =~ ^S[0-9][0-9] || "$seasonCheck" =~ ^S[0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonCheck | awk -F "S" '{print $2}')
                                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                "6" | "5" | "4")
                                                                    seasonEpisodeCheck=$(echo $blockEight | sed -E 's/.*(.....)/\1/')
                                                                    if [[ "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9] || "$seasonEpisodeCheck" =~ ^S[0-9]E[0-9][0-9]  || "$seasonEpisodeCheck" =~ ^S[0-9][0-9]E[0-9][0-9] ]];
                                                                    then
                                                                        seasonNumberCheck=$(echo $seasonEpisodeCheck | awk -F "S" '{print $2}' | awk -F "E" '{print $1}')
                                                                        episodeNumberCheck=$(echo $seasonEpisodeCheck | awk -F "E" '{print $2}')
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonEpisodeCheck - $seasonEpisodeCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumberCheck - $seasonNumberCheck" >> "$logfile"
                                                                        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumberCheck - $episodeNumberCheck" >> "$logfile"
                                                                    fi
                                                                ;;
                                                                *)
                                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Eight Does NOT Contain Title Code" >> "$logfile"
                                                                ;;
                                                        esac
                                                    else
                                                        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Block Eight Does NOT Contain Title Code" >> "$logfile"
                                                    fi
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - titleCode - $titleCode" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                                    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                            fi
                                    fi
                            fi
                    fi
            fi
    fi
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - FINAL titleCode - $titleCode" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - FINAL seasonNumber - $seasonNumberCheck" >> "$logfile"
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - FINAL episodeNumber - $episodeNumberCheck" >> "$logfile"
    if [[ ! -z "$titleCode" ]];
    then
        export itemContentType=$(filterVidispineItemMetadata $itemId "metadata" "oly_contentType")
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - contentType - $itemContentType" >> "$logfile"
        if [[ "$itemContentType" == "episode" ]];
        then
            titleCode="$titleCode"S"$seasonNumberCheck"E"$episodeNumberCheck"
            echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - FINAL titleCode - $titleCode" >> "$logfile"
        fi
        export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"
        bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\"><field><name>oly_titleCode</name><value>$titleCode</value></field></timespan></MetadataDocument>")
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Body Data - $bodyData" >> "$logfile"
        curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData
        sleep 5
        bash -c "sudo /opt/olympusat/scriptsActive/importRightslineLegacyInfo-media_v5.1.sh $itemId $userName oly_titleCode /opt/olympusat/resources/rightslineData/RIGHTSLINE_CATALOG-ITEM_DATABASE_2024-10-08.csv > /dev/null 2>&1 &"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Metadata Update Completed" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Triggered Import Rightsline Legacy Info script" >> "$logfile"
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - No TitleCode Found in Title - skipping & exiting the Script/Workflow" >> "$logfile"
    fi
}
#--------------------------------------------------

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
export userName=$2
if [[ -z "$userName" ]];
then
    userName="admin"
fi

logfile="/opt/olympusat/logs/ingestMetadataWorkflow-$mydate.log"
# --------------------------------------------------
# Lock file to ensure only one job runs at a time
lockFile="/opt/olympusat/workflowQueues/ingestMetadataWorkflow/jobQueue.lock"
echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Job Initiated by [$userName]" >> "$logfile"
sleep 1
# Acquire the lock by waiting if another job is running
while [ -f "$lockFile" ];
do
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Waiting for the previous job to finish..." >> "$logfile"
    sleep 3
done
# Acquire the lock for this job
touch "$lockFile"
# Ensure that the lock is released when the job finishes
trap releaseLock EXIT
# --------------------------------------------------
export itemVersionType=$(filterVidispineItemMetadata $itemId "metadata" "oly_versionType")
if [[ "$itemVersionType" == "originalFile" ]];
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Gathering Information from [$itemVersionType]" >> "$logfile"
    getOriginalFileFlagsUrl="http://10.1.1.34:8080/API/item/$itemId/metadata?field=oly_originalFileFlags&terse=yes&includeConstraintValue=all"
    itemOriginalFileFlags=$(curl --location $getOriginalFileFlagsUrl --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=MUjgt5uKtW9KNzBvnj6GtAYhRGX8Q13etYkYdrVTXj9o7Jemi8yPYULPFwtfMO12')
    #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Original File Flags Info - [$itemOriginalFileFlags]" >> "$logfile"
    if [[ "$itemOriginalFileFlags" == *"originalrawmaster"* ]];
    then
        #echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Triggering Jump to processContent Internal Function" >> "$logfile"
        # Jump to content processing
        processContent
    else
        echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Original File Flag is NOT Supported - skipping & exiting the Script/Workflow" >> "$logfile"
    fi
elif [[ "$itemVersionType" == *"conformFile"* || "$itemVersionType" == *"censoredFile"* ]]
then
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Extracting Rightsline Item ID from Title" >> "$logfile"
else
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Version Type - {$itemVersionType}" >> "$logfile"
    echo "$(date +%Y/%m/%d_%H:%M:%S) - (ingestMetadataWorkflow) - [$itemId] - Version Type NOT Supported - skipping & exiting the Script/Workflow" >> "$logfile"
fi

IFS=$saveIFS