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

saveIFS=$IFS
IFS=$(echo -e "\n\b")

export mydate=$(date +%Y-%m-%d)
export datetime=$(date +%Y/%m/%d_%H:%M)

#Variables to be set by Metadata fields or information from Cantemo to be used in email body
export itemId=$1
export title=$(filterVidispineItemMetadata $itemId "metadata" "title")
export url="http://10.1.1.34:8080/API/item/$itemId/metadata/"

logfile="/opt/olympusat/logs/titleDeconstruct-$mydate.log"

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Deconstructing Title - $title" >> "$logfile"

if [[ "$title" == *_RAW ]];
then
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title ends with _RAW - {$title} - Removing _RAW" >> "$logfile"
    title=$(echo $title | sed 's/.\{4\}$//')
    echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - New Title - {$title}" >> "$logfile"
fi

numberOfUnderscores=$(echo $title | awk -F"_" '{print NF-1}')

echo $numberOfUnderscores
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Number of Underscores - $numberOfUnderscores" >> "$logfile"

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

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
        if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
        then
            case $blockOneCharCount in
                "7")
                    titleCode=$(echo $blockOne)
                ;;
                "9")
                    titleCode=$(echo $blockOne)
                ;;
                "10")
                    titleCode=$(echo $blockOne)
                ;;
                "11")
                    titleCode=$(echo $blockOne)
                ;;
                "12")
                    titleCode=$(echo $blockOne)
                ;;
                "13")
                    titleCode=$(echo $blockOne)
                ;;
                *)
                    titleByLanguage=$(echo $blockOne)
                ;;
            esac
        else
            titleByLanguage=$(echo $blockOne)
        fi

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
        if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
        then
            language=$(echo $blockTwo)
        else
            blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
            if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
            then
                imageType=$(echo $blockTwo)
            fi
        fi

        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

        if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
        then
            case $blockThreeCharCount in
                "7")
                    titleCode=$(echo $blockThree)
                ;;
                "9")
                    titleCode=$(echo $blockThree)
                ;;
                "10")
                    titleCode=$(echo $blockThree)
                ;;
                "11")
                    titleCode=$(echo $blockThree)
                ;;
                "12")
                    titleCode=$(echo $blockThree)
                ;;
                "13")
                    titleCode=$(echo $blockThree)
                ;;
                *)
                    imageMisc=$(echo $blockThree)
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
            if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
            then
                seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                imageDesc=$(echo $blockFour)
            else
                blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                then
                    imageType=$(echo $blockFour)
                else
                    if [[ "$blockFour" == *" "* ]];
                    then
                        imageDesc=$(echo $blockFour)
                    else
                        imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                    fi
                fi
            fi
        fi

        if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
        then
            imageSize=$(echo $blockFive)
        else
            if [[ "$blockFive" =~ ^(M|S).*[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
            then
                seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                imageDesc=$(echo $blockFive)
            else
                blockFive=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                if [[ ("$blockFive" == "cover") || ("$blockFive" == "feature") || ("$blockFive" == "keyart") || ("$blockFive" == *"still"*) || ("$blockFive" == "blank") ]];
                then
                    imageType=$(echo $blockFive)
                else
                    if [[ "$blockFive" == *" "* ]];
                    then
                        imageDesc=$(echo $blockFive)
                    else
                        imageDesc=$(echo $blockFive | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
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
        
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
        
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

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
                if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                then
                    case $blockOneCharCount in
                        "7")
                            titleCode=$(echo $blockOne)
                        ;;
                        "9")
                            titleCode=$(echo $blockOne)
                        ;;
                        "10")
                            titleCode=$(echo $blockOne)
                        ;;
                        "11")
                            titleCode=$(echo $blockOne)
                        ;;
                        "12")
                            titleCode=$(echo $blockOne)
                        ;;
                        "13")
                            titleCode=$(echo $blockOne)
                        ;;
                        *)
                            titleByLanguage=$(echo $blockOne)
                        ;;
                    esac
                else
                    titleByLanguage=$(echo $blockOne)
                fi

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
                if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                then
                    language=$(echo $blockTwo)
                else
                    blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                    if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
                    then
                        imageType=$(echo $blockTwo)
                    fi
                fi

                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

                if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                then
                    case $blockThreeCharCount in
                        "7")
                            titleCode=$(echo $blockThree)
                        ;;
                        "9")
                            titleCode=$(echo $blockThree)
                        ;;
                        "10")
                            titleCode=$(echo $blockThree)
                        ;;
                        "11")
                            titleCode=$(echo $blockThree)
                        ;;
                        "12")
                            titleCode=$(echo $blockThree)
                        ;;
                        "13")
                            titleCode=$(echo $blockThree)
                        ;;
                        *)
                            imageMisc=$(echo $blockThree)
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
                    if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                    then
                        seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                        episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                        imageDesc=$(echo $blockFour)
                    else
                        blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                        if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                        then
                            imageType=$(echo $blockFour)
                        else
                            if [[ "$blockFour" == *" "* ]];
                            then
                                imageDesc=$(echo $blockFour)
                            else
                                imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
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
                
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
                
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

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                            else
                                titleCode=$(echo $title | awk -F "_" '{print $1}')
                                imageType=$(echo $title | awk -F "_" '{print $2}')
                                titleByLanguage=$(echo $title | awk -F "_" '{print $3}')
                                titleByLanguage=$(echo $titleByLanguage | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
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

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
                                if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                then
                                    case $blockOneCharCount in
                                        "7")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        "9")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        "10")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        "11")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        "12")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        "13")
                                            titleCode=$(echo $blockOne)
                                        ;;
                                        *)
                                            titleByLanguage=$(echo $blockOne)
                                        ;;
                                    esac
                                else
                                    titleByLanguage=$(echo $blockOne)
                                fi

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
                                if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                then
                                    language=$(echo $blockTwo)
                                else
                                    blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                    if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
                                    then
                                        imageType=$(echo $blockTwo)
                                    fi
                                fi

                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

                                if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                then
                                    case $blockThreeCharCount in
                                        "7")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        "9")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        "10")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        "11")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        "12")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        "13")
                                            titleCode=$(echo $blockThree)
                                        ;;
                                        *)
                                            imageMisc=$(echo $blockThree)
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
                                    if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                    then
                                        seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                        episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                        imageDesc=$(echo $blockFour)
                                    else
                                        blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                                        then
                                            imageType=$(echo $blockFour)
                                        else
                                            if [[ "$blockFour" == *" "* ]];
                                            then
                                                imageDesc=$(echo $blockFour)
                                            else
                                                imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                            fi
                                        fi
                                    fi
                                fi

                                if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                then
                                    imageSize=$(echo $blockFive)
                                else
                                    if [[ "$blockFive" =~ ^(M|S).*[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                    then
                                        seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                        episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                        imageDesc=$(echo $blockFive)
                                    else
                                        blockFive=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockFive" == "cover") || ("$blockFive" == "feature") || ("$blockFive" == "keyart") || ("$blockFive" == *"still"*) || ("$blockFive" == "blank") ]];
                                        then
                                            imageType=$(echo $blockFive)
                                        else
                                            if [[ "$blockFive" == *" "* ]];
                                            then
                                                imageDesc=$(echo $blockFive)
                                            else
                                                imageDesc=$(echo $blockFive | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                            fi
                                        fi
                                    fi
                                fi

                                if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                then
                                    imageSize=$(echo $blockSix)
                                else
                                    if [[ "$blockSix" =~ ^(M|S).*[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                    then
                                        seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                        episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                        imageDesc=$(echo $blockSix)
                                    else
                                        blockSix=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                        if [[ ("$blockSix" == "cover") || ("$blockSix" == "feature") || ("$blockSix" == "keyart") || ("$blockSix" == *"still"*) || ("$blockSix" == "blank") ]];
                                        then
                                            imageType=$(echo $blockSix)
                                        else
                                            if [[ "$blockSix" == *" "* ]];
                                            then
                                                imageDesc=$(echo $blockSix)
                                            else
                                                imageDesc=$(echo $blockSix | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
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
                                
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
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

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
                                        if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                        then
                                            case $blockOneCharCount in
                                                "7")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                "9")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                "10")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                "11")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                "12")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                "13")
                                                    titleCode=$(echo $blockOne)
                                                ;;
                                                *)
                                                    titleByLanguage=$(echo $blockOne)
                                                ;;
                                            esac
                                        else
                                            titleByLanguage=$(echo $blockOne)
                                        fi

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
                                        if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                        then
                                            language=$(echo $blockTwo)
                                        else
                                            blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                            if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
                                            then
                                                imageType=$(echo $blockTwo)
                                            fi
                                        fi

                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

                                        if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                        then
                                            case $blockThreeCharCount in
                                                "7")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                "9")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                "10")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                "11")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                "12")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                "13")
                                                    titleCode=$(echo $blockThree)
                                                ;;
                                                *)
                                                    imageMisc=$(echo $blockThree)
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
                                            if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                            then
                                                seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                imageDesc=$(echo $blockFour)
                                            else
                                                blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                                                then
                                                    imageType=$(echo $blockFour)
                                                else
                                                    if [[ "$blockFour" == *" "* ]];
                                                    then
                                                        imageDesc=$(echo $blockFour)
                                                    else
                                                        imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                    fi
                                                fi
                                            fi
                                        fi

                                        if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                        then
                                            imageSize=$(echo $blockFive)
                                        else
                                            if [[ "$blockFive" =~ ^(M|S).*[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                            then
                                                seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                imageDesc=$(echo $blockFive)
                                            else
                                                blockFive=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockFive" == "cover") || ("$blockFive" == "feature") || ("$blockFive" == "keyart") || ("$blockFive" == *"still"*) || ("$blockFive" == "blank") ]];
                                                then
                                                    imageType=$(echo $blockFive)
                                                else
                                                    if [[ "$blockFive" == *" "* ]];
                                                    then
                                                        imageDesc=$(echo $blockFive)
                                                    else
                                                        imageDesc=$(echo $blockFive | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                    fi
                                                fi
                                            fi
                                        fi

                                        if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                        then
                                            imageSize=$(echo $blockSix)
                                        else
                                            if [[ "$blockSix" =~ ^(M|S).*[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                            then
                                                seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                imageDesc=$(echo $blockSix)
                                            else
                                                blockSix=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockSix" == "cover") || ("$blockSix" == "feature") || ("$blockSix" == "keyart") || ("$blockSix" == *"still"*) || ("$blockSix" == "blank") ]];
                                                then
                                                    imageType=$(echo $blockSix)
                                                else
                                                    if [[ "$blockSix" == *" "* ]];
                                                    then
                                                        imageDesc=$(echo $blockSix)
                                                    else
                                                        imageDesc=$(echo $blockSix | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                    fi
                                                fi
                                            fi
                                        fi

                                        if [[ "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                        then
                                            imageSize=$(echo $blockSeven)
                                        else
                                            if [[ "$blockSeven" =~ ^(M|S).*[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockSeven" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                            then
                                                seasonNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                episodeNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                imageDesc=$(echo $blockSeven)
                                            else
                                                blockSeven=$(echo $blockSeven | tr '[:upper:]' '[:lower:]')
                                                if [[ ("$blockSeven" == "cover") || ("$blockSeven" == "feature") || ("$blockSeven" == "keyart") || ("$blockSeven" == *"still"*) || ("$blockSeven" == "blank") ]];
                                                then
                                                    imageType=$(echo $blockSeven)
                                                else
                                                    if [[ "$blockSeven" == *" "* ]];
                                                    then
                                                        imageDesc=$(echo $blockSeven)
                                                    else
                                                        imageDesc=$(echo $blockSeven | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
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
                                        
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                        echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
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

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block One for Info - {$blockOne} - {$blockOneCharCount}" >> "$logfile"
                                                if [[ "$blockOne" =~ ^(M|S).*[0-9]$ ]];
                                                then
                                                    case $blockOneCharCount in
                                                        "7")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        "9")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        "10")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        "11")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        "12")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        "13")
                                                            titleCode=$(echo $blockOne)
                                                        ;;
                                                        *)
                                                            titleByLanguage=$(echo $blockOne)
                                                        ;;
                                                    esac
                                                else
                                                    titleByLanguage=$(echo $blockOne)
                                                fi

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title Code - {$titleCode}" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Title By Language - {$titleByLanguage}" >> "$logfile"

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Check Block Two for Info - {$blockTwo} - {$blockTwoCharCount}" >> "$logfile"
                                                if [[ ("$blockTwo" == "EN") || ("$blockTwo" == "ES") || ("$blockTwo" == "FR") || ("$blockTwo" == "OG") ]];
                                                then
                                                    language=$(echo $blockTwo)
                                                else
                                                    blockTwo=$(echo $blockTwo | tr '[:upper:]' '[:lower:]')
                                                    if [[ ("$blockTwo" == "cover") || ("$blockTwo" == "feature") || ("$blockTwo" == "keyart") || ("$blockTwo" == "still") || ("$blockTwo" == "blank") ]];
                                                    then
                                                        imageType=$(echo $blockTwo)
                                                    fi
                                                fi

                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Language - {$language}" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Image Type - {$imageType}" >> "$logfile"

                                                if [[ "$blockThree" =~ ^(M|S).*[0-9]$ ]];
                                                then
                                                    case $blockThreeCharCount in
                                                        "7")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        "9")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        "10")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        "11")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        "12")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        "13")
                                                            titleCode=$(echo $blockThree)
                                                        ;;
                                                        *)
                                                            imageMisc=$(echo $blockThree)
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
                                                    if [[ "$blockFour" =~ ^(M|S).*[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFour" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                                    then
                                                        seasonNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $blockFour | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        imageDesc=$(echo $blockFour)
                                                    else
                                                        blockFour=$(echo $blockFour | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockFour" == "cover") || ("$blockFour" == "feature") || ("$blockFour" == "keyart") || ("$blockFour" == *"still"*) || ("$blockFour" == "blank") ]];
                                                        then
                                                            imageType=$(echo $blockFour)
                                                        else
                                                            if [[ "$blockFour" == *" "* ]];
                                                            then
                                                                imageDesc=$(echo $blockFour)
                                                            else
                                                                imageDesc=$(echo $blockFour | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                            fi
                                                        fi
                                                    fi
                                                fi

                                                if [[ "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockFive" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                then
                                                    imageSize=$(echo $blockFive)
                                                else
                                                    if [[ "$blockFive" =~ ^(M|S).*[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockFive" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                                    then
                                                        seasonNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $blockFive | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        imageDesc=$(echo $blockFive)
                                                    else
                                                        blockFive=$(echo $blockFive | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockFive" == "cover") || ("$blockFive" == "feature") || ("$blockFive" == "keyart") || ("$blockFive" == *"still"*) || ("$blockFive" == "blank") ]];
                                                        then
                                                            imageType=$(echo $blockFive)
                                                        else
                                                            if [[ "$blockFive" == *" "* ]];
                                                            then
                                                                imageDesc=$(echo $blockFive)
                                                            else
                                                                imageDesc=$(echo $blockFive | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                            fi
                                                        fi
                                                    fi
                                                fi

                                                if [[ "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSix" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                then
                                                    imageSize=$(echo $blockSix)
                                                else
                                                    if [[ "$blockSix" =~ ^(M|S).*[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockSix" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                                    then
                                                        seasonNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $blockSix | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        imageDesc=$(echo $blockSix)
                                                    else
                                                        blockSix=$(echo $blockSix | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockSix" == "cover") || ("$blockSix" == "feature") || ("$blockSix" == "keyart") || ("$blockSix" == *"still"*) || ("$blockSix" == "blank") ]];
                                                        then
                                                            imageType=$(echo $blockSix)
                                                        else
                                                            if [[ "$blockSix" == *" "* ]];
                                                            then
                                                                imageDesc=$(echo $blockSix)
                                                            else
                                                                imageDesc=$(echo $blockSix | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                            fi
                                                        fi
                                                    fi
                                                fi

                                                if [[ "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockSeven" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                then
                                                    imageSize=$(echo $blockSeven)
                                                else
                                                    if [[ "$blockSeven" =~ ^(M|S).*[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockSeven" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockSeven" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                                    then
                                                        seasonNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $blockSeven | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        imageDesc=$(echo $blockSeven)
                                                    else
                                                        blockSeven=$(echo $blockSeven | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockSeven" == "cover") || ("$blockSeven" == "feature") || ("$blockSeven" == "keyart") || ("$blockSeven" == *"still"*) || ("$blockSeven" == "blank") ]];
                                                        then
                                                            imageType=$(echo $blockSeven)
                                                        else
                                                            if [[ "$blockSeven" == *" "* ]];
                                                            then
                                                                imageDesc=$(echo $blockSeven)
                                                            else
                                                                imageDesc=$(echo $blockSeven | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
                                                            fi
                                                        fi
                                                    fi
                                                fi

                                                if [[ "$blockEight" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9][0-9]x[0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9][0-9] || "$blockEight" =~ ^[0-9][0-9][0-9]x[0-9][0-9][0-9] ]];
                                                then
                                                    imageSize=$(echo $blockEight)
                                                else
                                                    if [[ "$blockEight" =~ ^(M|S).*[0-9]$ || "$blockEight" =~ ^(M|S)[0-9].*E[0-9]$ || "$blockEight" =~ ^(M|S)[0-9].*E[0-9][0-9]$ || "$blockEight" =~ ^(M|S)[0-9][0-9].*E[0-9]$ || "$blockEight" =~ ^(M|S)[0-9][0-9].*E[0-9][0-9]$ ]];
                                                    then
                                                        seasonNumberCheck=$(echo $blockEight | awk 'BEGIN { FPAT = "[0-9]+" } {print $1}')
                                                        episodeNumberCheck=$(echo $blockEight | awk 'BEGIN { FPAT = "[0-9]+" } {print $2}')
                                                        imageDesc=$(echo $blockEight)
                                                    else
                                                        blockEight=$(echo $blockEight | tr '[:upper:]' '[:lower:]')
                                                        if [[ ("$blockEight" == "cover") || ("$blockEight" == "feature") || ("$blockEight" == "keyart") || ("$blockEight" == *"still"*) || ("$blockEight" == "blank") ]];
                                                        then
                                                            imageType=$(echo $blockEight)
                                                        else
                                                            if [[ "$blockEight" == *" "* ]];
                                                            then
                                                                imageDesc=$(echo $blockEight)
                                                            else
                                                                imageDesc=$(echo $blockEight | sed -r -e "s/([^A-Z])([A-Z])/\1 \2/g" -e "s/([A-Z]+)([A-Z])/\1 \2/g")
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
                                                
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - +++++++++++++++++++++++++++++++++" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleCode - $titleCode" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageType - $imageType" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - titleByLanguage - $titleByLanguage" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - language - $language" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageSize - $imageSize" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageDesc - $imageDesc" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - imageMisc - $imageMisc" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - seasonNumber - $seasonNumberCheck" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - episodeNumber - $episodeNumberCheck" >> "$logfile"
                                                echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - graphicsTags - $graphicsTags" >> "$logfile"
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
        fieldName="oly_titleEs"
    else
        fieldName="oly_titleEn"
    fi
else
    fieldName="oly_seriesName"
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

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Type - $graphicsType" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Resolution - $graphicsResolution" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Language - $graphicsLanguage" >> "$logfile"
echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Graphics Tags - $graphicsTags" >> "$logfile"

#bodyData=$(echo "<MetadataDocument xmlns=\"http://xml.vidispine.com/schema/vidispine\"><timespan start=\"-INF\" end=\"+INF\">$graphicsTags<field><name>oly_titleCode</name><value>$titleCode</value></field><field><name>oly_primaryMetadataLanguage</name><value>$graphicsLanguage</value></field><field><name>oly_graphicsLanguage</name><value>$graphicsLanguage</value></field><field><name>oly_graphicsResolution</name><value>$graphicsResolution</value></field><field><name>$fieldName</name><value>$titleByLanguage</value></field><field><name>oly_graphicsType</name><value>$graphicsType</value></field></timespan></MetadataDocument>")

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Body Data - $bodyData" >> "$logfile"

#curl -s -o /dev/null --location --request PUT $url --header 'Content-Type: application/xml' --header 'Authorization: Basic YWRtaW46MTBsbXBAc0B0' --header 'Cookie: csrftoken=xZqBrKBPBOUANsWFnMC3aF90S52Ip3tgXdUHwWZvhNnu9aLl9j4rdrxRhV9nSQx9' --data $bodyData

sleep 5

echo "$(date +%Y/%m/%d_%H:%M) - ($itemId) - Metadata Update Completed" >> "$logfile"

IFS=$saveIFS